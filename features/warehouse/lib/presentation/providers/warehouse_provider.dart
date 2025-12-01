import 'package:core/core.dart';
import 'package:warehouse/domain/usecases/get_warehouses.dart';
import 'package:warehouse/presentation/providers/warehouse_repository_provider.dart';
import 'package:warehouse/presentation/view_models/warehouse.vm.dart';

final getWarehousesProvider = Provider<GetWarehouses>((ref) {
  // Di sini kamu harus inject repository
  // Asumsi kamu sudah punya warehouseRepositoryProvider
  final repo = ref.read(warehouseRepositoryProvider);
  return GetWarehouses(repo);
});

final warehouseViewModelProvider =
    StateNotifierProvider<WarehouseViewModel, WarehouseState>((ref) {
  final getWarehouses = ref.watch(getWarehousesProvider);
  return WarehouseViewModel(getWarehouses);
});
