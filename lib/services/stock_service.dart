import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_config.dart';

class StockService {
  static Future<Map<String, dynamic>> fetchStocks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        return {
          'success': false,
          'message': 'Sesi login telah berakhir. Silakan login kembali.',
        };
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/stocks'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization':
              'Bearer $token', // Menyelipkan token ke Laravel Sanctum
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return {
          'success': true,
          'total_skus': body['total_skus'] ?? 0,
          'low_stock_count': body['low_stock_count'] ?? 0,
          'data': body['data'] ?? [],
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Akses ditolak (401). Silakan login ulang.',
        };
      } else {
        return {
          'success': false,
          'message':
              'Gagal mengambil data stok (Status: ${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server backend.',
      };
    }
  }
}
