import 'package:flutter/material.dart';

class PriceSimulationPage extends StatefulWidget {
  const PriceSimulationPage({super.key});

  @override
  State<PriceSimulationPage> createState() => _PriceSimulationPageState();
}

class _PriceSimulationPageState extends State<PriceSimulationPage> {
  // Controller & State untuk simulasi
  String? _selectedProduct = 'rolade500';
  final TextEditingController _quantityController = TextEditingController(
    text: '12',
  );
  final int _pcsPerCarton = 30;
  final double _basePricePerPack = 35000;

  double _fractionalCarton = 0.4;
  double _totalPrice = 420000;

  @override
  void initState() {
    super.initState();
    _calculateSimulation();
  }

  void _calculateSimulation() {
    final int qty = int.tryParse(_quantityController.text) ?? 0;
    setState(() {
      _fractionalCarton = qty > 0 ? qty / _pcsPerCarton : 0.0;
      _totalPrice = qty * _basePricePerPack;
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color brandPrimary = Color(0xFF1A2B4C);
    const Color brandSurface = Color(0xFFF8F9FF);
    const Color brandTextVariant = Color(0xFF44474E);
    const Color brandOutline = Color(0xFFC5C6CF);

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
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Title
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

                // Main Grid Layout
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 650) {
                      // Desktop / Tablet 2 Columns
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 7,
                            child: _buildFormSection(
                              brandPrimary,
                              brandOutline,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 5,
                            child: _buildResultSection(
                              brandPrimary,
                              brandOutline,
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Mobile 1 Column
                      return Column(
                        children: [
                          _buildFormSection(brandPrimary, brandOutline),
                          const SizedBox(height: 16),
                          _buildResultSection(brandPrimary, brandOutline),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- BAGIAN FORMULIR PARAMETER ---
  Widget _buildFormSection(Color brandPrimary, Color brandOutline) {
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

          // Produk Dropdown
          const Text(
            'PRODUK',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF44474E),
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _selectedProduct,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: brandOutline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: brandOutline),
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: 'rolade500',
                child: Text('Rolade Sapi 500gr'),
              ),
              DropdownMenuItem(
                value: 'sosis250',
                child: Text('Sosis Ayam 250gr'),
              ),
              DropdownMenuItem(
                value: 'nugget500',
                child: Text('Nugget Ayam 500gr'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedProduct = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // Kuantitas & Conversion Ratio dalam Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'KUANTITAS (PACKS)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF44474E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: brandOutline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: brandOutline),
                        ),
                      ),
                      onChanged: (val) => _calculateSimulation(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ISI PER KARTON',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF44474E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      readOnly: true,
                      controller: TextEditingController(text: '$_pcsPerCarton'),
                      decoration: InputDecoration(
                        isDense: true,
                        suffixText: 'pcs',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: brandOutline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: brandOutline),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Harga per Pack Dasar
          const Text(
            'HARGA PER PACK DASAR (RP)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF44474E),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            readOnly: true,
            controller: TextEditingController(text: '35.000'),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: brandOutline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: brandOutline),
              ),
              filled: true,
              fillColor: const Color(0xFFF8F9FF),
            ),
          ),
          const SizedBox(height: 24),

          // Tombol Hitung
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

  // --- BAGIAN HASIL & INFO ---
  Widget _buildResultSection(Color brandPrimary, Color brandOutline) {
    return Column(
      children: [
        // Main Result Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: const Color(0xFFFFB95F),
            ), // Tertiary fixed dim accent
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

              // Fractional Result
              const Text(
                'Konversi Fraksional',
                style: TextStyle(fontSize: 12, color: Color(0xFF44474E)),
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
                    style: TextStyle(fontSize: 14, color: Color(0xFF44474E)),
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
                  'Rumus: ${_quantityController.text} packs / $_pcsPerCarton packs',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF44474E),
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1),
              ),

              // Price Result
              const Text(
                'Total Estimasi Harga',
                style: TextStyle(fontSize: 12, color: Color(0xFF44474E)),
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
                  Text(
                    _totalPrice
                        .toStringAsFixed(0)
                        .replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]}.',
                        ),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: brandPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '(${_quantityController.text} packs × Rp 35.000)',
                style: const TextStyle(fontSize: 12, color: Color(0xFF44474E)),
              ),

              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 16),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Info Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF4FF),
            border: Border.all(color: brandOutline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: brandPrimary, size: 22),
              const SizedBox(width: 12),
              const Expanded(
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
                        color: Color(0xFF44474E),
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
