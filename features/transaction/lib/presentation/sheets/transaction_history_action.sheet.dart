import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/presentation/controllers/transaction_history_action.controller.dart';

Future<void> showTransactionHistoryActionSheet(
  BuildContext context,
  WidgetRef ref,
  TransactionEntity txn,
) async {
  final theme = Theme.of(context);
  await showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header dengan tombol close (X) di kanan atas
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 4, 4),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Aksi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Tutup',
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Lihat'),
              onTap: () async {
                final controller =
                    TransactionHistoryActionController(ref, context);
                await controller.onShow(txn);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Ubah'),
              onTap: () async {
                final controller =
                    TransactionHistoryActionController(ref, context);
                // prefer controller flow which opens POS as sheet
                await controller.onEdit(txn);
              },
            ),
            if (txn.status == TransactionStatus.proses)
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Selesai'),
                onTap: () async {
                  final controller =
                      TransactionHistoryActionController(ref, context);
                  await controller.onComplete(txn);
                },
              ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Batal'),
              onTap: () async {
                final controller =
                    TransactionHistoryActionController(ref, context);
                await controller.onCancel(txn);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: theme.colorScheme.error),
              title: Text('Hapus',
                  style: TextStyle(color: theme.colorScheme.error)),
              onTap: () async {
                final controller =
                    TransactionHistoryActionController(ref, context);
                await controller.onDelete(txn);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
