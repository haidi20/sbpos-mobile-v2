import 'package:flutter_test/flutter_test.dart';
import 'package:dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:dashboard/data/data/dashboard_data.dart';

void main() {
  test('DashboardRepositoryImpl can be instantiated with DashboardData', () {
    final data = DashboardData();
    final repo = DashboardRepositoryImpl(data);
    expect(repo, isA<DashboardRepositoryImpl>());
  });
}
