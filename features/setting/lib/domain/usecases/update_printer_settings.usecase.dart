import 'package:core/core.dart';
import 'package:setting/domain/entities/setting_config.entity.dart';
import 'package:setting/domain/repositories/setting.repository.dart';

class UpdatePrinterSettings {
  final SettingRepository repository;
  UpdatePrinterSettings(this.repository);

  Future<Either<Failure, PrinterSettingsEntity>> call(
    PrinterSettingsEntity printerSettings, {
    bool? isOffline,
  }) async {
    try {
      return await repository.updatePrinterSettings(
        printerSettings,
        isOffline: isOffline,
      );
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}
