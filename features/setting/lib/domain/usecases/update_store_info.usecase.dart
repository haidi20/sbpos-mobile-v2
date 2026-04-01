import 'package:core/core.dart';
import 'package:setting/domain/entities/setting_config.entity.dart';
import 'package:setting/domain/repositories/setting.repository.dart';

class UpdateStoreInfo {
  final SettingRepository repository;
  UpdateStoreInfo(this.repository);

  Future<Either<Failure, StoreInfoEntity>> call(
    StoreInfoEntity storeInfo, {
    bool? isOffline,
  }) async {
    try {
      return await repository.updateStoreInfo(
        storeInfo,
        isOffline: isOffline,
      );
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
