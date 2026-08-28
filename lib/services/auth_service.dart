import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/login_response.dart';
import '../services/api_config.dart';

class AuthService {
  Future<LoginResponse> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'username': username, 'password': password}),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final loginResponse = LoginResponse.fromJson(responseData);

      if (response.statusCode == 200 && loginResponse.token != null) {
        await _saveSession(loginResponse);
      }

      return loginResponse;
    } catch (e) {
      return LoginResponse(
        success: false,
        message: 'Koneksi gagal. Pastikan server backend aktif.',
      );
    }
  }

  Future<void> _saveSession(LoginResponse data) async {
    final prefs = await SharedPreferences.getInstance();
    if (data.token != null) {
      await prefs.setString('token', data.token!);
    }
    if (data.user != null) {
      await prefs.setString('user_id', data.user!.id.toString());
      await prefs.setString('user_name', data.user!.name);
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        await http.post(
          Uri.parse('${ApiConfig.baseUrl}/login'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (e) {
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
    }
  }
}