class StockResponse {
  final String status;
  final int totalSkus;
  final int lowStockCount;
  final List<StockProduct> data;

  StockResponse({
    required this.status,
    required this.totalSkus,
    required this.lowStockCount,
    required this.data,
  });

  factory StockResponse.fromJson(Map<String, dynamic> json) {
    return StockResponse(
      status: json['status'] ?? 'error',
      totalSkus: json['total_skus'] ?? 0,
      lowStockCount: json['low_stock_count'] ?? 0,
      data: (json['data'] as List? ?? [])
          .map((item) => StockProduct.fromJson(item))
          .toList(),
    );
  }
}

class StockProduct {
  final int id;
  final String title;
  final String subtitle;
  final String level;
  final int rawQty;
  final String unit;
  final String status;
  final String? imageUrl;

  StockProduct({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.level,
    required this.rawQty,
    required this.unit,
    required this.status,
    this.imageUrl,
  });

  factory StockProduct.fromJson(Map<String, dynamic> json) {
    return StockProduct(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      level: json['level'] ?? '0',
      rawQty: json['raw_qty'] ?? 0,
      unit: json['unit'] ?? 'pcs',
      status: json['status'] ?? 'In Stock',
      imageUrl:
          json['imageUrl'] ??
          json['image_url'], // Antisipasi beda format key dari API
    );
  }

  // Getter otomatis untuk URL gambar (Lebih rapi dan idiomatik di Dart)
  String get displayImageUrl {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return imageUrl!;
    }
    return 'https://www.fivafood.co.id/web/image/product.product/17/image_512?unique=10e2976';
  }
}
