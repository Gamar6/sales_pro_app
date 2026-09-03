class Partner {
  final int partnerId;
  final String partnerName;
  final String kota;
  final int daysSince;
  final String retensiStatus;
  final String aktifGroup;
  final String alamat;
  final double latitude;
  final double longitude;
  final String visitStatus;
  final String salesName;

  Partner({
    required this.partnerId,
    required this.partnerName,
    required this.kota,
    required this.daysSince,
    required this.retensiStatus,
    required this.aktifGroup,
    required this.alamat,
    required this.latitude,
    required this.longitude,
    this.visitStatus = 'IDLE',
    this.salesName = '',
  });

  static String _parseString(dynamic value) {
    if (value == null || value == false) return '';
    if (value is String) return value;
    return value.toString();
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  bool get isOccupied => const {
    'IN_VISIT',
    'ON_VISIT',
    'ON VISIT',
    'CLAIMED',
    'IN_PROGRESS',
    'COMPLETED',
    'SELESAI',
  }.contains(visitStatus);

  factory Partner.fromJson(Map<String, dynamic> json) {
    String statusRaw = '';
    String salesNameRaw = '';

    // Check claim_info
    if (json['claim_info'] != null && json['claim_info'] is Map) {
      final claimMap = json['claim_info'] as Map;
      statusRaw = _parseString(claimMap['status']);
      salesNameRaw = _parseString(
        claimMap['sales_name'] ??
            claimMap['user_name'] ??
            claimMap['name'] ??
            claimMap['claimed_by_name'] ??
            claimMap['claimed_by'] ??
            claimMap['salesman'] ??
            claimMap['sales'],
      );
    }

    // Fallback jika tidak ada claim_info atau salesName di claim_info masih kosong
    if (statusRaw.isEmpty) {
      statusRaw = _parseString(json['visit_status'] ?? json['status']);
    }
    if (salesNameRaw.isEmpty) {
      salesNameRaw = _parseString(
        json['sales_name'] ??
            json['user_name'] ??
            json['claimed_by_name'] ??
            json['claimed_by'] ??
            json['salesman'] ??
            json['sales'],
      );
    }

    String visitState = statusRaw.toUpperCase();
    if (visitState == 'AVAILABLE' || visitState.isEmpty) {
      visitState = 'IDLE';
    }

    return Partner(
      partnerId: _parseInt(json['partner_id']),
      partnerName: _parseString(json['partner_name']),
      kota: _parseString(json['kota']),
      daysSince: _parseInt(json['days_since']),
      retensiStatus: _parseString(json['retensi_status']),
      aktifGroup: _parseString(json['aktif_group']),
      alamat: _parseString(json['alamat']),
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      visitStatus: visitState,
      salesName: salesNameRaw,
    );
  }

  Partner copyWith({
    int? partnerId,
    String? partnerName,
    String? kota,
    int? daysSince,
    String? retensiStatus,
    String? aktifGroup,
    String? alamat,
    double? latitude,
    double? longitude,
    String? visitStatus,
    String? salesName,
  }) {
    return Partner(
      partnerId: partnerId ?? this.partnerId,
      partnerName: partnerName ?? this.partnerName,
      kota: kota ?? this.kota,
      daysSince: daysSince ?? this.daysSince,
      retensiStatus: retensiStatus ?? this.retensiStatus,
      aktifGroup: aktifGroup ?? this.aktifGroup,
      alamat: alamat ?? this.alamat,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      visitStatus: visitStatus ?? this.visitStatus,
      salesName: salesName ?? this.salesName,
    );
  }
}