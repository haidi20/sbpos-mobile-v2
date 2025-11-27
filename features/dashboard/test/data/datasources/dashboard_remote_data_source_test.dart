import 'package:flutter_test/flutter_test.dart';
import 'package:dashboard/data/datasources/dashboard_remote_data_source.dart';

void main() {
  test('DashboardRemoteDataSource can be instantiated', () {
    final ds = DashboardRemoteDataSource();
    expect(ds, isA<DashboardRemoteDataSource>());
  });
}
