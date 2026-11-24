import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';
import '../theme/app_theme.dart';

/// Widget Banner Ad adaptif yang tampil rapi di atas BottomNavigationBar
/// dan otomatis tersembunyi jika mode Bebas Iklan sedang aktif atau offline.
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoaded && !_isLoading && AdService().isSupportedPlatform) {
      _loadBanner();
    }
  }

  Future<void> _loadBanner() async {
    _isLoading = true;
    final width = MediaQuery.of(context).size.width.truncate();
    final AdSize? adaptiveSize =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
    final adSize = adaptiveSize ?? AdSize.banner;

    final banner = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
            _isLoading = false;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: ${error.message}');
          ad.dispose();
          if (mounted) {
            setState(() {
              _isLoaded = false;
              _isLoading = false;
            });
          }
        },
      ),
    );

    await banner.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AdService().isSupportedPlatform) {
      return const SizedBox.shrink();
    }

    return ValueListenableBuilder<bool>(
      valueListenable: AdService().isAdFreeNotifier,
      builder: (context, isAdFree, child) {
        if (isAdFree || !_isLoaded || _bannerAd == null) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: AppTheme.cardBorder, width: 1),
            ),
          ),
          alignment: Alignment.center,
          child: SizedBox(
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          ),
        );
      },
    );
  }
}
