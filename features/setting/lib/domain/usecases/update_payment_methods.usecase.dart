import 'package:core/core.dart';
import 'package:setting/domain/entities/setting_config.entity.dart';
import 'package:setting/domain/repositories/setting.repository.dart';

class UpdatePaymentMethods {
  final SettingRepository repository;
  UpdatePaymentMethods(this.repository);

  Future<Either<Failure, List<PaymentMethodEntity>>> call(
    List<PaymentMethodEntity> paymentMethods, {
    bool? isOffline,
  }) async {
    try {
      return await repository.updatePaymentMethods(
        paymentMethods,
        isOffline: isOffline,
      );
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
