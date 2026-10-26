import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/login_response.dart';
import '../services/api_config.dart';
import '../models/contact_person.dart';

class AuthService {
  Future<LoginResponse> login(String username, String password) async {
    try {
      final response = await ApiConfig.withClient(
        (client) => client.post(
          Uri.parse('${ApiConfig.baseUrl}/login'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({'username': username, 'password': password}),
        ),
        timeout: const Duration(seconds: 15),
      );

      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      final loginResponse = LoginResponse.fromJson(responseData);

      if (response.statusCode == 200 && loginResponse.token != null) {
        await _saveSession(loginResponse);
      }

      return loginResponse;
    } on TimeoutException {
      return LoginResponse(
        success: false,
        message:
            'Login membutuhkan waktu terlalu lama. Periksa koneksi internet, lalu coba lagi.',
      );
    } on SocketException {
      return LoginResponse(
        success: false,
        message:
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on http.ClientException {
      return LoginResponse(
        success: false,
        message:
            'Koneksi ke server terputus. Periksa jaringan, lalu coba lagi.',
      );
    } on FormatException {
      return LoginResponse(
        success: false,
        message:
            'Respons server tidak dapat dibaca. Silakan coba lagi beberapa saat.',
      );
    } catch (_) {
      return LoginResponse(
        success: false,
        message: 'Terjadi kesalahan saat login. Silakan coba lagi.',
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
      prefs.remove('username'),
    ]);
  }

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

      final response = await ApiConfig.withClient(
        (client) => client.post(
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
        ),
        timeout: ApiConfig.requestTimeout,
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

  Future<void> changeUsername(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Sesi berakhir, silakan login kembali.');
      }

      final response = await ApiConfig.withClient(
        (client) => client.put(
          Uri.parse('${ApiConfig.baseUrl}/user/username'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'username': username}),
        ),
        timeout: ApiConfig.requestTimeout,
      );
      final responseData = jsonDecode(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(responseData['message'] ?? 'Gagal mengubah username.');
      }

      await prefs.setString('username', username);
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

      final uri = Uri.parse('${ApiConfig.baseUrl}/user');
      final response = await ApiConfig.withClient(
        (client) => client.get(
          uri,
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
        timeout: ApiConfig.requestTimeout,
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
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

      final bytes = await imageFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes('photo', bytes, filename: imageFile.name),
      );

      final response = await ApiConfig.send(
        request,
        timeout: ApiConfig.uploadTimeout,
      );
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

  Future<String> forgotPassword(String email) async {
    try {
      final response = await ApiConfig.withClient(
        (client) => client.post(
          Uri.parse('${ApiConfig.baseUrl}/forgot-password'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({'email': email}),
        ),
        timeout: ApiConfig.requestTimeout,
      );

      Map<String, dynamic> responseData = {};

      if (response.body.isNotEmpty) {
        responseData = jsonDecode(response.body);
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData['message'] ??
            'Link reset password berhasil dikirim ke email.';
      }

      throw Exception(
        responseData['message'] ?? 'Gagal mengirim permintaan reset password.',
      );
    } catch (e) {
      if (e is Exception) rethrow;

      throw Exception('Koneksi gagal. Pastikan server backend aktif.');
    }
  }

  Future<String> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await ApiConfig.withClient(
        (client) => client.post(
          Uri.parse('${ApiConfig.baseUrl}/reset-password'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'email': email,
            'token': token,
            'password': password,
            'password_confirmation': passwordConfirmation,
          }),
        ),
        timeout: ApiConfig.requestTimeout,
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData['message'] ?? 'Password berhasil diubah.';
      }

      throw Exception(responseData['message'] ?? 'Gagal mengubah password.');
    } catch (e) {
      if (e is Exception) rethrow;

      throw Exception('Koneksi gagal. Pastikan server backend aktif.');
    }
  }

  Future<List<ContactPerson>> getContactPersons() async {
    try {
      final response = await ApiConfig.withClient(
        (client) => client.get(
          Uri.parse('${ApiConfig.baseUrl}/contact-persons'),
          headers: {'Accept': 'application/json'},
        ),
        timeout: ApiConfig.requestTimeout,
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(
          responseData['message'] ?? 'Gagal memuat daftar admin.',
        );
      }

      final data = responseData['data'];

      if (data is! List) {
        return [];
      }

      return data
          .map(
            (item) => ContactPerson.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } catch (e) {
      if (e is Exception) rethrow;

      throw Exception('Koneksi gagal. Pastikan server backend aktif.');
    }
  }
}
