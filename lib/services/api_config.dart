import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String baseUrl = 'https://express.fivafood.co.id/api';
  static const Duration requestTimeout = Duration(seconds: 12);

  static Future<http.Response> get(Uri uri, {Map<String, String>? headers}) {
    final request = http.Request('GET', uri);
    if (headers != null) request.headers.addAll(headers);
    return _send(request);
  }

  static Future<http.Response> post(
    Uri uri, {
    Map<String, String>? headers,
    String? body,
  }) {
    final request = http.Request('POST', uri);
    if (headers != null) request.headers.addAll(headers);
    if (body != null) request.body = body;
    return _send(request);
  }

  static Future<http.Response> put(
    Uri uri, {
    Map<String, String>? headers,
    String? body,
  }) {
    final request = http.Request('PUT', uri);
    if (headers != null) request.headers.addAll(headers);
    if (body != null) request.body = body;
    return _send(request);
  }

  static Future<http.Response> sendMultipart(http.MultipartRequest request) {
    return _send(request);
  }

  static Future<http.Response> _send(http.BaseRequest request) async {
    final client = http.Client();
    try {
      return await client
          .send(request)
          .then(http.Response.fromStream)
          .timeout(requestTimeout);
    } finally {
      client.close();
    }
  }

  static Future<Map<String, String>> getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
