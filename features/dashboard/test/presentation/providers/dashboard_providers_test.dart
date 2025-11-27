import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dashboard/presentation/providers/dashboard_provider.dart';
import 'package:dashboard/presentation/providers/dashboard_repository_provider.dart';

void main() {
  test('dashboard providers return expected values (stubs)', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final value = container.read(dashboardProvider);
    final repo = container.read(dashboardRepositoryProvider);

    // In stubs providers return null; assert that reading does not throw
    expect(value, isNull);
    expect(repo, isNull);
  });
}
