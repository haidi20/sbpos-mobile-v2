import 'package:flutter_test/flutter_test.dart';
import 'package:dashboard/data/responses/dashboard_response.dart';

void main() {
  test('DashboardResponse can be instantiated', () {
    final r = DashboardResponse();
    expect(r, isA<DashboardResponse>());
  });
}
