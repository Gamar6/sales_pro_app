import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/store_model.dart';
import './api_config.dart';

class ApiService {
  Future<List<StoreModel>> fetchStores() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/retensi'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final dynamic body = jsonDecode(response.body);

      // Menangani format penulisan response Laravel (baik 'data' wrapper maupun array langsung)
      final List<dynamic> dataList = body is Map<String, dynamic>
          ? (body['data'] ?? [])
          : body;

      List<StoreModel> stores = dataList
          .map((item) => StoreModel.fromJson(item))
          .toList();
      stores.sort((a, b) => a.priority.compareTo(b.priority));
      return stores;
    } else {
      throw Exception(
        'Gagal memuat data dari API Laravel (Status: ${response.statusCode})',
      );
    }
  }
}
