import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sales_app/models/field_store_model.dart';
import 'package:sales_app/models/visit_report_model.dart';

void main() {
  group('FieldStoreModel', () {
    test('serializes and parses field store data', () {
      final original = FieldStoreModel(
        id: 8,
        storeName: 'Toko Baru',
        ownerName: 'Pemilik',
        phoneNumber: '08123456789',
        address: 'Jalan Merdeka',
        latitude: -6.2,
        longitude: 106.8,
        photoUrl: 'https://example.test/toko.jpg',
      );

      final parsed = FieldStoreModel.fromJson(original.toJson());

      expect(parsed.id, 8);
      expect(parsed.storeName, 'Toko Baru');
      expect(parsed.ownerName, 'Pemilik');
      expect(parsed.latitude, -6.2);
      expect(parsed.phoneNumber, '08123456789');
      expect(parsed.photoUrl, 'https://example.test/toko.jpg');
    });
  });

  group('VisitReportModel', () {
    test('serializes check-in fields to json and multipart fields', () {
      final report = VisitReportModel(
        storeType: 'field',
        storeId: 12,
        picName: 'PIC',
        activities: const ['Visit', 'Order'],
        stockPercentage: 45,
        stockPcs: 10,
        notes: 'PIC: PIC\nAktivitas: Visit, Order',
        photos: [XFile('check-in.jpg')],
        checkInPhoto: XFile('check-in.jpg'),
        checkInLatitude: -6.2,
        checkInLongitude: 106.8,
        visitedAt: DateTime.utc(2025, 1, 1),
      );

      final json = report.toJson();
      final fields = report.toFieldsMap();

      expect(json['store_type'], 'field');
      expect(json['store_id'], 12);
      expect(json['pic_name'], 'PIC');
      expect(json['activities'], ['Visit', 'Order']);
      expect(json['stock_percentage'], 45);
      expect(json['stock_pcs'], 10);
      expect(json['check_in_photo'], 'check-in.jpg');
      expect(fields['store_id'], '12');
      expect(fields['pic_name'], 'PIC');
      expect(fields['activities[0]'], 'Visit');
      expect(fields['stock_percentage'], '45');
      expect(fields['stock_pcs'], '10');
      expect(fields['check_in_lat'], '-6.2');
      expect(fields['check_in_lng'], '106.8');
      expect(fields['visited_at'], '2025-01-01T00:00:00.000Z');
      expect(VisitReportModel.fromJson(json).picName, 'PIC');
    });

    test(
      'regular visit payload keeps the StoreVisit relation and GPS fields',
      () {
        final report = VisitReportModel(
          storeType: 'regular',
          storeId: 70,
          storeVisitId: '23',
          picName: 'PIC',
          activities: const ['Visit'],
          stockPercentage: 45,
          stockPcs: 10,
          notes: 'Follow up',
          photos: [XFile('visit.jpg')],
          checkInLatitude: -6.2,
          checkInLongitude: 106.8,
          salesAccuracy: 4.5,
        );

        final fields = report.toRegularVisitFieldsMap();

        expect(fields['store_visit_id'], '23');
        expect(fields['pic_name'], 'PIC');
        expect(fields['activities[0]'], 'Visit');
        expect(fields['sales_latitude'], '-6.2');
        expect(fields['sales_longitude'], '106.8');
        expect(fields['sales_accuracy'], '4.5');
      },
    );
  });
}
