// /lib/providers/repository_providers.dart
import 'package:core/core.dart';
import 'package:warehouse/domain/repositories/warehouse_repository.dart';
import 'package:warehouse/data/repositories/warehouse_repository_impl.dart';
import 'package:warehouse/data/datasources/warehouse_local_data_source.dart';
import 'package:warehouse/data/datasources/warehouse_remote_data_source.dart';

final warehouseRemoteDataSourceProvider = Provider<WarehouseRemoteDataSource>(
  (ref) => WarehouseRemoteDataSource(),
);

final warehouseLocalDataSourceProvider = Provider<WarehouseLocalDataSource>(
  (ref) => WarehouseLocalDataSource(),
);

final warehouseRepositoryProvider = Provider<WarehouseRepository>((ref) {
  final remote = ref.read(warehouseRemoteDataSourceProvider);
  final local = ref.read(warehouseLocalDataSourceProvider);

  return WarehouseRepositoryImpl(
    remote: remote,
    local: local,
  );
});
