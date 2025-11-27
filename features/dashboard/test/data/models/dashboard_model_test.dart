import 'package:flutter_test/flutter_test.dart';
import 'package:dashboard/data/models/dashboard_model.dart';

void main() {
  test('DashboardModel can be instantiated', () {
    final m = DashboardModel();
    expect(m, isA<DashboardModel>());
  });
}
