import 'package:core/core.dart';
import 'package:expense/domain/entities/expense.entity.dart';

class ExpenseListTile extends StatelessWidget {
  final ExpenseEntity expense;
  final VoidCallback? onTap;

  const ExpenseListTile({
    super.key,
    required this.expense,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = expense.createdAt != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(expense.createdAt!)
        : '-';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.outbox_rounded, color: Colors.red, size: 24),
        ),
        title: Text(
          expense.categoryName ?? 'Pengeluaran',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (expense.notes != null && expense.notes!.isNotEmpty)
                Text(
                  expense.notes!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 2),
              Text(
                dateStr,
                style: TextStyle(fontSize: 11, color: Colors.grey[400]),
              ),
            ],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Rp ${NumberFormat('#,###').format(expense.totalAmount ?? 0)}',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.red,
                fontSize: 15,
                letterSpacing: 0.2,
              ),
            ),
            if ((expense.qty ?? 0) > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'QTY: ${expense.qty}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
