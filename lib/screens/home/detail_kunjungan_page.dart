import 'package:flutter/material.dart';

class DetailKunjunganPage extends StatelessWidget {
  final Map<String, dynamic> visit;

  // Ganti baseUrl sesuai domain/IP server backend kamu
  static const String baseUrl = 'http://10.0.2.2:8000';

  const DetailKunjunganPage({super.key, required this.visit});

  String _formatDateTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '-';
    final parsed = DateTime.tryParse(isoString)?.toLocal();
    if (parsed == null) return isoString;
    return '${parsed.day.toString().padLeft(2, '0')}-${parsed.month.toString().padLeft(2, '0')}-${parsed.year} '
        '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final partner = visit['partner'] as Map<String, dynamic>?;
    final report = visit['report'] as Map<String, dynamic>?;

    final storeName = partner?['name'] ?? 'Toko Tanpa Nama';
    final address = partner?['street'] ?? 'Alamat tidak tersedia';
    final checkIn = _formatDateTime(visit['check_in_at']);
    final checkOut = _formatDateTime(visit['check_out_at']);

    final photos = (report?['photos'] as List<dynamic>?) ?? [];
    final activities = (report?['activities'] as List<dynamic>?) ?? [];

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
          'Detail Kunjungan',
          style: TextStyle(
            color: Color(0xFF003F87),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Informasi Toko
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFC2C6D4)),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    storeName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003F87),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Color(0xFF424752),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          address,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF424752),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTimeInfo('Check-in', checkIn),
                      _buildTimeInfo('Check-out', checkOut),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Detail Laporan Kunjungan
            const Text(
              'Laporan Hasil Kunjungan',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF141D23),
              ),
            ),
            const SizedBox(height: 8),

            if (report == null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFC2C6D4)),
                ),
                child: const Center(
                  child: Text(
                    'Belum ada laporan yang disubmit untuk kunjungan ini.',
                  ),
                ),
              )
            else
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
                    _buildRow('Nama PIC', report['pic_name'] ?? '-'),
                    _buildRow('Stok (Pcs)', '${report['stock_pcs'] ?? 0} Pcs'),
                    _buildRow(
                      'Persentase Stok',
                      '${report['stock_percentage'] ?? 0}%',
                    ),
                    _buildRow('Catatan', report['notes'] ?? '-'),
                    const SizedBox(height: 12),

                    const Text(
                      'Aktivitas:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (activities.isNotEmpty)
                      ...activities.map(
                        (act) => Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                          child: Text(
                            '• $act',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      )
                    else
                      const Text('-', style: TextStyle(fontSize: 13)),

                    const SizedBox(height: 16),
                    const Text(
                      'Foto Kunjungan:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Grid Foto Kunjungan
                    if (photos.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: photos.length,
                        itemBuilder: (context, index) {
                          final photoPath = photos[index].toString();
                          final fullUrl = photoPath.startsWith('http')
                              ? photoPath
                              : '$baseUrl$photoPath';

                          return ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              fullUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                    ),
                                  ),
                            ),
                          );
                        },
                      )
                    else
                      const Text(
                        'Tidak ada foto.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF424752)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF424752), fontSize: 13),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF141D23),
              ),
            ),
          ),
        ],
      ),
    );
  }
}