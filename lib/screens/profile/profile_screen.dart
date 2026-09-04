import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _pushNotifications = true;
  bool _locationServices = true;
  bool _isUploading = false;

  String _profileImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCJDXKmFNJE-LN9nd914mMkcouhS8RrXJgEm3c38hDZ51q0TyR3OMC9sAPVRkTqatZMb-Y6s0AtuMRAMBBeK4W02tT8PoHx8O6ePV9vLYNoM4ZFUzH-adcweUPKXoZXM4aJj3-VWAJZB4V5LoTm7EZb7ALTuwbBryDXaPHOHr3miJ09CzxKxpz-9PnRZr-UJbbPzI9j37KDvyMfV_qR-B3GcoCg_pVRwOCGJWNvngyNaRk67_61gd3L';

  // Modal Pilihan Kamera / Galeri
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFF031636),
              ),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadPhoto(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Color(0xFF031636)),
              title: const Text('Ambil dari Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadPhoto(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Preview Foto Profil Dalam Modal
  void _showProfileImagePreview() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                _profileImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Icon(Icons.person, size: 80, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showImagePickerOptions();
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Ubah Foto'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Proses Memilih & Unggah Foto ke Backend
  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);

    if (pickedFile == null) return;

    setState(() => _isUploading = true);

    try {
      final newUrl = await AuthService().uploadProfilePhoto(pickedFile);

      if (mounted) {
        setState(() {
          // Trik timestamp agar NetworkImage langsung me-refresh tampilan gambar baru
          _profileImageUrl =
              '$newUrl?t=${DateTime.now().millisecondsSinceEpoch}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profil berhasil diperbarui!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Ambil foto dari cache lokal dulu agar tampilan cepat
    final cachedPhoto = prefs.getString('profile_photo_url');
    if (cachedPhoto != null && mounted) {
      setState(() {
        _profileImageUrl =
            '$cachedPhoto?t=${DateTime.now().millisecondsSinceEpoch}';
      });
    }

    // 2. Ambil data terbaru dari API Laravel
    try {
      final userData = await AuthService().getProfile();
      final String? photoUrl = userData['profile_photo_url'];

      if (photoUrl != null && photoUrl.isNotEmpty && mounted) {
        // Update cache lokal
        await prefs.setString('profile_photo_url', photoUrl);

        setState(() {
          _profileImageUrl =
              '$photoUrl?t=${DateTime.now().millisecondsSinceEpoch}';
        });
      }
    } catch (e) {
      print('Gagal load dari API, memakai cache lokal: $e');
    }
  }

  // Konfirmasi & Proses Logout
  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar Aplikasi'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Ya, Keluar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await AuthService().logout();
    if (!mounted) return;

    Navigator.pop(context);
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FF),
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFF031636),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 24),
                _buildAccountSettingsSection(),
                const SizedBox(height: 24),
                _buildPreferencesSection(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _isUploading ? null : _showProfileImagePreview,
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFF8F9FF),
                      width: 4,
                    ),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(_profileImageUrl),
                    ),
                  ),
                  child: _isUploading
                      ? Container(
                          decoration: const BoxDecoration(
                            color: Colors.black38,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF006C49),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFF8F9FF),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sarah Jenkins',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF031636),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Senior Field Representative',
            style: TextStyle(fontSize: 14, color: Color(0xFF44474E)),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildContactChip(Icons.call, '(555) 019-2834'),
              _buildContactChip(Icons.mail, 's.jenkins@fieldauth.com'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF031636), size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF0B1C30),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          child: Text(
            'Account Settings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF031636),
            ),
          ),
        ),
        const SizedBox(height: 8),
        ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildActionCard(
              icon: Icons.edit_square,
              title: 'Edit Profile',
              subtitle: 'Update basic info',
              iconBgColor: const Color(0xFF1A2B4C),
              iconColor: const Color(0xFF8293BA),
            ),
            const SizedBox(height: 8),
            _buildActionCard(
              icon: Icons.badge,
              title: 'Change Name',
              subtitle: 'Legal name updates',
              iconBgColor: const Color(0xFFE5EEFF),
              iconColor: const Color(0xFF0B1C30),
            ),
            const SizedBox(height: 8),
            _buildActionCard(
              icon: Icons.phone_iphone,
              title: 'Change Phone',
              subtitle: 'Primary contact number',
              iconBgColor: const Color(0xFFE5EEFF),
              iconColor: const Color(0xFF0B1C30),
            ),
            const SizedBox(height: 8),
            _buildActionCard(
              icon: Icons.lock_reset,
              title: 'Change Password',
              subtitle: 'Security credentials',
              iconBgColor: const Color(0xFFE5EEFF),
              iconColor: const Color(0xFF0B1C30),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBgColor,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 5,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B1C30),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF44474E),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF44474E)),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          child: Text(
            'App Preferences',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF031636),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              SwitchListTile(
                secondary: const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF44474E),
                ),
                title: const Text(
                  'Push Notifications',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0B1C30),
                  ),
                ),
                value: _pushNotifications,
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFF031636),
                onChanged: (bool value) {
                  setState(() {
                    _pushNotifications = value;
                  });
                },
              ),
              const Divider(height: 1, color: Color(0xFFC5C6CF)),
              SwitchListTile(
                secondary: const Icon(
                  Icons.location_on_outlined,
                  color: Color(0xFF44474E),
                ),
                title: const Text(
                  'Location Services',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0B1C30),
                  ),
                ),
                value: _locationServices,
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFF031636),
                onChanged: (bool value) {
                  setState(() {
                    _locationServices = value;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFDAD6),
              foregroundColor: const Color(0xFF93000A),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout),
            label: const Text(
              'Log Out',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
