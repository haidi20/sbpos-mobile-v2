import 'package:core/core.dart';
import 'package:setting/domain/entities/setting_config.entity.dart';
import 'package:setting/domain/usecases/update_printer_settings.usecase.dart';
import 'package:setting/presentation/view_models/setting.state.dart';

class SettingPrinterViewModelActions {
  SettingPrinterViewModelActions({
    required UpdatePrinterSettings updatePrinterSettings,
    required PrinterFacade printerFacade,
    required SettingState Function() getState,
    required void Function(SettingState) setState,
    required PrinterSettingsState Function(PrinterSettingsEntity)
        mapPrinterEntityToState,
    required PrinterSettingsEntity Function() buildPrinterEntity,
    required Future<void> Function() syncPrinterServiceFromState,
  })  : _updatePrinterSettings = updatePrinterSettings,
        _printerFacade = printerFacade,
        _getState = getState,
        _setState = setState,
        _mapPrinterEntityToState = mapPrinterEntityToState,
        _buildPrinterEntity = buildPrinterEntity,
        _syncPrinterServiceFromState = syncPrinterServiceFromState;

  final UpdatePrinterSettings _updatePrinterSettings;
  final PrinterFacade _printerFacade;
  final SettingState Function() _getState;
  final void Function(SettingState) _setState;
  final PrinterSettingsState Function(PrinterSettingsEntity)
      _mapPrinterEntityToState;
  final PrinterSettingsEntity Function() _buildPrinterEntity;
  final Future<void> Function() _syncPrinterServiceFromState;

  void setPrinterAutoPrint(bool value) {
    final state = _getState();
    _setState(
      state.copyWith(
        printer: state.printer.copyWith(
          autoPrint: value,
          message: '',
          isError: false,
        ),
      ),
    );
    unawaited(_syncPrinterServiceFromState());
    unawaited(_updatePrinterSettings(_buildPrinterEntity()));
  }

  void setPrinterPrintLogo(bool value) {
    final state = _getState();
    _setState(
      state.copyWith(
        printer: state.printer.copyWith(
          printLogo: value,
          message: '',
          isError: false,
        ),
      ),
    );
    unawaited(_syncPrinterServiceFromState());
    unawaited(_updatePrinterSettings(_buildPrinterEntity()));
  }

  void setPrinterPaperWidth(String value) {
    final state = _getState();
    _setState(
      state.copyWith(
        printer: state.printer.copyWith(
          paperWidth: value,
          message: '',
          isError: false,
        ),
      ),
    );
    unawaited(_syncPrinterServiceFromState());
    unawaited(_updatePrinterSettings(_buildPrinterEntity()));
  }

  void setPrinterConnected(String deviceName, bool isConnected) {
    final state = _getState();
    final updatedDevices = state.printer.devices.map((device) {
      if (device.name != deviceName) {
        return device;
      }

      return device.copyWith(
        isConnected: isConnected,
        subtitle: isConnected ? 'Terhubung' : 'Terputus',
      );
    }).toList();

    _setState(
      state.copyWith(
        printer: state.printer.copyWith(
          devices: updatedDevices,
          message: isConnected
              ? '$deviceName berhasil dihubungkan'
              : '$deviceName berhasil diputus',
          isError: false,
        ),
      ),
    );
    unawaited(_syncPrinterServiceFromState());
    unawaited(_updatePrinterSettings(_buildPrinterEntity()));
  }

  Future<bool> onTestPrint() async {
    final state = _getState();
    final hasConnectedPrinter =
        state.printer.devices.any((device) => device.isConnected);

    if (!hasConnectedPrinter) {
      _setState(
        state.copyWith(
          printer: state.printer.copyWith(
            message: 'Tidak ada printer yang terhubung untuk test print',
            isError: true,
          ),
        ),
      );
      return false;
    }

    final saveResult = await _updatePrinterSettings(_buildPrinterEntity());
    final persisted = await saveResult.fold(
      (failure) async {
        final nextState = _getState();
        _setState(
          nextState.copyWith(
            printer: nextState.printer.copyWith(
              message: failure.message,
              isError: true,
            ),
          ),
        );
        return false;
      },
      (printer) async {
        final nextState = _getState();
        _setState(
          nextState.copyWith(
            printer: _mapPrinterEntityToState(printer).copyWith(
              message: '',
              isError: false,
            ),
          ),
        );
        await _syncPrinterServiceFromState();
        return true;
      },
    );

    if (!persisted) {
      return false;
    }

    final result = await _printerFacade.printTestReceipt();
    final nextState = _getState();
    _setState(
      nextState.copyWith(
        printer: nextState.printer.copyWith(
          message: result.message,
          isError: !result.isSuccess,
        ),
      ),
    );
    return result.isSuccess;
  }
}
