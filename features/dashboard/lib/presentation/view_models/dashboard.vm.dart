import 'package:core/core.dart';

class DashboardState {
  final bool isLoading;
  final String? error;

  DashboardState({
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class DashboardViewModel extends StateNotifier<DashboardState> {
  // final GetDashboardData _getDashboardData;

  // DashboardViewModel(this._getDashboardData) : super(DashboardState()) {
  // Future.microtask(fetchDashboardData);
  // }

  DashboardViewModel() : super(DashboardState());

  Future<void> fetchDashboardData() async {
    state = state.copyWith(isLoading: true, error: null);
    // final result = await _getDashboardData();
    // result.fold(
    //   (failure) =>
    //       state = state.copyWith(isLoading: false, error: failure.message),
    //   (data) => state = state.copyWith(isLoading: false, data: data),
    // );
  }
}
