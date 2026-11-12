class VisitCorrectionHistoryModel {
  final String visitId;
  final String status;
  final DateTime? completedAt;
  final DateTime? deadlineAt;
  final bool canCorrect;
  final Map<String, dynamic> originalData;
  final Map<String, dynamic> effectiveData;
  final List<Map<String, dynamic>> corrections;

  const VisitCorrectionHistoryModel({
    required this.visitId,
    required this.status,
    required this.completedAt,
    required this.deadlineAt,
    required this.canCorrect,
    required this.originalData,
    required this.effectiveData,
    required this.corrections,
  });

  factory VisitCorrectionHistoryModel.fromJson(Map<String, dynamic> json) {
    final window = json['correction_window'];
    if (window is! Map) {
      throw const FormatException('Data window koreksi tidak valid.');
    }

    final visitId = json['visit_id'];
    final status = json['status'];
    final rawCorrections = json['corrections'];

    if (visitId == null ||
        status == null ||
        json['original_data'] is! Map ||
        json['effective_data'] is! Map ||
        rawCorrections is! List) {
      throw const FormatException('Data riwayat koreksi tidak valid.');
    }

    return VisitCorrectionHistoryModel(
      visitId: visitId.toString(),
      status: status.toString(),
      completedAt: DateTime.tryParse(
        json['completed_at']?.toString() ?? '',
      )?.toLocal(),
      deadlineAt: DateTime.tryParse(
        window['deadline_at']?.toString() ?? '',
      )?.toLocal(),
      canCorrect: window['can_correct'] == true,
      originalData: Map<String, dynamic>.from(json['original_data'] as Map),
      effectiveData: Map<String, dynamic>.from(json['effective_data'] as Map),
      corrections: rawCorrections.map((correction) {
        if (correction is! Map) {
          throw const FormatException('Data item koreksi tidak valid.');
        }
        return Map<String, dynamic>.from(correction);
      }).toList(),
    );
  }
}
