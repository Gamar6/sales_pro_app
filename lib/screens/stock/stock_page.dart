import 'package:flutter/material.dart';
import '../../models/stock_model.dart';
import '../../services/stock_service.dart';

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  // State data dari API
  bool _isLoading = true;
  int _totalSkus = 0;
  int _lowStockCount = 0;
  List<StockProduct> _products = [];

  // Controller & State Search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // State Sorting (Filter Kategori telah dihapus)
  String _selectedSort = 'Default';

  final List<String> _sortOptions = [
    'Default',
    'Stok Terbanyak',
    'Stok Tersedikit',
    'Nama (A-Z)',
    'Nama (Z-A)',
  ];

  @override
  void initState() {
    super.initState();
    _fetchStockData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi mengambil data dari API
  Future<void> _fetchStockData() async {
    setState(() => _isLoading = true);

    final result = await StockService.fetchStocks();

    if (result['success']) {
      setState(() {
        _products = (result['data'] as List)
            .map((item) => StockProduct.fromJson(item))
            .toList();
        _totalSkus = result['total_skus'] ?? 0;
        _lowStockCount = result['low_stock_count'] ?? 0;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal memuat data stok'),
          ),
        );
      }
    }
  }

  // Getter untuk memproses Search dan Sorting secara realtime
  List<StockProduct> get _filteredProducts {
    List<StockProduct> filtered = List.from(_products);

    // 1. Filter Pencarian Teks
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        final titleMatch = product.title.toLowerCase().contains(
          _searchQuery.toLowerCase(),
        );
        final subtitleMatch = product.subtitle.toLowerCase().contains(
          _searchQuery.toLowerCase(),
        );
        return titleMatch || subtitleMatch;
      }).toList();
    }

    // 2. Sorting / Pengurutan Data
    switch (_selectedSort) {
      case 'Stok Terbanyak':
        filtered.sort((a, b) {
          final int stockA = int.tryParse(a.level) ?? 0;
          final int stockB = int.tryParse(b.level) ?? 0;
          return stockB.compareTo(stockA);
        });
        break;
      case 'Stok Tersedikit':
        filtered.sort((a, b) {
          final int stockA = int.tryParse(a.level) ?? 0;
          final int stockB = int.tryParse(b.level) ?? 0;
          return stockA.compareTo(stockB);
        });
        break;
      case 'Nama (A-Z)':
        filtered.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
      case 'Nama (Z-A)':
        filtered.sort(
          (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()),
        );
        break;
      case 'Default':
      default:
        break;
    }

    return filtered;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Low Stock':
        return const Color(0xFFCD8300);
      case 'Out of Stock':
        return const Color(0xFFBA1A1A);
      case 'In Stock':
      default:
        return const Color(0xFF006C49);
    }
  }

  Color _getStatusBg(String status) {
    switch (status) {
      case 'Low Stock':
        return const Color(0xFFFFDDB8);
      case 'Out of Stock':
        return const Color(0xFFFFDAD6);
      case 'In Stock':
      default:
        return const Color(0xFF6FFBBE);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color brandPrimary = Color(0xFF1A2B4C);
    const Color brandSurface = Color(0xFFF8F9FF);
    const Color brandOutline = Color(0xFFC5C6CF);

    final displayList = _filteredProducts;

    return Scaffold(
      backgroundColor: brandSurface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: false,
        title: const Text(
          'Stock Levels',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: brandPrimary,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchStockData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Search Field ---
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari produk...',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF75777F),
                      ),
                      prefixIcon: const Icon(Icons.search, color: brandPrimary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: brandOutline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: brandOutline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: brandPrimary,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- Summary Stats Bento ---
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: brandOutline),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TOTAL SKUS',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF44474E),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isLoading ? '...' : '$_totalSkus',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: brandPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: brandOutline),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'LOW STOCK',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFCD8300),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _isLoading ? '...' : '$_lowStockCount',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFCD8300),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- Sorting Only Row ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: brandOutline),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedSort,
                        isExpanded: true,
                        icon: const Icon(
                          Icons.sort,
                          size: 18,
                          color: brandPrimary,
                        ),
                        items: _sortOptions.map((String option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Text(
                              option,
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedSort = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Inventory List ---
                  _isLoading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 60),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : displayList.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 60),
                          child: Center(
                            child: Text(
                              'Produk tidak ditemukan.',
                              style: TextStyle(color: Color(0xFF75777F)),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: displayList.length,
                          itemBuilder: (context, index) {
                            final product = displayList[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: _buildProductListItem(
                                product,
                                brandOutline,
                                brandPrimary,
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Card Produk
  Widget _buildProductListItem(
    StockProduct product,
    Color brandOutline,
    Color brandPrimary,
  ) {
    final statusColor = _getStatusColor(product.status);
    final statusBg = _getStatusBg(product.status);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: brandOutline),
      ),
      child: Row(
        children: [
          // 1. Gambar Produk
          // 1. Gambar Produk
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 64,
              height: 64,
              child: Image.network(
                product
                    .displayImageUrl, // Langsung panggil getter yang sudah aman
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFEFF4FF),
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Color(0xFF75777F),
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 2. Info Teks Produk
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: brandPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF75777F),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // 3. Stok Level & Status Badge (Kanan)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      product.status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    product.level,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    product.unit,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF75777F),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
