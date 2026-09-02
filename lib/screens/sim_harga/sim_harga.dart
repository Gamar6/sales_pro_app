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

  // Untuk sementara semua produk menggunakan 30 pcs/karton.
  // Nanti bisa dipindahkan ke StockProduct.
  static const int _pcsPerCarton = 30;

  StockProduct? _selectedProduct;

  final TextEditingController _quantityController = TextEditingController(
    text: '12',
  );

  double _fractionalCarton = 0.4;
  double _totalPrice = 0;

  final NumberFormat _currencyFormat = NumberFormat('#,##0', 'id_ID');

  @override
  void initState() {
    super.initState();

    _selectedProduct =
        widget.initialProduct ??
        (widget.products.isNotEmpty ? widget.products.first : null);

    _calculateSimulation();
  }

  void _calculateSimulation() {
    final int qty = int.tryParse(_quantityController.text) ?? 0;
    final double price = _selectedProduct?.price ?? 0;

    setState(() {
      _fractionalCarton = qty > 0 ? qty / _pcsPerCarton : 0;

      _totalPrice = qty * price;
    });
  }

  String _formatRupiah(double value) {
    return _currencyFormat.format(value);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }

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
            color: Colors.black.withOpacity(0.02),
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

          DropdownButtonFormField<StockProduct>(
            value: product,
            isExpanded: true,
            decoration: InputDecoration(
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
            ),
            items: widget.products.map((product) {
              return DropdownMenuItem<StockProduct>(
                value: product,
                child: Text(product.title, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedProduct = value;
              });

              _calculateSimulation();
            },
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(child: _buildQuantityField()),
              const SizedBox(width: 12),
              Expanded(child: _buildCartonField()),
            ],
          ),

          const SizedBox(height: 16),

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

  Widget _buildCartonField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ISI PER KARTON',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: brandTextVariant,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          readOnly: true,
          controller: TextEditingController(text: _pcsPerCarton.toString()),
          decoration: _inputDecoration(suffixText: 'packs', filled: true),
        ),
      ],
    );
  }

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
                color: Colors.black.withOpacity(0.02),
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
                    _fractionalCarton.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B1C30),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Karton',
                    style: TextStyle(fontSize: 14, color: brandTextVariant),
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
                  'Rumus: $qty packs / $_pcsPerCarton packs',
                  style: const TextStyle(fontSize: 11, color: brandTextVariant),
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1),
              ),

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
