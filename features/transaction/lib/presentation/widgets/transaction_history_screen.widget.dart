// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
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

  // Removed name/table selector: search now supports name and table directly.

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      color: AppColors.sbBg,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
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
            ],
          ),
          const SizedBox(height: 16),
          // Search Bar with suffix selector for name/table
          TextField(
            onChanged: onSearch,
            textInputAction: TextInputAction.search,
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            decoration: InputDecoration(
              hintText: 'Cari menu, No. Order atau Catatan...',
              hintStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey.shade400,
              ),
              // suffix dihapus: dedicated selector no longer needed
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
  final bool isLoading;
  final List<TransactionEntity> transactions;
  final Future<void> Function(TransactionEntity) onTap;
  final Future<void> Function(TransactionEntity)? onLongPress;

  /// Callback dipanggil saat pengguna menggeser horizontal pada daftar.
  /// Mengirim jumlah hari untuk digeser: positif -> maju (hari berikutnya), negatif -> mundur (hari sebelumnya).
  final ValueChanged<int>? onDateShift;

  const TransactionHistoryList({
    super.key,
    this.onLongPress,
    this.onDateShift,
    required this.onTap,
    this.isLoading = false,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    // build the actual list content (muating / empty / items)
    final Widget listContent;
    if (isLoading) {
      listContent = ListView(
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
    } else if (transactions.isEmpty) {
      listContent = ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: const [
          _TransactionHistoryEmpty(),
        ],
      );
    } else {
      listContent = ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: transactions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final tx = transactions[index];
          return TransactionHistoryCard(
            transaction: tx,
            onTap: () => onTap(tx),
            onLongPress: onLongPress == null ? null : () => onLongPress!(tx),
          );
        },
      );
    }

    return Stack(
      children: [
        // Use pan gestures to capture horizontal swipes for date shifting.
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (_) {},
          onPanUpdate: (details) {},
          onPanEnd: (details) {
            final vx = details.velocity.pixelsPerSecond.dx;
            const velocityThreshold = 200; // pixels/sec
            if (vx.abs() >= velocityThreshold) {
              if (vx > 0) {
                // fling to right -> previous date
                onDateShift?.call(-1);
              } else {
                // fling to left -> next date
                onDateShift?.call(1);
              }
            }
          },
          onPanCancel: () {},
          child: listContent,
        ),
      ],
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
            Icon(
              Icons.receipt_long,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
