import 'package:core/core.dart';
import '../../domain/entities/outlet.entity.dart';
import '../../domain/usecases/get_outlets.usecase.dart';

class OutletState {
  final List<OutletEntity> outlets;
  const OutletState({this.outlets = const []});

  OutletState copyWith({List<OutletEntity>? outlets}) {
    return OutletState(outlets: outlets ?? this.outlets);
  }
}

class OutletViewModel extends StateNotifier<OutletState> {
  final GetOutlets _getOutlets;

  OutletViewModel(this._getOutlets) : super(const OutletState()) {
    Future.microtask(fetchOutlets);
  }

  Future<void> fetchOutlets() async {
    final Either<Failure, List<OutletEntity>> result = await _getOutlets.call();

    result.fold((l) => null, (r) {
      state = state.copyWith(outlets: r);
    });
  }
}
