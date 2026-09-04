import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/stock_model.dart';

class PriceSimulationPage extends StatefulWidget {
  final List<StockProduct> products;
  final StockProduct? initialProduct;

  const PriceSimulationPage({
    super.key,
    required this.products,
    this.initialProduct,
  });

  @override
  State<PriceSimulationPage> createState() => _PriceSimulationPageState();
}

class _PriceSimulationPageState extends State<PriceSimulationPage> {
  static const Color brandPrimary = Color(0xFF1A2B4C);
  static const Color brandSurface = Color(0xFFF8F9FF);
  static const Color brandTextVariant = Color(0xFF44474E);
  static const Color brandOutline = Color(0xFFC5C6CF);

  StockProduct? _selectedProduct;

  final TextEditingController _quantityController = TextEditingController(
    text: '0',
  );

  final TextEditingController _productSearchController =
      TextEditingController();

  double _fractionalPackage = 0;
  double _totalPrice = 0;

  int _packsPerPackage = 1;
  String _packageUnit = 'Karton';

  final NumberFormat _currencyFormat = NumberFormat('#,##0', 'id_ID');

  List<StockProduct> _filteredProducts = [];
  bool _showProductResults = false;

  @override
  void initState() {
    super.initState();

    _selectedProduct =
        widget.initialProduct ??
        (widget.products.isNotEmpty ? widget.products.first : null);

    if (_selectedProduct != null) {
      _productSearchController.text = _selectedProduct!.title;
    }

    _filteredProducts = List.from(widget.products);

    _productSearchController.addListener(_onProductSearchChanged);

    _calculateSimulation();
  }

  // ============================================================
  // MENENTUKAN PACKAGING BERDASARKAN BERAT PRODUK
  // ============================================================

  void _updatePackaging() {
    final product = _selectedProduct;

    if (product == null) {
      _packsPerPackage = 1;
      _packageUnit = 'Karton';
      return;
    }

    // Weight dari Odoo menggunakan KG.
    final double weightKg = product.weight;

    // 150 gram
    if ((weightKg - 0.115).abs() < 0.001) {
      _packsPerPackage = 30;
      _packageUnit = 'Karton';
    }
    // 250 gram
    else if ((weightKg - 0.25).abs() < 0.001) {
      _packsPerPackage = 30;
      _packageUnit = 'Karton';
    }
    // 500 gram
    else if ((weightKg - 0.5).abs() < 0.001) {
      _packsPerPackage = 15;
      _packageUnit = 'Karton';
    }
    // 1000 gram / 1 kg
    else if ((weightKg - 1.0).abs() < 0.001) {
      _packsPerPackage = 10;
      _packageUnit = 'Bal';
    }
    // 400 gram
    else if((weightKg - 0.4).abs() < 0.001) {
      _packsPerPackage = 20;
      _packageUnit = 'Karton';
    }
    // Jika berat belum dikenali
    else {
      _packsPerPackage = 1;
      _packageUnit = 'Karton';
    }
  }

  // ============================================================
  // SEARCH PRODUK
  // ============================================================

  void _onProductSearchChanged() {
    final query = _productSearchController.text.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredProducts = List.from(widget.products);
      } else {
        _filteredProducts = widget.products.where((product) {
          return product.title.toLowerCase().contains(query);
        }).toList();
      }

      _showProductResults = true;
    });
  }

  // ============================================================
  // PILIH PRODUK
  // ============================================================

  void _selectProduct(StockProduct product) {
    setState(() {
      _selectedProduct = product;
      _productSearchController.text = product.title;
      _showProductResults = false;
    });

    _calculateSimulation();
  }

  // ============================================================
  // HITUNG SIMULASI
  // ============================================================

  void _calculateSimulation() {
    final int qty = int.tryParse(_quantityController.text) ?? 0;
    final double price = _selectedProduct?.price ?? 0;

    _updatePackaging();

    setState(() {
      _fractionalPackage = qty > 0 ? qty / _packsPerPackage : 0;

      _totalPrice = qty * price;
    });
  }

  // ============================================================
  // FORMAT RUPIAH
  // ============================================================

  String _formatRupiah(double value) {
    return _currencyFormat.format(value);
  }

  // ============================================================
  // FORMAT BERAT
  // ============================================================

  String _formatWeight(double weightKg) {
    final grams = weightKg * 1000;

    if (grams == grams.roundToDouble()) {
      return '${grams.toInt()} g';
    }

    return '${grams.toStringAsFixed(0)} g';
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _productSearchController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();

        setState(() {
          _showProductResults = false;
        });
      },
      child: Scaffold(
        backgroundColor: brandSurface,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: brandPrimary),
            onPressed: () {},
          ),
          title: const Text(
            'Field Sales Pro',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: brandPrimary,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list, color: brandPrimary),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Simulasi Harga',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B1C30),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Hitung konversi karton dan simulasi total harga untuk pesanan toko.',
                    style: TextStyle(fontSize: 14, color: brandTextVariant),
                  ),
                  const SizedBox(height: 16),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 650) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 7, child: _buildFormSection()),
                            const SizedBox(width: 16),
                            Expanded(flex: 5, child: _buildResultSection()),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          _buildFormSection(),
                          const SizedBox(height: 16),
                          _buildResultSection(),
                        ],
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
  // FORM SECTION
  // ============================================================

  Widget _buildFormSection() {
    final product = _selectedProduct;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: brandOutline),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Parameter Perhitungan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0B1C30),
            ),
          ),

          const Divider(height: 24),

          const Text(
            'PRODUK',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: brandTextVariant,
            ),
          ),

          const SizedBox(height: 6),

          // ======================================================
          // SEARCH PRODUK
          // ======================================================
          TextField(
            controller: _productSearchController,
            onTap: () {
              setState(() {
                _showProductResults = true;
              });
            },
            decoration: InputDecoration(
              hintText: 'Cari nama produk...',
              prefixIcon: const Icon(Icons.search, color: brandPrimary),
              suffixIcon: _productSearchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _productSearchController.clear();

                        setState(() {
                          _selectedProduct = null;
                          _filteredProducts = List.from(widget.products);
                          _showProductResults = true;
                        });

                        _calculateSimulation();
                      },
                    )
                  : null,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: brandOutline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: brandOutline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: brandPrimary, width: 1.5),
              ),
            ),
          ),

          // ======================================================
          // HASIL SEARCH
          // ======================================================
          if (_showProductResults)
            Container(
              margin: const EdgeInsets.only(top: 4),
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: brandOutline),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: _filteredProducts.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.search_off, color: brandTextVariant),
                          SizedBox(width: 10),
                          Text(
                            'Produk tidak ditemukan',
                            style: TextStyle(
                              fontSize: 13,
                              color: brandTextVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _filteredProducts.length,
                      separatorBuilder: (context, index) {
                        return const Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                        );
                      },
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];

                        final isSelected = _selectedProduct == product;

                        return Material(
                          color: isSelected ? brandSurface : Colors.white,
                          child: InkWell(
                            onTap: () {
                              _selectProduct(product);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: brandSurface,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(
                                      Icons.inventory_2_outlined,
                                      color: brandPrimary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? brandPrimary
                                                : const Color(0xFF0B1C30),
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Rp ${_formatRupiah(product.price)} / pack',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: brandTextVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: brandPrimary,
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

          const SizedBox(height: 16),

          // ======================================================
          // QUANTITY + PACKAGING
          // ======================================================
          Row(
            children: [
              Expanded(child: _buildQuantityField()),
              const SizedBox(width: 12),
              Expanded(child: _buildPackageField()),
            ],
          ),

          const SizedBox(height: 16),

          // ======================================================
          // HARGA
          // ======================================================
          _buildPriceField(),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: brandPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _calculateSimulation,
              icon: const Icon(Icons.calculate, size: 20),
              label: const Text(
                'Hitung Simulasi',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUANTITY FIELD
  // ============================================================

  Widget _buildQuantityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'KUANTITAS (PACKS)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: brandTextVariant,
          ),
        ),

        const SizedBox(height: 6),

        TextField(
          controller: _quantityController,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration(),
          onChanged: (_) => _calculateSimulation(),
        ),
      ],
    );
  }

  // ============================================================
  // PACKAGE FIELD
  // ============================================================

  Widget _buildPackageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ISI PER $_packageUnit'.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: brandTextVariant,
          ),
        ),

        const SizedBox(height: 6),

        TextField(
          readOnly: true,
          controller: TextEditingController(text: _packsPerPackage.toString()),
          decoration: _inputDecoration(suffixText: 'packs', filled: true),
        ),
      ],
    );
  }

  // ============================================================
  // PRICE FIELD
  // ============================================================

  Widget _buildPriceField() {
    final price = _selectedProduct?.price ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HARGA PER PACK DASAR (RP)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: brandTextVariant,
          ),
        ),

        const SizedBox(height: 6),

        TextField(
          readOnly: true,
          controller: TextEditingController(text: _formatRupiah(price)),
          decoration: _inputDecoration(filled: true),
        ),
      ],
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({String? suffixText, bool filled = false}) {
    return InputDecoration(
      isDense: true,
      suffixText: suffixText,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: brandOutline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: brandOutline),
      ),
      filled: filled,
      fillColor: brandSurface,
    );
  }

  // ============================================================
  // RESULT SECTION
  // ============================================================

  Widget _buildResultSection() {
    final product = _selectedProduct;

    final price = product?.price ?? 0;

    final qty = int.tryParse(_quantityController.text) ?? 0;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFFFB95F)),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'HASIL SIMULASI',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Color(0xFFCD8300),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Konversi Fraksional',
                style: TextStyle(fontSize: 12, color: brandTextVariant),
              ),

              const SizedBox(height: 4),

              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _fractionalPackage.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B1C30),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _packageUnit,
                    style: const TextStyle(
                      fontSize: 14,
                      color: brandTextVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5EEFF),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Rumus: $qty packs / $_packsPerPackage packs',
                  style: const TextStyle(fontSize: 11, color: brandTextVariant),
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1),
              ),

              // ==================================================
              // BERAT PRODUK
              // ==================================================
              if (product != null) ...[
                const Text(
                  'Berat Produk',
                  style: TextStyle(fontSize: 12, color: brandTextVariant),
                ),

                const SizedBox(height: 4),

                Text(
                  _formatWeight(product.weight),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B1C30),
                  ),
                ),

                const SizedBox(height: 16),

                const Divider(height: 1),

                const SizedBox(height: 16),
              ],

              // ==================================================
              // TOTAL HARGA
              // ==================================================
              const Text(
                'Total Estimasi Harga',
                style: TextStyle(fontSize: 12, color: brandTextVariant),
              ),

              const SizedBox(height: 4),

              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  const Text(
                    'Rp ',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Expanded(
                    child: Text(
                      _formatRupiah(_totalPrice),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: brandPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Text(
                '($qty packs × Rp ${_formatRupiah(price)})',
                style: const TextStyle(fontSize: 12, color: brandTextVariant),
              ),

              const SizedBox(height: 20),

              const Divider(height: 1),

              const SizedBox(height: 16),

              if (product != null)
                Text(
                  'Produk: ${product.title}',
                  style: const TextStyle(fontSize: 12, color: brandTextVariant),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ========================================================
        // CATATAN
        // ========================================================
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF4FF),
            border: Border.all(color: brandOutline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: brandPrimary, size: 22),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Catatan Pembelian Fraksional',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0B1C30),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Pembelian di bawah 1 karton penuh mungkin tidak memenuhi syarat untuk diskon grosir standar. Pastikan untuk memverifikasi kebijakan toko.',
                      style: TextStyle(
                        fontSize: 12,
                        color: brandTextVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}