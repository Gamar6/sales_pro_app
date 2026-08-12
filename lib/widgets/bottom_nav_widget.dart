import 'package:flutter/material.dart';

class BottomNavWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavWidget({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFF006C49),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType
          .fixed, // Penting jika menu lebih dari 3 agar tidak error
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag),
          label: 'Resensi',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Stock'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Simulasi Harga'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
