import 'package:core/core.dart';
import 'package:setting/domain/entities/setting_config.entity.dart';
import 'package:setting/domain/repositories/setting.repository.dart';

class GetSettingConfig {
  final SettingRepository repository;
  GetSettingConfig(this.repository);

  Future<Either<Failure, SettingConfigEntity>> call({
    bool? isOffline,
  }) async {
    try {
      return await repository.getSettingConfig(isOffline: isOffline);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
