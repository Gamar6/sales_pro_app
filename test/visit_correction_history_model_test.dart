import 'package:flutter_test/flutter_test.dart';
import 'package:sales_app/models/visit_correction_history_model.dart';

void main() {
  group('VisitCorrectionHistoryModel', () {
    test('parses the server correction window and effective data', () {
      final history = VisitCorrectionHistoryModel.fromJson({
        'visit_id': 481,
        'status': 'COMPLETED',
        'completed_at': '2026-11-12 08:00:00',
        'correction_window': {
          'deadline_at': '2026-11-12 20:00:00',
          'can_correct': true,
        },
        'original_data': {'stock_percentage': 80},
        'effective_data': {'stock_percentage': 65},
        'corrections': [
          {
            'id': 12,
            'status': 'approved',
            'previous_data': {'stock_percentage': 80},
            'correction_data': {'stock_percentage': 65},
          },
        ],
      });

      expect(history.visitId, '481');
      expect(history.status, 'COMPLETED');
      expect(history.canCorrect, isTrue);
      expect(history.deadlineAt, DateTime(2026, 11, 12, 20));
      expect(history.originalData['stock_percentage'], 80);
      expect(history.effectiveData['stock_percentage'], 65);
      expect(history.corrections.single['status'], 'approved');
    });

    test('rejects an incomplete correction history response', () {
      expect(
        () => VisitCorrectionHistoryModel.fromJson({
          'visit_id': 481,
          'status': 'COMPLETED',
        }),
        throwsFormatException,
      );
    });
  });
}
