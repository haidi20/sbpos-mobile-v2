import 'package:core/core.dart';
import 'package:setting/data/datasources/setting_local.data_source.dart';
import 'package:setting/data/datasources/setting_remote.data_source.dart';
import 'package:setting/data/models/setting_config.model.dart';
import 'package:setting/domain/entities/setting_config.entity.dart';
import 'package:setting/domain/repositories/setting.repository.dart';

class SettingRepositoryImpl implements SettingRepository {
  SettingRepositoryImpl({
    required this.remote,
    required this.local,
  });

  final SettingRemoteDataSource? remote;
  final SettingLocalDataSource local;

  static final Logger _logger = Logger('SettingRepositoryImpl');

  @override
  Future<Either<Failure, SettingConfigEntity>> getSettingConfig({
    bool? isOffline,
  }) async {
    if (isOffline == true) {
      try {
        final config = await local.getSettingConfig();
        return Right(config.toEntity());
      } catch (e, st) {
        _logger.severe('Kesalahan lokal saat getSettingConfig offline', e, st);
        return const Left(CacheFailure());
      }
    }

    if (remote == null) {
      return _loadLocalConfigFallback();
    }

    try {
      final remoteConfig = await remote!.getSettingConfig();
      final localConfig = await local.getSettingConfig();
      final mergedConfig = remoteConfig.copyWith(
        security: localConfig.security,
      );
      await local.saveSettingConfig(mergedConfig);
      return Right(mergedConfig.toEntity());
    } on ServerException catch (e, st) {
      _logger.warning('Gagal mengambil config setting dari server', e, st);
      return _loadLocalConfigFallback();
    } on NetworkException catch (e, st) {
      _logger.warning('Gagal mengambil config setting karena jaringan', e, st);
      return _loadLocalConfigFallback();
    } catch (e, st) {
      _logger.severe('Kesalahan tak terduga saat getSettingConfig', e, st);
      return _loadLocalConfigFallback();
    }
  }

  @override
  Future<Either<Failure, StoreInfoEntity>> updateStoreInfo(
    StoreInfoEntity storeInfo, {
    bool? isOffline,
  }) async {
    try {
      final localConfig = await local.getSettingConfig();
      final localUpdatedConfig = await local.saveSettingConfig(
        localConfig.copyWith(
          store: StoreInfoModel.fromEntity(storeInfo),
        ),
      );

      if (isOffline == true) {
        return Right(localUpdatedConfig.store.toEntity());
      }

      if (remote == null) {
        return Right(localUpdatedConfig.store.toEntity());
      }

      final remoteUpdated = await remote!.updateStoreInfo(
        StoreInfoModel.fromEntity(storeInfo),
      );
      final persistedConfig = await local.saveSettingConfig(
        localUpdatedConfig.copyWith(store: remoteUpdated),
      );
      return Right(persistedConfig.store.toEntity());
    } on ServerException catch (e, st) {
      _logger.warning('Gagal update store info ke server', e, st);
      return const Left(ServerFailure());
    } on NetworkException catch (e, st) {
      _logger.warning('Gagal update store info karena jaringan', e, st);
      return const Left(NetworkFailure());
    } catch (e, st) {
      _logger.severe('Kesalahan tak terduga saat updateStoreInfo', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, PrinterSettingsEntity>> updatePrinterSettings(
    PrinterSettingsEntity printerSettings, {
    bool? isOffline,
  }) async {
    try {
      final localConfig = await local.getSettingConfig();
      final localUpdatedConfig = await local.saveSettingConfig(
        localConfig.copyWith(
          printer: PrinterSettingsModel.fromEntity(printerSettings),
        ),
      );

      if (isOffline == true) {
        return Right(localUpdatedConfig.printer.toEntity());
      }

      if (remote == null) {
        return Right(localUpdatedConfig.printer.toEntity());
      }

      final remoteUpdated = await remote!.updatePrinterSettings(
        PrinterSettingsModel.fromEntity(printerSettings),
      );
      final persistedConfig = await local.saveSettingConfig(
        localUpdatedConfig.copyWith(printer: remoteUpdated),
      );
      return Right(persistedConfig.printer.toEntity());
    } on ServerException catch (e, st) {
      _logger.warning('Gagal update printer settings ke server', e, st);
      return const Left(ServerFailure());
    } on NetworkException catch (e, st) {
      _logger.warning('Gagal update printer settings karena jaringan', e, st);
      return const Left(NetworkFailure());
    } catch (e, st) {
      _logger.severe('Kesalahan tak terduga saat updatePrinterSettings', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<PaymentMethodEntity>>> updatePaymentMethods(
    List<PaymentMethodEntity> paymentMethods, {
    bool? isOffline,
  }) async {
    try {
      final localConfig = await local.getSettingConfig();
      final localUpdatedConfig = await local.saveSettingConfig(
        localConfig.copyWith(
          paymentMethods: paymentMethods
              .map(PaymentMethodModel.fromEntity)
              .toList(),
        ),
      );

      if (isOffline == true) {
        return Right(
          localUpdatedConfig.paymentMethods.map((item) => item.toEntity()).toList(),
        );
      }

      if (remote == null) {
        return Right(
          localUpdatedConfig.paymentMethods.map((item) => item.toEntity()).toList(),
        );
      }

      final remoteUpdated = await remote!.updatePaymentMethods(
        paymentMethods.map(PaymentMethodModel.fromEntity).toList(),
      );
      final persistedConfig = await local.saveSettingConfig(
        localUpdatedConfig.copyWith(paymentMethods: remoteUpdated),
      );
      return Right(
        persistedConfig.paymentMethods.map((item) => item.toEntity()).toList(),
      );
    } on ServerException catch (e, st) {
      _logger.warning('Gagal update payment methods ke server', e, st);
      return const Left(ServerFailure());
    } on NetworkException catch (e, st) {
      _logger.warning('Gagal update payment methods karena jaringan', e, st);
      return const Left(NetworkFailure());
    } catch (e, st) {
      _logger.severe('Kesalahan tak terduga saat updatePaymentMethods', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, ProfileSettingsEntity>> updateProfileSettings(
    ProfileSettingsEntity profileSettings, {
    bool? isOffline,
  }) async {
    try {
      final localConfig = await local.getSettingConfig();
      final localUpdatedConfig = await local.saveSettingConfig(
        localConfig.copyWith(
          profile: ProfileSettingsModel.fromEntity(profileSettings),
        ),
      );

      if (isOffline == true) {
        return Right(localUpdatedConfig.profile.toEntity());
      }

      if (remote == null) {
        return Right(localUpdatedConfig.profile.toEntity());
      }

      final remoteUpdated = await remote!.updateProfileSettings(
        ProfileSettingsModel.fromEntity(profileSettings),
      );
      final persistedConfig = await local.saveSettingConfig(
        localUpdatedConfig.copyWith(profile: remoteUpdated),
      );
      return Right(persistedConfig.profile.toEntity());
    } on ServerException catch (e, st) {
      _logger.warning('Gagal update profile settings ke server', e, st);
      return const Left(ServerFailure());
    } on NetworkException catch (e, st) {
      _logger.warning('Gagal update profile settings karena jaringan', e, st);
      return const Left(NetworkFailure());
    } catch (e, st) {
      _logger.severe('Kesalahan tak terduga saat updateProfileSettings', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, NotificationPreferencesEntity>>
      updateNotificationPreferences(
    NotificationPreferencesEntity notificationPreferences, {
    bool? isOffline,
  }) async {
    try {
      final localConfig = await local.getSettingConfig();
      final localUpdatedConfig = await local.saveSettingConfig(
        localConfig.copyWith(
          notifications: NotificationPreferencesModel.fromEntity(
            notificationPreferences,
          ),
        ),
      );

      if (isOffline == true) {
        return Right(localUpdatedConfig.notifications.toEntity());
      }

      if (remote == null) {
        return Right(localUpdatedConfig.notifications.toEntity());
      }

      final remoteUpdated = await remote!.updateNotificationPreferences(
        NotificationPreferencesModel.fromEntity(notificationPreferences),
      );
      final persistedConfig = await local.saveSettingConfig(
        localUpdatedConfig.copyWith(notifications: remoteUpdated),
      );
      return Right(persistedConfig.notifications.toEntity());
    } on ServerException catch (e, st) {
      _logger.warning(
        'Gagal update notification preferences ke server',
        e,
        st,
      );
      return const Left(ServerFailure());
    } on NetworkException catch (e, st) {
      _logger.warning(
        'Gagal update notification preferences karena jaringan',
        e,
        st,
      );
      return const Left(NetworkFailure());
    } catch (e, st) {
      _logger.severe(
        'Kesalahan tak terduga saat updateNotificationPreferences',
        e,
        st,
      );
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> updateSecuritySettings(
    SecuritySettingsEntity securitySettings, {
    bool? isOffline,
  }) async {
    try {
      final localConfig = await local.getSettingConfig();
      await local.saveSettingConfig(
        localConfig.copyWith(
          // PIN tidak disimpan plaintext di lokal; setelah submit form kembali kosong.
          security: const SecuritySettingsModel(
            oldPin: '',
            newPin: '',
            confirmPin: '',
          ),
        ),
      );

      if (isOffline == true) {
        return const Right(true);
      }

      if (remote == null) {
        return const Right(true);
      }

      final updated = await remote!.updateSecuritySettings(
        SecuritySettingsModel.fromEntity(securitySettings),
      );
      return Right(updated);
    } on ServerException catch (e, st) {
      _logger.warning('Gagal update security settings ke server', e, st);
      return const Left(ServerFailure());
    } on NetworkException catch (e, st) {
      _logger.warning('Gagal update security settings karena jaringan', e, st);
      return const Left(NetworkFailure());
    } catch (e, st) {
      _logger.severe('Kesalahan tak terduga saat updateSecuritySettings', e, st);
      return const Left(UnknownFailure());
    }
  }

  Future<Either<Failure, SettingConfigEntity>> _loadLocalConfigFallback() async {
    try {
      final localConfig = await local.getSettingConfig();
      return Right(localConfig.toEntity());
    } catch (e, st) {
      _logger.severe('Fallback config lokal juga gagal', e, st);
      return const Left(CacheFailure());
    }
  }
}
