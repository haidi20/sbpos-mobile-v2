import 'package:core/core.dart';

typedef DateSelectedCallback = void Function(DateTime? date);

class TransactionHistoryTabTime extends StatefulWidget {
  final DateTime? selectedDate;
  final DateSelectedCallback onSelected;
  final int daysCount;

  const TransactionHistoryTabTime({
    super.key,
    required this.selectedDate,
    required this.onSelected,
    this.daysCount = 7,
  });

  @override
  State<TransactionHistoryTabTime> createState() =>
      _TransactionHistoryTabTimeState();
}

class _TransactionHistoryTabTimeState extends State<TransactionHistoryTabTime> {
  final ScrollController _ctrl = ScrollController();
  final List<GlobalKey> _itemKeys = [];

  double _indicatorLeft = 0;
  double _indicatorTop = 0;
  double _indicatorWidth = 0;
  bool _showIndicator = false;
  Color _indicatorColor = Colors.orange;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_updateIndicator);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateIndicator());
  }

  @override
  void dispose() {
    _ctrl.removeListener(_updateIndicator);
    _ctrl.dispose();
    super.dispose();
  }

  List<DateTime> _generateDays() {
    final today = DateTime.now();
    return List.generate(widget.daysCount, (i) {
      final diff = widget.daysCount - 1 - i;
      return DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: diff));
    });
  }

  void _updateIndicator() {
    if (!mounted) return;
    final days = _generateDays();

    int activeIndex = -1;
    if (widget.selectedDate != null) {
      for (var i = 0; i < days.length; i++) {
        final d = days[i];
        if (widget.selectedDate!.year == d.year &&
            widget.selectedDate!.month == d.month &&
            widget.selectedDate!.day == d.day) {
          activeIndex = i;
          break;
        }
      }
    }

    if (activeIndex < 0 || activeIndex >= _itemKeys.length) {
      if (_showIndicator) setState(() => _showIndicator = false);
      return;
    }

    final keyContext = _itemKeys[activeIndex].currentContext;
    final rootBox = context.findRenderObject() as RenderBox?;
    if (keyContext == null || rootBox == null) {
      if (_showIndicator) setState(() => _showIndicator = false);
      return;
    }

    final box = keyContext.findRenderObject() as RenderBox?;
    if (box == null) {
      if (_showIndicator) setState(() => _showIndicator = false);
      return;
    }

    final topLeft = box.localToGlobal(Offset.zero, ancestor: rootBox);
    final width = box.size.width;

    // position indicator just below the item's content so it's close to the text
    final left = topLeft.dx;
    final top = topLeft.dy + box.size.height - 6;

    final isSpecialList = widget.daysCount == 7;
    final specialIndex = isSpecialList ? (days.length - 1) : -1;
    final isSpecialActive = activeIndex == specialIndex && specialIndex >= 0;

    setState(() {
      _indicatorLeft = left;
      _indicatorTop = top;
      _indicatorWidth = width;
      _indicatorColor = isSpecialActive ? AppColors.sbBlue : Colors.orange;
      _showIndicator = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = _generateDays();

    while (_itemKeys.length < days.length) {
      _itemKeys.add(GlobalKey());
    }

    return SizedBox(
      height: 64,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SingleChildScrollView(
            controller: _ctrl,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: List.generate(days.length, (idx) {
                final d = days[idx];
                final isActive = widget.selectedDate != null &&
                    widget.selectedDate!.year == d.year &&
                    widget.selectedDate!.month == d.month &&
                    widget.selectedDate!.day == d.day;
                final isSpecial =
                    widget.daysCount == 7 && idx == days.length - 1;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    key: _itemKeys[idx],
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        if (isSpecial) {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: widget.selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) widget.onSelected(picked);
                          _updateIndicator();
                          return;
                        }
                        widget.onSelected(d);
                        final ctx = _itemKeys[idx].currentContext;
                        if (!mounted || ctx == null) return;
                        Scrollable.ensureVisible(ctx,
                            duration: const Duration(milliseconds: 280),
                            alignment: 0.7,
                            curve: Curves.easeInOut);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 6),
                        child: Text(
                          d.toDisplayDate(),
                          style: TextStyle(
                            color: isSpecial
                                ? Colors.orange
                                : (isActive
                                    ? AppColors.sbBlue
                                    : AppColors.gray700),
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          if (_showIndicator)
            Positioned(
              left: _indicatorLeft,
              top: _indicatorTop,
              child: Container(
                width: _indicatorWidth,
                height: 3,
                decoration: BoxDecoration(
                  color: _indicatorColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(covariant TransactionHistoryTabTime oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateIndicator());
  }
}
