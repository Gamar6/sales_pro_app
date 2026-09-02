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
      status: json['status']?.toString() ?? 'error',
      totalSkus: (json['total_skus'] as num?)?.toInt() ?? 0,
      lowStockCount: (json['low_stock_count'] as num?)?.toInt() ?? 0,
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
  final double price;
  final String? imageUrl;

  StockProduct({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.level,
    required this.rawQty,
    required this.unit,
    required this.status,
    required this.price,
    this.imageUrl,
  });

  factory StockProduct.fromJson(Map<String, dynamic> json) {
    return StockProduct(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,

      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      level: json['level']?.toString() ?? '0',

      rawQty: (json['raw_qty'] as num?)?.toInt() ?? 0,

      unit: json['unit']?.toString() ?? 'pcs',

      status: json['status']?.toString() ?? 'In Stock',

      price: (json['price'] as num?)?.toDouble() ?? 0,

      imageUrl: json['imageUrl']?.toString() ?? json['image_url']?.toString(),
    );
  }

  String get displayImageUrl {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return imageUrl!;
    }

    return 'https://www.fivafood.co.id/web/image/product.product/17/image_512?unique=10e2976';
  }
}
