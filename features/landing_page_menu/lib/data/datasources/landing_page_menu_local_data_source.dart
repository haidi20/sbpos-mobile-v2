import 'package:core/core.dart';
import 'package:landing_page_menu/data/models/product_model.dart';
import 'package:landing_page_menu/data/datasources/tables/product_table.dart';

class LandingPageMenuLocalDataSource with BaseErrorHelper {
  final ProductTable productTable = ProductTable();

  static final Logger _logger = Logger('LandingPageMenuLocalDataSource');

  Future<List<ProductModel>> getProducts() async {
    try {
      final result = await productTable.getAll();
      return result.map((e) => ProductModel.fromDbLocal(e)).toList();
    } on CacheException catch (e, stackTrace) {
      _logger.severe('CacheException in getProducts: $e', e, stackTrace);
      throw const CacheFailure();
    } on Exception catch (e, stackTrace) {
      _logger.severe('Unexpected error in getProducts: $e', e, stackTrace);
      throw const UnknownFailure();
    }
  }

  Future<bool> insertSyncProducts({
    required List<ProductModel>? products,
  }) async {
    if (products == null || products.isEmpty) {
      _logger.warning('insertSyncProducts called with null or empty products');
      return false;
    }

    try {
      final now = DateTime.now();
      final dbEntities = products.map((e) {
        final modelWithSync = e.copyWith(syncedAt: now);
        return modelWithSync.toDbLocal();
      }).toList();

      return await productTable.insertSync(dbEntities);
    } on CacheException catch (e, stackTrace) {
      _logger.severe('CacheException in insertSyncProducts: $e', e, stackTrace);
      throw const CacheFailure();
    } on Exception catch (e, stackTrace) {
      _logger.severe(
          'Unexpected error in insertSyncProducts: $e', e, stackTrace);
      throw const UnknownFailure();
    }
  }

  // ───  FUNGSI PUBLIK 1: untuk data SUDAH DISINKRON (dari server, dll) ───
  /// Menyimpan produk yang sudah disinkronisasi dengan server.
  /// Mengisi `syncedAt` dengan waktu saat ini.
  Future<bool> insertProduct(ProductModel product) async {
    final productWithSync = product.copyWith(syncedAt: DateTime.now());
    return _insertProductToDb(productWithSync);
  }

  // ─── FUNGSI PUBLIK 2: untuk data OFFLINE (entri manual, draft, dll) ───
  /// Menyimpan produk secara lokal tanpa status sinkronisasi.
  /// Mengatur `syncedAt` menjadi `null`.
  Future<bool> insertOfflineProduct(ProductModel product) async {
    final productWithoutSync = product.copyWith(syncedAt: null);
    return _insertProductToDb(productWithoutSync);
  }

  // ─── HELPER INTERNAL (private) ───────────────────────────────
  // Menangani SEMUA logika database + error handling
  // Tidak perlu tahu apakah data "online" atau "offline" — dia hanya menyimpan.
  Future<bool> _insertProductToDb(ProductModel product) async {
    try {
      final insertProduct = product.toDbLocal();
      return await productTable.insert(insertProduct);
    } on CacheException catch (e, stackTrace) {
      _logger.severe('CacheException during product insert: $e', e, stackTrace);
      throw const CacheFailure();
    } on Exception catch (e, stackTrace) {
      _logger.severe(
          'Unexpected error during product insert: $e', e, stackTrace);
      throw const UnknownFailure();
    }
  }
}
