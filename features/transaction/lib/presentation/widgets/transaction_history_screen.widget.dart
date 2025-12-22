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
              // if (onDateSelected != null)
              //   Container(
              //     decoration: BoxDecoration(
              //       color: Colors.white,
              //       borderRadius: BorderRadius.circular(12),
              //       border: Border.all(color: Colors.grey.shade200),
              //     ),
              //     child: IconButton(
              //       icon: const Icon(
              //         Icons.filter_list,
              //         color: AppColors.sbBlue,
              //       ),
              //       onPressed: () async {
              //         final now = DateTime.now();
              //         final picked = await showDatePicker(
              //           context: context,
              //           initialDate: now,
              //           firstDate: DateTime(2000),
              //           lastDate: DateTime(now.year + 2),
              //           builder: (ctx, child) => Theme(
              //             data: Theme.of(ctx).copyWith(
              //               colorScheme: const ColorScheme.light(
              //                 primary: AppColors.sbBlue,
              //                 onPrimary: Colors.white,
              //                 onSurface: Colors.black87,
              //               ),
              //             ),
              //             child: child!,
              //           ),
              //         );
              //         onDateSelected?.call(picked);
              //       },
              //     ),
              //   ),
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
              // suffix removed: dedicated selector no longer needed
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
class TransactionHistoryList extends StatefulWidget {
  final List<TransactionEntity> transactions;
  final Future<void> Function(TransactionEntity) onTap;
  final Future<void> Function(TransactionEntity)? onLongPress;
  final bool isLoading;

  /// Callback invoked when the user swipes horizontally on the list.
  /// Passes number of days to shift: positive -> add days (next), negative -> subtract days (previous).
  final ValueChanged<int>? onDateShift;

  const TransactionHistoryList({
    super.key,
    required this.onTap,
    required this.transactions,
    this.onLongPress,
    this.isLoading = false,
    this.onDateShift,
  });

  @override
  State<TransactionHistoryList> createState() => _TransactionHistoryListState();
}

class _TransactionHistoryListState extends State<TransactionHistoryList> {
  // Shadow state removed per request.

  @override
  Widget build(BuildContext context) {
    // build the actual list content (loading / empty / items)
    final Widget listContent;
    if (widget.isLoading) {
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
    } else if (widget.transactions.isEmpty) {
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
        itemCount: widget.transactions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final tx = widget.transactions[index];
          return TransactionHistoryCard(
            transaction: tx,
            onTap: () => widget.onTap(tx),
            onLongPress: widget.onLongPress == null
                ? null
                : () => widget.onLongPress!(tx),
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
                widget.onDateShift?.call(-1);
              } else {
                // fling to left -> next date
                widget.onDateShift?.call(1);
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
