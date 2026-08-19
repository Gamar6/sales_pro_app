import 'package:flutter/material.dart';

class StoreReviewPage extends StatefulWidget {
  const StoreReviewPage({Key? key}) : super(key: key);

  @override
  State<StoreReviewPage> createState() => _StoreReviewPageState();
}

class _StoreReviewPageState extends State<StoreReviewPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FF),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF031636)),
          onPressed: () {},
        ),
        title: const Text(
          'Retensi Toko',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF031636),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF031636)),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFC5C6CF), height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Map Context Header
            Container(
              height: 160,
              decoration: const BoxDecoration(
                color: Color(0xFFCBDBF5),
                image: DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDxPUoji6JkcFiimyX-pcQYC_wLNd0wv6HcI7lG7BwAmjC4iJlLvKvaS43EtqTcfSkluSYg54NJfRDCouCycueJAzbTgI4X-JSNAP47OfnHU3N_IuoLWPQ5Tk7E4TmVk7Qp0iny0AKXjU6IeAt0t-ausBtQ6DB1SCm6TiHyuv9zqoTEyglH84nckw9BMVk81npCr_Td_oCtrAF0gHWk6t5_krSGhcdqXuKEK29AI4Ra57o5IG2-REw6',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          const Color(0xFFF8F9FF),
                          const Color(0xFFF8F9FF).withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'WILAYAH AKTIF',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF44474E),
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Jakarta Selatan',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF031636),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(9999),
                            border: Border.all(color: const Color(0xFFC5C6CF)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              CircleAvatar(
                                radius: 4,
                                backgroundColor: Color(0xFF006C49),
                              ),
                              SizedBox(width: 6),
                              Text(
                                '4 Toko Terdekat',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF0B1C30),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Canvas
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Filter/Sort Row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0B1C30),
                            side: const BorderSide(color: Color(0xFFC5C6CF)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            minimumSize: const Size(0, 48),
                          ),
                          icon: const Text('Status: Semua'),
                          label: const Icon(Icons.expand_more, size: 18),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0B1C30),
                            side: const BorderSide(color: Color(0xFFC5C6CF)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            minimumSize: const Size(0, 48),
                          ),
                          icon: const Text('Urutkan: Jarak'),
                          label: const Icon(Icons.sort, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Card 1: Green (< 15 days)
                  _buildStoreCard(
                    borderColor: const Color(0xFF006C49),
                    title: 'Toko Makmur Jaya',
                    address:
                        'Jl. Sudirman No. 45, Kebayoran Baru, Jakarta Selatan',
                    chipText: '12 Hari Lalu (Senin, 12 Mei)',
                    chipBgColor: const Color(0xFF6CF8BB),
                    chipTextColor: const Color(0xFF00714D),
                    chipIcon: Icons.check_circle,
                    distance: '1.2 km',
                    isOccupied: false,
                  ),
                  const SizedBox(height: 12),

                  // Card 2: Yellow (> 15 days)
                  _buildStoreCard(
                    borderColor: const Color(0xFFFFB95F),
                    title: 'Sinar Baru Permai',
                    address:
                        'Jl. Antasari Blok B No. 12, Cipete, Jakarta Selatan',
                    chipText: '22 Hari Lalu (Kamis, 2 Mei)',
                    chipBgColor: const Color(0xFFFFDDB8),
                    chipTextColor: const Color(0xFF653E00),
                    chipIcon: Icons.schedule,
                    distance: '3.5 km',
                    isOccupied: false,
                  ),
                  const SizedBox(height: 12),

                  // Card 3: Red (> 30 days)
                  _buildStoreCard(
                    borderColor: const Color(0xFFBA1A1A),
                    title: 'Bintang Harapan',
                    address:
                        'Pasar Santa Lt. 1 Kios 45, Senopati, Jakarta Selatan',
                    chipText: '45 Hari Lalu (Senin, 9 Apr)',
                    chipBgColor: const Color(0xFFFFDAD6),
                    chipTextColor: const Color(0xFF93000A),
                    chipIcon: Icons.warning,
                    distance: '5.1 km',
                    isOccupied: false,
                    isErrorDistance: true,
                  ),
                  const SizedBox(height: 12),

                  // Card 4: Occupied (Greyed Out)
                  _buildStoreCard(
                    borderColor: const Color(0xFF75777F),
                    title: 'Toko Sentosa Jaya',
                    address:
                        'Jl. Fatmawati Raya No. 88, Cilandak, Jakarta Selatan',
                    chipText: '18 Hari Lalu (Senin, 6 Mei)',
                    chipBgColor: const Color(0xFFE5EEFF),
                    chipTextColor: const Color(0xFF75777F),
                    chipIcon: Icons.history,
                    distance: '2.8 km',
                    isOccupied: true,
                    occupantMessage: 'Sedang dikunjungi oleh Sales Budi',
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreCard({
    required Color borderColor,
    required String title,
    required String address,
    required String chipText,
    required Color chipBgColor,
    required Color chipTextColor,
    required IconData chipIcon,
    required String distance,
    bool isOccupied = false,
    bool isErrorDistance = false,
    String? occupantMessage,
  }) {
    return Opacity(
      opacity: isOccupied ? 0.9 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: isOccupied ? const Color(0xFFD3E4FE) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFC5C6CF)),
          boxShadow: [
            if (!isOccupied)
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 6, color: borderColor),
              ),
              if (isOccupied && occupantMessage != null)
                Positioned.fill(
                  child: Container(
                    color: const Color(0xFFD3E4FE).withOpacity(0.4),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF213145),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.lock,
                              size: 18,
                              color: Color(0xFFEAF1FF),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              occupantMessage,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFEAF1FF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0).copyWith(left: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isOccupied
                                      ? const Color(0xFF44474E)
                                      : const Color(0xFF0B1C30),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                address,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: isOccupied
                                      ? const Color(0xFF75777F)
                                      : const Color(0xFF44474E),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: chipBgColor,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: chipTextColor.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(chipIcon, size: 14, color: chipTextColor),
                              const SizedBox(width: 4),
                              Text(
                                chipText,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: chipTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFFDCE9FF), width: 1.0),
                        ),
                      ),
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 18,
                                color: isErrorDistance
                                    ? const Color(0xFFBA1A1A)
                                    : const Color(0xFF44474E),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                distance,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isErrorDistance
                                      ? const Color(0xFFBA1A1A)
                                      : const Color(0xFF44474E),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              SizedBox(
                                height: 48,
                                width: 48,
                                child: OutlinedButton(
                                  onPressed: isOccupied ? null : () {},
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    side: BorderSide(
                                      color: isOccupied
                                          ? const Color(0xFF75777F)
                                          : const Color(0xFF031636),
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.route,
                                    color: isOccupied
                                        ? const Color(0xFF75777F)
                                        : const Color(0xFF031636),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: isOccupied ? null : () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isOccupied
                                        ? const Color(0xFF75777F)
                                        : const Color(0xFF031636),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                    ),
                                  ),
                                  child: const Text(
                                    'Kunjungi',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
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
            ],
          ),
        ),
      ),
    );
  }
}
