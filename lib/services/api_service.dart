import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/partner_model.dart';
import 'api_config.dart';

class ApiService {
  static const String _cacheKeyPrefix = 'retensi_partners_cache_';

  Future<List<Partner>?> getCachedPartners() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    if (userId == null || userId.isEmpty) return null;

    final cachedData = prefs.getString('$_cacheKeyPrefix$userId');
    if (cachedData == null) return null;

    final decodedData = jsonDecode(cachedData);
    if (decodedData is! List) {
      await prefs.remove('$_cacheKeyPrefix$userId');
      return null;
    }

    return decodedData
        .map((item) => Partner.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<List<Partner>> fetchPartners() async {
    try {
      final headers = await ApiConfig.getAuthHeaders();

      final response = await ApiConfig.get(
        Uri.parse('${ApiConfig.baseUrl}/retensi'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);

        List<dynamic> jsonList = [];

        if (decodedData is Map<String, dynamic>) {
          jsonList = decodedData['data'] ?? [];
        } else if (decodedData is List) {
          jsonList = decodedData;
        }

        final partners = jsonList
            .map((json) => Partner.fromJson(json))
            .toList();
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('user_id');
        if (userId != null && userId.isNotEmpty) {
          try {
            await prefs.setString(
              '$_cacheKeyPrefix$userId',
              jsonEncode(jsonList),
            );
          } catch (error) {
            debugPrint('Gagal menyimpan cache daftar toko: $error');
          }
        }
        return partners;
      } else {
        throw Exception(
          'Gagal memuat data toko (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      throw Exception('Koneksi Gagal: $e');
    }
  }
}
