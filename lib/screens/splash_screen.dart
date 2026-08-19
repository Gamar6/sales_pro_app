import 'package:flutter/material.dart';
import './auth/login.dart'; // Uncomment jika sudah ingin dihubungkan ke halaman login

void main() {
  runApp(const FieldAuthoritySplashApp());
}

class FieldAuthoritySplashApp extends StatelessWidget {
  const FieldAuthoritySplashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loading - Field Authority',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1C467F),
          primary: const Color(0xFF1C467F),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Inisialisasi animasi untuk progress bar loading (berdurasi 2 detik, berulang)
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Simulasi waktu tunggu sebelum pindah halaman (misal 3 detik)
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C467F),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.8,
            colors: [Colors.white.withOpacity(0.05), Colors.transparent],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 24.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(), // Spacer atas agar seimbang
                // Main Content: Logo Berdenyut (Pulse)
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0.95, end: 1.05),
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  builder: (context, scale, child) {
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAu2f7GRVsbcqGkk71rrzAU3Ho3sF45yBfp8qWiBbEYmfjf9zUaC4Mmawg_U49PdhdXrNIAhAfI9LLh2-cIoHHIol6NV5aCmnpDnWkqiBCGpmruZa2mVNtyGQRk-hnZcKXLNFKY1fIYGZqA-d7_HBlCP5olZYTrfMfYjOj8I-gmeb2VLw8TrxY52WO1slAa3GYQ5zp9ztt3BSnrs_nwdtveYPiXlGxi_BYnXoCm6wxtMoBWZwPadYK_AdfGQ5kD2rigCA',
                    width: 250,
                    fit: BoxFit.contain,
                  ),
                ),

                // Bottom Area: Loader dan Footer Info
                Column(
                  children: [
                    // Loading Indicator Area
                    SizedBox(
                      width: 280,
                      child: Column(
                        children: [
                          Text(
                            'INITIALIZING',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.8),
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Progress Bar Container
                          Container(
                            height: 4,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              // Animasi progress bar bergerak
                              child: AnimatedBuilder(
                                animation: _controller,
                                builder: (context, child) {
                                  return FractionallySizedBox(
                                    widthFactor:
                                        0.5 + (_controller.value * 0.5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFF48110,
                                        ), // Brand Orange
                                        borderRadius: BorderRadius.circular(99),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Footer Text
                    Opacity(
                      opacity: 0.7,
                      child: Column(
                        children: [
                          const Text(
                            'Distribusi Pangan Terpercaya',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.0,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'v1.0.0',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w300,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
