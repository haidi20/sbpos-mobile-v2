// ignore_for_file: use_build_context_synchronously
import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/screens/transaction_history_detail.screen.dart';

class TransactionHistoryActionController {
  final WidgetRef ref;
  final BuildContext context;

  TransactionHistoryActionController(this.ref, this.context);

  Future<void> onShow(TransactionEntity txn) async {
    try {
      Navigator.of(context).pop();
    } catch (_) {}

    final details = txn.details ?? [];
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionHistoryDetailScreen(
        tx: txn,
        details: details,
      ),
    );
  }

  Future<void> onEdit(TransactionEntity txn) async {
    try {
      Navigator.of(context).pop();
    } catch (_) {}

    try {
      final posVm = ref.read(transactionPosViewModelProvider.notifier);
      await posVm.setTransactionForEdit(txn);

      context.pushNamed(AppRoutes.transactionPos);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error membuka POS: $e')),
      );
    }
  }

  Future<void> onDelete(TransactionEntity txn) async {
    try {
      Navigator.of(context).pop();
    } catch (_) {}

    final delete = ref.read(deleteTransaction);
    try {
      final res = await delete.call(txn.id!, isOffline: true);
      res.fold((f) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal hapus: $f')),
        );
      }, (ok) async {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi dihapus')),
        );
        try {
          await ref
              .read(transactionHistoryViewModelProvider.notifier)
              .onRefresh();
        } catch (_) {}
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
