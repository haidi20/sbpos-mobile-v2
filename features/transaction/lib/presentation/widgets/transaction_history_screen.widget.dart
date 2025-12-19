// Header + Search widget (extracted for testability)
import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/presentation/components/transaction_history.card.dart';

class TransactionHistoryHeader extends StatelessWidget {
  final ValueChanged<String> onSearch;
  final ValueChanged<DateTime?>? onDateSelected;
  final Future<void> Function()? onRefresh;
  final bool isLoading;

  const TransactionHistoryHeader({
    super.key,
    required this.onSearch,
    this.onDateSelected,
    this.onRefresh,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      color: AppColors.sbBg,
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Riwayat Transaksi',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Row(
              //   children: [
              //     Container(
              //       decoration: BoxDecoration(
              //         color: Colors.white,
              //         borderRadius: BorderRadius.circular(12),
              //         border: Border.all(color: Colors.grey.shade200),
              //       ),
              //       child: IconButton(
              //         icon: const Icon(
              //           Icons.filter_list,
              //           color: AppColors.sbBlue,
              //         ),
              //         onPressed: () async {
              //           if (onDateSelected == null) return;
              //           final now = DateTime.now();
              //           final picked = await showDatePicker(
              //             context: context,
              //             initialDate: now,
              //             firstDate: DateTime(2000),
              //             lastDate: DateTime(now.year + 2),
              //             builder: (ctx, child) => Theme(
              //               data: Theme.of(ctx).copyWith(
              //                 colorScheme: const ColorScheme.light(
              //                   primary: AppColors.sbBlue,
              //                   onPrimary: Colors.white,
              //                   onSurface: Colors.black87,
              //                 ),
              //               ),
              //               child: child!,
              //             ),
              //           );
              //           onDateSelected!(picked);
              //         },
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
          const SizedBox(height: 16),
          // Search Bar
          TextField(
            onChanged: onSearch,
            decoration: InputDecoration(
              hintText: 'Cari No. Order atau Catatan...',
              hintStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: AppColors.sbBlue.withOpacity(0.2), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// Transaction list extracted for easier unit testing
class TransactionHistoryList extends StatelessWidget {
  final List<TransactionEntity> transactions;
  final Future<void> Function(TransactionEntity) onTap;
  final bool isLoading;

  const TransactionHistoryList({
    super.key,
    required this.onTap,
    required this.transactions,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: const [
          SizedBox(height: 24),
          Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      );
    }

    if (transactions.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: const [
          _TransactionHistoryEmpty(),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return TransactionHistoryCard(
          transaction: tx,
          onTap: () => onTap(tx),
        );
      },
    );
  }
}

// Simple private widget to show when there are no transactions. Testable.
class _TransactionHistoryEmpty extends StatelessWidget {
  final String message = 'Belum ada transaksi.';
  const _TransactionHistoryEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
