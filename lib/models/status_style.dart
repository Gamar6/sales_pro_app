import 'package:flutter/material.dart';

class StatusStyle {
  final Color color;
  final Color chipBgColor;
  final Color chipTextColor;
  final IconData chipIcon;

  const StatusStyle({
    required this.color,
    required this.chipBgColor,
    required this.chipTextColor,
    required this.chipIcon,
  });

  static StatusStyle getStyle(String status) {
    switch (status.toUpperCase().replaceAll(' ', '')) {
      case 'REDFLAG':
        return const StatusStyle(
          color: Color(0xFFBA1A1A),
          chipBgColor: Color(0xFFFFDAD6),
          chipTextColor: Color(0xFF93000A),
          chipIcon: Icons.warning,
        );
      case 'WARNING':
        return const StatusStyle(
          color: Color(0xFFFFB95F),
          chipBgColor: Color(0xFFFFDDB8),
          chipTextColor: Color(0xFF653E00),
          chipIcon: Icons.schedule,
        );
      case 'ACTIVE':
      case 'AKTIF':
        return const StatusStyle(
          color: Color(0xFF006C49),
          chipBgColor: Color(0xFF6CF8BB),
          chipTextColor: Color(0xFF00714D),
          chipIcon: Icons.check_circle,
        );
      case 'WARM':
        return const StatusStyle(
          color: Color(0xFFFF8C00),
          chipBgColor: Color(0xFFFFDAB9),
          chipTextColor: Color(0xFF8B4000),
          chipIcon: Icons.local_fire_department,
        );
      case 'COLD':
        return const StatusStyle(
          color: Color(0xFF75777F),
          chipBgColor: Color(0xFFE5EEFF),
          chipTextColor: Color(0xFF44474E),
          chipIcon: Icons.ac_unit,
        );
      case 'DEADZONE':
        return const StatusStyle(
          color: Color(0xFF303030),
          chipBgColor: Color(0xFFD0D0D0),
          chipTextColor: Color(0xFF1A1A1A),
          chipIcon: Icons.cancel,
        );
      default:
        return const StatusStyle(
          color: Color(0xFF75777F),
          chipBgColor: Color(0xFFE5EEFF),
          chipTextColor: Color(0xFF75777F),
          chipIcon: Icons.info,
        );
    }
  }
}
