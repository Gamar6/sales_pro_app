import 'package:flutter/material.dart';
import 'screens/store_route_screen.dart';

void main() {
  runApp(const FieldSalesApp());
}

class FieldSalesApp extends StatelessWidget {
  const FieldSalesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Field Sales Pro',
      theme: ThemeData(
        primaryColor: const Color(0xFF031636),
        scaffoldBackgroundColor: const Color(0xFFF8F9FF),
        fontFamily: 'Inter',
      ),
      home: const StoreRouteScreen(),
    );
  }
}