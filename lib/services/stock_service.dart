import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class StockService {
  static Future<Map<String, dynamic>> fetchStocks({String search = ''}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/stocks?search=$search'),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return {
          'success': true,
          'total_skus': body['total_skus'] ?? 0,
          'low_stock_count': body['low_stock_count'] ?? 0,
          'data': body['data'] ?? [],
        };
      }
      return {'success': false, 'message': 'Gagal memuat data stok.'};
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan koneksi: $e'};
    }
  }

}
