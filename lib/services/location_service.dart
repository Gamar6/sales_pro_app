import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  double calculateDistance(
    double? startLat,
    double? startLng,
    double? endLat,
    double? endLng,
  ) {
    if (startLat == null ||
        startLng == null ||
        endLat == null ||
        endLng == null) {
      return double
          .infinity; 
    }

    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  String calculateDistanceString(
    Position? currentPosition,
    double? targetLat,
    double? targetLng,
  ) {
    if (currentPosition == null || targetLat == null || targetLng == null) {
      return '-';
    }

    double distanceInMeters = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      targetLat,
      targetLng,
    );

    if (distanceInMeters >= 1000) {
      double distanceInKm = distanceInMeters / 1000;
      return '${distanceInKm.toStringAsFixed(1)} km';
    } else {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    }
  }
}
