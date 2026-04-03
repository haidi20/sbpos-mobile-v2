import 'package:core/core.dart';
import 'package:transaction/domain/entitties/shift.entity.dart';
import 'package:transaction/presentation/providers/open_cashier.provider.dart';

class OpenCashierGuard extends ConsumerStatefulWidget {
  const OpenCashierGuard({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  ConsumerState<OpenCashierGuard> createState() => _OpenCashierGuardState();
}

class _OpenCashierGuardState extends ConsumerState<OpenCashierGuard> {
  bool _isShowingCloseCashierDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(openCashierViewModelProvider.notifier).getShiftStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(openCashierViewModelProvider);
    final viewModel = ref.read(openCashierViewModelProvider.notifier);
    final router = GoRouter.of(context);

    if (state.isLoadingStatus && !state.hasCheckedStatus) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            key: Key('open-cashier-guard-loading'),
          ),
        ),
      );
    }

    if (state.errorMessage.isNotEmpty && !state.isShiftOpen) {
      return Scaffold(
        body: Center(
          child: _OpenCashierGuardError(
            message: state.errorMessage,
            onRetry: () {
              ref.read(openCashierViewModelProvider.notifier).getShiftStatus();
            },
          ),
        ),
      );
    }

    if (state.hasCheckedStatus && state.shouldForceOpenCashier) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        context.go(AppRoutes.openCashier);
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.hasCheckedStatus &&
        state.isShiftOpen &&
        state.shouldSuggestCloseCashier &&
        !_isShowingCloseCashierDialog) {
      _isShowingCloseCashierDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) {
          return;
        }

        final shift = state.shiftStatus?.shift;
        final isDifferentDay = shift != null && _isShiftFromPreviousDay(shift);

        final shouldCloseCashier =
            await _showCloseCashierConfirmation(context, isDifferentDay: isDifferentDay);
        if (!mounted) {
          return;
        }

        viewModel.dismissCloseCashierSuggestion();
        _isShowingCloseCashierDialog = false;

        if (shouldCloseCashier == true) {
          router.go(AppRoutes.closeCashier);
        }
      });
    }

    return widget.child;
  }

  bool _isShiftFromPreviousDay(ShiftEntity shift) {
    final shiftDate = shift.date ?? shift.startTime ?? shift.createdAt;
    if (shiftDate == null) {
      return false;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final shiftDay = DateTime(shiftDate.year, shiftDate.month, shiftDate.day);

    return shiftDay.isBefore(today);
  }

  Future<bool?> _showCloseCashierConfirmation(
    BuildContext context, {
    required bool isDifferentDay,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Tutup Kasir'),
          content: Text(
            isDifferentDay
                ? 'Shift aktif berasal dari hari sebelumnya. Apakah Anda ingin tutup kasir sekarang?'
                : 'Apakah Anda ingin tutup kasir sekarang?',
          ),
          actions: [
            TextButton(
              key: const Key('different-day-close-cashier-no'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Tidak'),
            ),
            ElevatedButton(
              key: const Key('different-day-close-cashier-yes'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Tutup Kasir'),
            ),
          ],
        );
      },
    );
  }
}

class _OpenCashierGuardError extends StatelessWidget {
  const _OpenCashierGuardError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            key: const Key('open-cashier-guard-retry'),
            onPressed: onRetry,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}
