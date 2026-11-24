import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';
import '../theme/app_theme.dart';

/// Widget Native Ad bertema elegan yang menyatu dengan kartu UI Teman Nikah.
/// Menggunakan NativeTemplateStyle bawaan Google Mobile Ads SDK.
class AdNativeWidget extends StatefulWidget {
  final Color accentColor;
  final TemplateType templateType;

  const AdNativeWidget({
    super.key,
    this.accentColor = AppTheme.primaryRose,
    this.templateType = TemplateType.medium,
  });

  @override
  State<AdNativeWidget> createState() => _AdNativeWidgetState();
}

class _AdNativeWidgetState extends State<AdNativeWidget> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    if (AdService().isSupportedPlatform) {
      _loadNativeAd();
    }
  }

  void _loadNativeAd() {
    final nativeAd = NativeAd(
      adUnitId: AdService.nativeAdUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _nativeAd = ad as NativeAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('NativeAd failed to load: ${error.message}');
          ad.dispose();
          if (mounted) {
            setState(() {
              _isLoaded = false;
            });
          }
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: widget.templateType,
        mainBackgroundColor: Colors.white,
        cornerRadius: 16.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: widget.accentColor,
          style: NativeTemplateFontStyle.bold,
          size: 14.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: AppTheme.textDark,
          backgroundColor: Colors.white,
          style: NativeTemplateFontStyle.bold,
          size: 15.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: AppTheme.textMuted,
          backgroundColor: Colors.white,
          style: NativeTemplateFontStyle.normal,
          size: 13.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: AppTheme.textLight,
          backgroundColor: Colors.white,
          style: NativeTemplateFontStyle.normal,
          size: 12.0,
        ),
      ),
    );

    nativeAd.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
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
        if (isAdFree || !_isLoaded || _nativeAd == null) {
          return const SizedBox.shrink();
        }

        final double adHeight =
            widget.templateType == TemplateType.small ? 115 : 345;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: adHeight,
            width: double.infinity,
            child: AdWidget(ad: _nativeAd!),
          ),
        );
      },
    );
  }
}
