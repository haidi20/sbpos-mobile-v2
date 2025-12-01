import 'package:product/data/models/category_model.dart';
import 'package:product/domain/entities/product_entity.dart';

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

  ProductModel({
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

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Helper untuk parse DateTime
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) {
        final numValue = num.tryParse(value);
        return numValue?.toDouble();
      }
      return null;
    }

    bool? parseBool(dynamic value) {
      if (value == null) return null;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) {
        if (value == '1' || value.toLowerCase() == 'true') return true;
        if (value == '0' || value.toLowerCase() == 'false') return false;
      }
      return null;
    }

    // Logic pembersih URL dipindah kesini (Best Practice)
    String? cleanImage(String? url) {
      if (url == null) return null;
      return url.replaceAll(r'\/', '/').replaceAll(r'http:', 'https:');
    }

    return ProductModel(
      id: json['id'] as int?,
      idServer: json['id'] as int?,
      name: json['name'] as String?,
      slug: json['slug'] as String?,
      code: json['code'] as String?,
      type: json['type'] as String?,
      barcodeSymbology: json['barcode_symbology'] as String?,
      categoryId: json['category_id'] as int?,
      unitId: json['unit_id'] as int?,
      businessId: json['business_id'] as int?,
      cost: parseDouble(json['cost']),
      price: parseDouble(json['price']),
      qty: parseDouble(json['qty']),
      alertQuantity: parseDouble(json['alert_quantity']),
      image: cleanImage(json['image'] as String?),
      productDetails: json['product_details'] as String?,
      isActive: parseBool(json['is_active']),
      isDiffPrice: parseBool(json['is_diffPrice']),
      deletedAt: parseDate(json['deleted_at']),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      syncedAt: json['synced_at'] != null ? DateTime.now() : null,

      // 👇 Parse field kategori baru
      categoryParentId: json['category_parent_id'] as int?,
      categoryParentName: json['category_parent_name'] as String?,
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      gofoodPrice: parseDouble(json['gofood_price']),
      grabfoodPrice: parseDouble(json['grabfood_price']),
      shopeefoodPrice: parseDouble(json['shopeefood_price']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'is_diffPrice': isDiffPrice,
      'deleted_at': deletedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'category_parent_id': categoryParentId,
      'category_parent_name': categoryParentName,
      'category': category?.toJson(),
      'gofood_price': gofoodPrice,
      'grabfood_price': grabfoodPrice,
      'shopeefood_price': shopeefoodPrice,
    };
  }

  // Convert to entity
  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      idServer: idServer,
      name: name,
      slug: slug,
      code: code,
      type: type,
      barcodeSymbology: barcodeSymbology,
      categoryId: categoryId,
      unitId: unitId,
      businessId: businessId,
      cost: cost,
      price: price,
      qty: qty,
      alertQuantity: alertQuantity,
      image: image,
      productDetails: productDetails,
      isActive: isActive ?? false,
      isDiffPrice: isDiffPrice,
      deletedAt: deletedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      syncedAt: syncedAt,

      // Jika ProductEntity juga perlu field ini, tambahkan
      categoryParentId: categoryParentId,
      categoryParentName: categoryParentName,
      category: category?.toEntity(),
    );
  }

  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      idServer: entity.idServer,
      name: entity.name,
      slug: entity.slug,
      code: entity.code,
      type: entity.type,
      barcodeSymbology: entity.barcodeSymbology,
      categoryId: entity.categoryId,
      unitId: entity.unitId,
      businessId: entity.businessId,
      cost: entity.cost,
      price: entity.price,
      qty: entity.qty,
      alertQuantity: entity.alertQuantity,
      image: entity.image,
      productDetails: entity.productDetails,
      isActive: entity.isActive,
      isDiffPrice: entity.isDiffPrice,
      deletedAt: entity.deletedAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      syncedAt: entity.syncedAt,
      categoryParentId: entity.categoryParentId,
      categoryParentName: entity.categoryParentName,
      category: entity.category != null
          ? CategoryModel.fromEntity(entity.category!)
          : null,
    );
  }

  factory ProductModel.fromDbLocal(Map<String, dynamic> map) {
    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is String) return int.tryParse(v);
      return null;
    }

    DateTime? toDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) {
        final n = num.tryParse(v);
        return n?.toDouble();
      }
      return null;
    }

    // Catatan: fromDbLocal biasanya TIDAK menyimpan objek nested seperti `category`
    // Jadi kita hanya ambil ID & nama parent jika disimpan di db lokal
    return ProductModel(
      id: toInt(map['id']),
      idServer: toInt(map['id_server']),
      name: map['name'] as String?,
      slug: map['slug'] as String?,
      code: map['code'] as String?,
      type: map['type'] as String?,
      barcodeSymbology: map['barcode_symbology'] as String?,
      categoryId: toInt(map['category_id']),
      unitId: toInt(map['unit_id']),
      businessId: toInt(map['business_id']),
      cost: toDouble(map['cost']),
      price: toDouble(map['price']),
      qty: toDouble(map['qty']),
      alertQuantity: toDouble(map['alert_quantity']),
      image: map['image'] as String?,
      productDetails: map['product_details'] as String?,
      isActive: map['is_active'] as bool?,
      isDiffPrice: map['is_diffPrice'] as bool?,
      deletedAt: toDate(map['deleted_at']),
      createdAt: toDate(map['created_at']),
      updatedAt: toDate(map['updated_at']),
      syncedAt: toDate(map['synced_at']),
      // categoryParentId: toInt(map['category_parent_id']),
      // categoryParentName: map['category_parent_name'] as String?,
      // // category biasanya tidak disimpan lengkap di db lokal → null
      // category: null,
    );
  }

  Map<String, dynamic> toDbLocal() {
    return {
      'id': id,
      'id_server': idServer,
      'name': name,
      'slug': slug,
      'code': code,
      'type': type,
      'category_id': categoryId,
      'unit_id': unitId,
      'business_id': businessId,
      'cost': cost,
      'price': price,
      'qty': qty,
      'alert_quantity': alertQuantity,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
      // 'category_parent_id': categoryParentId,
      // 'category_parent_name': categoryParentName,
      // Jangan simpan objek `category` ke db lokal
    };
  }
}
