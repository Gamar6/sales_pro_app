import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_config.dart';

class StockService {
  static const String _cacheKey = 'stock_cache';

  static Future<Map<String, dynamic>?> getCachedStocks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null || raw.isEmpty) return null;

      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;

      return decoded;
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveCachedStocks(Map<String, dynamic> payload) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(payload));
    } catch (_) {}
  }

  static Future<Map<String, dynamic>> fetchStocks({
    bool forceRefresh = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final cached = await getCachedStocks();
      if (!forceRefresh && cached != null) {
        return {
          'success': true,
          'cached': true,
          'total_skus': cached['total_skus'] ?? 0,
          'low_stock_count': cached['low_stock_count'] ?? 0,
          'data': cached['data'] ?? [],
          'message': 'Menampilkan data offline / sinyal lemah',
        };
      }

      if (token == null || token.isEmpty) {
        if (cached != null) {
          return {
            'success': true,
            'cached': true,
            'total_skus': cached['total_skus'] ?? 0,
            'low_stock_count': cached['low_stock_count'] ?? 0,
            'data': cached['data'] ?? [],
            'message': 'Menampilkan data offline / sinyal lemah',
          };
        }

        return {
          'success': false,
          'message': 'Sesi login telah berakhir. Silakan login kembali.',
        };
      }

      final response = await ApiConfig.get(
        Uri.parse('${ApiConfig.baseUrl}/stocks'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final payload = {
          'success': true,
          'total_skus': body['total_skus'] ?? 0,
          'low_stock_count': body['low_stock_count'] ?? 0,
          'data': body['data'] ?? [],
        };

        await saveCachedStocks(payload);

        return {
          'success': true,
          'cached': false,
          'total_skus': payload['total_skus'],
          'low_stock_count': payload['low_stock_count'],
          'data': payload['data'],
        };
      }

      final fallback = await getCachedStocks();
      if (fallback != null) {
        return {
          'success': true,
          'cached': true,
          'total_skus': fallback['total_skus'] ?? 0,
          'low_stock_count': fallback['low_stock_count'] ?? 0,
          'data': fallback['data'] ?? [],
          'message': 'Menampilkan data offline.',
        };
      }

      if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Akses ditolak (401). Silakan login ulang.',
        };
      }

      return {
        'success': false,
        'message': 'Gagal mengambil data stok (Status: ${response.statusCode})',
      };
    } catch (_) {
      final fallback = await getCachedStocks();
      if (fallback != null) {
        return {
          'success': true,
          'cached': true,
          'total_skus': fallback['total_skus'] ?? 0,
          'low_stock_count': fallback['low_stock_count'] ?? 0,
          'data': fallback['data'] ?? [],
          'message': 'Menampilkan data offline.',
        };
      }

      return {
        'success': false,
        'message': 'Tidak dapat terhubung ke server backend.',
      };
    }
  }
}
