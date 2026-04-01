part of 'package:setting/presentation/view_models/setting.vm.dart';

mixin _SettingPrinterViewModelMixin on _SettingViewModelScope {
  void setPrinterAutoPrint(bool value) {
    state = state.copyWith(
      printer: state.printer.copyWith(
        autoPrint: value,
        message: '',
        isError: false,
      ),
    );
    unawaited(_syncPrinterServiceFromState());
    unawaited(_updatePrinterSettings(_buildPrinterEntity()));
  }

  void setPrinterPrintLogo(bool value) {
    state = state.copyWith(
      printer: state.printer.copyWith(
        printLogo: value,
        message: '',
        isError: false,
      ),
    );
    unawaited(_syncPrinterServiceFromState());
    unawaited(_updatePrinterSettings(_buildPrinterEntity()));
  }

  void setPrinterPaperWidth(String value) {
    state = state.copyWith(
      printer: state.printer.copyWith(
        paperWidth: value,
        message: '',
        isError: false,
      ),
    );
    unawaited(_syncPrinterServiceFromState());
    unawaited(_updatePrinterSettings(_buildPrinterEntity()));
  }

  void setPrinterConnected(String deviceName, bool isConnected) {
    final updatedDevices = state.printer.devices.map((device) {
      if (device.name != deviceName) {
        return device;
      }

      return device.copyWith(
        isConnected: isConnected,
        subtitle: isConnected ? 'Terhubung' : 'Terputus',
      );
    }).toList();

    state = state.copyWith(
      printer: state.printer.copyWith(
        devices: updatedDevices,
        message: isConnected
            ? '$deviceName berhasil dihubungkan'
            : '$deviceName berhasil diputus',
        isError: false,
      ),
    );
    unawaited(_syncPrinterServiceFromState());
    unawaited(_updatePrinterSettings(_buildPrinterEntity()));
  }

  Future<bool> onTestPrint() async {
    final hasConnectedPrinter =
        state.printer.devices.any((device) => device.isConnected);

    if (!hasConnectedPrinter) {
      state = state.copyWith(
        printer: state.printer.copyWith(
          message: 'Tidak ada printer yang terhubung untuk test print',
          isError: true,
        ),
      );
      return false;
    }

    final saveResult = await _updatePrinterSettings(_buildPrinterEntity());
    final persisted = await saveResult.fold(
      (failure) async {
        state = state.copyWith(
          printer: state.printer.copyWith(
            message: failure.message,
            isError: true,
          ),
        );
        return false;
      },
      (printer) async {
        state = state.copyWith(
          printer: _mapPrinterEntityToState(printer).copyWith(
            message: '',
            isError: false,
          ),
        );
        await _syncPrinterServiceFromState();
        return true;
      },
    );

    if (!persisted) {
      return false;
    }

    final result = await _receiptPrinterService.printTestReceipt();
    state = state.copyWith(
      printer: state.printer.copyWith(
        message: result.message,
        isError: !result.isSuccess,
      ),
    );
    return result.isSuccess;
  }
}
