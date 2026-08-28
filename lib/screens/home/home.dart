import 'package:flutter/material.dart';
import '../../widgets/bottom_nav_widget.dart';
import './history_visit.dart';
import '../retensi/retensi_toko.dart';
import '../sim_harga/sim_harga.dart';
import '../stock/stock_page.dart';
import '../profile/profile_screen.dart';
import '../../services/visit_service.dart';
import '../../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String? _activeOutletName;
  String? _activeVisitId;
  final VisitService _visitService = VisitService();
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadActiveVisit();
  }

  Future<void> _loadActiveVisit() async {
    final activeVisit = await _visitService.getActiveVisitDetails();
    if (!mounted || activeVisit == null) return;

    var outletName = activeVisit['outlet_name']?.toString();
    if (outletName == null || outletName.isEmpty) {
      final partnerId = int.tryParse(
        activeVisit['odoo_partner_id']?.toString() ?? '',
      );
      if (partnerId != null) {
        final partners = await _apiService.fetchPartners();
        for (final partner in partners) {
          if (partner.partnerId == partnerId) {
            outletName = partner.partnerName;
            break;
          }
        }
      }
    }

    if (!mounted || outletName == null || outletName.isEmpty) return;

    setState(() {
      _activeVisitId = activeVisit['visit_id']?.toString();
      _activeOutletName = outletName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFF),
      appBar: _currentIndex == 0 ? _buildAppBar() : null,
      body: _getPagesBody(),
      bottomNavigationBar: BottomNavWidget(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        activeOutletName: _activeOutletName,
        activeVisitId: _activeVisitId,
        onFinishVisit: () {
          // TUTUP STICKY BANNER (Tanpa pindah halaman)
          setState(() {
            _activeOutletName = null;
            _activeVisitId = null;
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
            _buildActiveVisitBanner(), // Banner di halaman Home
          ],
        );
      case 1:
        return StoreReviewPage(
          onVisitOutlet: (selectedOutletName, visitId) {
            setState(() {
              _activeOutletName = selectedOutletName;
              _activeVisitId = visitId;
            });
          },
        );
      case 2:
        return const StockPage();
      case 3:
        return const PriceSimulationPage();
      case 4:
        return const ProfileScreen();
      default:
        return Center(child: Text("Halaman Indeks $_currentIndex"));
    }
  }

  // WIDGET STICKY BANNER DI HALAMAN HOME
  Widget _buildActiveVisitBanner() {
    if (_activeOutletName == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFFFFF3E0),
      child: Row(
        children: [
          const Icon(Icons.storefront, color: Color(0xFFE65100), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Kunjungan Aktif: $_activeOutletName',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE65100),
              ),
            ),
          ),
          InkWell(
            onTap: () => setState(() {
              _activeOutletName = null;
              _activeVisitId = null;
            }),
            child: const Icon(Icons.close, size: 18, color: Color(0xFFE65100)),
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
                          'Selamat Pagi, Sales!',
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
              onPressed: () {
                setState(() {
                  _currentIndex = 1; // Pindah ke Tab Retensi Toko
                });
              },
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

          // 3. Visit History Section
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
