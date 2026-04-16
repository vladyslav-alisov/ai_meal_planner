import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../ads_service.dart';

class AdaptiveBannerAdSection extends ConsumerStatefulWidget {
  const AdaptiveBannerAdSection({
    super.key,
    this.horizontalPadding = 20,
    this.topPadding = 0,
    this.bottomPadding = 0,
  });

  final double horizontalPadding;
  final double topPadding;
  final double bottomPadding;

  @override
  ConsumerState<AdaptiveBannerAdSection> createState() =>
      _AdaptiveBannerAdSectionState();
}

class _AdaptiveBannerAdSectionState
    extends ConsumerState<AdaptiveBannerAdSection> {
  BannerAd? _bannerAd;
  AnchoredAdaptiveBannerAdSize? _adSize;
  bool _isLoaded = false;
  int? _lastWidth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadBannerIfNeeded();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _loadBannerIfNeeded() async {
    final adsService = ref.read(adsServiceProvider);
    if (!adsService.hasBannerAdUnit) {
      return;
    }

    final width = math.max(
      1,
      (MediaQuery.sizeOf(context).width - (widget.horizontalPadding * 2))
          .round(),
    );

    if (_lastWidth == width && _bannerAd != null) {
      return;
    }

    _lastWidth = width;
    _isLoaded = false;
    await _bannerAd?.dispose();
    _bannerAd = null;

    final adSize = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);

    if (!mounted || adSize == null) {
      return;
    }

    final bannerAd = BannerAd(
      adUnitId: adsService.bannerAdUnitId,
      request: const AdRequest(),
      size: adSize,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }

          setState(() {
            _bannerAd = ad as BannerAd;
            _adSize = adSize;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) {
            return;
          }
          setState(() {
            _bannerAd = null;
            _adSize = null;
            _isLoaded = false;
          });
        },
      ),
    );

    await bannerAd.load();
  }

  @override
  Widget build(BuildContext context) {
    final bannerAd = _bannerAd;
    final adSize = _adSize;
    if (!_isLoaded || bannerAd == null || adSize == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        widget.horizontalPadding,
        widget.topPadding,
        widget.horizontalPadding,
        widget.bottomPadding,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        child: SizedBox(
          width: bannerAd.size.width.toDouble(),
          height: adSize.height.toDouble(),
          child: AdWidget(ad: bannerAd),
        ),
      ),
    );
  }
}
