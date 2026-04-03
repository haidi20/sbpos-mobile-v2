import 'package:core/core.dart';
import 'package:core/data/datasources/operational_remote_data_source.dart';
import 'package:core/domain/usecases/check_service_status.dart';
import 'package:core/domain/usecases/check_subscription_status.dart';

final operationalRemoteDataSourceProvider = Provider<OperationalRemoteDataSource>(
  (ref) => OperationalRemoteDataSource(),
);

final operationalRepositoryProvider = Provider<OperationalRepository>(
  (ref) => OperationalRepositoryImpl(
    remote: ref.read(operationalRemoteDataSourceProvider),
  ),
);

final checkServiceStatusProvider = Provider<CheckServiceStatus>(
  (ref) => CheckServiceStatus(ref.read(operationalRepositoryProvider)),
);

final checkSubscriptionStatusProvider = Provider<CheckSubscriptionStatus>(
  (ref) => CheckSubscriptionStatus(ref.read(operationalRepositoryProvider)),
);

final operationalStatusViewModelProvider =
    StateNotifierProvider<OperationalStatusViewModel, OperationalStatusState>(
  (ref) => OperationalStatusViewModel(
    ref.read(checkServiceStatusProvider),
    ref.read(checkSubscriptionStatusProvider),
  ),
);
