class Store {
  final int id;
  final String name;
  final String address;
  final String area;
  final double latitude;
  final double longitude;
  final String distanceLabel;
  final bool isClaimed;
  final String? claimedByName;
  final String status;
  
  Store({
    required this.id,
    required this.name,
    required this.address,
    required this.area,
    required this.latitude,
    required this.longitude,
    required this.distanceLabel,
    required this.isClaimed,
    this.claimedByName,
    required this.status,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] ?? 0,
      name: json['store_name'] ?? json['name'] ?? '',
      address: json['address'] ?? '',
      area: json['area'] ?? '',
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      distanceLabel: json['distance_label'] ?? '',
      isClaimed: json['is_claimed'] ?? false,
      claimedByName: json['claimed_by_name'],
      status: json['status'] ?? 'available',
    );
  }
}
