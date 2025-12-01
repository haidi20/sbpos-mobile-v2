import 'category_entity.dart';
import 'package:product/data/models/product_model.dart';

class ProductEntity {
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
  final CategoryEntity? category;
  final double? gofoodPrice;
  final double? grabfoodPrice;
  final double? shopeefoodPrice;

  const ProductEntity({
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

  ProductEntity copyWith({
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
    CategoryEntity? category,
    double? gofoodPrice,
    double? grabfoodPrice,
    double? shopeefoodPrice,
  }) {
    return ProductEntity(
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

  factory ProductEntity.fromModel(ProductModel model) {
    return ProductEntity(
      id: model.id,
      idServer: model.idServer,
      name: model.name,
      slug: model.slug,
      code: model.code,
      type: model.type,
      barcodeSymbology: model.barcodeSymbology,
      categoryId: model.categoryId,
      unitId: model.unitId,
      businessId: model.businessId,
      cost: model.cost,
      price: model.price,
      qty: model.qty,
      alertQuantity: model.alertQuantity,
      image: model.image,
      productDetails: model.productDetails,
      isActive: model.isActive,
      isDiffPrice: model.isDiffPrice,
      deletedAt: model.deletedAt,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      syncedAt: model.syncedAt,
      categoryParentId: model.categoryParentId,
      categoryParentName: model.categoryParentName,
      category: model.category != null
          ? CategoryEntity.fromModel(model.category!)
          : null,
      gofoodPrice: model.gofoodPrice,
      grabfoodPrice: model.grabfoodPrice,
      shopeefoodPrice: model.shopeefoodPrice,
    );
  }

  ProductModel toModel() {
    return ProductModel(
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
      isActive: isActive,
      isDiffPrice: isDiffPrice,
      deletedAt: deletedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      syncedAt: syncedAt,
      categoryParentId: categoryParentId,
      categoryParentName: categoryParentName,
      category: category?.toModel(),
      gofoodPrice: gofoodPrice,
      grabfoodPrice: grabfoodPrice,
      shopeefoodPrice: shopeefoodPrice,
    );
  }

  List<Object?> get props => [
        id,
        idServer,
        name,
        slug,
        code,
        type,
        barcodeSymbology,
        categoryId,
        unitId,
        businessId,
        cost,
        price,
        qty,
        alertQuantity,
        image,
        productDetails,
        isActive,
        isDiffPrice,
        deletedAt,
        createdAt,
        updatedAt,
        syncedAt,
        categoryParentId,
        categoryParentName,
        category,
        gofoodPrice,
        grabfoodPrice,
        shopeefoodPrice,
      ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductEntity &&
        other.id == id &&
        other.idServer == idServer &&
        other.name == name &&
        other.slug == slug &&
        other.code == code &&
        other.type == type &&
        other.barcodeSymbology == barcodeSymbology &&
        other.categoryId == categoryId &&
        other.unitId == unitId &&
        other.businessId == businessId &&
        other.cost == cost &&
        other.price == price &&
        other.qty == qty &&
        other.alertQuantity == alertQuantity &&
        other.image == image &&
        other.productDetails == productDetails &&
        other.isActive == isActive &&
        other.isDiffPrice == isDiffPrice &&
        other.deletedAt?.millisecondsSinceEpoch ==
            deletedAt?.millisecondsSinceEpoch &&
        other.createdAt?.millisecondsSinceEpoch ==
            createdAt?.millisecondsSinceEpoch &&
        other.updatedAt?.millisecondsSinceEpoch ==
            updatedAt?.millisecondsSinceEpoch &&
        other.syncedAt?.millisecondsSinceEpoch ==
            syncedAt?.millisecondsSinceEpoch &&
        other.categoryParentId == categoryParentId &&
        other.categoryParentName == categoryParentName &&
        other.category == category &&
        other.gofoodPrice == gofoodPrice &&
        other.grabfoodPrice == grabfoodPrice &&
        other.shopeefoodPrice == shopeefoodPrice;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      id,
      idServer,
      name,
      slug,
      code,
      type,
      barcodeSymbology,
      categoryId,
      unitId,
      businessId,
      cost,
      price,
      qty,
      alertQuantity,
      image,
      productDetails,
      isActive,
      isDiffPrice,
      deletedAt?.millisecondsSinceEpoch,
      createdAt?.millisecondsSinceEpoch,
      updatedAt?.millisecondsSinceEpoch,
      syncedAt?.millisecondsSinceEpoch,
      categoryParentId,
      categoryParentName,
      category,
      gofoodPrice,
      grabfoodPrice,
      shopeefoodPrice,
    ]);
  }
}
