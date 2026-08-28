// lib/model/partner_model.dart

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
  });

  // Jika backend kirim false / null -> diubah jadi "" (String)
  static String _parseString(dynamic value) {
    if (value == null || value == false) return '';
    if (value is String) return value;
    return value.toString();
  }

  // Jika backend kirim false / null / String -> diubah jadi int
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // Jika backend kirim false / null / String -> diubah jadi double
  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // --- FACTORY FROM JSON ---
  factory Partner.fromJson(Map<String, dynamic> json) {
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
    );
  }
}
