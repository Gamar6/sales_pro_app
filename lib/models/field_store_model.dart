class FieldStoreModel {
  final int? id;
  final String storeName;
  final String? ownerName;
  final String? phoneNumber;
  final String address;
  final double latitude;
  final double longitude;
  final String? photoUrl;
  final DateTime? createdAt;

  const FieldStoreModel({
    this.id,
    required this.storeName,
    this.ownerName,
    this.phoneNumber,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.photoUrl,
    this.createdAt,
  });

  factory FieldStoreModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    return FieldStoreModel(
      id: int.tryParse(
        (json['id'] ?? json['field_store_id'])?.toString() ?? '',
      ),
      storeName: (json['store_name'] ?? json['name'] ?? '').toString(),
      ownerName: json['owner_name']?.toString(),
      phoneNumber: (json['phone_number'] ?? json['phone'])?.toString(),
      address: (json['address'] ?? '').toString(),
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      photoUrl: json['photo_url']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'store_name': storeName,
    'owner_name': ownerName,
    'phone_number': phoneNumber,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    if (photoUrl != null) 'photo_url': photoUrl,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
  };
}
