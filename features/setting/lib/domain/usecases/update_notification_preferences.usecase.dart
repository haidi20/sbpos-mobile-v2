import 'package:core/core.dart';
import 'package:setting/domain/entities/setting_config.entity.dart';
import 'package:setting/domain/repositories/setting.repository.dart';

class UpdateNotificationPreferences {
  final SettingRepository repository;
  UpdateNotificationPreferences(this.repository);

  Future<Either<Failure, NotificationPreferencesEntity>> call(
    NotificationPreferencesEntity notificationPreferences, {
    bool? isOffline,
  }) async {
    try {
      return await repository.updateNotificationPreferences(
        notificationPreferences,
        isOffline: isOffline,
      );
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
