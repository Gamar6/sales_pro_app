import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _pushNotifications = true;
  bool _locationServices = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FF),
        elevation: 0,
        scrolledUnderElevation: 1,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFF031636),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 400,
          ), // Opsional: batasi lebar maksimal agar bagus di tablet/HP besar
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Profile Snapshot Bento Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
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
                            image: const DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuCJDXKmFNJE-LN9nd914mMkcouhS8RrXJgEm3c38hDZ51q0TyR3OMC9sAPVRkTqatZMb-Y6s0AtuMRAMBBeK4W02tT8PoHx8O6ePV9vLYNoM4ZFUzH-adcweUPKXoZXM4aJj3-VWAJZB4V5LoTm7EZb7ALTuwbBryDXaPHOHr3miJ09CzxKxpz-9PnRZr-UJbbPzI9j37KDvyMfV_qR-B3GcoCg_pVRwOCGJWNvngyNaRk67_61gd3L',
                              ),
                            ),
                          ),
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
                        _buildContactChip(
                          Icons.mail,
                          's.jenkins@fieldauth.com',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Account Settings Section
              _buildAccountSettingsSection(),
              const SizedBox(height: 24),

              // Preferences Section
              _buildPreferencesSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
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
  }) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
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
                color: Colors.black.withOpacity(0.03),
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
                activeColor: Colors.white,
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
                activeColor: Colors.white,
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
            onPressed: () async {
              // 1. Tampilkan konfirmasi dialog (Best Practice Industrial UX)
              final bool? confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Keluar Aplikasi'),
                  content: const Text('Apakah Anda yakin ingin keluar?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Ya, Keluar',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm != true) return;

              // 2. Tampilkan Loading Indicator
              if (!context.mounted) return;
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );

              // 3. Eksekusi Service Logout
              final authService = AuthService();
              await authService.logout();

              // 4. Tutup Dialog Loading & Redirect ke Halaman Login
              if (!context.mounted) return;
              Navigator.pop(context); // Tutup loading

              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login', // Pastikan route login sudah terdaftar
                (route) => false, // Menghapus seluruh stack navigasi sebelumnya
              );
            },
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
