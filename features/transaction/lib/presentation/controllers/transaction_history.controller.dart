import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/sheets/transaction_history_action.sheet.dart';
import 'package:transaction/presentation/screens/transaction_history_detail.screen.dart';

class TransactionHistoryController {
  TransactionHistoryController();

  /// Alias yang digunakan oleh screen untuk konsistensi nama sebelum refactor.
  Future<void> onShowTransactionDetail(
      BuildContext context, TransactionEntity tx) {
    final details = tx.details ?? [];
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionHistoryDetailScreen(
        tx: tx,
        details: details,
      ),
    );
  }

  /// Backwards-compatible alias gunakand by some screens.
  Future<void> showTransactionDetail(
      BuildContext context, TransactionEntity tx) {
    return onShowTransactionDetail(context, tx);
  }

  /// Show actions for a transaction (edit / other actions).
  Future<void> showTransactionActions(
      BuildContext context, WidgetRef ref, TransactionEntity tx) async {
    await showTransactionHistoryActionSheet(
      context,
      ref,
      tx,
    );
  }

  /// Tampilkan date picker dan set selected date pada ViewModel.
  Future<void> showDatePickerAndSelect(
      BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 2),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.sbBlue,
            onPrimary: Colors.white,
            onSurface: Colors.black87,
          ),
        ),
        child: child!,
      ),
    );

    // Panggil ViewModel untuk menyimpan pilihan tanggal (boleh null)
    try {
      final vm = ref.read(transactionHistoryViewModelProvider.notifier);
      vm.setSelectedDate(picked);
    } catch (_) {}
  }
}
