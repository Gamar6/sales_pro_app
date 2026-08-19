import 'package:flutter/material.dart';
import '../../widgets/bottom_nav_widget.dart';
import './history_visit.dart';
import './report.dart';
import '../retensi/retensi_toko.dart';
import '../sim_harga/sim_harga.dart';
import '../stock/stock_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // Default di Home
  final List<Widget> _pages = [
    // Indeks 0: Home (Dashboard kamu)
    // Karena dashboard butuh struktur Column khusus (dengan banner sticky),
    // kita bungkus logikanya atau buat method terpisah.
    const SizedBox.shrink(), // Placeholder, nanti ditangani kondisi di body
    // Indeks 1: Halaman Report (sesuai import './report.dart')
    // const ReportPage(), // Sesuaikan dengan nama kelas di report.dart kamu
    // Indeks 2: Halaman History Visit (sesuai import './history_visit.dart')
    const VisitHistoryPage(),

    // Indeks 3 & 4 (jika ada, sesuaikan dengan total menu di BottomNavWidget kamu)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFF),
      // AppBar hanya muncul di indeks 0 (Home)
      appBar: _currentIndex == 0 ? _buildAppBar() : null,

      // Mengatur halaman yang tampil berdasarkan _currentIndex
      body: _getPagesBody(),

      bottomNavigationBar: BottomNavWidget(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  // Helper method untuk menentukan body berdasarkan index
  Widget _getPagesBody() {
    switch (_currentIndex) {
      case 0:
        return Column(
          children: [
            Expanded(child: _buildDashboardContent(context)),
            _buildActiveVisitBanner(),
          ],
        );
      case 1:
        return const StoreReviewPage(); 
      case 2:
      return const StockPage();
      case 3:
        return const PriceSimulationPage();
      default:
        return Center(child: Text("Halaman Indeks $_currentIndex"));
    }
  }

  @override
  Widget buildDashboardContent(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFF),
      appBar: _currentIndex == 0 ? _buildAppBar() : null,

      body: _currentIndex == 0
          ? Column(
              children: [
                // Konten utama scrollable
                Expanded(child: _buildDashboardContent(context)),
                // Banner Kunjungan Aktif (Sticky tepat di atas BottomNav)
                _buildActiveVisitBanner(),
              ],
            )
          : Center(child: Text("Halaman Indeks $_currentIndex")),

      bottomNavigationBar: BottomNavWidget(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildActiveVisitBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFC2C6D4),
            width: 1,
          ), // Garis pembatas atas
          left: BorderSide(color: Color(0xFF003F87), width: 4),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'KUNJUNGAN AKTIF',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003F87),
                ),
              ),
              const Text(
                'Ahmad Frozen Food',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VisitFormPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003F87),
            ),
            child: const Text('Selesai', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56.0),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF6FAFF),
          border: Border(
            bottom: BorderSide(color: Color(0xFFC2C6D4), width: 1.0),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFC2C6D4)),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuBiDbZGtQo3RkzpMbtd30QF_Oj7cyw1o-wUuBFyHet9BZZ2hpGCKhvyJA5wCk3pLGjmV6CYWSEUQ1-9UFe4NCajq8bhuaoRuHSXaxNQJ7P26IdDXE37C-D24B6GwD_L7LVCPQ24ipR--SbpEDA7NOkqEg9bLUmfh13yABWrvoiTg4AbiboQeLL4M9poM0UM5d6Gyh7pLFoXCW-sVq9UgN0-096bkk0y8HmO6A6ajFbQOZPYlLxPmkXe',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Selamat Pagi, [Nama Sales]!',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF424752),
                          ),
                        ),
                        Text(
                          'Selasa, 18 Agustus 2026',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF424752),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Text(
                  'Fiva Food',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF003F87),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- KONTEN DASHBOARD BIASA (TANPA STACK MELAYANG) ---
  Widget _buildDashboardContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Performance Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFC2C6D4)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RINGKASAN PERFORMA HARI INI',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: Color(0xFF141D23),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF424752),
                          fontFamily: 'Inter',
                        ),
                        children: [
                          TextSpan(text: 'Target Kunjungan Hari Ini: 8 / 6 '),
                          TextSpan(
                            text: '(TERCAPAI +2)',
                            style: TextStyle(
                              color: Color(0xFF006E25),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF725400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '+2',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFC842),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: SizedBox(
                    height: 8,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 75,
                          child: Container(color: const Color(0xFFFABD00)),
                        ),
                        Expanded(
                          flex: 25,
                          child: Container(color: const Color(0xFF003F87)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Kerja Bagus!... Terus tingkatkan kunjungan Anda.',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF424752),
                  ),
                ),
                const SizedBox(height: 12),
                // Integrated Tile (Trip Bulanan)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6EFF8),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFC2C6D4)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: const Color(0xFFC2C6D4),
                              ),
                            ),
                            child: const Icon(
                              Icons.route,
                              color: Color(0xFF003F87),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'TRIP BULANAN (TOTAL)',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: Color(0xFF424752),
                                ),
                              ),
                              Text(
                                '112 Kunjungan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF141D23),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Icon(Icons.chevron_right, color: Color(0xFF727784)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 2. Main Action Button
          SizedBox(
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003F87),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 1,
              ),
              icon: const Icon(Icons.storefront, size: 18),
              label: const Text(
                'PILIH TOKO / BUKA TAB RETENSI',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 4. Visit History Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'RIWAYAT KUNJUNGAN',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Color(0xFF141D23),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VisitHistoryPage(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                ),
                child: const Text(
                  'VIEW ALL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003F87),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _buildHistoryItem('Toko Barokah', 'Jl. Jend. Sudirman', '11:30'),
          const SizedBox(height: 4),
          _buildHistoryItem('Agen Nugget Jaya', 'Pasar Induk', '10:45'),
        ],
      ),
    );
  }

  // Widget pendukung untuk item Riwayat Kunjungan
  Widget _buildHistoryItem(String title, String subtitle, String time) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFC2C6D4)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF006E25),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF141D23),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF424752),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF424752),
            ),
          ),
        ],
      ),
    );
  }
}
