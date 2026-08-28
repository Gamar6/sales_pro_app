import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/partner_model.dart';
import '../../services/api_service.dart';
import '../../services/location_service.dart';
import '../../services/store_visit_service.dart';
import '../home/report.dart';

class StoreReviewPage extends StatefulWidget {
  // Callback untuk menginfokan nama toko ke MainScreen
  final Function(String outletName, String visitId)? onVisitOutlet;

  const StoreReviewPage({Key? key, this.onVisitOutlet}) : super(key: key);

  @override
  State<StoreReviewPage> createState() => _StoreReviewPageState();
}

class _StoreReviewPageState extends State<StoreReviewPage> {
  // 1. Service Instance
  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();

  // 2. State Management
  List<Partner> _partners = [];
  List<Partner> _filteredPartners = [];
  List<String> _availableCities = ['Semua'];
  Position? _currentPosition;
  bool _isLoading = true;
  String _errorMessage = '';

  // 3. State Pencarian, Filter, & Sorting
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'Semua';
  String _selectedCity = 'Semua';
  String _selectedSort = 'Default';

  @override
  void initState() {
    super.initState();
    _loadPartnersData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPartnersData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final position = await _locationService.getCurrentLocation();
      final partners = await _apiService.fetchPartners();

      final cities = [
        'Semua',
        ...partners.map((e) => e.kota).where((c) => c.isNotEmpty).toSet(),
      ];

      if (!mounted) return;
      setState(() {
        _currentPosition = position;
        _partners = partners;
        _filteredPartners = partners;
        _availableCities = cities;
        _isLoading = false;
      });
      _applyFilterAndSort();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilterAndSort() {
    List<Partner> result = List.from(_partners);

    // 1. Filter by Search Query
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((partner) {
        return partner.partnerName.toLowerCase().contains(query) ||
            partner.alamat.toLowerCase().contains(query) ||
            partner.kota.toLowerCase().contains(query);
      }).toList();
    }

    // 2. Filter by Status
    if (_selectedStatus != 'Semua') {
      result = result
          .where(
            (partner) =>
                partner.retensiStatus.toUpperCase() ==
                _selectedStatus.toUpperCase(),
          )
          .toList();
    }

    // 3. Filter by City
    if (_selectedCity != 'Semua') {
      result = result
          .where(
            (partner) =>
                partner.kota.toLowerCase() == _selectedCity.toLowerCase(),
          )
          .toList();
    }

    // 4. Sorting
    switch (_selectedSort) {
      case 'Terdekat':
        result.sort((a, b) {
          final distA = _locationService.calculateDistance(
            _currentPosition?.latitude,
            _currentPosition?.longitude,
            a.latitude,
            a.longitude,
          );
          final distB = _locationService.calculateDistance(
            _currentPosition?.latitude,
            _currentPosition?.longitude,
            b.latitude,
            b.longitude,
          );
          return distA.compareTo(distB);
        });
        break;
      case 'Kunjungan Terlama':
        result.sort((a, b) => b.daysSince.compareTo(a.daysSince));
        break;
      case 'Nama A-Z':
        result.sort((a, b) => a.partnerName.compareTo(b.partnerName));
        break;
    }

    setState(() => _filteredPartners = result);
  }

  void _showSelectionBottomSheet({
    required BuildContext context,
    required String title,
    required List<String> options,
    required String selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxHeight: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    return ListTile(
                      title: Text(option),
                      trailing: selectedValue == option
                          ? const Icon(Icons.check, color: Colors.blue)
                          : null,
                      onTap: () {
                        onSelected(option);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: _buildAppBar(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildMapHeader()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [_buildFilterRow(), const SizedBox(height: 16)],
              ),
            ),
          ),
          _buildSliverContentArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF8F9FF),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Color(0xFF031636)),
        onPressed: () {},
      ),
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (_) => _applyFilterAndSort(),
              decoration: const InputDecoration(
                hintText: 'Cari toko atau alamat...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Color(0xFF75777F), fontSize: 16),
              ),
              style: const TextStyle(color: Color(0xFF031636), fontSize: 16),
            )
          : const Text(
              'Retensi Toko',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF031636),
              ),
            ),
      actions: [
        IconButton(
          icon: Icon(
            _isSearching ? Icons.close : Icons.search,
            color: const Color(0xFF031636),
          ),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                _applyFilterAndSort();
              }
            });
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: const Color(0xFFC5C6CF), height: 1.0),
      ),
    );
  }

  Widget _buildMapHeader() {
    return Container(
      height: 160,
      decoration: const BoxDecoration(color: Color(0xFFCBDBF5)),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  const Color(0xFFF8F9FF),
                  const Color(0xFFF8F9FF).withOpacity(0),
                ],
              ),
            ),
          ),
          const Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WILAYAH AKTIF',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF44474E),
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Data Semua Wilayah',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF031636),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterButton(
            label: 'Status: $_selectedStatus',
            icon: Icons.expand_more,
            onPressed: () => _showSelectionBottomSheet(
              context: context,
              title: 'Filter Berdasarkan Status',
              options: [
                'Semua',
                'ACTIVE',
                'WARNING',
                'RED FLAG',
                'COLD',
                'DEAD ZONE',
              ],
              selectedValue: _selectedStatus,
              onSelected: (val) {
                setState(() => _selectedStatus = val);
                _applyFilterAndSort();
              },
            ),
          ),
          const SizedBox(width: 8),
          _filterButton(
            label: 'Kota: $_selectedCity',
            icon: Icons.expand_more,
            onPressed: () => _showSelectionBottomSheet(
              context: context,
              title: 'Filter Berdasarkan Kota',
              options: _availableCities,
              selectedValue: _selectedCity,
              onSelected: (val) {
                setState(() => _selectedCity = val);
                _applyFilterAndSort();
              },
            ),
          ),
          const SizedBox(width: 8),
          _filterButton(
            label: 'Urut: $_selectedSort',
            icon: Icons.sort,
            onPressed: () => _showSelectionBottomSheet(
              context: context,
              title: 'Urutkan Berdasarkan',
              options: ['Default', 'Terdekat', 'Kunjungan Terlama', 'Nama A-Z'],
              selectedValue: _selectedSort,
              onSelected: (val) {
                setState(() => _selectedSort = val);
                _applyFilterAndSort();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0B1C30),
        side: const BorderSide(color: Color(0xFFC5C6CF)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: const Size(0, 42),
      ),
      icon: Text(label),
      label: Icon(icon, size: 18),
    );
  }

  Widget _buildSliverContentArea() {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return SliverFillRemaining(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, color: Colors.red[300], size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPartnersData,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredPartners.isEmpty) {
      return const SliverFillRemaining(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(
            child: Text(
              'Tidak ada data toko yang cocok.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final partner = _filteredPartners[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: PartnerCard(
              partner: partner,
              distanceText: _locationService.calculateDistanceString(
                _currentPosition,
                partner.latitude,
                partner.longitude,
              ),
              onVisit: () async {
                final result = await StoreVisitService().claimStore(
                  odooPartnerId: partner.partnerId,
                );

                if (!context.mounted) return;

                if (result['success'] == true) {
                  final visitId = result['visit_id']?.toString();
                  if (visitId == null || visitId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('ID Kunjungan tidak ditemukan.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  widget.onVisitOutlet?.call(partner.partnerName, visitId);

                  final saved = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VisitFormPage(
                        outletName: partner.partnerName,
                        visitId: visitId,
                      ),
                    ),
                  );

                  if (saved == true && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Kunjungan selesai.')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message'] ?? 'Gagal klaim toko'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          );
        }, childCount: _filteredPartners.length),
      ),
    );
  }
}

// ============================================================================
// WIDGET CONFIG & PARTNER CARD
// ============================================================================

class StatusConfig {
  final Color borderColor;
  final Color chipBgColor;
  final Color chipTextColor;
  final IconData chipIcon;

  const StatusConfig(
    this.borderColor,
    this.chipBgColor,
    this.chipTextColor,
    this.chipIcon,
  );

  static StatusConfig getTheme(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return const StatusConfig(
          Color(0xFF006C49),
          Color(0xFF6CF8BB),
          Color(0xFF00714D),
          Icons.check_circle,
        );
      case 'WARNING':
        return const StatusConfig(
          Color(0xFFF29900),
          Color(0xFFFFDDB8),
          Color(0xFF653E00),
          Icons.schedule,
        );
      case 'RED FLAG':
        return const StatusConfig(
          Color(0xFFBA1A1A),
          Color(0xFFFFDAD6),
          Color(0xFF93000A),
          Icons.flag,
        );
      case 'COLD':
        return const StatusConfig(
          Color(0xFF8E9099),
          Color(0xFFE3E2E6),
          Color(0xFF44474E),
          Icons.ac_unit,
        );
      case 'DEAD ZONE':
        return const StatusConfig(
          Color(0xFF44474E),
          Color(0xFFC4C6D0),
          Color(0xFF1A1C1E),
          Icons.block,
        );
      default:
        return const StatusConfig(
          Color(0xFFC5C6CF),
          Color(0xFFF3F4F9),
          Color(0xFF44474E),
          Icons.help_outline,
        );
    }
  }
}

class PartnerCard extends StatelessWidget {
  final Partner partner;
  final String distanceText;
  final VoidCallback? onVisit;

  const PartnerCard({
    Key? key,
    required this.partner,
    required this.distanceText,
    this.onVisit,
  }) : super(key: key);

  Future<void> _openGoogleMaps(BuildContext context) async {
    if (partner.latitude == null || partner.longitude == null) return;

    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${partner.latitude},${partner.longitude}',
    );
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          _showSnackBar(context, 'Tidak dapat membuka Google Maps');
        }
      }
    } catch (e) {
      debugPrint('Error launching maps: $e');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = StatusConfig.getTheme(partner.retensiStatus);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC5C6CF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 6, color: theme.borderColor),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0).copyWith(left: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              partner.partnerName,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0B1C30),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${partner.alamat}, ${partner.kota}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: Color(0xFF44474E),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.chipBgColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: theme.chipTextColor.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              theme.chipIcon,
                              size: 14,
                              color: theme.chipTextColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              partner.retensiStatus.toUpperCase(),
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: theme.chipTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.history,
                        size: 14,
                        color: Color(0xFF75777F),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Kunjungan terakhir: ${partner.daysSince} hari lalu',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Color(0xFF75777F),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Color(0xFFDCE9FF), width: 1.0),
                      ),
                    ),
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.near_me,
                                size: 12,
                                color: Color(0xFF75777F),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Jarak: $distanceText',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    color: Color(0xFF75777F),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 40,
                              width: 40,
                              child: OutlinedButton(
                                onPressed: () => _openGoogleMaps(context),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  side: const BorderSide(
                                    color: Color(0xFF031636),
                                    width: 2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.route,
                                  size: 20,
                                  color: Color(0xFF031636),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 40,
                              child: ElevatedButton(
                                onPressed: onVisit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF031636),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                ),
                                child: const Text(
                                  'Kunjungi',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
