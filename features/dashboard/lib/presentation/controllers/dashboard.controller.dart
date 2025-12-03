import 'package:core/core.dart';

class DashboardController {
  DashboardController(this.ref, this.context);
  // logger intentionally omitted; enable if needed for debugging

  final WidgetRef ref;
  final BuildContext context;

  void onAddClick() {
    // Uncomment logger call if logging is required
    // Logger('DashboardController').info('[DashboardController] onAddClick invoked');
    context.pushNamed(AppRoutes.transactionPos);
  }
}
