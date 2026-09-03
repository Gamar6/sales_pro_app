import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'api_config.dart';

class StoreVisitService {
  /// Klaim toko untuk memulai kunjungan.
  ///
  /// Mengembalikan:
  /// {
  ///   'success': true,
  ///   'visit_id': 123,
  /// }
  Future<Map<String, dynamic>> claimStore({required int odooPartnerId}) async {
    try {
      final headers = await ApiConfig.getAuthHeaders();

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/store-visits/claim'),
        headers: headers,
        body: jsonEncode({'odoo_partner_id': odooPartnerId}),
      );

      final data = _decodeResponse(response);

      if (response.statusCode == 201) {
        final responseData = data['data'];
        final visitId = responseData is Map<String, dynamic>
            ? (responseData['visit_id'] ?? responseData['store_visit_id'])
            : data['visit_id'];

        if (visitId != null) {
          return {'success': true, 'visit_id': visitId};
        }

        return {
          'success': false,
          'message': 'ID Kunjungan tidak ditemukan pada respons server.',
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Gagal klaim toko.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  /// Submit laporan kunjungan.
  ///
  /// Digunakan untuk mengirim data laporan sekaligus foto.
  Future<Map<String, dynamic>> submitReport({
    required int visitId,
    required String picName,
    required String activities,
    required double stockPercentage,
    required int stockPcs,
    required String notes,
    required List<XFile> photos,
  }) async {
    try {
      final headers = await ApiConfig.getAuthHeaders();

      // MultipartRequest akan menentukan Content-Type sendiri
      // beserta boundary-nya, jadi Content-Type JSON harus dihapus.
      headers.remove('Content-Type');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/store-visits/$visitId/submit-report'),
      );

      request.headers.addAll(headers);

      // Text fields
      request.fields['pic_name'] = picName;
      request.fields['activities'] = activities;
      request.fields['stock_percentage'] = stockPercentage.toString();
      request.fields['stock_pcs'] = stockPcs.toString();
      request.fields['notes'] = notes;

      // Photos
      for (final photo in photos) {
        final bytes = await photo.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes('photos[]', bytes, filename: photo.name),
        );
      }

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      final data = _decodeResponse(response);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Laporan berhasil dikirim.',
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Gagal kirim laporan.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  /// Decode response JSON dengan aman.
  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.body.isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {};
    } catch (_) {
      return {};
    }
  }
}
