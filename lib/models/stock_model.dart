class StockProduct {
  final int id;
  final String title;
  final String subtitle;
  final String level;
  final double rawQty;
  final String unit;
  final String status;
  final double price;
  final double weight;
  final String weightUnit;
  final String packageUnit;
  final int packsPerPackage;
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
    required this.weight,
    required this.weightUnit,
    required this.packageUnit,
    required this.packsPerPackage,
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

      rawQty: (json['raw_qty'] as num?)?.toDouble() ?? 0,

      unit: json['unit']?.toString() ?? 'pcs',

      status: json['status']?.toString() ?? 'In Stock',

      price: (json['price'] as num?)?.toDouble() ?? 0,

      // Berat produk dari Laravel/Odoo
      weight: (json['weight'] as num?)?.toDouble() ?? 0,

      weightUnit: json['weight_unit']?.toString() ?? 'kg',

      // Packaging
      packageUnit: json['package_unit']?.toString() ?? 'karton',

      packsPerPackage: (json['packs_per_package'] as num?)?.toInt() ?? 1,

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
