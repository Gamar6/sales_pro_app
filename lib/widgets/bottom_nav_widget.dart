import 'package:flutter/material.dart';
import '../screens/home/report.dart'; // Tempat VisitFormPage dsb.

class BottomNavWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  final String? activeOutletName;
  final VoidCallback? onFinishVisit;
  final String? activeVisitId;

  const BottomNavWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.activeOutletName,
    this.onFinishVisit,
    this.activeVisitId,
  });

  @override
  Widget build(BuildContext context) {
    const primaryNavy = Color(0xFF1E3A60);
    const pillIndicator = Color(0xFFD9E4EF);

    final bool hasActiveVisit =
        activeOutletName != null && activeOutletName!.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasActiveVisit) _buildActiveVisitBanner(context),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey.shade200, width: 1.0),
            ),
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: Colors.white,
              indicatorColor: pillIndicator,
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                final bool isSelected = states.contains(WidgetState.selected);
                return TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: primaryNavy,
                );
              }),
              iconTheme: WidgetStateProperty.all(
                const IconThemeData(color: primaryNavy, size: 24),
              ),
            ),
            child: NavigationBar(
              selectedIndex: currentIndex,
              elevation: 0,
              onDestinationSelected: onTap,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.rate_review_outlined),
                  selectedIcon: Icon(Icons.rate_review),
                  label: 'Retensi',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.inventory_2_outlined),
                  selectedIcon: Icon(Icons.inventory_2),
                  label: 'Stock',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.calculate_outlined),
                  selectedIcon: const Icon(Icons.calculate),
                  label: currentIndex == 3 ? 'Simulasi Produk' : 'Simulasi...',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveVisitBanner(BuildContext context) {
    final String outletName = activeOutletName ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFC2C6D4), width: 1),
          left: BorderSide(color: Color(0xFF003F87), width: 4),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'KUNJUNGAN AKTIF',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003F87),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  outletName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003F87),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onPressed: () async {
              if (outletName.isEmpty) return;

              final isSuccess = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => VisitFormPage(
                    outletName: outletName,
                    visitId: activeVisitId,
                  ),
                ),
              );

              if (isSuccess == true && onFinishVisit != null) {
                onFinishVisit!();
              }
            },
            child: const Text('Selesaikan Kunjungan'),
          ),
        ],
      ),
    );
  }
}
