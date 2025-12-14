import 'package:core/core.dart';

typedef DateSelectedCallback = void Function(DateTime? date);

class TransactionHistoryTabTime extends StatefulWidget {
  final DateTime? selectedDate;
  final DateSelectedCallback onSelected;
  final int daysCount;
  final double alignment;
  final Duration scrollDuration;
  final Curve scrollCurve;

  const TransactionHistoryTabTime({
    super.key,
    required this.selectedDate,
    required this.onSelected,
    this.daysCount = 7,
    this.alignment = 0.7,
    this.scrollDuration = const Duration(milliseconds: 280),
    this.scrollCurve = Curves.easeInOut,
  });

  @override
  State<TransactionHistoryTabTime> createState() =>
      _TransactionHistoryTabTimeState();
}

class _TransactionHistoryTabTimeState extends State<TransactionHistoryTabTime> {
  late final ScrollController _ctrl;
  final List<GlobalKey> _itemKeys = [];
  final GlobalKey _rowKey = GlobalKey();
  double _underlineLeft = 0;
  double _underlineWidth = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = ScrollController();
    // scroll to right (end) so "today" is visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_ctrl.hasClients) {
        _ctrl.jumpTo(_ctrl.position.maxScrollExtent);
      }
      // position underline for initial selected tab
      _updateUnderlineForSelected();
    });
  }

  @override
  void didUpdateWidget(covariant TransactionHistoryTabTime oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateUnderlineForSelected();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(widget.daysCount, (i) {
      // produce from older -> today
      final diff = widget.daysCount - 1 - i;
      final d = DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: diff));
      return d;
    });

    // ensure we have keys for each day item
    while (_itemKeys.length < days.length) {
      _itemKeys.add(GlobalKey());
    }

    return SizedBox(
      height: 64,
      child: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _ctrl,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Container(
                key: _rowKey,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: List.generate(days.length, (idx) {
                    final d = days[idx];
                    final isActive = widget.selectedDate != null &&
                        widget.selectedDate!.year == d.year &&
                        widget.selectedDate!.month == d.month &&
                        widget.selectedDate!.day == d.day;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                        key: _itemKeys[idx],
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            widget.onSelected(d);
                            final ctx = _itemKeys[idx].currentContext;
                            if (!mounted || ctx == null) return;
                            // small scroll to center the tapped tab
                            Scrollable.ensureVisible(ctx,
                                duration: widget.scrollDuration,
                                alignment: widget.alignment,
                                curve: widget.scrollCurve);
                            // update underline after layout
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _updateUnderlineForIndex(idx);
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 6),
                            child: Text(
                              d.toDisplayDate(),
                              style: TextStyle(
                                color: isActive
                                    ? AppColors.sbBlue
                                    : AppColors.gray700,
                                fontWeight: isActive
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // underline
          AnimatedPositioned(
            duration: widget.scrollDuration,
            curve: widget.scrollCurve,
            left: _underlineLeft,
            bottom: 6,
            child: AnimatedContainer(
              duration: widget.scrollDuration,
              curve: widget.scrollCurve,
              width: _underlineWidth,
              height: 2,
              decoration: BoxDecoration(
                color: AppColors.sbBlue,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateUnderlineForSelected() {
    final today = DateTime.now();
    final days = List.generate(widget.daysCount, (i) {
      final diff = widget.daysCount - 1 - i;
      return DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: diff));
    });

    final sel = widget.selectedDate;
    if (sel == null) return;
    final idx = days.indexWhere(
        (d) => d.year == sel.year && d.month == sel.month && d.day == sel.day);
    if (idx >= 0) _updateUnderlineForIndex(idx);
  }

  void _updateUnderlineForIndex(int idx) {
    if (_itemKeys.length <= idx) return;
    final itemCtx = _itemKeys[idx].currentContext;
    final rowCtx = _rowKey.currentContext;
    if (itemCtx == null || rowCtx == null) return;
    try {
      final renderItem = itemCtx.findRenderObject();
      final renderRow = rowCtx.findRenderObject();
      if (renderItem is! RenderBox || renderRow is! RenderBox) return;
      final itemBox = renderItem;
      final rowBox = renderRow;
      final global = itemBox.localToGlobal(Offset.zero);
      final local = rowBox.globalToLocal(global);
      final left = local.dx;
      final width = itemBox.size.width;
      if (!mounted) return;
      setState(() {
        _underlineLeft = left;
        _underlineWidth = width;
      });
    } catch (e, st) {
      try {
        Logger('TransactionHistoryTabTime')
            .warning('Failed to update underline', e, st);
      } catch (_) {}
    }
  }
}
