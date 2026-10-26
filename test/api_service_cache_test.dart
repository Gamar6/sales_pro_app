import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sales_app/services/api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApiService cached partners', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('loads cached partners for the signed-in user', () async {
      SharedPreferences.setMockInitialValues({
        'user_id': '42',
        'retensi_partners_cache:42': jsonEncode([
          {
            'partner_id': 7,
            'partner_name': 'Toko Offline',
            'kota': 'Bandung',
            'days_since': 3,
            'retensi_status': 'ACTIVE',
            'aktif_group': 'A',
            'alamat': 'Jalan Contoh',
            'latitude': -6.9,
            'longitude': 107.6,
          },
        ]),
      });

      final partners = await ApiService().getCachedPartners();

      expect(partners, hasLength(1));
      expect(partners!.single.partnerId, 7);
      expect(partners.single.partnerName, 'Toko Offline');
    });

    test('does not read another user cache', () async {
      SharedPreferences.setMockInitialValues({
        'user_id': '42',
        'retensi_partners_cache:99': jsonEncode([
          {'partner_id': 7, 'partner_name': 'Toko User Lain'},
        ]),
      });

      final partners = await ApiService().getCachedPartners();

      expect(partners, isNull);
    });
  });
}
