import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../models/field_store_model.dart';
import 'api_config.dart';

class FieldStoreService {
  Future<FieldStoreModel> createFieldStore({
    required FieldStoreModel store,
    required XFile photo,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.v1BaseUrl}/field-stores'),
    );
    final headers = await ApiConfig.getAuthHeaders();
    headers.remove('Content-Type');
    request.headers.addAll(headers);

    final fields = store.toJson()
      ..remove('id')
      ..remove('photo_url')
      ..remove('created_at');
    request.fields.addAll({
      for (final entry in fields.entries)
        if (entry.value != null) entry.key: entry.value.toString(),
    });
    request.files.add(
      http.MultipartFile.fromBytes(
        'photo',
        await photo.readAsBytes(),
        filename: photo.name,
      ),
    );

    final response = await ApiConfig.send(
      request,
      timeout: ApiConfig.uploadTimeout,
    );
    final body = _decodeResponse(response);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_errorMessage(body, response.statusCode));
    }

    final responseData = body['data'] ?? body;
    if (responseData is! Map<String, dynamic>) {
      throw const FormatException('Format respons toko baru tidak valid.');
    }

    return FieldStoreModel.fromJson(responseData);
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.body.isEmpty) return {};
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw const FormatException('Format respons server tidak valid.');
  }

  String _errorMessage(Map<String, dynamic> body, int statusCode) {
    final errors = body['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final firstError = errors.values.first;
      if (firstError is List && firstError.isNotEmpty) {
        return firstError.first.toString();
      }
    }

    final message = body['message']?.toString();
    if (message != null && message.isNotEmpty) return message;
    return 'Gagal menyimpan toko baru (status $statusCode).';
  }
}
