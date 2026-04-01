import 'package:core/core.dart';

@immutable
class PrinterDeviceState {
  final String name;
  final String subtitle;
  final bool isConnected;

  const PrinterDeviceState({
    required this.name,
    required this.subtitle,
    required this.isConnected,
  });

  const PrinterDeviceState.initial()
      : name = 'Epson TM-T82',
        subtitle = 'Terhubung',
        isConnected = true;

  PrinterDeviceState copyWith({
    String? name,
    String? subtitle,
    bool? isConnected,
  }) {
    return PrinterDeviceState(
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

@immutable
class PrinterSettingsState {
  final bool autoPrint;
  final bool printLogo;
  final String paperWidth;
  final List<PrinterDeviceState> devices;
  final String message;
  final bool isError;

  const PrinterSettingsState({
    required this.autoPrint,
    required this.printLogo,
    required this.paperWidth,
    required this.devices,
    required this.message,
    required this.isError,
  });

  const PrinterSettingsState.initial()
      : autoPrint = true,
        printLogo = true,
        paperWidth = '80mm',
        devices = const [PrinterDeviceState.initial()],
        message = '',
        isError = false;

  PrinterSettingsState copyWith({
    bool? autoPrint,
    bool? printLogo,
    String? paperWidth,
    List<PrinterDeviceState>? devices,
    String? message,
    bool? isError,
  }) {
    return PrinterSettingsState(
      autoPrint: autoPrint ?? this.autoPrint,
      printLogo: printLogo ?? this.printLogo,
      paperWidth: paperWidth ?? this.paperWidth,
      devices: devices ?? this.devices,
      message: message ?? this.message,
      isError: isError ?? this.isError,
    );
  }
}
