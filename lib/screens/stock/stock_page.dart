import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/stock_model.dart';
import '../../services/stock_service.dart';

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  // ============================================================
  // CONSTANTS
  // ============================================================

  static const Color brandPrimary = Color(0xFF1A2B4C);
  static const Color brandSurface = Color(0xFFF8F9FF);
  static const Color brandTextVariant = Color(0xFF44474E);
  static const Color brandOutline = Color(0xFFC5C6CF);

  // ============================================================
  // API / DATA STATE
  // ============================================================

  bool _isLoading = true;
  int _totalSkus = 0;
  int _lowStockCount = 0;
  List<StockProduct> _products = [];

  // ============================================================
  // SEARCH STATE
  // ============================================================

  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  // ============================================================
  // SORTING STATE
  // ============================================================

  String _selectedSort = 'Default';

  final List<String> _sortOptions = [
    'Default',
    'Stok Terbanyak',
    'Stok Tersedikit',
    'Nama (A-Z)',
    'Nama (Z-A)',
  ];

  // ============================================================
  // EXPANDED PRODUCT STATE
  // ============================================================

  /// ID produk yang sedang dibuka.
  ///
  /// Hanya satu produk yang bisa expanded dalam satu waktu.
  int? _expandedProductId;

  // ============================================================
  // FORMATTER
  // ============================================================

  final NumberFormat _currencyFormat = NumberFormat('#,##0', 'id_ID');

  // ============================================================
  // LIFECYCLE
  // ============================================================

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

  // ============================================================
  // FETCH STOCK DATA
  // ============================================================

  Future<void> _fetchStockData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final result = await StockService.fetchStocks();

      if (!mounted) return;

      if (result['success'] == true) {
        final products = (result['data'] as List)
            .map((item) => StockProduct.fromJson(item))
            .toList();

        setState(() {
          _products = products;
          _totalSkus = result['total_skus'] ?? 0;
          _lowStockCount = result['low_stock_count'] ?? 0;
          _isLoading = false;

          // Tutup detail ketika data di-refresh.
          _expandedProductId = null;
        });
      } else {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal memuat data stok'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Terjadi kesalahan saat memuat data stok.'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // SEARCH + SORT
  // ============================================================

  List<StockProduct> get _filteredProducts {
    List<StockProduct> filtered = List<StockProduct>.from(_products);

    // ----------------------------------------------------------
    // SEARCH
    // ----------------------------------------------------------

    final query = _searchQuery.trim().toLowerCase();

    if (query.isNotEmpty) {
      filtered = filtered.where((product) {
        final titleMatch = product.title.toLowerCase().contains(query);

        final subtitleMatch = product.subtitle.toLowerCase().contains(query);

        return titleMatch || subtitleMatch;
      }).toList();
    }

    // ----------------------------------------------------------
    // SORT
    // ----------------------------------------------------------

    switch (_selectedSort) {
      case 'Stok Terbanyak':
        filtered.sort((a, b) => b.rawQty.compareTo(a.rawQty));
        break;

      case 'Stok Tersedikit':
        filtered.sort((a, b) => a.rawQty.compareTo(b.rawQty));
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

  // ============================================================
  // EXPAND / COLLAPSE
  // ============================================================

  void _toggleProduct(StockProduct product) {
    setState(() {
      if (_expandedProductId == product.id) {
        _expandedProductId = null;
      } else {
        _expandedProductId = product.id;
      }
    });
  }

  // ============================================================
  // STATUS HELPERS
  // ============================================================

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

  // ============================================================
  // PACKAGING RULE
  // ============================================================

  Map<String, dynamic> _getPackagingInfo(StockProduct product) {
    final double weightKg = product.weight;

    // 115g
    if ((weightKg - 0.115).abs() < 0.001) {
      return {'packs': 30, 'unit': 'Karton'};
    }

    // 250g
    if ((weightKg - 0.25).abs() < 0.001) {
      return {'packs': 30, 'unit': 'Karton'};
    }

    // 400g
    if ((weightKg - 0.4).abs() < 0.001) {
      return {'packs': 20, 'unit': 'Karton'};
    }

    // 500g
    if ((weightKg - 0.5).abs() < 0.001) {
      return {'packs': 15, 'unit': 'Karton'};
    }

    // 1kg
    if ((weightKg - 1.0).abs() < 0.001) {
      return {'packs': 10, 'unit': 'Bal'};
    }

    // Fallback
    return {'packs': product.packsPerPackage, 'unit': product.packageUnit};
  }

  // ============================================================
  // FORMAT HELPERS
  // ============================================================

  String _formatRupiah(double value) {
    return 'Rp ${_currencyFormat.format(value)}';
  }

  String _formatWeight(double weightKg) {
    if (weightKg <= 0) {
      return '-';
    }

    final grams = weightKg * 1000;

    if (grams % 1000 == 0) {
      return '${(grams / 1000).toStringAsFixed(0)} kg';
    }

    if (grams == grams.roundToDouble()) {
      return '${grams.toStringAsFixed(0)} g';
    }

    return '${grams.toStringAsFixed(1)} g';
  }

  String _formatStock(double qty) {
    if (qty == qty.roundToDouble()) {
      return qty.toStringAsFixed(0);
    }

    return qty.toStringAsFixed(2);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final displayList = _filteredProducts;

    return Scaffold(
      backgroundColor: brandSurface,

      // --------------------------------------------------------
      // APP BAR
      // --------------------------------------------------------
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

      // --------------------------------------------------------
      // BODY
      // --------------------------------------------------------
      body: RefreshIndicator(
        onRefresh: _fetchStockData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // SEARCH
                  // ==================================================
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

                                setState(() {
                                  _searchQuery = '';
                                  _expandedProductId = null;
                                });
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
                        _expandedProductId = null;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // SUMMARY STATS
                  // ==================================================
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          title: 'TOTAL SKUS',
                          value: _isLoading ? '...' : '$_totalSkus',
                          valueColor: brandPrimary,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _buildSummaryCard(
                          title: 'LOW STOCK',
                          value: _isLoading ? '...' : '$_lowStockCount',
                          valueColor: const Color(0xFFCD8300),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // SORTING
                  // ==================================================
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
                          if (newValue == null) return;

                          setState(() {
                            _selectedSort = newValue;
                            _expandedProductId = null;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // INVENTORY LIST
                  // ==================================================
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

                            final isExpanded = _expandedProductId == product.id;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _buildProductListItem(product, isExpanded),
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

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: brandOutline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRODUCT CARD
  // ============================================================

  Widget _buildProductListItem(StockProduct product, bool isExpanded) {
    final statusColor = _getStatusColor(product.status);

    final statusBg = _getStatusBg(product.status);

    final packaging = _getPackagingInfo(product);

    final int packsPerPackage = packaging['packs'] as int;

    final String packageUnit = packaging['unit'] as String;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _toggleProduct(product),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: isExpanded
                  ? brandPrimary.withValues(alpha: 0.35)
                  : brandOutline,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // ==================================================
              // MAIN PRODUCT ROW
              // ==================================================
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ------------------------------------------------
                    // IMAGE
                    // ------------------------------------------------
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 64,
                        height: 64,
                        child: Image.network(
                          product.displayImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFEFF4FF),
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Color(0xFF75777F),
                                size: 24,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // ------------------------------------------------
                    // PRODUCT INFO
                    // ------------------------------------------------
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: brandPrimary,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            product.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF75777F),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // ------------------------------------------------
                    // STOCK + STATUS
                    // ------------------------------------------------
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
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
              ),

              // ==================================================
              // EXPANDED DETAIL
              // ==================================================
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                child: isExpanded
                    ? _buildExpandedDetail(
                        product,
                        statusColor,
                        packsPerPackage,
                        packageUnit,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EXPANDED DETAIL
  // ============================================================

  Widget _buildExpandedDetail(
    StockProduct product,
    Color statusColor,
    int packsPerPackage,
    String packageUnit,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --------------------------------------------------------
          // DIVIDER
          // --------------------------------------------------------
          Divider(
            height: 1,
            thickness: 1,
            color: brandOutline.withValues(alpha: 0.6),
          ),

          const SizedBox(height: 14),

          // --------------------------------------------------------
          // HEADER DETAIL
          // --------------------------------------------------------
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: brandPrimary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 18,
                  color: brandPrimary,
                ),
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Text(
                  'Detail Produk',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: brandPrimary,
                  ),
                ),
              ),

              Icon(
                Icons.keyboard_arrow_up,
                color: Colors.grey.shade500,
                size: 20,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // --------------------------------------------------------
          // DETAIL GRID
          // --------------------------------------------------------
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  icon: Icons.scale_outlined,
                  label: 'Berat',
                  value: _formatWeight(product.weight),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _buildDetailItem(
                  icon: Icons.sell_outlined,
                  label: 'Harga',
                  value: _formatRupiah(product.price),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'Isi Kemasan',
                  value: '$packsPerPackage pack / $packageUnit',
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _buildDetailItem(
                  icon: Icons.warehouse_outlined,
                  label: 'Stok',
                  value: '${_formatStock(product.rawQty)} ${product.unit}',
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // --------------------------------------------------------
          // LOCATION
          // --------------------------------------------------------
          _buildDetailItem(
            icon: Icons.location_on_outlined,
            label: 'Lokasi',
            value: product.subtitle.replaceFirst('Lokasi: ', ''),
          ),

          const SizedBox(height: 14),

          // --------------------------------------------------------
          // PACKAGING INFO
          // --------------------------------------------------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: brandOutline.withValues(alpha: 0.7)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: brandPrimary.withValues(alpha: 0.8),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    '1 $packageUnit berisi '
                    '$packsPerPackage pack. '
                    'Informasi kemasan mengikuti '
                    'berat produk.',
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.45,
                      color: brandTextVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DETAIL ITEM
  // ============================================================

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: brandOutline.withValues(alpha: 0.7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: brandPrimary),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF75777F),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: brandTextVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}