import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

class StockService {
  static const String _cacheKeyPrefix = 'stock_cache';

  static Future<Map<String, dynamic>?> getCachedStocks() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    if (userId == null || userId.isEmpty) return null;

    final raw = prefs.getString('$_cacheKeyPrefix:$userId');
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        await prefs.remove('$_cacheKeyPrefix:$userId');
        return null;
      }
      return decoded;
    } on FormatException {
      await prefs.remove('$_cacheKeyPrefix:$userId');
      return null;
    }
  }

  static Future<void> saveCachedStocks(Map<String, dynamic> payload) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId == null || userId.isEmpty) return;

      await prefs.setString('$_cacheKeyPrefix:$userId', jsonEncode(payload));
    } catch (error, stackTrace) {
      developer.log(
        'Could not save refreshed stock data to cache.',
        name: 'StockService',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static Future<Map<String, dynamic>> fetchStocks() async {
    Map<String, dynamic>? cached;
    try {
      cached = await getCachedStocks();
      final headers = await ApiConfig.getAuthHeaders();
      if (!headers.containsKey('Authorization')) {
        return _cachedOrError(
          cached,
          'Sesi login telah berakhir. Silakan login kembali.',
        );
      }

      final response = await ApiConfig.get(
        Uri.parse('${ApiConfig.baseUrl}/stocks'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['data'] != null && body['data'] is! List) {
          throw const FormatException(
            'Format data stok dari server tidak valid.',
          );
        }
        final payload = {
          'success': true,
          'total_skus': body['total_skus'] ?? 0,
          'low_stock_count': body['low_stock_count'] ?? 0,
          'data': body['data'] ?? [],
        };

        await saveCachedStocks(payload);
        return {...payload, 'success': true, 'cached': false};
      }

      final message = response.statusCode == 401
          ? 'Akses ditolak (401). Silakan login ulang.'
          : 'Gagal mengambil data stok (Status: ${response.statusCode})';
      return _cachedOrError(cached, message);
    } on TimeoutException {
      return _cachedOrError(
        cached,
        'Koneksi lambat. Data cache tetap tersedia; coba lagi.',
      );
    } on SocketException {
      return _cachedOrError(
        cached,
        'Tidak ada koneksi ke server. Coba lagi saat jaringan membaik.',
      );
    } on Exception {
      return _cachedOrError(cached, 'Tidak dapat memuat data stok. Coba lagi.');
    }
  }

  static Map<String, dynamic> _cachedOrError(
    Map<String, dynamic>? cached,
    String errorMessage,
  ) {
    if (cached != null) {
      return {
        'success': true,
        'cached': true,
        'total_skus': cached['total_skus'] ?? 0,
        'low_stock_count': cached['low_stock_count'] ?? 0,
        'data': cached['data'] ?? [],
        'message': errorMessage,
      };
    }

    return {'success': false, 'message': errorMessage};
  }
}
