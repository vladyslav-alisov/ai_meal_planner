import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

abstract class AdsService {
  Future<void> initialize();
  Future<void> maybeShowMealPlanInterstitial();
  String get bannerAdUnitId;
  bool get hasBannerAdUnit;
}

class GoogleMobileAdsService implements AdsService {
  GoogleMobileAdsService({required String bannerAdUnitId, required String interstitialAdUnitId})
    : _bannerAdUnitId = bannerAdUnitId.trim(),
      _interstitialAdUnitId = interstitialAdUnitId.trim();

  final String _bannerAdUnitId;
  final String _interstitialAdUnitId;

  bool _isInitialized = false;
  bool _isShowingInterstitial = false;
  int _mealPlanGenerationCount = 0;
  InterstitialAd? _interstitialAd;

  @override
  String get bannerAdUnitId => _bannerAdUnitId;

  @override
  bool get hasBannerAdUnit => _bannerAdUnitId.isNotEmpty;

  bool get _hasInterstitialAdUnit => _interstitialAdUnitId.isNotEmpty;

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    await MobileAds.instance.initialize();
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: ["dd01560772086945b0551c65cb77263a"]),
    );
    _isInitialized = true;
    _loadInterstitial();
  }

  @override
  Future<void> maybeShowMealPlanInterstitial() async {
    if (!_isInitialized) {
      await initialize();
    }

    _mealPlanGenerationCount++;

    // Show every second successful meal plan generation to keep the flow usable.
    final shouldShow = _mealPlanGenerationCount.isEven;
    final interstitialAd = _interstitialAd;

    if (!shouldShow || _isShowingInterstitial || interstitialAd == null) {
      if (interstitialAd == null) {
        _loadInterstitial();
      }
      return;
    }

    _isShowingInterstitial = true;
    interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _isShowingInterstitial = false;
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingInterstitial = false;
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitial();
      },
    );

    await interstitialAd.show();
  }

  void _loadInterstitial() {
    if (!_hasInterstitialAdUnit || _interstitialAd != null) {
      return;
    }

    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
        },
      ),
    );
  }
}

final adsServiceProvider = Provider<AdsService>((ref) {
  return GoogleMobileAdsService(
    bannerAdUnitId: dotenv.env['ADMOB_BANNER_AD_UNIT_ID'] ?? '',
    interstitialAdUnitId: dotenv.env['ADMOB_INTERSTITIAL_AD_UNIT_ID'] ?? '',
  );
});
