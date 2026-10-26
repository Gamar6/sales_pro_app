import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sales_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ApiService cached partners', () {
    test('loads only the current user cache', () async {
      SharedPreferences.setMockInitialValues({
        'user_id': 'sales-1',
        'retensi_partners_cache_sales-1': jsonEncode([
          {'partner_id': 23, 'partner_name': 'Toko Offline'},
        ]),
        'retensi_partners_cache_sales-2': jsonEncode([
          {'partner_id': 99, 'partner_name': 'Toko Pengguna Lain'},
        ]),
      });

      final partners = await ApiService().getCachedPartners();

      expect(partners, hasLength(1));
      expect(partners!.single.partnerId, 23);
      expect(partners.single.partnerName, 'Toko Offline');
    });

    test(
      'does not load another account cache when user id is missing',
      () async {
        SharedPreferences.setMockInitialValues({
          'retensi_partners_cache_sales-1': jsonEncode([
            {'partner_id': 23, 'partner_name': 'Toko Offline'},
          ]),
        });

        final partners = await ApiService().getCachedPartners();

        expect(partners, isNull);
      },
    );
  });
}
