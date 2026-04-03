import 'package:core/core.dart';
import 'package:outlet/domain/entities/outlet.entity.dart';
import 'package:outlet/domain/usecases/get_outlets.usecase.dart';

enum OutletStatus { initial, loading, success, error }

class OutletState {
  final List<OutletEntity> outlets;
  final OutletStatus status;
  final String? errorMessage;

  const OutletState({
    this.outlets = const [],
    this.status = OutletStatus.initial,
    this.errorMessage,
  });

  OutletState copyWith({
    List<OutletEntity>? outlets,
    OutletStatus? status,
    String? errorMessage,
  }) {
    return OutletState(
      outlets: outlets ?? this.outlets,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OutletState &&
        other.outlets == outlets &&
        other.status == status &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(outlets, status, errorMessage);
}

class OutletViewModel extends StateNotifier<OutletState> {
  final GetOutlets _getOutlets;

  OutletViewModel(this._getOutlets) : super(const OutletState()) {
    Future.microtask(fetchOutlets);
  }

  Future<void> fetchOutlets() async {
    state = state.copyWith(status: OutletStatus.loading);

    final result = await _getOutlets.call();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: OutletStatus.error,
          errorMessage: _mapFailureToMessage(failure),
        );
      },
      (outlets) {
        state = state.copyWith(
          status: OutletStatus.success,
          outlets: outlets,
        );
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) return 'Terjadi kesalahan pada server.';
    if (failure is NetworkFailure) return 'Koneksi internet bermasalah.';
    return 'Terjadi kesalahan tidak diketahui.';
  }
}
