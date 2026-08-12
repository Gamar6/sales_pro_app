class Store {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String area;
  final String distanceLabel;
  final String? status;

  Store({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.area,
    required this.distanceLabel,
    this.status,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      area: json['area'] ?? 'Lainnya',
      distanceLabel: json['distance_label'] ?? '0 km',
      status: json['status'] ?? 'Tidak Aktif',
    );
  }
}
