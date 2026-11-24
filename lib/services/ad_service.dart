import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service terpusat untuk mengelola semua iklan Google AdMob Android:
/// 1. Banner Ad
/// 2. Interstitial Ad
/// 3. Rewarded Ad
/// 4. Native Ad
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // =========================================================================
  // KONFIGURASI AD UNIT ID
  // Otomatis memakai Ad Unit Test resmi Google pada mode Debug / Profile,
  // dan memakai Ad Unit Produksi asli pada mode Release (`kReleaseMode`).
  // =========================================================================
  static bool get useTestAds => !kReleaseMode;

  // Official Google AdMob Android Test Ad Unit IDs (dipakai saat debug)
  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedId = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testNativeId = 'ca-app-pub-3940256099942544/2247696110';

  // Production AdMob Android Ad Unit IDs (Teman Nikah - ca-app-pub-9171274707010006~1207228628)
  static const String _prodBannerId = 'ca-app-pub-9171274707010006/9029878322';
  static const String _prodInterstitialId = 'ca-app-pub-9171274707010006/7389493595';
  static const String _prodRewardedId = 'ca-app-pub-9171274707010006/3450248585';
  static const String _prodNativeId = 'ca-app-pub-9171274707010006/9824085246';

  static String get bannerAdUnitId =>
      useTestAds ? _testBannerId : _prodBannerId;

  static String get interstitialAdUnitId =>
      useTestAds ? _testInterstitialId : _prodInterstitialId;

  static String get rewardedAdUnitId =>
      useTestAds ? _testRewardedId : _prodRewardedId;

  static String get nativeAdUnitId =>
      useTestAds ? _testNativeId : _prodNativeId;

  // =========================================================================
  // STATE & NOTIFIERS
  // =========================================================================
  bool _initialized = false;
  InterstitialAd? _interstitialAd;
  bool _isLoadingInterstitial = false;
  DateTime? _lastInterstitialShownAt;
  int _tabSwitchCounter = 0;

  RewardedAd? _rewardedAd;
  bool _isLoadingRewarded = false;

  /// Mode bebas iklan sementara (hadiah dari menonton Rewarded Ad)
  final ValueNotifier<bool> isAdFreeNotifier = ValueNotifier<bool>(false);
  DateTime? _adFreeUntil;

  static const String _adFreePrefKey = 'nikah_ad_free_until';
  static const Duration _interstitialCooldown = Duration(seconds: 60);
  static const int _tabSwitchesBeforeInterstitial = 4;

  bool get isSupportedPlatform => !kIsWeb && Platform.isAndroid;
  bool get isInterstitialReady => _interstitialAd != null;
  bool get isRewardedReady => _rewardedAd != null;
  bool get isAdFree {
    if (_adFreeUntil == null) return false;
    final active = DateTime.now().isBefore(_adFreeUntil!);
    if (!active && isAdFreeNotifier.value) {
      isAdFreeNotifier.value = false;
    }
    return active;
  }

  int get remainingAdFreeMinutes {
    if (!isAdFree || _adFreeUntil == null) return 0;
    final diff = _adFreeUntil!.difference(DateTime.now());
    return diff.inMinutes + (diff.inSeconds % 60 > 0 ? 1 : 0);
  }

  /// Inisialisasi Google Mobile Ads SDK & preload Interstitial + Rewarded
  Future<void> initialize() async {
    if (_initialized || !isSupportedPlatform) return;

    try {
      await MobileAds.instance.initialize();
      await _loadAdFreeStatus();
      _initialized = true;

      // Preload iklan layar penuh agar siap ditampilkan tanpa jeda
      loadInterstitialAd();
      loadRewardedAd();
    } catch (e) {
      debugPrint('AdMob initialization error: $e');
    }
  }

  Future<void> _loadAdFreeStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final millis = prefs.getInt(_adFreePrefKey);
      if (millis != null) {
        final until = DateTime.fromMillisecondsSinceEpoch(millis);
        if (DateTime.now().isBefore(until)) {
          _adFreeUntil = until;
          isAdFreeNotifier.value = true;
        } else {
          await prefs.remove(_adFreePrefKey);
          isAdFreeNotifier.value = false;
        }
      }
    } catch (e) {
      debugPrint('Error loading ad-free status: $e');
    }
  }

  Future<void> _grantAdFreeReward({Duration duration = const Duration(minutes: 30)}) async {
    _adFreeUntil = DateTime.now().add(duration);
    isAdFreeNotifier.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_adFreePrefKey, _adFreeUntil!.millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Error saving ad-free status: $e');
    }
  }

  Future<void> clearAdFreeForTesting() async {
    _adFreeUntil = null;
    isAdFreeNotifier.value = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_adFreePrefKey);
    } catch (_) {}
  }

  // =========================================================================
  // INTERSTITIAL AD
  // =========================================================================
  void loadInterstitialAd() {
    if (!isSupportedPlatform || _isLoadingInterstitial || _interstitialAd != null) return;
    _isLoadingInterstitial = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoadingInterstitial = false;
          _interstitialAd = ad;
          debugPrint('InterstitialAd loaded.');
        },
        onAdFailedToLoad: (error) {
          _isLoadingInterstitial = false;
          _interstitialAd = null;
          debugPrint('InterstitialAd failed to load: ${error.message}');
        },
      ),
    );
  }

  /// Panggil saat user berpindah tab — menampilkan Interstitial secara berkala
  /// dengan jeda cooldown agar tidak mengganggu kenyamanan pengguna.
  void onTabSwitched() {
    if (!isSupportedPlatform || isAdFree) return;
    _tabSwitchCounter++;
    if (_tabSwitchCounter >= _tabSwitchesBeforeInterstitial) {
      final canShowByCooldown = _lastInterstitialShownAt == null ||
          DateTime.now().difference(_lastInterstitialShownAt!) >= _interstitialCooldown;
      if (canShowByCooldown && _interstitialAd != null) {
        _tabSwitchCounter = 0;
        showInterstitialAd();
      }
    }
  }

  /// Tampilkan Interstitial Ad (set [force] = true untuk melewati cooldown/mode ad-free saat testing)
  Future<bool> showInterstitialAd({
    bool force = false,
    VoidCallback? onAdClosed,
  }) async {
    if (!isSupportedPlatform) {
      onAdClosed?.call();
      return false;
    }
    if (!force && isAdFree) {
      onAdClosed?.call();
      return false;
    }

    final ad = _interstitialAd;
    if (ad == null) {
      loadInterstitialAd();
      onAdClosed?.call();
      return false;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        _lastInterstitialShownAt = DateTime.now();
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
        onAdClosed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('InterstitialAd failed to show: ${error.message}');
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
        onAdClosed?.call();
      },
    );

    _interstitialAd = null;
    await ad.show();
    return true;
  }

  // =========================================================================
  // REWARDED AD
  // =========================================================================
  void loadRewardedAd() {
    if (!isSupportedPlatform || _isLoadingRewarded || _rewardedAd != null) return;
    _isLoadingRewarded = true;

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoadingRewarded = false;
          _rewardedAd = ad;
          debugPrint('RewardedAd loaded.');
        },
        onAdFailedToLoad: (error) {
          _isLoadingRewarded = false;
          _rewardedAd = null;
          debugPrint('RewardedAd failed to load: ${error.message}');
        },
      ),
    );
  }

  /// Tampilkan Rewarded Ad; jika user selesai menonton, otomatis aktifkan
  /// Bebas Iklan 30 Menit dan panggil [onRewardEarned].
  Future<bool> showRewardedAd({
    required void Function(RewardItem reward) onRewardEarned,
    VoidCallback? onAdNotReady,
    VoidCallback? onAdClosed,
  }) async {
    if (!isSupportedPlatform) {
      onAdNotReady?.call();
      return false;
    }

    final ad = _rewardedAd;
    if (ad == null) {
      loadRewardedAd();
      onAdNotReady?.call();
      return false;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        onAdClosed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('RewardedAd failed to show: ${error.message}');
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        onAdClosed?.call();
      },
    );

    _rewardedAd = null;
    await ad.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) async {
        await _grantAdFreeReward(duration: const Duration(minutes: 30));
        onRewardEarned(reward);
      },
    );
    return true;
  }

  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _interstitialAd = null;
    _rewardedAd = null;
  }
}
