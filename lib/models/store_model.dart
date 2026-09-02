class StoreModel {
  final int partnerId;
  final String partnerName;
  final String kota;
  final String salesName;
  final String phone;
  final String lastOrderDate;
  final int daysSince;
  final int weeksSince;
  final String retensiStatus;
  final String aktifGroup;
  final double avgRetensiWeeks;
  final double gapVsAverage;
  final double totalSales;
  final int priority;
  final String alamat;
  final double latitude;
  final double longitude;
  final bool isOccupied;
  final String? occupantMessage;

  StoreModel({
    required this.partnerId,
    required this.partnerName,
    required this.kota,
    required this.salesName,
    required this.phone,
    required this.lastOrderDate,
    required this.daysSince,
    required this.weeksSince,
    required this.retensiStatus,
    required this.aktifGroup,
    required this.avgRetensiWeeks,
    required this.gapVsAverage,
    required this.totalSales,
    required this.priority,
    required this.alamat,
    required this.latitude,
    required this.longitude,
    this.isOccupied = false,
    this.occupantMessage,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    // Helper fungsi konversi aman
    String parseString(dynamic val) {
      if (val == null || val == false) return '';
      return val.toString();
    }

    int parseInt(dynamic val, [int defaultVal = 0]) {
      if (val == null || val == false) return defaultVal;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? defaultVal;
    }

    double parseDouble(dynamic val, [double defaultVal = 0.0]) {
      if (val == null || val == false) return defaultVal;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? defaultVal;
    }

    bool parseBool(dynamic val) {
      if (val == null) return false;
      if (val is bool) return val;
      if (val is int) return val == 1;
      if (val is String) return val.toLowerCase() == 'true' || val == '1';
      return false;
    }

    return StoreModel(
      partnerId: parseInt(json['partner_id']),
      partnerName: parseString(json['partner_name']),
      kota: parseString(json['kota']),
      salesName: parseString(json['sales_name']),
      phone: parseString(json['phone']),
      lastOrderDate: parseString(json['last_order_date']),
      daysSince: parseInt(json['days_since']),
      weeksSince: parseInt(json['weeks_since']),
      retensiStatus: parseString(json['retensi_status']),
      aktifGroup: parseString(json['aktif_group']),
      avgRetensiWeeks: parseDouble(json['avg_retensi_weeks']),
      gapVsAverage: parseDouble(json['gap_vs_average']),
      totalSales: parseDouble(json['total_sales']),
      priority: parseInt(json['priority'], 99),
      alamat: parseString(json['alamat']),
      latitude: parseDouble(json['latitude'], -6.2088),
      longitude: parseDouble(json['longitude'], 106.8456),
      isOccupied: parseBool(json['is_occupied']),
      occupantMessage:
          json['occupant_message'] == null || json['occupant_message'] == false
          ? null
          : json['occupant_message'].toString(),
    );
  }
}