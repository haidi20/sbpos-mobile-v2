import 'package:core/core.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:product/domain/usecases/get_products.usecase.dart';
import 'package:product/domain/usecases/create_product.usecase.dart';
import 'package:product/domain/usecases/update_product.usecase.dart';
import 'package:product/domain/usecases/delete_product.usecase.dart';
import 'package:product/presentation/view_models/product_management.state.dart';

class ProductManagementViewModel extends StateNotifier<ProductManagementState> {
  ProductManagementViewModel({
    required GetProducts getProductsUsecase,
    required CreateProduct createProductUsecase,
    required UpdateProduct updateProductUsecase,
    required DeleteProduct deleteProductUsecase,
  })  : _getProductsUsecase = getProductsUsecase,
        _createProductUsecase = createProductUsecase,
        _updateProductUsecase = updateProductUsecase,
        _deleteProductUsecase = deleteProductUsecase,
        super(const ProductManagementState());

  final GetProducts _getProductsUsecase;
  final CreateProduct _createProductUsecase;
  final UpdateProduct _updateProductUsecase;
  final DeleteProduct _deleteProductUsecase;

  ProductEntity _draft = const ProductEntity();
  ProductEntity get draft => _draft;

  // Getters
  String? get searchQuery => state.searchQuery;

  // Setters
  void setIsForm(bool v) => state = state.copyWith(isForm: v);

  void setDraftProduct(ProductEntity p) => _draft = p;

  void setSearchQuery(String q) => state = state.copyWith(searchQuery: q);

  void setDraftField(String field, dynamic value) {
    switch (field) {
      case 'name':
        _draft = _draft.copyWith(name: value as String?);
        break;
      case 'price':
        _draft = _draft.copyWith(price: value as double?);
        break;
      case 'category':
        _draft = _draft.copyWith(category: value);
        break;
      default:
        break;
    }
  }

  // Data getter: load products (offline-only)
  Future<void> getProducts() async {
    state = state.copyWith(loading: true);
    try {
      final result = await _getProductsUsecase(isOffline: true);
      result.fold((failure) {
        state = state.copyWith(loading: false, error: failure.message);
      }, (list) async {
        state = state.copyWith(loading: false, products: list);
      });
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  // Create
  Future<void> onCreateProduct() async {
    final name = (_draft.name ?? '').trim();
    if (name.isEmpty) return;
    final entity = _draft.copyWith(createdAt: DateTime.now());
    final res = await _createProductUsecase(entity, isOffline: true);
    res.fold((failure) {
      state = state.copyWith(error: failure.message);
    }, (created) {
      final updated = [...state.products, created];
      state = state.copyWith(products: updated, isForm: false);
      _draft = const ProductEntity();
    });
  }

  // Update
  Future<void> onUpdateProduct() async {
    final name = (_draft.name ?? '').trim();
    if (name.isEmpty) return;
    final res = await _updateProductUsecase(_draft, isOffline: true);
    res.fold((failure) {
      state = state.copyWith(error: failure.message);
    }, (updated) {
      final list =
          state.products.map((p) => p.id == updated.id ? updated : p).toList();
      state = state.copyWith(products: list, isForm: false);
      _draft = const ProductEntity();
    });
  }

  Future<bool> onDeleteProductById(int? id) async {
    try {
      if (id == null) return false;
      final res = await _deleteProductUsecase(id, isOffline: true);
      return res.fold((failure) {
        state = state.copyWith(error: failure.message);
        return false;
      }, (ok) {
        if (ok) {
          final updated = state.products.where((p) => p.id != id).toList();
          state = state.copyWith(products: updated);
        }
        return ok;
      });
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> onSaveOrUpdate() async {
    if (_draft.id != null) {
      await onUpdateProduct();
    } else {
      await onCreateProduct();
    }
  }
}
