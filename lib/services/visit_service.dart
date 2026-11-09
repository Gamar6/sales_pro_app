import 'dart:convert'; // Impor untuk jsonDecode
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';
import '../models/visit_report_model.dart';

class VisitService {
  static const String _historyCacheKeyPrefix = 'visit_history_cache';

  Future<Map<String, dynamic>?> getActiveVisitDetails() async {
    try {
      final headers = await ApiConfig.getAuthHeaders();
      final response = await ApiConfig.get(
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
        if ((data['store_id'] ??
                visitData['store_id'] ??
                data['odoo_partner_id'] ??
                visitData['odoo_partner_id'] ??
                data['partner_id'] ??
                visitData['partner_id']) !=
            null)
          'store_id':
              data['store_id'] ??
              visitData['store_id'] ??
              data['odoo_partner_id'] ??
              visitData['odoo_partner_id'] ??
              data['partner_id'] ??
              visitData['partner_id'],
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

  Future<void> submitVisit(VisitReportModel model) async {
    final bool isRegularStore = model.storeType == 'regular';
    if (isRegularStore &&
        (model.storeVisitId == null || model.storeVisitId!.isEmpty)) {
      throw ArgumentError(
        'ID kunjungan aktif wajib ada untuk mengirim laporan toko reguler.',
      );
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        isRegularStore
            ? '${ApiConfig.baseUrl}/store-visits/${model.storeVisitId}/submit-report'
            : '${ApiConfig.v1BaseUrl}/visit-reports',
      ),
    );

    final headers = await ApiConfig.getAuthHeaders();
    headers.remove('Content-Type');
    request.headers.addAll(headers);

    request.fields.addAll(
      isRegularStore ? model.toRegularVisitFieldsMap() : model.toFieldsMap(),
    );

    for (final photo in model.photos) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'photos[]',
          await photo.readAsBytes(),
          filename: photo.name,
        ),
      );
    }

    if (!isRegularStore && model.checkInPhoto != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'check_in_photo',
          await model.checkInPhoto!.readAsBytes(),
          filename: model.checkInPhoto!.name,
        ),
      );
    }

    final response = await ApiConfig.send(
      request,
      timeout: ApiConfig.uploadTimeout,
    );

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
    } catch (_) {}

    return 'Gagal mengirim laporan (status ${response.statusCode}).';
  }

  Future<void> cancelVisit(String visitId) async {
    final headers = await ApiConfig.getAuthHeaders();
    final response = await ApiConfig.post(
      Uri.parse('${ApiConfig.baseUrl}/store-visits/$visitId/cancel'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(response));
    }
  }

  Future<List<dynamic>?> getCachedVisitHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    if (userId == null || userId.isEmpty) return null;

    final raw = prefs.getString('$_historyCacheKeyPrefix:$userId');
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        await prefs.remove('$_historyCacheKeyPrefix:$userId');
        return null;
      }
      return decoded;
    } on FormatException {
      await prefs.remove('$_historyCacheKeyPrefix:$userId');
      return null;
    }
  }

  Future<List<dynamic>> refreshVisitHistory() async {
    final headers = await ApiConfig.getAuthHeaders();
    final response = await ApiConfig.get(
      Uri.parse('${ApiConfig.baseUrl}/store-visits/history'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal memuat riwayat (Status: ${response.statusCode}).');
    }

    final decoded = jsonDecode(response.body);
    final List<dynamic> history;
    if (decoded is Map<String, dynamic> && decoded['data'] is List) {
      history = decoded['data'] as List<dynamic>;
    } else if (decoded is List) {
      history = decoded;
    } else {
      throw const FormatException('Format riwayat kunjungan tidak valid.');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId != null && userId.isNotEmpty) {
        await prefs.setString(
          '$_historyCacheKeyPrefix:$userId',
          jsonEncode(history),
        );
      }
    } catch (error, stackTrace) {
      developer.log(
        'Could not save refreshed visit history to cache.',
        name: 'VisitService',
        error: error,
        stackTrace: stackTrace,
      );
    }

    return history;
  }

  Future<List<dynamic>> getVisitHistory() async {
    try {
      return await refreshVisitHistory();
    } catch (error, stackTrace) {
      developer.log(
        'Could not refresh visit history; trying the local cache.',
        name: 'VisitService',
        error: error,
        stackTrace: stackTrace,
      );
      return await getCachedVisitHistory() ?? [];
    }
  }
}
