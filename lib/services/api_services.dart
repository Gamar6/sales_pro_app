import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/store_model.dart';

class ApiService {
  // Ganti IP sesuai server Laravel Anda
  static const String baseUrl = 'http://192.168.53.175:8000/api';

  static Future<Map<String, dynamic>> fetchStores() async {
    double latitude = -6.200000;
    double longitude = 106.816666;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.deniedForever) {
          // Pakai default
        } else {
          Position position = await Geolocator.getCurrentPosition();
          latitude = position.latitude;
          longitude = position.longitude;
        }
      }
    } catch (e) {
      print('GPS Error: $e');
    }

    try {
      final url = Uri.parse(
        '$baseUrl/nearby-stores?latitude=$latitude&longitude=$longitude',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          List<dynamic> rawData = data['data'];
          List<Store> stores = rawData
              .map((json) => Store.fromJson(json))
              .toList();
          return {'success': true, 'data': stores};
        }
      }
      return {'success': false, 'data': <Store>[]};
    } catch (e) {
      print('API Error: $e');
      return {'success': false, 'data': <Store>[]};
    }
  }
}
