import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String baseUrl = 'https://express.fivafood.co.id/api';
  static const Duration requestTimeout = Duration(seconds: 12);
  static const Duration uploadTimeout = Duration(seconds: 30);

  static Future<http.Response> get(Uri uri, {Map<String, String>? headers}) {
    final request = http.Request('GET', uri);
    if (headers != null) request.headers.addAll(headers);
    return send(request);
  }

  static Future<http.Response> post(
    Uri uri, {
    Map<String, String>? headers,
    String? body,
  }) {
    final request = http.Request('POST', uri);
    if (headers != null) request.headers.addAll(headers);
    if (body != null) request.body = body;
    return send(request);
  }

  static Future<http.Response> put(
    Uri uri, {
    Map<String, String>? headers,
    String? body,
  }) {
    final request = http.Request('PUT', uri);
    if (headers != null) request.headers.addAll(headers);
    if (body != null) request.body = body;
    return send(request);
  }

  static Future<http.Response> send(
    http.BaseRequest request, {
    Duration? timeout,
  }) {
    return withClient((client) async {
      final streamedResponse = await client.send(request);
      return http.Response.fromStream(streamedResponse);
    }, timeout: timeout);
  }

  static Future<http.Response> withClient(
    Future<http.Response> Function(http.Client client) request, {
    Duration? timeout,
  }) async {
    final client = http.Client();
    final requestTimeout = timeout ?? ApiConfig.requestTimeout;

    try {
      return await request(client).timeout(
        requestTimeout,
        onTimeout: () {
          client.close();
          throw TimeoutException(
            'Request timed out after ${requestTimeout.inSeconds} seconds.',
          );
        },
      );
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
