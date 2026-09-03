import 'package:flutter_test/flutter_test.dart';
import 'package:sales_app/models/partner_model.dart';

void main() {
  Partner partnerWithStatus(String status) {
    return Partner.fromJson({
      'partner_id': 1,
      'partner_name': 'Toko Uji',
      'claim_info': {'status': status},
    });
  }

  group('Partner visit status', () {
    test('AVAILABLE store can be visited', () {
      final partner = partnerWithStatus('AVAILABLE');

      expect(partner.visitStatus, 'IDLE');
      expect(partner.isOccupied, isFalse);
    });

    test('IN_VISIT store is occupied', () {
      final partner = partnerWithStatus('IN_VISIT');

      expect(partner.isOccupied, isTrue);
    });

    test('COMPLETED store is occupied for the current day', () {
      final partner = partnerWithStatus('COMPLETED');

      expect(partner.isOccupied, isTrue);
    });

    test('CANCELLED store can be visited again', () {
      final partner = partnerWithStatus('CANCELLED');

      expect(partner.isOccupied, isFalse);
    });
  });
}
