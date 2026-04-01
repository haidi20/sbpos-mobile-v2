import 'package:core/core.dart';
import 'package:setting/domain/entities/setting_config.entity.dart';
import 'package:setting/domain/repositories/setting.repository.dart';

class UpdateProfileSettings {
  final SettingRepository repository;
  UpdateProfileSettings(this.repository);

  Future<Either<Failure, ProfileSettingsEntity>> call(
    ProfileSettingsEntity profileSettings, {
    bool? isOffline,
  }) async {
    try {
      return await repository.updateProfileSettings(
        profileSettings,
        isOffline: isOffline,
      );
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
