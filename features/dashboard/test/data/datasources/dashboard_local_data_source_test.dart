import 'package:flutter_test/flutter_test.dart';
import 'package:dashboard/data/datasources/dashboard_local_data_source.dart';

void main() {
  test('DashboardLocalDataSource can be instantiated', () {
    final ds = DashboardLocalDataSource();
    expect(ds, isA<DashboardLocalDataSource>());
  });
}
