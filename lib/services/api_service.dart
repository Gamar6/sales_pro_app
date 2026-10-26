import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/partner_model.dart';
import 'api_config.dart';

class ApiService {
  static const _partnersCacheKeyPrefix = 'retensi_partners_cache';

  Future<List<Partner>?> getCachedPartners() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    if (userId == null || userId.isEmpty) return null;

    final cacheKey = '$_partnersCacheKeyPrefix:$userId';
    final cachedJson = prefs.getString(cacheKey);
    if (cachedJson == null || cachedJson.isEmpty) return null;

    try {
      final decoded = json.decode(cachedJson);
      if (decoded is! List) {
        await prefs.remove(cacheKey);
        return null;
      }

      return decoded
          .whereType<Map>()
          .map(
            (partner) => Partner.fromJson(Map<String, dynamic>.from(partner)),
          )
          .toList();
    } on FormatException {
      await prefs.remove(cacheKey);
      return null;
    }
  }

  Future<List<Partner>> fetchPartners() async {
    final headers = await ApiConfig.getAuthHeaders();

    final response = await ApiConfig.get(
      Uri.parse('${ApiConfig.baseUrl}/retensi'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal memuat data toko (Status: ${response.statusCode})',
      );
    }

    final dynamic decodedData = json.decode(response.body);
    final List<dynamic> jsonList;

    if (decodedData is Map<String, dynamic> &&
        (decodedData['data'] == null || decodedData['data'] is List)) {
      jsonList = decodedData['data'] as List<dynamic>? ?? [];
    } else if (decodedData is List) {
      jsonList = decodedData;
    } else {
      throw const FormatException('Format data toko dari server tidak valid.');
    }

    final partners = jsonList
        .whereType<Map>()
        .map((partner) => Partner.fromJson(Map<String, dynamic>.from(partner)))
        .toList();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId != null && userId.isNotEmpty) {
        await prefs.setString(
          '$_partnersCacheKeyPrefix:$userId',
          json.encode(partners.map((partner) => partner.toJson()).toList()),
        );
      }
    } catch (error, stackTrace) {
      developer.log(
        'Could not save refreshed store data to cache.',
        name: 'ApiService',
        error: error,
        stackTrace: stackTrace,
      );
    }

    return partners;
  }
}
