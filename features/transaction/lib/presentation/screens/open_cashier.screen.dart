import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:transaction/presentation/providers/open_cashier.provider.dart';
import 'package:transaction/presentation/view_models/open_cashier.state.dart';

class OpenCashierScreen extends ConsumerStatefulWidget {
  const OpenCashierScreen({super.key});

  @override
  ConsumerState<OpenCashierScreen> createState() => _OpenCashierScreenState();
}

class _OpenCashierScreenState extends ConsumerState<OpenCashierScreen> {
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(openCashierViewModelProvider.notifier).getShiftStatus();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<OpenCashierState>(
      openCashierViewModelProvider,
      (previous, next) {
        if (_amountController.text == next.balanceInput) {
          return;
        }

        _amountController.value = TextEditingValue(
          text: next.balanceInput,
          selection: TextSelection.collapsed(
            offset: next.balanceInput.length,
          ),
        );
      },
    );

    final state = ref.watch(openCashierViewModelProvider);
    final viewModel = ref.read(openCashierViewModelProvider.notifier);

    if (state.isLoadingStatus && !state.hasCheckedStatus) {
      return const Scaffold(
        body: Center(
          child: _OpenCashierLoading(),
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
              const _OpenCashierHeader(),
              const SizedBox(height: 24),
              _OpenCashierAmountCard(
                controller: _amountController,
                formattedBalance: state.formattedBalance,
                onChanged: viewModel.setInitialBalance,
              ),
              const SizedBox(height: 16),
              if (state.errorMessage.isNotEmpty)
                _OpenCashierMessageCard(
                  key: const Key('open-cashier-error-message'),
                  message: state.errorMessage,
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red.shade700,
                  icon: Icons.error_outline,
                ),
              if (state.successMessage.isNotEmpty)
                _OpenCashierMessageCard(
                  key: const Key('open-cashier-success-message'),
                  message: state.successMessage,
                  backgroundColor: Colors.green.shade50,
                  foregroundColor: Colors.green.shade700,
                  icon: Icons.check_circle_outline,
                ),
              const SizedBox(height: 24),
              _OpenCashierActionButton(
                isLoading: state.isSubmitting,
                onPressed: () async {
                  final isSuccess = await viewModel.onOpenCashier();
                  if (!context.mounted || !isSuccess) {
                    return;
                  }
                  context.go(AppRoutes.dashboard);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OpenCashierHeader extends StatelessWidget {
  const _OpenCashierHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Buka Kasir',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Silahkan masukkan jumlah saldo di laci',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}

class _OpenCashierAmountCard extends StatelessWidget {
  const _OpenCashierAmountCard({
    required this.controller,
    required this.formattedBalance,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String formattedBalance;
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
            'Saldo Kasir',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('open-cashier-amount-field'),
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Masukkan saldo awal',
              prefixIcon: const Icon(Icons.payments_outlined),
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
              color: AppColors.sbBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              formattedBalance,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.sbBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpenCashierActionButton extends StatelessWidget {
  const _OpenCashierActionButton({
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
        key: const Key('open-cashier-submit-button'),
        onPressed: isLoading ? null : () => unawaited(onPressed()),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade600,
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
                'Buka Kasir',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}

class _OpenCashierMessageCard extends StatelessWidget {
  const _OpenCashierMessageCard({
    super.key,
    required this.message,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
  });

  final String message;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: foregroundColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: foregroundColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpenCashierLoading extends StatelessWidget {
  const _OpenCashierLoading();

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator(
      key: Key('open-cashier-loading'),
    );
  }
}
