import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/home/home.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  bool isAuthenticated = await _checkAuthToken();

  FlutterNativeSplash.remove();

  runApp(FieldSalesApp(isAuthenticated: isAuthenticated));
}

Future<bool> _checkAuthToken() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    return token != null && token.isNotEmpty;
  } catch (_) {
    return false;
  }
}

class FieldSalesApp extends StatefulWidget {
  final bool isAuthenticated;

  const FieldSalesApp({super.key, required this.isAuthenticated});

  @override
  State<FieldSalesApp> createState() => _FieldSalesAppState();
}

class _FieldSalesAppState extends State<FieldSalesApp> {
  final AppLinks _appLinks = AppLinks();

  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initializeDeepLinks();
  }

  Future<void> _initializeDeepLinks() async {
    try {
      final Uri? initialUri = await _appLinks.getInitialLink();

      if (initialUri != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleDeepLink(initialUri);
        });
      }
    } catch (e) {
      debugPrint('Gagal membaca initial deep link: $e');
    }

    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleDeepLink(uri);
      },
      onError: (Object error) {
        debugPrint('Deep link error: $error');
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('Deep Link diterima: $uri');


    if (uri.scheme == 'fieldoperations' && uri.host == 'reset-password') {
      final token = uri.queryParameters['token'];
      final email = uri.queryParameters['email'];

      if (token == null || token.isEmpty || email == null || email.isEmpty) {
        debugPrint('Token atau email tidak ditemukan.');
        return;
      }

      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(token: token, email: email),
        ),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Sales App',
      debugShowCheckedModeBanner: false,

      initialRoute: widget.isAuthenticated ? '/home' : '/login',

      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
