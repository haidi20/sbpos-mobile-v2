import 'package:flutter_test/flutter_test.dart';
import 'package:dashboard/presentation/viewmodels/dashboard_viewmodel.dart';

void main() {
  test('DashboardViewModel can be instantiated', () {
    final vm = DashboardViewModel();
    expect(vm, isA<DashboardViewModel>());
  });
}
