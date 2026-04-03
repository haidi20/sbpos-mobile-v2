import 'package:core/core.dart';
import 'package:setting/data/datasources/setting_local.data_source.dart';
import 'package:setting/data/models/setting_config.model.dart';

abstract class BluetoothPrinterClient {
  Future<void> connect({
    required String printerName,
    required String paperWidth,
  });

  Future<void> disconnect();

  Future<void> print({
    required String printerName,
    required String paperWidth,
    required String payload,
  });
}

class DebugBluetoothPrinterClient implements BluetoothPrinterClient {
  DebugBluetoothPrinterClient({
    Logger? logger,
  }) : _logger = logger ?? Logger('DebugBluetoothPrinterClient');

  final Logger _logger;
  String? _connectedPrinterName;

  @override
  Future<void> connect({
    required String printerName,
    required String paperWidth,
  }) async {
    _connectedPrinterName = printerName;
    _logger.info(
      'Printer bluetooth "$printerName" ditandai terhubung dengan lebar kertas $paperWidth.',
    );
  }

  @override
  Future<void> disconnect() async {
    if (_connectedPrinterName != null) {
      _logger.info(
        'Printer bluetooth "$_connectedPrinterName" diputus dari sesi aktif.',
      );
    }
    _connectedPrinterName = null;
  }

  @override
  Future<void> print({
    required String printerName,
    required String paperWidth,
    required String payload,
  }) async {
    if (_connectedPrinterName != printerName) {
      await connect(printerName: printerName, paperWidth: paperWidth);
    }

    _logger.info(
      'Mengirim payload struk ke printer bluetooth "$printerName".',
    );
    _logger.fine(payload);
  }
}

class BluetoothPrinterFacade implements PrinterFacade {
  BluetoothPrinterFacade({
    required SettingLocalDataSource localDataSource,
    BluetoothPrinterClient? client,
    Logger? logger,
  })  : _localDataSource = localDataSource,
        _client = client ?? DebugBluetoothPrinterClient(),
        _logger = logger ?? Logger('BluetoothPrinterFacade');

  final SettingLocalDataSource _localDataSource;
  final BluetoothPrinterClient _client;
  final Logger _logger;

  Future<void>? _bootstrapOperation;
  ReceiptPrinterConfig _config = const ReceiptPrinterConfig(
    autoPrint: true,
    printLogo: true,
    paperWidth: '80mm',
    printerName: null,
    isConnected: false,
  );

  Future<void> bootstrap() {
    return _bootstrapOperation ??= _loadConfigFromLocal();
  }

  bool get _hasConnectedPrinter {
    final printerName = _config.printerName?.trim();
    return _config.isConnected && printerName != null && printerName.isNotEmpty;
  }

  @override
  Future<void> syncConfig(ReceiptPrinterConfig config) async {
    await bootstrap();
    await _applyConfig(config);
  }

  @override
  Future<ReceiptPrintResult> printTestReceipt() async {
    await bootstrap();
    return _print(
      const ReceiptPrintJob(
        title: 'SB POS',
        lines: [
          ReceiptPrintLine(
            label: 'Test Printer Berhasil',
            emphasize: true,
          ),
        ],
      ),
      successMessage: 'Test print berhasil',
    );
  }

  @override
  Future<ReceiptPrintResult> printReceipt(ReceiptPrintJob job) async {
    await bootstrap();
    return _print(
      job,
      successMessage: 'Struk berhasil dicetak',
    );
  }

  Future<void> _loadConfigFromLocal() async {
    try {
      final config = await _localDataSource.getSettingConfig();
      await _applyConfig(_mapSettingConfigToPrinterConfig(config));
    } catch (error, stackTrace) {
      _logger.warning(
        'Gagal bootstrap konfigurasi printer dari DB lokal. Facade tetap berjalan dengan mode tidak terhubung.',
        error,
        stackTrace,
      );
    }
  }

  ReceiptPrinterConfig _mapSettingConfigToPrinterConfig(
    SettingConfigModel config,
  ) {
    final connectedDevice =
        config.printer.devices.cast<PrinterDeviceModel?>().firstWhere(
              (device) => device?.isConnected == true,
              orElse: () => null,
            );

    return ReceiptPrinterConfig(
      autoPrint: config.printer.autoPrint,
      printLogo: config.printer.printLogo,
      paperWidth: config.printer.paperWidth,
      printerName: connectedDevice?.name,
      isConnected: connectedDevice != null,
    );
  }

  Future<void> _applyConfig(ReceiptPrinterConfig config) async {
    _config = config;

    if (!_hasConnectedPrinter) {
      try {
        await _client.disconnect();
      } catch (error, stackTrace) {
        _logger.warning(
          'Gagal memutus printer bluetooth saat sinkronisasi konfigurasi.',
          error,
          stackTrace,
        );
      }
      return;
    }

    final printerName = _config.printerName!.trim();
    try {
      await _client.connect(
        printerName: printerName,
        paperWidth: _config.paperWidth,
      );
    } catch (error, stackTrace) {
      _logger.warning(
        'Gagal menghubungkan printer bluetooth "$printerName" saat sinkronisasi konfigurasi.',
        error,
        stackTrace,
      );
    }
  }

  Future<ReceiptPrintResult> _print(
    ReceiptPrintJob job, {
    required String successMessage,
  }) async {
    if (!_hasConnectedPrinter) {
      return const ReceiptPrintResult.failure(
        'Printer bluetooth belum terhubung',
      );
    }

    final printerName = _config.printerName!.trim();
    final payload = _buildPayload(job);

    try {
      await _client.connect(
        printerName: printerName,
        paperWidth: _config.paperWidth,
      );
      await _client.print(
        printerName: printerName,
        paperWidth: _config.paperWidth,
        payload: payload,
      );
      return ReceiptPrintResult.success(
        '$successMessage melalui $printerName',
      );
    } catch (error, stackTrace) {
      _logger.warning(
        'Gagal mencetak struk ke printer bluetooth "$printerName".',
        error,
        stackTrace,
      );
      return const ReceiptPrintResult.failure(
        'Gagal mengirim data ke printer bluetooth',
      );
    }
  }

  String _buildPayload(ReceiptPrintJob job) {
    final buffer = StringBuffer();

    if (_config.printLogo) {
      buffer.writeln('[LOGO]');
    }

    buffer.writeln(job.title);
    buffer.writeln();

    for (final line in job.lines) {
      final label = line.emphasize ? line.label.toUpperCase() : line.label;
      final value = line.value?.trim();
      if (value != null && value.isNotEmpty) {
        buffer.writeln('$label : $value');
      } else {
        buffer.writeln(label);
      }
    }

    final footer = job.footer?.trim();
    if (footer != null && footer.isNotEmpty) {
      buffer.writeln();
      buffer.writeln(footer);
    }

    buffer.writeln();
    buffer.writeln();
    return buffer.toString();
  }
}
