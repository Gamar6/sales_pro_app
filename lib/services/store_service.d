import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/store_model.dart';
import 'api_config.dart';

class StoreService {
  static Future<Map<String, dynamic>> fetchStores({
    double lat = -7.71830000,
    double lng = 109.01500000,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/stores?latitude=$lat&longitude=$lng'),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        List<Store> stores = (body['data'] as List)
            .map((item) => Store.fromJson(item))
            .toList();
        return {'success': true, 'data': stores};
      }
      return {'success': false, 'message': 'Gagal memuat daftar toko.'};
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan koneksi: $e'};
    }
  }

  static Future<Map<String, dynamic>> claimStore({
    required int storeId,
    required int salesId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/stores/claim'),
        headers: ApiConfig.headers,
        body: jsonEncode({'store_id': storeId, 'sales_id': salesId}),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': body['message'] ?? 'Berhasil klaim toko.',
          'data': body['data'],
        };
      }
      return {
        'success': false,
        'message': body['message'] ?? 'Gagal me-klaim toko.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan jaringan.'};
    }
  }
}
