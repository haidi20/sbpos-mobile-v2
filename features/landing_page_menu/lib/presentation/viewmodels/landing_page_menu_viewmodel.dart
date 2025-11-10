// ViewModel for landing_page_menu
import 'package:core/core.dart';
import 'package:landing_page_menu/domain/usecases/get_products.dart';
import 'package:landing_page_menu/domain/entities/product_entity.dart';
import 'package:landing_page_menu/domain/entities/category_entity.dart';
import 'package:landing_page_menu/data/datasources/data/category_product_data.dart';

class LandingPageMenuState {
  final String? error;
  final bool isLoading;
  final double totalPrice;
  final int itemSelectedCount;
  final List<ProductEntity> products;
  final List<CategoryEntity> categoryMenuData;

  LandingPageMenuState({
    this.error,
    this.totalPrice = 0,
    this.isLoading = false,
    this.products = const [],
    this.itemSelectedCount = 0,
    this.categoryMenuData = CategoryProductData.data,
  });

  LandingPageMenuState copyWith({
    String? error,
    bool? isLoading,
    double? totalPrice,
    int? itemSelectedCount,
    List<ProductEntity>? products,
  }) {
    return LandingPageMenuState(
      error: error ?? this.error,
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      totalPrice: totalPrice ?? this.totalPrice,
      itemSelectedCount: itemSelectedCount ?? this.itemSelectedCount,
    );
  }
}

class LandingPageMenuViewModel extends StateNotifier<LandingPageMenuState> {
  final GetProducts _getProducts;

  LandingPageMenuViewModel(this._getProducts) : super(LandingPageMenuState());

  static final Logger _logger = Logger('LandingPageMenuViewModel');

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> fetchProducts() async {
    state = state.copyWith(isLoading: true, error: null);

    final Either<Failure, List<ProductEntity>> result =
        await _getProducts.call();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (products) {
        state = state.copyWith(
          isLoading: false,
          products: products,
        );
      },
    );
  }

  void updateItemSelectedCount(int count) {
    state = state.copyWith(itemSelectedCount: count);
  }

  void onCheckout() {
    // Implementasi logika checkout di sini
    // Misalnya, navigasi ke halaman pembayaran atau ringkasan pesanan
    _logger.info(
        'Navigasi ke halaman checkout dengan total harga: ${state.totalPrice}');
  }

  void addProductCart({required ProductEntity product}) {
    // Implementasi logika untuk menambahkan produk ke keranjang
    _logger.info('produk: ${product.name}');

    if (product.price == null || product.price! < 0) {
      _logger
          .warning('Produk ${product.name} memiliki harga nol atau negatif.');
      return;
    }

    double newTotalPrice = state.totalPrice + product.price!;
    int newItemCount = state.itemSelectedCount + 1;

    state = state.copyWith(
      totalPrice: newTotalPrice,
      itemSelectedCount: newItemCount,
    );
  }

  String get totalPriceReadable {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(state.totalPrice);
  }

  void clearState() {
    state = LandingPageMenuState();
  }
}
