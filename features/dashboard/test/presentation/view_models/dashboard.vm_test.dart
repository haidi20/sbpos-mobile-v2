import 'package:flutter_test/flutter_test.dart';
import 'package:dashboard/presentation/view_models/dashboard.vm.dart';

void main() {
  test('DashboardViewModel can be instantiated', () {
    final vm = DashboardViewModel();
    expect(vm, isA<DashboardViewModel>());
  });
}
