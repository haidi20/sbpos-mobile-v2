import 'package:core/core.dart';
import 'package:core/data/datasources/core_database.dart';
import 'package:product/data/models/cart_model.dart';
import 'package:product/data/datasources/db/cart.dao.dart';

class CartLocalDataSource with BaseErrorHelper {
  final CoreDatabase databaseHelper = CoreDatabase();
  final _logger = Logger('CartLocalDataSource');

  Future<List<CartModel>> getCarts() async {
    try {
      final db = await databaseHelper.database;
      if (db == null) {
        _logger.warning('Database gagal dibuka/null');
        return [];
      }
      final dao = CartDao(db);
      return await dao.getCarts();
    } catch (e, st) {
      _logger.severe('Error getCarts', e, st);
      return [];
    }
  }

  Future<CartModel?> insertCart(CartModel cart) async {
    try {
      final db = await databaseHelper.database;
      if (db == null) {
        _logger.warning('Database gagal dibuka/null');
        return null;
      }
      final dao = CartDao(db);
      return await dao.insertCart(cart.toInsertDbLocal());
    } catch (e, st) {
      _logger.severe('Error insertCart', e, st);
      rethrow;
    }
  }

  Future<List<CartModel>> insertSyncCarts(
      {required List<CartModel>? carts}) async {
    if (carts == null || carts.isEmpty) return [];
    try {
      final now = DateTime.now();
      final dbEntities = carts
          .map((e) => e.copyWith(syncedAt: now).toInsertDbLocal())
          .toList();
      final db = await databaseHelper.database;
      if (db == null) {
        _logger.warning('Database gagal dibuka/null');
        return [];
      }
      final dao = CartDao(db);
      final result = await dao.insertSyncCarts(dbEntities);
      return result;
    } catch (e, st) {
      _logger.severe('Error insertSyncCarts', e, st);
      return [];
    }
  }
}
