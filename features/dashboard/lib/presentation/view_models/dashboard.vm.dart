import 'dashboard.state.dart';
import 'package:core/core.dart';

class DashboardViewModel extends StateNotifier<DashboardState> {
  // final GetDashboardData _getDashboardData;

  // DashboardViewModel(this._getDashboardData) : super(DashboardState()) {
  // Future.microtask(fetchDashboardData);
  // }

  DashboardViewModel() : super(DashboardState());

  Future<void> getData() async {
    //
  }

  void onTabChange(AppTab tab) {
    state = state.copyWith(activeTab: tab);
  }
}
