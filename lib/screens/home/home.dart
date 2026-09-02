import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../services/visit_service.dart';
import '../../widgets/bottom_nav_widget.dart';
import '../../widgets/home_header.dart';
import '../profile/profile_screen.dart';
import '../retensi/retensi_toko.dart';
import '../sim_harga/sim_harga.dart';
import '../stock/stock_page.dart';
import './detail_kunjungan_page.dart';
import './history_visit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _salesName = 'Sales';
  int _currentIndex = 0;
  String? _activeOutletName;
  String? _activeVisitId;

  // State Data Dinamis
  bool _isLoadingDashboard = true;
  int _visitedToday = 0;
  final int _targetToday = 6;
  int _monthlyTrips = 0;
  List<dynamic> _recentVisits = [];

  final VisitService _visitService = VisitService();
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadSalesName();
    _loadActiveVisit();
    _loadDashboardData();
  }

  Future<void> _loadSalesName() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('user_name');

    if (!mounted || savedName == null || savedName.isEmpty) return;

    setState(() {
      _salesName = savedName;
    });
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

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    setState(() => _isLoadingDashboard = true);

    try {
      final historyList = await _visitService.getVisitHistory();
      if (!mounted) return;

      final visits = historyList ?? [];
      final now = DateTime.now();

      // Hitung kunjungan khusus hari ini berdasarkan check_in_at
      final todayCount = visits.where((v) {
        final checkInStr = v['check_in_at']?.toString();
        if (checkInStr == null) return false;
        final checkInDate = DateTime.tryParse(checkInStr)?.toLocal();
        if (checkInDate == null) return false;

        return checkInDate.year == now.year &&
            checkInDate.month == now.month &&
            checkInDate.day == now.day;
      }).length;

      setState(() {
        _recentVisits = visits;
        _monthlyTrips = visits.length;
        _visitedToday = todayCount;
        _isLoadingDashboard = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingDashboard = false);
      }
    }
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
          setState(() {
            _activeOutletName = null;
            _activeVisitId = null;
          });
          _loadDashboardData();
        },
      ),
    );
  }

  Widget _getPagesBody() {
    switch (_currentIndex) {
      case 0:
        return Column(
          children: [
            Expanded(child: _buildDashboardContent(context)),
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
                    HomeHeader(salesName: _salesName),
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
    if (_isLoadingDashboard) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF003F87)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PerformanceCard(
              visitedToday: _visitedToday,
              targetToday: _targetToday,
              monthlyTrips: _monthlyTrips,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () => setState(() => _currentIndex = 1),
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
            _buildHistoryHeader(context),
            const SizedBox(height: 4),
            _buildHistoryList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryHeader(BuildContext context) {
    return Row(
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
              MaterialPageRoute(builder: (context) => const VisitHistoryPage()),
            ).then((_) => _loadDashboardData());
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
    );
  }

  Widget _buildHistoryList() {
    if (_recentVisits.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFC2C6D4)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'kamu belum mengunjungi toko manapun hari ini',
          style: TextStyle(fontSize: 12, color: Color(0xFF424752)),
        ),
      );
    }

    return Column(
      children: _recentVisits.map((visit) {
        final partner = visit['partner'] as Map<String, dynamic>?;
        final outletName = partner?['name']?.toString() ?? 'Nama Toko';
        final address = partner?['street']?.toString() ?? 'Alamat Toko';

        String time = '00:00';
        if (visit['check_in_at'] != null) {
          final checkIn = DateTime.tryParse(
            visit['check_in_at'].toString(),
          )?.toLocal();
          if (checkIn != null) {
            time =
                "${checkIn.hour.toString().padLeft(2, '0')}:${checkIn.minute.toString().padLeft(2, '0')}";
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DetailKunjunganPage(visit: visit as Map<String, dynamic>),
                ),
              );
            },
            child: _buildHistoryItem(outletName, address, time),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHistoryItem(String outletName, String address, String time) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFC2C6D4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  outletName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003F87),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Color(0xFF424752),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        address,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF424752),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF424752),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget Terpisah: Performance Card
class _PerformanceCard extends StatelessWidget {
  final int visitedToday;
  final int targetToday;
  final int monthlyTrips;

  const _PerformanceCard({
    required this.visitedToday,
    required this.targetToday,
    required this.monthlyTrips,
  });

  @override
  Widget build(BuildContext context) {
    final int diff = visitedToday - targetToday;
    final String achievementText = diff >= 0 ? ' (Tercapai)' : ' (Belum tercapai)';

    return Container(
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
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF424752),
                    fontFamily: 'Inter',
                  ),
                  children: [
                    TextSpan(
                      text:
                          'Target Kunjungan Hari Ini: $visitedToday / $targetToday ',
                    ),
                    TextSpan(
                      text: achievementText,
                      style: TextStyle(
                        color: diff >= 0 ? const Color(0xFF006E25) : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF725400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  diff >= 0 ? '+$diff' : '$diff',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFC842),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: targetToday > 0
                  ? (visitedToday / targetToday).clamp(0.0, 1.0)
                  : 0.0,
              backgroundColor: const Color(0xFF003F87).withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFFABD00),
              ),
              minHeight: 8,
            ),
          ),        
          const SizedBox(height: 12),
          _MonthlyTripTile(monthlyTrips: monthlyTrips),
        ],
      ),
    );
  }
}

// Widget Terpisah: Monthly Trip Tile
class _MonthlyTripTile extends StatelessWidget {
  final int monthlyTrips;

  const _MonthlyTripTile({required this.monthlyTrips});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  border: Border.all(color: const Color(0xFFC2C6D4)),
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
                children: [
                  const Text(
                    'TRIP BULANAN (TOTAL)',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Color(0xFF424752),
                    ),
                  ),
                  Text(
                    '$monthlyTrips Kunjungan',
                    style: const TextStyle(
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
    );
  }
}