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
  double _accumulatedDx = 0.0;
  // UI hint shadows while dragging
  double _leftShadowOpacity = 0.0;
  double _rightShadowOpacity = 0.0;

  void _resetAccum() => _accumulatedDx = 0.0;

  void _updateShadows() {
    // Normalize accumulated drag distance into an opacity value.
    // Use a slightly more aggressive scale so the shadow is visible earlier.
    final v = (_accumulatedDx.abs() / 100).clamp(0.0, 0.85);
    if (_accumulatedDx > 0) {
      // Dragging to the right -> show left-side content hint on the left edge
      _leftShadowOpacity = v;
      _rightShadowOpacity = 0.0;
    } else if (_accumulatedDx < 0) {
      // Dragging to the left -> show right-side content hint on the right edge
      _rightShadowOpacity = v;
      _leftShadowOpacity = 0.0;
    } else {
      _leftShadowOpacity = 0.0;
      _rightShadowOpacity = 0.0;
    }
  }

  void _clearShadows() {
    setState(() {
      _leftShadowOpacity = 0.0;
      _rightShadowOpacity = 0.0;
    });
  }

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
        // Use pan gestures to better capture horizontal swipes while
        // allowing the inner ListView to handle vertical scrolls.
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (_) => _resetAccum(),
          onPanUpdate: (details) {
            final dx = details.delta.dx;
            if (dx == 0) return;
            _accumulatedDx += dx;
            setState(() {
              _updateShadows();
            });
          },
          onPanEnd: (details) {
            final vx = details.velocity.pixelsPerSecond.dx;
            const distanceThreshold = 60; // pixels
            // Accept either a sufficient drag distance or a fling velocity.
            if (_accumulatedDx.abs() >= distanceThreshold || vx.abs() >= 200) {
              if (_accumulatedDx > 0 || vx > 0) {
                // user moved to right -> request previous date (shift -1)
                widget.onDateShift?.call(-1);
              } else {
                // user moved to left -> request next date (shift +1)
                widget.onDateShift?.call(1);
              }
            }
            _resetAccum();
            _clearShadows();
          },
          onPanCancel: () {
            _resetAccum();
            _clearShadows();
          },
          child: listContent,
        ),

        // Left shadow
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: IgnorePointer(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: _leftShadowOpacity,
              child: Container(
                width: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withOpacity(0.28),
                      Colors.transparent
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Right shadow
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: IgnorePointer(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: _rightShadowOpacity,
              child: Container(
                width: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      Colors.black.withOpacity(0.28),
                      Colors.transparent
                    ],
                  ),
                ),
              ),
            ),
          ),
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
