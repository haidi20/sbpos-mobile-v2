import 'package:core/core.dart';
import 'package:setting/presentation/providers/setting.provider.dart';
import 'package:setting/presentation/view_models/setting.state.dart';
import 'package:setting/presentation/view_models/setting.vm.dart';

class PrinterScreen extends ConsumerWidget {
  const PrinterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final printerState = ref.watch(settingPrinterStateProvider);
    final viewModel = ref.read(settingViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Printer & Struk',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              )
            : null,
        shadowColor: Colors.grey.shade50,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSearch(),
            const SizedBox(height: 24),
            _buildDeviceList(
              context: context,
              devices: printerState.devices,
              onDisconnect: (deviceName) {
                viewModel.setPrinterConnected(deviceName, false);
                final latestState = ref.read(settingViewModelProvider).printer;
                showWarningSnackBar(context, latestState.message);
              },
            ),
            const SizedBox(height: 24),
            _buildPrintSetting(
              printerState: printerState,
              viewModel: viewModel,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                key: const Key('printer-test-print-button'),
                onPressed: () async {
                  final ok = await viewModel.onTestPrint();
                  final latestState = ref.read(settingPrinterStateProvider);

                  if (!context.mounted) {
                    return;
                  }

                  if (ok) {
                    showSuccessSnackBar(context, latestState.message);
                  } else {
                    showErrorSnackBar(context, latestState.message);
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.sbBlue,
                  side: const BorderSide(color: AppColors.sbBlue),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Test Print',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade500,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      activeColor: AppColors.sbBlue,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildSearch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sbBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.sbBlue.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.sbBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bluetooth,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mencari Printer...',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Pastikan bluetooth printer aktif',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList({
    required BuildContext context,
    required List<PrinterDeviceState> devices,
    required ValueChanged<String> onDisconnect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader('Perangkat Terhubung'),
        if (devices.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Text(
              'Belum ada printer yang tersedia pada sesi ini',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ...devices.map((device) {
          final statusColor = device.isConnected ? Colors.green : Colors.grey;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade200,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.print,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          device.subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                TextButton(
                  onPressed: device.isConnected ? () => onDisconnect(device.name) : null,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                  ),
                  child: Text(
                    device.isConnected ? 'Putus' : 'Nonaktif',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPrintSetting({
    required PrinterSettingsState printerState,
    required SettingViewModel viewModel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader('Pengaturan Cetak'),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildSwitchTile(
                'Auto Print Struk',
                printerState.autoPrint,
                viewModel.setPrinterAutoPrint,
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                'Cetak Logo Toko',
                printerState.printLogo,
                viewModel.setPrinterPrintLogo,
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text(
                  'Lebar Kertas',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: printerState.paperWidth,
                    items: ['58mm', '80mm']
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        viewModel.setPrinterPaperWidth(value);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
