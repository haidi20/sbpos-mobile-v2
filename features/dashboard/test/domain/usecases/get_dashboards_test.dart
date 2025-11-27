import 'package:flutter_test/flutter_test.dart';
import 'package:dashboard/domain/usecases/get_dashboards.dart';

void main() {
  test('GetDashboards can be instantiated', () {
    final uc = GetDashboards();
    expect(uc, isA<GetDashboards>());
  });
}
