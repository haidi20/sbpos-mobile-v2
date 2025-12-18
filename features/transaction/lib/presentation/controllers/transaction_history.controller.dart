import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/presentation/screens/transaction_history_detail.screen.dart';

/// Controller yang menyediakan helper untuk menampilkan detail transaksi.
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

  /// Backwards-compatible alias used by some screens.
  Future<void> showTransactionDetail(
      BuildContext context, TransactionEntity tx) {
    return onShowTransactionDetail(context, tx);
  }
}
