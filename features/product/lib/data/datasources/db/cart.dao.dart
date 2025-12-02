import 'package:product/data/models/cart_model.dart';

import 'cart.table.dart';
import 'package:core/core.dart';

class CartDao {
  final Database database;
  final _logger = Logger('CartDao');

  CartDao(this.database);

  Future<List<CartModel>> getCarts() async {
    try {
      final result = await database.query(CartTable.tableName);
      return result.map((e) => CartModel.fromDbLocal(e)).toList();
    } catch (e, s) {
      _logger.severe('Error getCarts: $e', e, s);
      rethrow;
    }
  }

  Future<CartModel?> getCartById(int id) async {
    try {
      final results = await database.query(
        CartTable.tableName,
        where: '${CartTable.colId} = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (results.isNotEmpty) return CartModel.fromDbLocal(results.first);
      return null;
    } catch (e, s) {
      _logger.severe('Error getCartById: $e', e, s);
      rethrow;
    }
  }

  Future<List<CartModel>> insertSyncCarts(
      List<Map<String, dynamic>> carts) async {
    try {
      return await database.transaction((txn) async {
        List<CartModel> inserted = [];
        for (var cart in carts) {
          try {
            final existing = await txn.query(
              CartTable.tableName,
              where: '${CartTable.colIdServer} = ?',
              whereArgs: [cart['id_server']],
              limit: 1,
            );
            int id;
            if (existing.isNotEmpty) {
              await txn.update(CartTable.tableName, cart,
                  where: '${CartTable.colIdServer} = ?',
                  whereArgs: [cart['id_server']]);
              id = existing.first[CartTable.colId] as int;
            } else {
              id = await txn.insert(CartTable.tableName, cart);
            }
            final result = await txn.query(
              CartTable.tableName,
              where: '${CartTable.colId} = ?',
              whereArgs: [id],
              limit: 1,
            );
            if (result.isNotEmpty)
              inserted.add(CartModel.fromDbLocal(result.first));
          } catch (e) {
            _logger.warning('Error upserting cart: $e');
            rethrow;
          }
        }
        return inserted;
      });
    } catch (e, s) {
      _logger.severe('Error insertSyncCarts: $e', e, s);
      rethrow;
    }
  }

  Future<CartModel> insertCart(Map<String, dynamic> cart) async {
    try {
      final id = await database.insert(CartTable.tableName, cart);
      final result = await database.query(
        CartTable.tableName,
        where: '${CartTable.colId} = ?',
        whereArgs: [id],
        limit: 1,
      );
      return CartModel.fromDbLocal(result.first);
    } catch (e, s) {
      _logger.severe('Error insertCart: $e', e, s);
      rethrow;
    }
  }

  Future<int> updateCart(Map<String, dynamic> cart) async {
    try {
      return await database.update(
        CartTable.tableName,
        cart,
        where: '${CartTable.colId} = ?',
        whereArgs: [cart['id']],
      );
    } catch (e, s) {
      _logger.severe('Error updateCart: $e', e, s);
      rethrow;
    }
  }

  Future<int> deleteCart(int id) async {
    try {
      return await database.delete(
        CartTable.tableName,
        where: '${CartTable.colId} = ?',
        whereArgs: [id],
      );
    } catch (e, s) {
      _logger.severe('Error deleteCart: $e', e, s);
      rethrow;
    }
  }

  Future<int> clearCarts() async {
    try {
      return await database.delete(CartTable.tableName);
    } catch (e, s) {
      _logger.severe('Error clearCarts: $e', e, s);
      rethrow;
    }
  }
}
