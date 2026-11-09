import 'package:image_picker/image_picker.dart';

class VisitReportModel {
  final String storeType;
  final int storeId;
  final String? storeVisitId;
  final String picName;
  final List<String> activities;
  final int? stockPercentage;
  final int? stockPcs;
  final String? notes;
  final List<XFile> photos;
  final XFile? checkInPhoto;
  final String? checkInPhotoUrl;
  final double checkInLatitude;
  final double checkInLongitude;
  final double salesAccuracy;
  final DateTime visitedAt;
  final DateTime locationCapturedAt;

  VisitReportModel({
    required this.storeType,
    required this.storeId,
    this.storeVisitId,
    required this.picName,
    required this.activities,
    required this.stockPercentage,
    required this.stockPcs,
    this.notes,
    this.photos = const [],
    this.checkInPhoto,
    this.checkInPhotoUrl,
    required this.checkInLatitude,
    required this.checkInLongitude,
    this.salesAccuracy = 0,
    DateTime? visitedAt,
    DateTime? locationCapturedAt,
  }) : visitedAt = visitedAt ?? DateTime.now().toUtc(),
       locationCapturedAt = locationCapturedAt ?? DateTime.now().toUtc();

  factory VisitReportModel.fromJson(Map<String, dynamic> json) {
    final rawActivities = json['activities'];
    final rawPhotos = json['photos'];

    return VisitReportModel(
      storeType: (json['store_type'] ?? 'regular').toString(),
      storeId: _parseInt(json['store_id']),
      storeVisitId: json['store_visit_id']?.toString(),
      picName: (json['pic_name'] ?? '').toString(),
      activities: rawActivities is List
          ? rawActivities.map((value) => value.toString()).toList()
          : const [],
      stockPercentage: _parseNullableInt(json['stock_percentage']),
      stockPcs: _parseNullableInt(json['stock_pcs']),
      notes: json['notes']?.toString(),
      photos: rawPhotos is List
          ? rawPhotos
                .map((value) => value.toString())
                .where((path) => path.isNotEmpty)
                .map(XFile.new)
                .toList()
          : const [],
      checkInPhotoUrl: (json['check_in_photo'] ?? json['check_in_photos'])
          ?.toString(),
      checkInLatitude: _parseDouble(json['check_in_lat']),
      checkInLongitude: _parseDouble(json['check_in_lng']),
      salesAccuracy: _parseDouble(json['sales_accuracy']),
      visitedAt: _parseDateTime(json['visited_at']),
      locationCapturedAt: _parseDateTime(json['location_captured_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'store_type': storeType,
    'store_id': storeId,
    'store_visit_id': ?storeVisitId,
    'pic_name': picName,
    'activities': activities,
    'stock_percentage': ?stockPercentage,
    'stock_pcs': ?stockPcs,
    'notes': notes,
    'photos': photos.map((photo) => photo.name).toList(),
    'check_in_photo': ?checkInPhoto?.name ?? checkInPhotoUrl,
    'check_in_lat': checkInLatitude,
    'check_in_lng': checkInLongitude,
    'sales_latitude': checkInLatitude,
    'sales_longitude': checkInLongitude,
    'sales_accuracy': salesAccuracy,
    'visited_at': visitedAt.toIso8601String(),
    'location_captured_at': locationCapturedAt.toIso8601String(),
  };

  Map<String, String> toFieldsMap() {
    final fields = <String, String>{
      'store_type': storeType,
      'store_id': storeId.toString(),
      'store_visit_id': ?storeVisitId,
      'pic_name': picName,
      'stock_percentage': ?stockPercentage?.toString(),
      'stock_pcs': ?stockPcs?.toString(),
      'notes': ?notes,
      'check_in_lat': checkInLatitude.toString(),
      'check_in_lng': checkInLongitude.toString(),
      'sales_latitude': checkInLatitude.toString(),
      'sales_longitude': checkInLongitude.toString(),
      'sales_accuracy': salesAccuracy.toString(),
      'visited_at': visitedAt.toIso8601String(),
      'location_captured_at': locationCapturedAt.toIso8601String(),
    };

    for (var index = 0; index < activities.length; index++) {
      fields['activities[$index]'] = activities[index];
    }

    return fields;
  }

  Map<String, String> toRegularVisitFieldsMap() {
    final fields = <String, String>{
      'store_type': storeType,
      'store_id': storeId.toString(),
      'store_visit_id': ?storeVisitId,
      'pic_name': picName,
      'stock_percentage': stockPercentage?.toString() ?? '',
      'stock_pcs': stockPcs?.toString() ?? '',
      'notes': notes ?? '',
      'sales_latitude': checkInLatitude.toString(),
      'sales_longitude': checkInLongitude.toString(),
      'sales_accuracy': salesAccuracy.toString(),
      'visited_at': visitedAt.toIso8601String(),
      'location_captured_at': locationCapturedAt.toIso8601String(),
    };

    for (var index = 0; index < activities.length; index++) {
      fields['activities[$index]'] = activities[index];
    }

    return fields;
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime _parseDateTime(dynamic value) =>
      DateTime.tryParse(value?.toString() ?? '')?.toUtc() ??
      DateTime.now().toUtc();
}
