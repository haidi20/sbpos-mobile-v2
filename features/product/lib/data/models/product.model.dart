import 'package:product/data/models/category.model.dart';

class ProductModel {
  final int? id;
  final int? idServer;
  final String? name;
  final String? slug;
  final String? code;
  final String? type;
  final String? barcodeSymbology;
  final int? categoryId;
  final int? unitId;
  final int? businessId;
  final double? cost;
  final double? price;
  final double? qty;
  final double? alertQuantity;
  final String? image;
  final String? productDetails;
  final bool? isActive;
  final bool? isDiffPrice;
  final DateTime? deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? syncedAt;

  final int? categoryParentId;
  final String? categoryParentName;
  final CategoryModel? category;

  final double? gofoodPrice;
  final double? grabfoodPrice;
  final double? shopeefoodPrice;

  const ProductModel({
    this.id,
    this.idServer,
    this.name,
    this.slug,
    this.code,
    this.type,
    this.barcodeSymbology,
    this.categoryId,
    this.unitId,
    this.businessId,
    this.cost,
    this.price,
    this.qty,
    this.alertQuantity,
    this.image,
    this.productDetails,
    this.isActive,
    this.isDiffPrice,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.syncedAt,
    this.categoryParentId,
    this.categoryParentName,
    this.category,
    this.gofoodPrice,
    this.grabfoodPrice,
    this.shopeefoodPrice,
  });

  ProductModel copyWith({
    int? id,
    int? idServer,
    String? name,
    String? slug,
    String? code,
    String? type,
    String? barcodeSymbology,
    int? categoryId,
    int? unitId,
    int? businessId,
    double? cost,
    double? price,
    double? qty,
    double? alertQuantity,
    String? image,
    String? productDetails,
    bool? isActive,
    bool? isDiffPrice,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
    int? categoryParentId,
    String? categoryParentName,
    CategoryModel? category,
    double? gofoodPrice,
    double? grabfoodPrice,
    double? shopeefoodPrice,
  }) {
    return ProductModel(
      id: id ?? this.id,
      idServer: idServer ?? this.idServer,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      code: code ?? this.code,
      type: type ?? this.type,
      barcodeSymbology: barcodeSymbology ?? this.barcodeSymbology,
      categoryId: categoryId ?? this.categoryId,
      unitId: unitId ?? this.unitId,
      businessId: businessId ?? this.businessId,
      cost: cost ?? this.cost,
      price: price ?? this.price,
      qty: qty ?? this.qty,
      alertQuantity: alertQuantity ?? this.alertQuantity,
      image: image ?? this.image,
      productDetails: productDetails ?? this.productDetails,
      isActive: isActive ?? this.isActive,
      isDiffPrice: isDiffPrice ?? this.isDiffPrice,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      categoryParentId: categoryParentId ?? this.categoryParentId,
      categoryParentName: categoryParentName ?? this.categoryParentName,
      category: category ?? this.category,
      gofoodPrice: gofoodPrice ?? this.gofoodPrice,
      grabfoodPrice: grabfoodPrice ?? this.grabfoodPrice,
      shopeefoodPrice: shopeefoodPrice ?? this.shopeefoodPrice,
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: _toInt(json['id']),
        idServer: _toInt(json['id_server'] ?? json['id']),
        name: json['name'] as String?,
        slug: json['slug'] as String?,
        code: json['code'] as String?,
        type: json['type'] as String?,
        barcodeSymbology: json['barcode_symbology'] as String?,
        categoryId: _toInt(json['category_id']),
        unitId: _toInt(json['unit_id']),
        businessId: _toInt(json['business_id']),
        cost: _toDouble(json['cost']),
        price: _toDouble(json['price']),
        qty: _toDouble(json['qty'] ?? json['quantity']),
        alertQuantity: _toDouble(json['alert_quantity']),
        image: json['image'] as String?,
        productDetails: json['product_details'] as String?,
        isActive: _toBool(json['is_active']),
        isDiffPrice: _toBool(json['is_diff_price']),
        deletedAt: _toDate(json['deleted_at']),
        createdAt: _toDate(json['created_at']),
        updatedAt: _toDate(json['updated_at']),
        syncedAt: _toDate(json['synced_at']),
        categoryParentId:
            _toInt(json['category_parent_id'] ?? json['category_parents_id']),
        categoryParentName: json['category_parent_name'] as String?,
        category: json['category'] != null
            ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
            : null,
        gofoodPrice: _toDouble(json['gofood_price']),
        grabfoodPrice: _toDouble(json['grabfood_price']),
        shopeefoodPrice: _toDouble(json['shopeefood_price']),
      );

  Map<String, dynamic> toJson() => {
        'id': idServer,
        'id_server': idServer,
        'name': name,
        'slug': slug,
        'code': code,
        'type': type,
        'barcode_symbology': barcodeSymbology,
        'category_id': categoryId,
        'unit_id': unitId,
        'business_id': businessId,
        'cost': cost,
        'price': price,
        'qty': qty,
        'alert_quantity': alertQuantity,
        'image': image,
        'product_details': productDetails,
        'is_active': isActive,
        'is_diff_price': isDiffPrice,
        'deleted_at': deletedAt?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'synced_at': syncedAt?.toIso8601String(),
        'category_parent_id': categoryParentId,
        'category_parent_name': categoryParentName,
        'category': category?.toJson(),
        'gofood_price': gofoodPrice,
        'grabfood_price': grabfoodPrice,
        'shopeefood_price': shopeefoodPrice,
      };

  Map<String, dynamic> toInsertDbLocal() => {
        'id': null,
        'id_server': idServer,
        'name': name,
        'slug': slug,
        'code': code,
        'type': type,
        'barcode_symbology': barcodeSymbology,
        'category_id': categoryId,
        'unit_id': unitId,
        'business_id': businessId,
        'cost': cost,
        'price': price,
        'qty': qty,
        'alert_quantity': alertQuantity,
        'image': image,
        'product_details': productDetails,
        'is_active': isActive,
        'is_diff_price': isDiffPrice,
        'deleted_at': deletedAt?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'synced_at': syncedAt?.toIso8601String(),
        'category_parent_id': categoryParentId,
        'category_parent_name': categoryParentName,
      };

  factory ProductModel.fromDbLocal(Map<String, dynamic> map) {
    return ProductModel(
      id: _toInt(map['id']),
      idServer: _toInt(map['id_server']),
      name: map['name'] as String?,
      slug: map['slug'] as String?,
      code: map['code'] as String?,
      type: map['type'] as String?,
      barcodeSymbology: map['barcode_symbology'] as String?,
      categoryId: _toInt(map['category_id']),
      unitId: _toInt(map['unit_id']),
      businessId: _toInt(map['business_id']),
      cost: _toDouble(map['cost']),
      price: _toDouble(map['price']),
      qty: _toDouble(map['qty']),
      alertQuantity: _toDouble(map['alert_quantity']),
      image: map['image'] as String?,
      productDetails: map['product_details'] as String?,
      isActive: _toBool(map['is_active']),
      isDiffPrice: _toBool(map['is_diff_price']),
      deletedAt: _toDate(map['deleted_at']),
      createdAt: _toDate(map['created_at']),
      updatedAt: _toDate(map['updated_at']),
      syncedAt: _toDate(map['synced_at']),
      categoryParentId: _toInt(map['category_parent_id']),
      categoryParentName: map['category_parent_name'] as String?,
      category: map['category'] != null
          ? CategoryModel.fromJson(Map<String, dynamic>.from(map['category']))
          : null,
      gofoodPrice: _toDouble(map['gofood_price']),
      grabfoodPrice: _toDouble(map['grabfood_price']),
      shopeefoodPrice: _toDouble(map['shopeefood_price']),
    );
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    return null;
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static DateTime? _toDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  static bool? _toBool(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    if (v is int) return v == 1;
    if (v is String) {
      if (v == '1') return true;
      if (v == '0') return false;
      return v.toLowerCase() == 'true';
    }
    return null;
  }
}
