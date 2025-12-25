import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';

class TransactionCard extends StatelessWidget {
  final TransactionEntity tx;
  final VoidCallback? onTap;

  const TransactionCard({super.key, required this.tx, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Order #${tx.sequenceNumber}'),
                  SyncStatus(idServer: tx.idServer, syncedAt: tx.syncedAt),
                ],
              ),
              const SizedBox(height: 4),
              Text('Rp ${tx.totalAmount}'),
            ],
          ),
        ),
      ),
    );
  }
}
