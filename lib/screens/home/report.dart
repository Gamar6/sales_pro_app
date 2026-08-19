import 'package:flutter/material.dart';

class VisitFormPage extends StatefulWidget {
  const VisitFormPage({super.key});

  @override
  State<VisitFormPage> createState() => _VisitFormPageState();
}

class _VisitFormPageState extends State<VisitFormPage> {
  int _currentIndex = 1; // Default tab Visits aktif

  // State untuk form
  final TextEditingController _picController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();

  // State Checkbox Aktivitas
  bool _isCheckChecked = false;
  bool _isVisitChecked = false;
  bool _isStikerChecked = false;
  bool _isLainLainChecked = false;

  @override
  void dispose() {
    _picController.dispose();
    _stokController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6FAFF),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF424752)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Fiva Food',
          style: TextStyle(
            color: Color(0xFF003F87),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFC2C6D4)),
              ),
              child: ClipOval(
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuA5XvybYXKBHgux_AxunNayK7KlrJqTnMKHg478-wIC9356bHNG1LSzcMKTrBY-g8p5G0-1gAFntjAZxPjcPqbWouBRkatXUrm5XamIDScLxU-qi_iVwxSJA5L6F_FGjrMwLamaS377mZaA30MHJrmzZMLKs3zBgmiA4CQVLLfAwaXZ_9F9ixtksCmtqiKyRItKpYrDykv-Yg4-O8W7EepwATg0hTytCuVYGhBzSmifUHjHYEaLWe4N',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.person, size: 18),
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFC2C6D4), height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 672), // max-w-2xl
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Titles
                const Text(
                  'Input Kunjungan Harian',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF141D23),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Catat aktivitas operasional lapangan.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF727784)),
                ),
                const SizedBox(height: 20),

                // Form Container
                Column(
                  children: [
                    // Read-only Info Card
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFC2C6D4)),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Nama Sales',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF727784),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Sadikun',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF141D23),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Area',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF727784),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'JABODETABEK',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF141D23),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(height: 1, color: const Color(0xFFDBE4ED)),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tanggal',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF727784),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Color(0xFF003F87),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '12 Oktober 2023',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF003F87),
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
                    const SizedBox(height: 12),

                    // Active Form Card
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFC2C6D4)),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Outlet Name (Readonly)
                          const Text(
                            'Outlet Name',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF141D23),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            readOnly: true,
                            controller: TextEditingController(
                              text: 'Toko Barokah',
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFECF5FE),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: const BorderSide(
                                  color: Color(0xFFC2C6D4),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: const BorderSide(
                                  color: Color(0xFFC2C6D4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // PIC
                          const Text(
                            'PIC',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF141D23),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _picController,
                            decoration: InputDecoration(
                              hintText: 'Nama penanggung jawab',
                              hintStyle: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF727784),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: const BorderSide(
                                  color: Color(0xFFC2C6D4),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: const BorderSide(
                                  color: Color(0xFF003F87),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Activities Checkboxes
                          const Text(
                            'Aktivitas',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF141D23),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 3.5,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            children: [
                              _buildCheckboxItem(
                                'Cek',
                                _isCheckChecked,
                                (val) => setState(
                                  () => _isCheckChecked = val ?? false,
                                ),
                              ),
                              _buildCheckboxItem(
                                'Visit',
                                _isVisitChecked,
                                (val) => setState(
                                  () => _isVisitChecked = val ?? false,
                                ),
                              ),
                              _buildCheckboxItem(
                                'Pemasangan Stiker',
                                _isStikerChecked,
                                (val) => setState(
                                  () => _isStikerChecked = val ?? false,
                                ),
                              ),
                              _buildCheckboxItem(
                                'Lain-lain',
                                _isLainLainChecked,
                                (val) => setState(
                                  () => _isLainLainChecked = val ?? false,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Sisa Stok (%)
                          const Text(
                            'Sisa Stok (%)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF141D23),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _stokController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              hintText: '0',
                              suffixText: '% ',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: const BorderSide(
                                  color: Color(0xFFC2C6D4),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: const BorderSide(
                                  color: Color(0xFF003F87),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Catatan
                          const Text(
                            'Catatan',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF141D23),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _catatanController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Masukkan catatan kunjungan...',
                              hintStyle: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF727784),
                              ),
                              contentPadding: const EdgeInsets.all(12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: const BorderSide(
                                  color: Color(0xFFC2C6D4),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: const BorderSide(
                                  color: Color(0xFF003F87),
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Photo Documentation Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Dokumentasi Foto',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF141D23),
                              ),
                            ),
                            Text(
                              'Maks. 4 Foto',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF727784),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        GridView.count(
                          crossAxisCount: 4,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          children: [
                            // Upload Trigger
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFC2C6D4),
                                  style: BorderStyle.solid,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.add_a_photo,
                                    color: Color(0xFF003F87),
                                    size: 20,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'TAMBAH',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF003F87),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Placeholder Previews
                            _buildPhotoPreviewBox(),
                            _buildPhotoPreviewBox(),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFECF5FE),
                                border: Border.all(
                                  color: const Color(0xFFC2C6D4),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.image,
                                  color: Color(0x33727784),
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Pastikan foto jelas dan memperlihatkan kondisi outlet/produk.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF727784),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Submit Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF003F87),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          // Aksi simpan kunjungan
                        },
                        icon: const Icon(Icons.save, size: 18),
                        label: const Text(
                          'Simpan Kunjungan',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxItem(
    String label,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFDBE4ED)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: const Color(0xFF003F87),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14, color: Color(0xFF141D23)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPreviewBox() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE0E9F2),
        border: Border.all(color: const Color(0xFFC2C6D4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          const Center(
            child: Icon(Icons.image, color: Color(0x66727784), size: 24),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: const Color(0xFFBA1A1A).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 14,
                color: Color(0xFFBA1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
