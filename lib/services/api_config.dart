import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String baseUrl = 'http://192.168.53.178:8000/api';

  static Future<Map<String, String>> getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(
      'token',
    );

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
