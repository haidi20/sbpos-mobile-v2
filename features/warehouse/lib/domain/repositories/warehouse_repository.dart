import 'package:core/core.dart'; // pastikan Failure ada di core
import 'package:warehouse/domain/entities/warehouse_entity.dart';

abstract class WarehouseRepository {
  Future<Either<Failure, List<WarehouseEntity>>> getDataWarehouses();
}
