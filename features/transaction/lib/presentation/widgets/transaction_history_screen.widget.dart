// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
// Header + Search widget (extracted for testability)
import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/presentation/components/transaction_history.card.dart';

class TransactionHistoryHeader extends StatefulWidget {
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
  State<TransactionHistoryHeader> createState() =>
      _TransactionHistoryHeaderState();
}

class _TransactionHistoryHeaderState extends State<TransactionHistoryHeader> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _openNameSelector() async {
    final res = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: _NameTableSelectionSheet(),
        );
      },
    );

    if (res != null) {
      final name = res['name'] ?? '';
      final table = res['table'] ?? '';
      final suffix = name.isNotEmpty
          ? ' | $name${table.isNotEmpty ? ' (#$table)' : ''}'
          : '';
      // Append or replace suffix in search
      final base = _controller.text.split(' | ').first;
      _controller.text = base + suffix;
      widget.onSearch(_controller.text);
    }
  }

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
              if (widget.onDateSelected != null)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.filter_list,
                      color: AppColors.sbBlue,
                    ),
                    onPressed: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: now,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(now.year + 2),
                        builder: (ctx, child) => Theme(
                          data: Theme.of(ctx).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: AppColors.sbBlue,
                              onPrimary: Colors.white,
                              onSurface: Colors.black87,
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      widget.onDateSelected?.call(picked);
                    },
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Search Bar with suffix selector for name/table
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: widget.onSearch,
            textInputAction: TextInputAction.search,
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
              suffix: GestureDetector(
                onTap: _openNameSelector,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ' | Nama',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.gray700,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.person,
                        size: 16,
                        color: AppColors.gray500,
                      ),
                    ],
                  ),
                ),
              ),
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

// Bottom sheet to select name and table number
class _NameTableSelectionSheet extends StatefulWidget {
  @override
  State<_NameTableSelectionSheet> createState() =>
      _NameTableSelectionSheetState();
}

class _NameTableSelectionSheetState extends State<_NameTableSelectionSheet> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _tableCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _tableCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const Text('Pilih Nama / Nomor Meja',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: 'Nama',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tableCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Nomor Meja (opsional)',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Batal'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop({
                    'name': _nameCtrl.text.trim(),
                    'table': _tableCtrl.text.trim()
                  });
                },
                child: const Text('Pilih'),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// Optional status TabBar used by older designs. Kept here so it's reusable
// when needed by screens. Indicator spans full tab width.
class TransactionHistoryStatusTabBar extends StatelessWidget {
  const TransactionHistoryStatusTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      // make underline indicator span full tab width
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorWeight: 3.0,
      indicatorColor: AppColors.sbBlue,
      labelColor: AppColors.sbBlue,
      unselectedLabelColor: AppColors.gray600,
      tabs: const [
        Tab(text: 'Main'),
        Tab(text: 'Proses'),
        Tab(text: 'Selesai'),
      ],
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
