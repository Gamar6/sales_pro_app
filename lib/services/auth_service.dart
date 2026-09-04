import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
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
    } catch (_) {
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
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove('token'),
      prefs.remove('user_id'),
      prefs.remove('user_name'),
    ]);
  }

  // Method baru untuk ganti password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Sesi berakhir, silakan login kembali.');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(
          responseData['message'] ?? 'Gagal memperbarui kata sandi.',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Koneksi gagal. Pastikan server backend aktif.');
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Sesi berakhir, silakan login kembali.');
      }

      // Sesuaikan endpoint ini dengan route Laravel kamu (misal: /user atau /profile)
      final uri = Uri.parse('${ApiConfig.baseUrl}/user');
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Jika Laravel mengembalikan { "data": { ... } }, gunakan responseData['data']
        // Jika Laravel mengembalikan langsung object user { "id": 1, ... }, gunakan responseData
        return responseData['data'] ?? responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Gagal memuat data profil.');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Koneksi gagal. Pastikan server backend aktif.');
    }
  }

  Future<String> uploadProfilePhoto(XFile imageFile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Sesi berakhir, silakan login kembali.');
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}/profile/photo');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Accept'] = 'application/json'
        ..headers['Authorization'] = 'Bearer $token';

      // Baca file dalam bentuk bytes agar aman untuk Flutter Web & Mobile
      final bytes = await imageFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes('photo', bytes, filename: imageFile.name),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData['data']['profile_photo_url'];
      } else {
        throw Exception(
          responseData['message'] ?? 'Gagal mengunggah foto profil.',
        );
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Koneksi gagal. Pastikan server backend aktif.');
    }
  }
} 