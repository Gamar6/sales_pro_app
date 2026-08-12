import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

void main() {
  runApp(const FieldSalesApp());
}

class FieldSalesApp extends StatelessWidget {
  const FieldSalesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Store Route List',
      theme: ThemeData(
        primaryColor: const Color(0xFF031636),
        scaffoldBackgroundColor: const Color(0xFFF8F9FF),
        fontFamily: 'Inter',
      ),
      home: const StoreRouteScreen(),
    );
  }
}

class StoreRouteScreen extends StatefulWidget {
  const StoreRouteScreen({Key? key}) : super(key: key);

  @override
  State<StoreRouteScreen> createState() => _StoreRouteScreenState();
}

class _StoreRouteScreenState extends State<StoreRouteScreen> {
  // State untuk Filter Area
  String _selectedArea = 'Semua Area';
  List<String> _areas = ['Semua Area']; // Akan diisi otomatis dari database

  // State untuk Data Toko & Loading
  List<dynamic> _stores = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _determinePositionAndFetchStores();
  }

  // Fungsi untuk mendapatkan GPS perangkat (Emulator / HP Fisik)
  Future<void> _determinePositionAndFetchStores() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Cek apakah GPS aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Jika GPS mati, fallback pakai koordinat default (misal: Bekasi/Jakarta)
      fetchStoresFromApi(latitude: -6.200000, longitude: 106.816666);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        fetchStoresFromApi(latitude: -6.200000, longitude: 106.816666);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      fetchStoresFromApi(latitude: -6.200000, longitude: 106.816666);
      return;
    }

    // Ambil posisi GPS saat ini
    Position position = await Geolocator.getCurrentPosition();
    fetchStoresFromApi(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  // Fungsi mengambil data dari API Laravel
  Future<void> fetchStoresFromApi({
    required double latitude,
    required double longitude,
  }) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // CATATAN URL:
      // Gunakan '10.0.2.2' jika menggunakan Android Emulator
      final url = Uri.parse(
        'http://192.168.53.248:8000/api/nearby-stores?latitude=$latitude&longitude=$longitude',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          List<dynamic> loadedStores = data['data'];

          // EKSTRAK AREA UNIK DARI DATABASE
          // Mengambil semua nilai 'area' dari tabel stores tanpa duplikat
          Set<String> uniqueAreas = {'Semua Area'};
          for (var store in loadedStores) {
            if (store['area'] != null) {
              uniqueAreas.add(store['area'].toString());
            }
          }

          setState(() {
            _stores = loadedStores;
            _areas = uniqueAreas
                .toList(); // Update list dropdown sesuai database

            // Jika area yang dipilih sebelumnya tidak ada di database lagi, reset ke 'Semua Area'
            if (!_areas.contains(_selectedArea)) {
              _selectedArea = 'Semua Area';
            }

            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error: $e');
    }
  }

  // Fungsi buka Maps pihak ke-3
  Future<void> _openMap(double latitude, double longitude) async {
    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka aplikasi Maps')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter toko berdasarkan dropdown area yang dipilih
    final filteredStores = _selectedArea == 'Semua Area'
        ? _stores
        : _stores.where((store) => store['area'] == _selectedArea).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FF),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF031636)),
          onPressed: () {},
        ),
        title: const Text(
          'Field Sales Pro',
          style: TextStyle(
            color: Color(0xFF031636),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF031636)),
            onPressed: () {
              // Refresh ulang GPS & data dari API
              _determinePositionAndFetchStores();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Search & Filter Controls ---
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFF8F9FF),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search store name or address...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF44474E),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFEFF4FF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFC5C6CF)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // DROPDOWN AREA OTOMATIS SESUAI DATABASE
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF4FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFC5C6CF)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedArea,
                      icon: const Icon(Icons.arrow_drop_down),
                      items: _areas.map((String area) {
                        return DropdownMenuItem<String>(
                          value: area,
                          child: Text(
                            area,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF031636),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedArea = newValue!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- Active Visit Banner ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF6CF8BB).withOpacity(0.95),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.location_on, color: Color(0xFF00714D)),
                    SizedBox(width: 8),
                    Text(
                      'Active Visit:\nResto Jaya Meat (Bekasi)',
                      style: TextStyle(
                        color: Color(0xFF002113),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006C49),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {},
                  child: const Text('Selesaikan'),
                ),
              ],
            ),
          ),

          // --- Main Content (List of Stores) ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredStores.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada toko ditemukan di area ini',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredStores.length,
                    itemBuilder: (context, index) {
                      final store = filteredStores[index];
                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      store['name'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Chip(
                                    label: Text('Belum Dikunjungi'),
                                    backgroundColor: Color(0x1A031636),
                                    labelStyle: TextStyle(
                                      color: Color(0xFF031636),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${store['address']} • ${store['distance_label']} • (${store['area']})',
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF031636,
                                        ),
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () {},
                                      child: const Text('Mulai Kunjungi'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  OutlinedButton(
                                    onPressed: () {
                                      double lat = double.parse(
                                        store['latitude'].toString(),
                                      );
                                      double lng = double.parse(
                                        store['longitude'].toString(),
                                      );
                                      _openMap(lat, lng);
                                    },
                                    child: const Icon(Icons.map),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // --- Bottom Navigation Bar ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFF006C49),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Catalog',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Customers'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
