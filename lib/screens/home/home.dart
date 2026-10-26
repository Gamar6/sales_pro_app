import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../services/visit_service.dart';
import '../../widgets/bottom_nav_widget.dart';
import '../../widgets/home_header.dart';
import '../../models/stock_model.dart';
import '../../services/stock_service.dart';
import '../profile/profile_screen.dart';
import '../retensi/retensi_toko.dart';
import '../sim_harga/sim_harga.dart';
import '../stock/stock_page.dart';
import './detail_kunjungan_page.dart';
import './history_visit.dart';
import '../../services/auth_service.dart';
import '../../widgets/async_state_widgets.dart';

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

  String _profileImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBiDbZGtQo3RkzpMbtd30QF_Oj7cyw1o-wUuBFyHet9BZZ2hpGCKhvyJA5wCk3pLGjmV6CYWSEUQ1-9UFe4NCajq8bhuaoRuHSXaxNQJ7P26IdDXE37C-D24B6GwD_L7LVCPQ24ipR--SbpEDA7NOkqEg9bLUmfh13yABWrvoiTg4AbiboQeLL4M9poM0UM5d6Gyh7pLFoXCW-sVq9UgN0-096bkk0y8HmO6A6ajFbQOZPYlLxPmkXe';

  // State Data Dinamis
  bool _isLoadingDashboard = true;
  bool _isRefreshingDashboard = false;
  bool _isDashboardOffline = false;
  bool _hasDashboardSnapshot = false;
  String? _dashboardError;
  int _visitedToday = 0;
  final int _targetToday = 5;
  int _monthlyTrips = 0;
  List<dynamic> _recentVisits = [];

  List<StockProduct> _stockProducts = [];
  bool _isLoadingStock = false;

  final VisitService _visitService = VisitService();
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrapHomeData();
    });
  }

  Future<void> _bootstrapHomeData() async {
    await Future.wait([
      _loadSalesName(),
      _loadUserProfile(),
      _loadActiveVisit(),
      _loadDashboardData(),
    ], eagerError: false);
  }

  void _handleNavigationTap(int index) {
    setState(() => _currentIndex = index);

    if (index == 3 && _stockProducts.isEmpty && !_isLoadingStock) {
      _loadStockProducts();
    }
  }

  Future<void> _loadSalesName() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('user_name');

    if (!mounted || savedName == null || savedName.isEmpty) return;

    setState(() {
      _salesName = savedName;
    });
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
        await prefs.setString('profile_photo_url', photoUrl);

        setState(() {
          _profileImageUrl =
              '$photoUrl?t=${DateTime.now().millisecondsSinceEpoch}';
        });
      }
    } catch (e) {
      debugPrint('Gagal load foto dari API, memakai cache lokal: $e');
    }
  }

  Future<void> _loadActiveVisit() async {
    try {
      final activeVisit = await _visitService.getActiveVisitDetails();

      if (!mounted || activeVisit == null) return;

      var outletName = activeVisit['outlet_name']?.toString();

      if (outletName == null || outletName.isEmpty) {
        final partnerId = int.tryParse(
          activeVisit['odoo_partner_id']?.toString() ?? '',
        );

        if (partnerId != null) {
          try {
            final partners = await _apiService.fetchPartners();

            for (final partner in partners) {
              if (partner.partnerId == partnerId) {
                outletName = partner.partnerName;
                break;
              }
            }
          } catch (e) {
            debugPrint('Gagal memuat nama outlet: $e');
          }
        }
      }

      if (!mounted || outletName == null || outletName.isEmpty) return;

      setState(() {
        _activeVisitId = activeVisit['visit_id']?.toString();
        _activeOutletName = outletName;
      });
    } catch (e) {
      debugPrint('Gagal memuat kunjungan aktif: $e');
    }
  }

  Future<void> _loadDashboardData() async {
    if (!mounted || _isRefreshingDashboard) return;
    setState(() {
      _isLoadingDashboard = !_hasDashboardSnapshot;
      _isRefreshingDashboard = true;
      _dashboardError = null;
    });

    try {
      final cachedVisits = await _visitService.getCachedVisitHistory();
      if (mounted && cachedVisits != null) {
        _applyDashboardVisits(cachedVisits);
        setState(() {
          _isLoadingDashboard = false;
          _isDashboardOffline = true;
          _hasDashboardSnapshot = true;
        });
      }
    } catch (error) {
      debugPrint('Gagal membaca cache riwayat dashboard: $error');
    }

    try {
      final historyList = await _visitService.refreshVisitHistory();
      if (!mounted) return;
      _applyDashboardVisits(historyList);
      setState(() {
        _isLoadingDashboard = false;
        _isDashboardOffline = false;
        _hasDashboardSnapshot = true;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingDashboard = false;
          _isDashboardOffline = _hasDashboardSnapshot;
          _dashboardError = _hasDashboardSnapshot ? null : e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshingDashboard = false);
      }
    }
  }

  void _applyDashboardVisits(List<dynamic> visits) {
    final now = DateTime.now();
    final completedVisits = visits.where((visit) {
      return visit is Map && visit['status']?.toString() == 'COMPLETED';
    }).toList();

    DateTime? visitDate(dynamic visit) {
      if (visit is! Map) return null;
      final checkIn = visit['check_in_at']?.toString();
      if (checkIn == null) return null;
      return DateTime.tryParse(checkIn)?.toLocal();
    }

    final monthlyVisits = completedVisits.where((visit) {
      final date = visitDate(visit);
      return date != null && date.year == now.year && date.month == now.month;
    }).toList();
    final todayVisits = monthlyVisits.where((visit) {
      final date = visitDate(visit);
      return date != null && date.day == now.day;
    }).toList();

    setState(() {
      _recentVisits = todayVisits.take(5).toList();
      _monthlyTrips = monthlyVisits.length;
      _visitedToday = todayVisits.length;
    });
  }

  Future<void> _loadStockProducts() async {
    if (_isLoadingStock) return;

    setState(() {
      _isLoadingStock = true;
    });

    try {
      final cachedStocks = await StockService.getCachedStocks();
      if (mounted && cachedStocks != null) {
        final cachedData = cachedStocks['data'] as List? ?? const [];
        setState(() {
          _stockProducts = cachedData
              .map((item) => StockProduct.fromJson(item))
              .toList();
        });
      }

      final result = await StockService.fetchStocks();

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          _stockProducts = (result['data'] as List)
              .map((item) => StockProduct.fromJson(item))
              .toList();

          _isLoadingStock = false;
        });
      } else {
        setState(() {
          _isLoadingStock = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingStock = false;
      });

      debugPrint('Gagal mengambil stock: $e');
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
        onTap: _handleNavigationTap,
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

  Widget _buildDashboardSkeleton() {
    return Column(
      children: [
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }

  Widget _getPagesBody() {
    switch (_currentIndex) {
      case 0:
        return Column(
          children: [Expanded(child: _buildDashboardContent(context))],
        );
      case 1:
        return StoreReviewPage(
          onVisitOutlet: (selectedOutletName, visitId) {
            setState(() {
              _activeOutletName = selectedOutletName;
              _activeVisitId = visitId;
            });
          },
          onVisitEnded: () {
            setState(() {
              _activeOutletName = null;
              _activeVisitId = null;
            });
            _loadDashboardData();
          },
        );
      case 2:
        return const StockPage();
      case 3:
        return PriceSimulationPage(products: _stockProducts);
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
                        image: DecorationImage(
                          // Menggunakan variabel _profileImageUrl yang sudah di-load
                          image: NetworkImage(_profileImageUrl),
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
    if (_isLoadingDashboard && !_hasDashboardSnapshot) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [_buildDashboardSkeleton()]),
      );
    }

    if (_dashboardError != null && !_hasDashboardSnapshot) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          AppErrorState(
            title: 'Gagal memuat ringkasan',
            message: _dashboardError!,
            onRetry: _loadDashboardData,
          ),
        ],
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
            if (_isDashboardOffline)
              AppOfflineBanner(
                message: 'Menampilkan data offline / sinyal lemah',
                onRetry: _loadDashboardData,
                isRetrying: _isRefreshingDashboard,
              ),
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

// Performance Card
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
    final String achievementText = diff >= 0
        ? ' (Tercapai)'
        : ' (Belum tercapai)';

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
              backgroundColor: const Color(0xFF003F87).withValues(alpha: 0.2),
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

// Monthly Trip Tile
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
