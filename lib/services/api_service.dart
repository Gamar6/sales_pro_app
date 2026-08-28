import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/partner_model.dart';
import 'api_config.dart';

class ApiService {
  Future<List<Partner>> fetchPartners() async {
    try {
      // Mengambil header lengkap beserta Authorization Bearer Token
      final headers = await ApiConfig.getAuthHeaders();

      final response = await http.get(
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

        return jsonList.map((json) => Partner.fromJson(json)).toList();
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
