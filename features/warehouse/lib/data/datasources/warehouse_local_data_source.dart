import 'package:core/utils/helpers/base_error_helper.dart';
import 'package:warehouse/data/models/warehouse_model.dart';
import 'package:warehouse/data/datasources/warehouse_database.dart';

class WarehouseLocalDataSource with BaseErrorHelper {
  final WarehouseDatabase databaseHelper = WarehouseDatabase();

  Future<List<WarehouseModel>> getWarehouses() async {
    final result = await databaseHelper.getWarehouses();

    if (result.isNotEmpty) {
      return result.map((e) => WarehouseModel.fromDbLocal(e)).toList();
    } else {
      return [];
    }
  }

  Future<void> insertSyncWarehouses({
    required List<WarehouseModel>? warehouses,
  }) async {
    if (warehouses == null || warehouses.isEmpty) return;

    final now = DateTime.now();

    // Isi syncedAt = sekarang pada setiap model sebelum konversi
    final dbEntities = warehouses.map((e) {
      // Jika WarehouseModel punya copyWith (immutable)
      final modelWithSync = e.copyWith(syncedAt: now);
      return modelWithSync.toInsertDbLocal();
    }).toList();

    await databaseHelper.insertSyncWarehouses(dbEntities);
  }
}
