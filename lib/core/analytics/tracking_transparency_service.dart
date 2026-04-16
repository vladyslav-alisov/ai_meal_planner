import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class TrackingTransparencyService {
  Future<TrackingStatus> getStatus();
  Future<TrackingStatus> requestPermissionIfNeeded();
}

class NativeTrackingTransparencyService implements TrackingTransparencyService {
  @override
  Future<TrackingStatus> getStatus() async {
    try {
      return await AppTrackingTransparency.trackingAuthorizationStatus;
    } catch (_) {
      return TrackingStatus.notSupported;
    }
  }

  @override
  Future<TrackingStatus> requestPermissionIfNeeded() async {
    final currentStatus = await getStatus();
    if (currentStatus != TrackingStatus.notDetermined) {
      return currentStatus;
    }

    try {
      return await AppTrackingTransparency.requestTrackingAuthorization();
    } catch (_) {
      return currentStatus;
    }
  }
}

final trackingTransparencyServiceProvider =
    Provider<TrackingTransparencyService>((ref) {
      return NativeTrackingTransparencyService();
    });
