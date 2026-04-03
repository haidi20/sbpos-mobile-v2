// ignore_for_file: use_build_context_synchronously
import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/screens/transaction_history_detail.screen.dart';

class TransactionHistoryActionController {
  final WidgetRef ref;
  final BuildContext context;

  TransactionHistoryActionController(this.ref, this.context);

  void _showSnack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 10,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<String?> _showTextPrompt({
    required String title,
    required String hintText,
    bool digitsOnly = false,
  }) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            keyboardType:
                digitsOnly ? TextInputType.number : TextInputType.text,
            maxLength: digitsOnly ? 6 : null,
            decoration: InputDecoration(
              hintText: hintText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              child: const Text('Lanjutkan'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    return result;
  }

  Future<void> onShow(TransactionEntity txn) async {
    try {
      Navigator.of(context).pop();
    } catch (_) {}

    List<TransactionDetailEntity> details = txn.details ?? [];
    TransactionEntity txToShow = txn;

    // If details are missing (common when listing transactions from a
    // lightweight API), try to fetch the full transaction by id.
    if ((details.isEmpty) && (txn.id != null)) {
      try {
        final getTxn = ref.read(getTransaction);
        final res = await getTxn.call(txn.id!);
        res.fold((f) {
          // ignore failure and fall back to showing whatever we have
        }, (full) {
          txToShow = full;
          details = full.details ?? [];
        });
      } catch (_) {}
    }

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionHistoryDetailScreen(
        tx: txToShow,
        details: details,
      ),
    );
  }

  Future<void> onEdit(TransactionEntity txn) async {
    try {
      Navigator.of(context).pop();
    } catch (_) {}

    try {
      var txToEdit = txn;
      final checker = ref.read(checkEditOrderProvider);
      final targetId = txn.idServer ?? txn.id;
      if (checker != null && targetId != null) {
        final result = await checker(targetId);
        final resolved = result.fold<TransactionEntity?>(
          (failure) {
            _showSnack(failure.message, error: true);
            return null;
          },
          (entity) => entity.transaction ?? txn,
        );
        if (resolved == null) {
          return;
        }
        txToEdit = resolved;
      }

      final posVm = ref.read(transactionPosViewModelProvider.notifier);
      await posVm.setTransactionForEdit(txToEdit);

      context.pushNamed(AppRoutes.transactionPos);
    } catch (e) {
      _showSnack('Error membuka POS: $e', error: true);
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
        _showSnack('Gagal hapus: $f', error: true);
      }, (ok) async {
        _showSnack('Transaksi dihapus');
        try {
          await ref
              .read(transactionHistoryViewModelProvider.notifier)
              .onRefresh();
        } catch (_) {}
      });
    } catch (e) {
      _showSnack('Error: $e', error: true);
    }
  }

  Future<void> onComplete(TransactionEntity txn) async {
    try {
      Navigator.of(context).pop();
    } catch (_) {}

    final updater = ref.read(updateTransaction);
    final updated = txn.copyWith(
      status: TransactionStatus.lunas,
      isPaid: true,
    );
    try {
      final res = await updater.call(updated, isOffline: true);
      res.fold((f) {
        _showSnack('Gagal menyelesaikan: $f', error: true);
      }, (ok) async {
        _showSnack('Transaksi ditandai selesai');
        try {
          await ref
              .read(transactionHistoryViewModelProvider.notifier)
              .onRefresh();
        } catch (_) {}
      });
    } catch (e) {
      _showSnack('Error: $e', error: true);
    }
  }

  Future<void> onCancel(TransactionEntity txn) async {
    try {
      Navigator.of(context).pop();
    } catch (_) {}

    final targetId = txn.idServer ?? txn.id;
    final requestCancel = ref.read(requestCancelTransactionProvider);
    final confirmCancel = ref.read(confirmCancelTransactionProvider);

    if (txn.status == TransactionStatus.pending &&
        targetId != null &&
        requestCancel != null &&
        confirmCancel != null) {
      final reason = await _showTextPrompt(
        title: 'Alasan Batal',
        hintText: 'Contoh: Customer berubah pikiran',
      );
      if (reason == null || reason.isEmpty) {
        _showSnack('Alasan batal wajib diisi', error: true);
        return;
      }

      final requestResult = await requestCancel(
        transactionId: targetId,
        reason: reason,
      );

      final canContinue = requestResult.fold(
        (failure) {
          _showSnack(failure.message, error: true);
          return false;
        },
        (_) => true,
      );

      if (!canContinue) {
        return;
      }

      final otp = await _showTextPrompt(
        title: 'Masukkan OTP Supervisor',
        hintText: '6 digit OTP',
        digitsOnly: true,
      );
      if (otp == null || otp.length != 6) {
        _showSnack('Kode OTP tidak valid', error: true);
        return;
      }

      final confirmResult = await confirmCancel(
        transactionId: targetId,
        otp: otp,
      );

      confirmResult.fold(
        (failure) {
          _showSnack(failure.message, error: true);
        },
        (_) async {
          _showSnack('Pesanan berhasil dibatalkan');
          try {
            await ref.read(transactionHistoryViewModelProvider.notifier).onRefresh();
          } catch (_) {}
        },
      );
      return;
    }

    final updater = ref.read(updateTransaction);
    final updated = txn.copyWith(
      status: TransactionStatus.batal,
    );
    try {
      final res = await updater.call(updated, isOffline: true);

      res.fold((f) {
        _showSnack('Gagal membatalkan: $f', error: true);
      }, (ok) async {
        _showSnack('Transaksi dibatalkan');
        try {
          await ref
              .read(transactionHistoryViewModelProvider.notifier)
              .onRefresh();
        } catch (_) {}
      });
    } catch (e) {
      _showSnack('Error: $e', error: true);
    }
  }
}
