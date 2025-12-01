import 'package:core/core.dart';
import 'package:dashboard/presentation/view_models/dashboard.state.dart';
import 'package:dashboard/presentation/view_models/dashboard.vm.dart';

final dashboardViewModelProvider =
    StateNotifierProvider<DashboardViewModel, DashboardState>(
        (ref) => DashboardViewModel());
