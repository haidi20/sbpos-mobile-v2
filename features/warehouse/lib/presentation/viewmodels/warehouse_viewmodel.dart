import 'package:core/core.dart';
import 'package:warehouse/domain/usecases/get_warehouses.dart';
import 'package:warehouse/domain/entities/warehouse_entity.dart';

class WarehouseState {
  final bool isLoading;
  final List<WarehouseEntity> warehouses;
  final String? error;

  WarehouseState({
    this.isLoading = false,
    this.warehouses = const [],
    this.error,
  });

  WarehouseState copyWith({
    bool? isLoading,
    List<WarehouseEntity>? warehouses,
    String? error,
  }) {
    return WarehouseState(
      isLoading: isLoading ?? this.isLoading,
      warehouses: warehouses ?? this.warehouses,
      error: error ?? this.error,
    );
  }
}

class WarehouseViewModel extends StateNotifier<WarehouseState> {
  final GetWarehouses _getWarehouses;

  WarehouseViewModel(this._getWarehouses) : super(WarehouseState()) {
    // Jalankan fetch secara async setelah objek selesai dibuat
    Future.microtask(fetchWarehouses);
  }

  Future<void> fetchWarehouses() async {
    state = state.copyWith(isLoading: true, error: null);

    // ✅ Ganti ke Failure
    final Either<Failure, List<WarehouseEntity>> result =
        await _getWarehouses.call();

    result.fold(
      (failure) {
        // print(failure.message);
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (warehouses) {
        state = state.copyWith(
          isLoading: false,
          warehouses: warehouses,
        );
      },
    );
  }
}
