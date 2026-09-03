import 'dart:convert'; // Impor untuk jsonDecode
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../models/visit_model.dart';

class VisitService {
  Future<Map<String, dynamic>?> getActiveVisitDetails() async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/visits/active'),
        headers: headers,
      );

      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> || decoded['data'] == null) {
        return null;
      }

      final data = decoded['data'];
      if (data is! Map<String, dynamic>) return null;

      final nestedVisit = data['store_visit'];
      final visitData = nestedVisit is Map<String, dynamic>
          ? nestedVisit
          : data;
      final visitId =
          visitData['visit_id'] ?? visitData['store_visit_id'] ?? data['id'];
      if (visitId == null) return null;

      final outletName =
          data['outlet_name'] ??
          data['store_name'] ??
          data['partner_name'] ??
          visitData['outlet_name'] ??
          visitData['store_name'] ??
          visitData['partner_name'] ??
          (data['partner'] is Map
              ? (data['partner']['name'] ?? data['partner']['partner_name'])
              : null) ??
          (data['store'] is Map
              ? (data['store']['name'] ?? data['store']['outlet_name'])
              : null) ??
          (data['outlet'] is Map
              ? (data['outlet']['name'] ?? data['outlet']['outlet_name'])
              : null) ??
          (visitData['partner'] is Map
              ? (visitData['partner']['name'] ??
                    visitData['partner']['partner_name'])
              : null) ??
          (visitData['store'] is Map
              ? (visitData['store']['name'] ??
                    visitData['store']['outlet_name'])
              : null) ??
          (visitData['outlet'] is Map
              ? (visitData['outlet']['name'] ??
                    visitData['outlet']['outlet_name'])
              : null);

      return {
        'visit_id': visitId.toString(),
        if (data['odoo_partner_id'] != null)
          'odoo_partner_id': data['odoo_partner_id'],
        if (outletName != null) 'outlet_name': outletName.toString(),
      };
    } catch (_) {
      return null;
    }
  }

  Future<String?> getActiveVisit() async {
    final activeVisit = await getActiveVisitDetails();
    return activeVisit?['visit_id']?.toString();
  }

  Future<void> submitVisit(VisitRequestModel model) async {
    final String endpoint = (model.visitId != null && model.visitId!.isNotEmpty)
        ? '/store-visits/${model.visitId}/submit-report'
        : '/store-visits/claim';

    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final request = http.MultipartRequest('POST', uri);

    final headers = await ApiConfig.getAuthHeaders();
    headers.remove('Content-Type');
    request.headers.addAll(headers);

    request.fields.addAll(model.toFieldsMap());

    for (var photo in model.photos) {
      final bytes = await photo.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes('photos[]', bytes, filename: photo.name),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_extractErrorMessage(response));
    }
  }

  String _extractErrorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final errors = decoded['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }
        }

        final message = decoded['message'];
        if (message != null && message.toString().isNotEmpty) {
          return message.toString();
        }
      }
    } catch (_) {
      // Respons non-JSON akan memakai pesan umum di bawah.
    }

    return 'Gagal mengirim laporan (status ${response.statusCode}).';
  }

  Future<void> cancelVisit(String visitId) async {
    final headers = await ApiConfig.getAuthHeaders();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/store-visits/$visitId/cancel'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(response));
    }
  }

  Future<List<dynamic>> getVisitHistory() async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/store-visits/history',
        ), // Sesuaikan endpoint API history di Laravel kamu
        headers: headers,
      );

      if (response.statusCode != 200) return [];

      final decoded = jsonDecode(response.body);

      // Sesuaikan struktur parsing ini dengan format JSON dari response backend Laravel
      if (decoded is Map<String, dynamic> && decoded['data'] != null) {
        final data = decoded['data'];
        if (data is List) {
          return data;
        }
      } else if (decoded is List) {
        return decoded;
      }

      return [];
    } catch (e) {
      return [];
    }
  }
}
