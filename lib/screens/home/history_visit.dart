import 'package:flutter/material.dart';

class VisitHistoryPage extends StatelessWidget {
  const VisitHistoryPage({super.key});

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
          tooltip: 'Kembali ke Dashboard',
        ),
        title: const Text(
          'Riwayat Kunjungan',
          style: TextStyle(
            color: Color(0xFF003F87),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xFF003F87)),
            onPressed: () {},
            tooltip: 'Notifikasi',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFC2C6D4), height: 1.0),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Filter Section
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterButton('Hari Ini', isSelected: true),
                const SizedBox(width: 8),
                _buildFilterButton('Kemarin'),
                const SizedBox(width: 8),
                _buildFilterButton('Minggu Ini'),
                const SizedBox(width: 8),
                _buildFilterButton('Kustom', hasDropdown: true),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Stats Summary
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: const Color(0xFFECF5FE),
              border: Border.all(color: const Color(0xFFC2C6D4)),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Kunjungan',
                      style: TextStyle(fontSize: 12, color: Color(0xFF424752)),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '112',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF141D23),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text(
                      'Tercapai',
                      style: TextStyle(fontSize: 12, color: Color(0xFF424752)),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '98%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF006E25),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Visit List
          Column(
            children: const [
              VisitCard(
                storeName: 'Toko Barokah',
                address: 'Jl. Jend. Sudirman No. 45',
                time: '18 Ags 2026, 11:30',
              ),
              SizedBox(height: 4),
              VisitCard(
                storeName: 'Agen Nugget Jaya',
                address: 'Pasar Induk Kramat Jati Blok C',
                time: '18 Ags 2026, 10:15',
              ),
              SizedBox(height: 4),
              VisitCard(
                storeName: 'Warung Makan Sederhana',
                address: 'Jl. Raya Bogor KM 22',
                time: '18 Ags 2026, 09:00',
              ),
              SizedBox(height: 4),
              VisitCard(
                storeName: 'Grosir Daging Segar',
                address: 'Kawasan Industri Pulogadung',
                time: '18 Ags 2026, 08:20',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(
    String label, {
    bool isSelected = false,
    bool hasDropdown = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF003F87) : const Color(0xFFECF5FE),
        border: Border.all(
          color: isSelected ? const Color(0xFF003F87) : const Color(0xFFC2C6D4),
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: isSelected ? Colors.white : const Color(0xFF424752),
            ),
          ),
          if (hasDropdown) ...[
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: Color(0xFF424752),
            ),
          ],
        ],
      ),
    );
  }
}

class VisitCard extends StatelessWidget {
  final String storeName;
  final String address;
  final String time;

  const VisitCard({
    super.key,
    required this.storeName,
    required this.address,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF6FAFF),
        border: Border.all(color: const Color(0xFFC2C6D4)),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF0056B3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.storefront,
              color: Color(0xFFBBD0FF),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storeName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF141D23),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  address,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF424752),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 14,
                      color: Color(0xFF424752),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF424752),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF80F98B),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.check_circle, size: 12, color: Color(0xFF007327)),
                SizedBox(width: 4),
                Text(
                  'Selesai',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF007327),
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
