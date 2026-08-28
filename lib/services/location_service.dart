import 'package:geolocator/geolocator.dart';

class LocationService {
  // Fungsi untuk mengecek izin dan mengambil koordinat GPS saat ini
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

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // >>> TAMBAHKAN METHOD INI UNTUK MENGATASI ERROR <<<
  // Fungsi helper untuk menghitung jarak dalam bentuk angka (double dalam meter)
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
          .infinity; // Beri nilai maksimum jika koordinat tidak lengkap
    }

    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  // Fungsi helper untuk menghitung jarak dan otomatis memformat ke Meter atau Kilometer (untuk ditampilkan di UI)
  String calculateDistanceString(
    Position? currentPosition,
    double? targetLat,
    double? targetLng,
  ) {
    if (currentPosition == null || targetLat == null || targetLng == null)
      return '-';

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