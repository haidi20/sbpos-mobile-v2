import 'package:core/core.dart';

class DashboardController {
  DashboardController(this.ref, this.context);
  static final Logger _logger = Logger('DashboardController');

  final WidgetRef ref;
  final BuildContext context;

  void onAddClick() {
    _logger.info('[DashboardController] onAddClick invoked');

    context.pushNamed(AppRoutes.transaction);
  }
}
