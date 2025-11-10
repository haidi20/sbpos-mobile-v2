import 'package:core/core.dart'; // pastikan Failure ada di sini
import 'package:warehouse/domain/entities/warehouse_entity.dart';
import 'package:warehouse/domain/repositories/warehouse_repository.dart';

class GetWarehouses {
  final WarehouseRepository repository;

  GetWarehouses(this.repository);

  Future<Either<Failure, List<WarehouseEntity>>> call() async {
    return await repository.getDataWarehouses();
  }
}
