import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setting/domain/entities/setting_config.entity.dart';
import 'package:setting/domain/repositories/setting.repository.dart';
import 'package:setting/domain/usecases/get_setting_config.usecase.dart';
import 'package:setting/domain/usecases/update_notification_preferences.usecase.dart';
import 'package:setting/domain/usecases/update_payment_methods.usecase.dart';
import 'package:setting/domain/usecases/update_printer_settings.usecase.dart';
import 'package:setting/domain/usecases/update_profile_settings.usecase.dart';
import 'package:setting/domain/usecases/update_security_settings.usecase.dart';
import 'package:setting/domain/usecases/update_store_info.usecase.dart';

import 'package:setting/testing/setting_test_fixtures.dart';

void main() {
  group('Setting usecases try/catch', () {
    test('GetSettingConfig mengembalikan success dari repository', () async {
      final usecase = GetSettingConfig(
        _ThrowingSettingRepository(
          getSettingConfigHandler: ({bool? isOffline}) async =>
              Right(buildSettingConfigEntity()),
        ),
      );

      final result = await usecase(isOffline: true);

      result.fold(
        (failure) => fail('Expected success but got ${failure.message}'),
        (config) => expect(config.store.storeName, equals('SB Coffee Samarinda')),
      );
    });

    test('GetSettingConfig menangkap exception tak terduga menjadi UnknownFailure',
        () async {
      final usecase = GetSettingConfig(
        _ThrowingSettingRepository(
          getSettingConfigHandler: ({bool? isOffline}) async {
            throw Exception('boom');
          },
        ),
      );

      final result = await usecase();

      result.fold(
        (failure) => expect(failure, isA<UnknownFailure>()),
        (_) => fail('Expected failure'),
      );
    });

    test('UpdateStoreInfo meneruskan hasil repository saat sukses', () async {
      final store = buildStoreInfoEntity();
      final usecase = UpdateStoreInfo(
        _ThrowingSettingRepository(
          updateStoreInfoHandler: (value, {bool? isOffline}) async => Right(value),
        ),
      );

      final result = await usecase(store);

      result.fold(
        (failure) => fail('Expected success but got ${failure.message}'),
        (data) => expect(data.branch, equals('Samarinda Ulu')),
      );
    });

    test('UpdateStoreInfo menangkap Failure yang dilempar repository', () async {
      final usecase = UpdateStoreInfo(
        _ThrowingSettingRepository(
          updateStoreInfoHandler: (value, {bool? isOffline}) async {
            throw const LocalValidation('Store gagal diproses');
          },
        ),
      );

      final result = await usecase(buildStoreInfoEntity());

      result.fold(
        (failure) => expect(failure.message, equals('Store gagal diproses')),
        (_) => fail('Expected failure'),
      );
    });

    test('UpdatePrinterSettings menangkap exception tak terduga', () async {
      final usecase = UpdatePrinterSettings(
        _ThrowingSettingRepository(
          updatePrinterSettingsHandler: (value, {bool? isOffline}) async {
            throw StateError('printer failure');
          },
        ),
      );

      final result = await usecase(buildPrinterSettingsEntity());

      result.fold(
        (failure) => expect(failure, isA<UnknownFailure>()),
        (_) => fail('Expected failure'),
      );
    });

    test('UpdatePaymentMethods meneruskan success repository', () async {
      final methods = buildPaymentMethodEntities();
      final usecase = UpdatePaymentMethods(
        _ThrowingSettingRepository(
          updatePaymentMethodsHandler: (value, {bool? isOffline}) async =>
              Right(value),
        ),
      );

      final result = await usecase(methods);

      result.fold(
        (failure) => fail('Expected success but got ${failure.message}'),
        (data) => expect(data.length, equals(5)),
      );
    });

    test('UpdatePaymentMethods menangkap Failure repository', () async {
      final usecase = UpdatePaymentMethods(
        _ThrowingSettingRepository(
          updatePaymentMethodsHandler: (value, {bool? isOffline}) async {
            throw const ServerFailure();
          },
        ),
      );

      final result = await usecase(buildPaymentMethodEntities());

      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected failure'),
      );
    });

    test('UpdateProfileSettings meneruskan success repository', () async {
      final profile = buildProfileSettingsEntity();
      final usecase = UpdateProfileSettings(
        _ThrowingSettingRepository(
          updateProfileSettingsHandler: (value, {bool? isOffline}) async =>
              Right(value),
        ),
      );

      final result = await usecase(profile);

      result.fold(
        (failure) => fail('Expected success but got ${failure.message}'),
        (data) => expect(data.name, equals('Sinta Dewi')),
      );
    });

    test('UpdateProfileSettings menangkap exception tak terduga', () async {
      final usecase = UpdateProfileSettings(
        _ThrowingSettingRepository(
          updateProfileSettingsHandler: (value, {bool? isOffline}) async {
            throw Exception('profile failure');
          },
        ),
      );

      final result = await usecase(buildProfileSettingsEntity());

      result.fold(
        (failure) => expect(failure, isA<UnknownFailure>()),
        (_) => fail('Expected failure'),
      );
    });

    test('UpdateNotificationPreferences meneruskan success repository',
        () async {
      final notification = buildNotificationPreferencesEntity();
      final usecase = UpdateNotificationPreferences(
        _ThrowingSettingRepository(
          updateNotificationPreferencesHandler: (
            value, {
            bool? isOffline,
          }) async =>
              Right(value),
        ),
      );

      final result = await usecase(notification);

      result.fold(
        (failure) => fail('Expected success but got ${failure.message}'),
        (data) => expect(data.stockAlert, isTrue),
      );
    });

    test('UpdateNotificationPreferences menangkap Failure repository',
        () async {
      final usecase = UpdateNotificationPreferences(
        _ThrowingSettingRepository(
          updateNotificationPreferencesHandler: (
            value, {
            bool? isOffline,
          }) async {
            throw const NetworkFailure();
          },
        ),
      );

      final result = await usecase(buildNotificationPreferencesEntity());

      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Expected failure'),
      );
    });

    test('UpdateSecuritySettings meneruskan success repository', () async {
      final usecase = UpdateSecuritySettings(
        _ThrowingSettingRepository(
          updateSecuritySettingsHandler: (value, {bool? isOffline}) async =>
              const Right(true),
        ),
      );

      final result = await usecase(buildSecuritySettingsEntity());

      result.fold(
        (failure) => fail('Expected success but got ${failure.message}'),
        (ok) => expect(ok, isTrue),
      );
    });

    test('UpdateSecuritySettings menangkap exception tak terduga', () async {
      final usecase = UpdateSecuritySettings(
        _ThrowingSettingRepository(
          updateSecuritySettingsHandler: (value, {bool? isOffline}) async {
            throw ArgumentError('security failure');
          },
        ),
      );

      final result = await usecase(buildSecuritySettingsEntity());

      result.fold(
        (failure) => expect(failure, isA<UnknownFailure>()),
        (_) => fail('Expected failure'),
      );
    });
  });
}

typedef _GetSettingConfigHandler = Future<Either<Failure, SettingConfigEntity>>
    Function({bool? isOffline});
typedef _UpdateStoreInfoHandler = Future<Either<Failure, StoreInfoEntity>>
    Function(StoreInfoEntity storeInfo, {bool? isOffline});
typedef _UpdatePrinterSettingsHandler =
    Future<Either<Failure, PrinterSettingsEntity>> Function(
  PrinterSettingsEntity printerSettings, {
  bool? isOffline,
});
typedef _UpdatePaymentMethodsHandler =
    Future<Either<Failure, List<PaymentMethodEntity>>> Function(
  List<PaymentMethodEntity> paymentMethods, {
  bool? isOffline,
});
typedef _UpdateProfileSettingsHandler =
    Future<Either<Failure, ProfileSettingsEntity>> Function(
  ProfileSettingsEntity profileSettings, {
  bool? isOffline,
});
typedef _UpdateNotificationPreferencesHandler = Future<
    Either<Failure, NotificationPreferencesEntity>> Function(
  NotificationPreferencesEntity notificationPreferences, {
  bool? isOffline,
});
typedef _UpdateSecuritySettingsHandler = Future<Either<Failure, bool>> Function(
  SecuritySettingsEntity securitySettings, {
  bool? isOffline,
});

class _ThrowingSettingRepository implements SettingRepository {
  _ThrowingSettingRepository({
    _GetSettingConfigHandler? getSettingConfigHandler,
    _UpdateStoreInfoHandler? updateStoreInfoHandler,
    _UpdatePrinterSettingsHandler? updatePrinterSettingsHandler,
    _UpdatePaymentMethodsHandler? updatePaymentMethodsHandler,
    _UpdateProfileSettingsHandler? updateProfileSettingsHandler,
    _UpdateNotificationPreferencesHandler?
        updateNotificationPreferencesHandler,
    _UpdateSecuritySettingsHandler? updateSecuritySettingsHandler,
  })  : _getSettingConfigHandler = getSettingConfigHandler,
        _updateStoreInfoHandler = updateStoreInfoHandler,
        _updatePrinterSettingsHandler = updatePrinterSettingsHandler,
        _updatePaymentMethodsHandler = updatePaymentMethodsHandler,
        _updateProfileSettingsHandler = updateProfileSettingsHandler,
        _updateNotificationPreferencesHandler =
            updateNotificationPreferencesHandler,
        _updateSecuritySettingsHandler = updateSecuritySettingsHandler;

  final _GetSettingConfigHandler? _getSettingConfigHandler;
  final _UpdateStoreInfoHandler? _updateStoreInfoHandler;
  final _UpdatePrinterSettingsHandler? _updatePrinterSettingsHandler;
  final _UpdatePaymentMethodsHandler? _updatePaymentMethodsHandler;
  final _UpdateProfileSettingsHandler? _updateProfileSettingsHandler;
  final _UpdateNotificationPreferencesHandler?
      _updateNotificationPreferencesHandler;
  final _UpdateSecuritySettingsHandler? _updateSecuritySettingsHandler;

  @override
  Future<Either<Failure, SettingConfigEntity>> getSettingConfig({
    bool? isOffline,
  }) async {
    return _getSettingConfigHandler?.call(isOffline: isOffline) ??
        Right(buildSettingConfigEntity());
  }

  @override
  Future<Either<Failure, NotificationPreferencesEntity>>
      updateNotificationPreferences(
    NotificationPreferencesEntity notificationPreferences, {
    bool? isOffline,
  }) async {
    return _updateNotificationPreferencesHandler?.call(
          notificationPreferences,
          isOffline: isOffline,
        ) ??
        Right(notificationPreferences);
  }

  @override
  Future<Either<Failure, List<PaymentMethodEntity>>> updatePaymentMethods(
    List<PaymentMethodEntity> paymentMethods, {
    bool? isOffline,
  }) async {
    return _updatePaymentMethodsHandler?.call(
          paymentMethods,
          isOffline: isOffline,
        ) ??
        Right(paymentMethods);
  }

  @override
  Future<Either<Failure, PrinterSettingsEntity>> updatePrinterSettings(
    PrinterSettingsEntity printerSettings, {
    bool? isOffline,
  }) async {
    return _updatePrinterSettingsHandler?.call(
          printerSettings,
          isOffline: isOffline,
        ) ??
        Right(printerSettings);
  }

  @override
  Future<Either<Failure, ProfileSettingsEntity>> updateProfileSettings(
    ProfileSettingsEntity profileSettings, {
    bool? isOffline,
  }) async {
    return _updateProfileSettingsHandler?.call(
          profileSettings,
          isOffline: isOffline,
        ) ??
        Right(profileSettings);
  }

  @override
  Future<Either<Failure, bool>> updateSecuritySettings(
    SecuritySettingsEntity securitySettings, {
    bool? isOffline,
  }) async {
    return _updateSecuritySettingsHandler?.call(
          securitySettings,
          isOffline: isOffline,
        ) ??
        const Right(true);
  }

  @override
  Future<Either<Failure, StoreInfoEntity>> updateStoreInfo(
    StoreInfoEntity storeInfo, {
    bool? isOffline,
  }) async {
    return _updateStoreInfoHandler?.call(
          storeInfo,
          isOffline: isOffline,
        ) ??
        Right(storeInfo);
  }
}
