import 'package:flutter/material.dart';
import '../utils/date_helper.dart';

class HomeHeader extends StatelessWidget {
  final String salesName;

  const HomeHeader({super.key, required this.salesName});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          salesName,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF424752),
          ),
        ),
        Text(
          DateHelper.getFormattedDate(),
          style: const TextStyle(fontSize: 12, color: Color(0xFF424752)),
        ),
      ],
    );
  }
}
