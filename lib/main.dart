import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/auth/login_screen.dart';
import 'screens/home/home.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // 1. Tahan splash bawaan HP
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 2. Cek status login
  bool isAuthenticated = await _checkAuthToken();

  // 3. Lepas splash bawaan HP
  FlutterNativeSplash.remove();

  // 4. Jalankan app langsung ke login / home
  runApp(FieldSalesApp(isAuthenticated: isAuthenticated));
}

Future<bool> _checkAuthToken() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  } catch (e) {
    return false;
  }
}

class FieldSalesApp extends StatelessWidget {
  final bool isAuthenticated;

  const FieldSalesApp({super.key, required this.isAuthenticated});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sales App',
      debugShowCheckedModeBanner: false,
      // Langsung tentukan halaman awal berdasarkan status login
      initialRoute: isAuthenticated ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}