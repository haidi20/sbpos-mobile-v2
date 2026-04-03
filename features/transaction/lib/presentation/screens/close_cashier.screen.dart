import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:transaction/presentation/providers/close_cashier.provider.dart';

class CloseCashierScreen extends ConsumerStatefulWidget {
  const CloseCashierScreen({super.key});

  @override
  ConsumerState<CloseCashierScreen> createState() => _CloseCashierScreenState();
}

class _CloseCashierScreenState extends ConsumerState<CloseCashierScreen> {
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(closeCashierViewModelProvider.notifier).getCloseCashierStatus();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(closeCashierViewModelProvider);
    final viewModel = ref.read(closeCashierViewModelProvider.notifier);

    if (state.isLoadingStatus && !state.hasCheckedStatus) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const _CloseCashierHeader(),
              const SizedBox(height: 24),
              _CloseCashierAmountCard(
                controller: _amountController,
                formattedCash: state.formattedCashInDrawer,
                onChanged: viewModel.setCashInDrawer,
              ),
              const SizedBox(height: 16),
              if (state.warningMessage.isNotEmpty)
                _CloseCashierMessageCard(
                  key: const Key('close-cashier-warning-message'),
                  message: state.warningMessage,
                  backgroundColor: Colors.orange.shade50,
                  foregroundColor: Colors.orange.shade800,
                  icon: Icons.warning_amber_outlined,
                  trailingText: state.pendingOrders > 0
                      ? 'Pending order: ${state.pendingOrders}'
                      : null,
                ),
              if (state.errorMessage.isNotEmpty)
                _CloseCashierMessageCard(
                  key: const Key('close-cashier-error-message'),
                  message: state.errorMessage,
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red.shade700,
                  icon: Icons.error_outline,
                ),
              if (state.successMessage.isNotEmpty)
                _CloseCashierMessageCard(
                  key: const Key('close-cashier-success-message'),
                  message: state.successMessage,
                  backgroundColor: Colors.green.shade50,
                  foregroundColor: Colors.green.shade700,
                  icon: Icons.check_circle_outline,
                ),
              const SizedBox(height: 24),
              _CloseCashierActionButton(
                isLoading: state.isSubmitting,
                onPressed: () async {
                  final isSuccess = await viewModel.onCloseCashier();
                  if (!context.mounted || !isSuccess) {
                    return;
                  }
                  context.go(AppRoutes.login);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CloseCashierHeader extends StatelessWidget {
  const _CloseCashierHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tutup Kasir',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Masukkan jumlah uang di laci sebelum menutup kasir',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

class _CloseCashierAmountCard extends StatelessWidget {
  const _CloseCashierAmountCard({
    required this.controller,
    required this.formattedCash,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String formattedCash;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Uang Di Kasir',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('close-cashier-amount-field'),
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Masukkan uang di kasir',
              prefixIcon: const Icon(Icons.point_of_sale_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              formattedCash,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CloseCashierActionButton extends StatelessWidget {
  const _CloseCashierActionButton({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        key: const Key('close-cashier-submit-button'),
        onPressed: isLoading ? null : () => unawaited(onPressed()),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Tutup Kasir',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}

class _CloseCashierMessageCard extends StatelessWidget {
  const _CloseCashierMessageCard({
    super.key,
    required this.message,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    this.trailingText,
  });

  final String message;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foregroundColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color: foregroundColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (trailingText != null && trailingText!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    trailingText!,
                    style: TextStyle(
                      color: foregroundColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
