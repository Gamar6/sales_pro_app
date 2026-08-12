import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/store_model.dart';
import '../services/api_services.dart';
import 'completion_report_screen.dart';
import '../widgets/bottom_nav_widget.dart';

class StoreRouteScreen extends StatefulWidget {
  const StoreRouteScreen({Key? key}) : super(key: key);

  @override
  State<StoreRouteScreen> createState() => _StoreRouteScreenState();
}

class _StoreRouteScreenState extends State<StoreRouteScreen> {
  String _selectedArea = 'Semua Area';
  List<String> _areas = ['Semua Area'];
  List<Store> _stores = [];
  bool _isLoading = true;

  // State untuk pencarian & view mode
  String _searchQuery = '';
  bool _isMapView = false;

  // Warna sesuai Tailwind Palette HTML
  static const Color primaryNavy = Color(0xFF1C467F);
  static const Color primaryDark = Color(0xFF031636);
  static const Color activeBannerBg = Color(0xFF70F5A8);
  static const Color bgSurface = Color(0xFFF8F9FF);
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color borderOutline = Color(0xFFC5C6CF);
  static const Color textOnSurfaceVariant = Color(0xFF44474E);
  static const Color badgeOrange = Color(0xFFF48110);

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  Future<void> _loadStores() async {
    setState(() => _isLoading = true);

    final result = await ApiService.fetchStores();
    if (result['success'] == true) {
      List<Store> loadedStores = result['data'];

      Set<String> uniqueAreas = {'Semua Area'};
      for (var store in loadedStores) {
        if (store.area.isNotEmpty) {
          uniqueAreas.add(store.area);
        }
      }

      setState(() {
        _stores = loadedStores;
        _areas = uniqueAreas.toList();
        if (!_areas.contains(_selectedArea)) {
          _selectedArea = 'Semua Area';
        }
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openMap(double latitude, double longitude) async {
    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filtering toko berdasarkan Area dan Search Query
    final filteredStores = _stores.where((store) {
      final matchesArea =
          _selectedArea == 'Semua Area' || store.area == _selectedArea;
      final matchesSearch =
          store.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          store.address.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesArea && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: bgSurface,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: primaryNavy),
          onPressed: () {},
        ),
        title: const Text(
          'Field Sales Pro',
          style: TextStyle(
            color: primaryNavy,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: primaryNavy),
            onPressed: _loadStores, // Tap untuk refresh data
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Search & Filter Controls Panel
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    // Search Bar Input
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: borderOutline.withOpacity(0.5),
                          ),
                        ),
                        child: TextField(
                          onChanged: (val) =>
                              setState(() => _searchQuery = val),
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(
                            hintText: 'Search store name or address...',
                            hintStyle: TextStyle(
                              color: textOnSurfaceVariant,
                              fontSize: 13,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: textOnSurfaceVariant,
                              size: 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Dropdown Area Filter
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: borderOutline.withOpacity(0.5),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedArea,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: primaryDark,
                          ),
                          style: const TextStyle(
                            color: primaryDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          items: _areas.map((area) {
                            return DropdownMenuItem(
                              value: area,
                              child: Text(area),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null)
                              setState(() => _selectedArea = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // View Toggle Switch (List View vs Map Route)
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _isMapView = false),
                          child: Container(
                            height: 38,
                            decoration: BoxDecoration(
                              color: !_isMapView
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: !_isMapView
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.list,
                                  size: 18,
                                  color: !_isMapView
                                      ? primaryNavy
                                      : textOnSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'List View',
                                  style: TextStyle(
                                    fontWeight: !_isMapView
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: !_isMapView
                                        ? primaryNavy
                                        : textOnSurfaceVariant,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _isMapView = true),
                          child: Container(
                            height: 38,
                            decoration: BoxDecoration(
                              color: _isMapView
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: _isMapView
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.map_outlined,
                                  size: 18,
                                  color: _isMapView
                                      ? primaryNavy
                                      : textOnSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Map Route',
                                  style: TextStyle(
                                    fontWeight: _isMapView
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: _isMapView
                                        ? primaryNavy
                                        : textOnSurfaceVariant,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Active Visit Sticky Banner
          Container(
            color: activeBannerBg,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: primaryNavy, size: 22),
                    const SizedBox(width: 8),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          color: primaryNavy,
                          fontSize: 13,
                          height: 1.2,
                        ),
                        children: [
                          TextSpan(text: 'Active Visit:\n'),
                          TextSpan(
                            text: 'Resto Jaya Meat (Bekasi)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryNavy,
                    foregroundColor: Colors.white,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  // PINDAH KE SINI: Navigasi ke CompletionReportScreen
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CompletionReportScreen(
                          storeName: 'Resto Jaya Meat (Bekasi)',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Selesaikan',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          // 3. Main Content / List Toko
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: primaryNavy),
                  )
                : filteredStores.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada toko ditemukan',
                      style: TextStyle(color: textOnSurfaceVariant),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredStores.length,
                    itemBuilder: (context, index) {
                      final store = filteredStores[index];
                      return _buildStoreCard(store);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavWidget(
        currentIndex: 0,
        onTap: (index) {
          if (index != 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Menu indeks $index diklik')),
            );
          }
        },
      ),
    );
  }

  // Widget Pembuat Card Toko Sesuai Status HTML
  Widget _buildStoreCard(Store store) {
    final String status = (store.status ?? '').toLowerCase();
    final bool isCompleted =
        status.contains('sudah') || status.contains('completed');
    final bool isOccupied =
        status.contains('sedang') || status.contains('occupied');

    // 1. Toko Sudah Dikunjungi (Completed Card)
    if (isCompleted) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderOutline.withOpacity(0.4),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: primaryNavy.withOpacity(0.7),
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Completed at ${store.distanceLabel.isNotEmpty ? store.distanceLabel : "10:30 AM"}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: textOnSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF006C49).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 14, color: Color(0xFF006C49)),
                  SizedBox(width: 4),
                  Text(
                    'Sudah Dikunjungi',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF006C49),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 2. Toko Sedang Dikunjungi / Disabled (Occupied Card)
    if (isOccupied) {
      return Opacity(
        opacity: 0.75,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderOutline.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryNavy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.alt_route,
                              size: 16,
                              color: textOnSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${store.address} • ${store.distanceLabel}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: textOnSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF402600).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock, size: 14, color: Color(0xFFCD8300)),
                        SizedBox(width: 4),
                        Text(
                          'Sedang Dikunjungi',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFCD8300),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Opacity(
                opacity: 0.5,
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryNavy,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: null, // Disabled
                          child: const Text('Mulai Kunjungi'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        border: Border.all(color: borderOutline, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.map, color: textOnSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Toko Belum Dikunjungi (Unvisited Card - Default Action)
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderOutline.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.alt_route,
                          size: 16,
                          color: textOnSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${store.address} • ${store.distanceLabel.isNotEmpty ? store.distanceLabel : store.area}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: textOnSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeOrange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Belum Dikunjungi',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryNavy,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    // DISESUAIKAN: Aksi Mulai Kunjungi (Misal: trigger status / SnackBar)
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Kunjungan ke ${store.name} dimulai'),
                        ),
                      );
                    },
                    child: const Text(
                      'Mulai Kunjungi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () => _openMap(store.latitude, store.longitude),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    border: Border.all(color: borderOutline, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.map, color: textOnSurfaceVariant),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}