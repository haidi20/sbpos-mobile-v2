import 'package:core/core.dart';
import 'package:setting/domain/entities/setting_config.entity.dart';
import 'package:setting/domain/repositories/setting.repository.dart';

class UpdateSecuritySettings {
  final SettingRepository repository;
  UpdateSecuritySettings(this.repository);

  Future<Either<Failure, bool>> call(
    SecuritySettingsEntity securitySettings, {
    bool? isOffline,
  }) async {
    try {
      return await repository.updateSecuritySettings(
        securitySettings,
        isOffline: isOffline,
      );
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
