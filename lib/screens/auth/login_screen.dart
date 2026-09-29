import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'forgot_password_screen.dart';
import '../../models/login_response.dart';
import '../../services/auth_service.dart';
import '../../models/contact_person.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final LoginResponse response = await _authService.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (response.success || response.token != null) {
        final prefs = await SharedPreferences.getInstance();

        if (response.token != null) {
          await prefs.setString('token', response.token!);
        }

        final user = response.user;
        if (user != null) {
          await prefs.setString('user_name', user.name);
          await prefs.setString('username', user.username);
        }

        if (!mounted) return;

        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showErrorSnackBar(response.message);
      }
    } catch (e) {
      _showErrorSnackBar('Terjadi kesalahan koneksi. Silakan coba lagi.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _contactAdmin() async {
    try {
      final contactPersons = await _authService.getContactPersons();

      if (!mounted) return;

      if (contactPersons.isEmpty) {
        _showErrorSnackBar('Belum ada admin yang dapat dihubungi.');
        return;
      }

      if (contactPersons.length == 1) {
        await _openWhatsApp(contactPersons.first);
        return;
      }

      await _showContactPersonPicker(contactPersons);
    } catch (e) {
      if (!mounted) return;

      _showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _openWhatsApp(ContactPerson contact) async {
    final phone = _normalizePhoneNumber(contact.nohp);

    if (phone.isEmpty) {
      _showErrorSnackBar('Nomor WhatsApp ${contact.name} tidak valid.');
      return;
    }

    final message = Uri.encodeComponent(
      'Halo ${contact.name},\n\n'
      'Saya ingin melaporkan kendala terkait akun saya '
      'dengan detail sebagai berikut:\n\n'
      'Nama Pengguna/Email: [Masukkan Nama/Email]\n'
      'Kendala yang Dihadapi: [Jelaskan singkat, '
      'misal: tidak bisa login / gagal memuat halaman]\n'
      'Pesan Error (jika ada): [Masukkan pesan error. '
      'Pesan error boleh berupa gambar]\n\n'
      'Mohon bantuan dan arahannya untuk menyelesaikan '
      'kendala ini.\n'
      'Terima kasih.',
    );

    final uri = Uri.parse('https://wa.me/$phone?text=$message');

    if (!await canLaunchUrl(uri)) {
      _showErrorSnackBar('WhatsApp tidak dapat dibuka.');
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _normalizePhoneNumber(String value) {
    var phone = value.replaceAll(RegExp(r'\D'), '');

    if (phone.startsWith('0')) {
      phone = '62${phone.substring(1)}';
    } else if (phone.startsWith('8')) {
      phone = '62$phone';
    }

    return phone;
  }

  Future<void> _showContactPersonPicker(
    List<ContactPerson> contactPersons,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Admin',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Pilih admin yang ingin kamu hubungi.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ...contactPersons.map(
                  (contact) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      child: Text(
                        contact.name.isNotEmpty
                            ? contact.name[0].toUpperCase()
                            : '?',
                      ),
                    ),
                    title: Text(
                      contact.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(contact.nohp),
                    trailing: const Icon(Icons.chat_outlined),
                    onTap: () async {
                      Navigator.pop(context);
                      await _openWhatsApp(contact);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C467F),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogoHeader(),
                const SizedBox(height: 40),
                _buildLoginForm(),
                const SizedBox(height: 48),
                _buildFooterLinks(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24.0),
          child: Image.network(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDVL1FWR1T7UMskMT3iHZNh_FyZpE_uIV4b-DHR7obP1SrUgtCpeVdWDwFhRh1p_AAK-qwmVbSrD5T2BTnZnSjRR5EtX4TrdNMoek5PxjKoiSkjNTwoPiB5OXCjudcKo2DVT1b-PHWNLcHJzPb6iorYYk7zMdjd7Hbd07waNfL-m12fD5qSIsh8E1VfvMmK6OYg9RzqfES-6u2xE16mt7TGYGC8eKSRO5aWYUBsyxQMNyJQCrrj0y6M4AcNrbthyno2eQ',
            height: 240,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.shield, size: 100, color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Field Operations',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Authentication Required',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _usernameController,
              textInputAction: TextInputAction.next,
              style: const TextStyle(color: Color(0xFF0B1C30)),
              validator: (val) => val == null || val.trim().isEmpty
                  ? 'Username wajib diisi'
                  : null,
              decoration: _inputDecoration(
                hintText: 'Username',
                prefixIcon: Icons.person,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleLogin(),
              style: const TextStyle(color: Color(0xFF0B1C30)),
              validator: (val) => val == null || val.trim().isEmpty
                  ? 'Password wajib diisi'
                  : null,
              decoration: _inputDecoration(
                hintText: 'Password',
                prefixIcon: Icons.lock,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF75777F),
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF48110),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterLinks() {
    return Column(
      children: [
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ForgotPasswordScreen(),
              ),
            );
          },
          child: Text(
            'Lupa Password?',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              decoration: TextDecoration.underline,
              decorationColor: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 48,
          height: 1,
          color: Colors.white.withValues(alpha: 0.2),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _contactAdmin,
          icon: const Icon(Icons.support_agent, size: 16, color: Colors.white),
          label: Text(
            'Hubungi Admin',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF75777F)),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF75777F)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.95),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF48110), width: 2),
      ),
    );
  }
}
