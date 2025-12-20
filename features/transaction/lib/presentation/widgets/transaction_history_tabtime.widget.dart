import 'package:core/core.dart';

class TransactionHistoryTabtime extends StatefulWidget {
  /// Number of consecutive dates to show (including today).
  final int daysToShow;
  final ValueChanged<DateTime>? onDateSelected;
  final DateTime? selectedDate;
  final double itemWidth;
  final double height;

  const TransactionHistoryTabtime({
    super.key,
    this.daysToShow = 90,
    this.onDateSelected,
    this.selectedDate,
    this.itemWidth = 88,
    this.height = 72,
  }) : assert(daysToShow > 0);

  @override
  State<TransactionHistoryTabtime> createState() =>
      _TransactionHistoryTabtimeState();
}

class _TransactionHistoryTabtimeState extends State<TransactionHistoryTabtime> {
  final ScrollController _controller = ScrollController();
  late final List<DateTime> _dates;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(Duration(days: widget.daysToShow - 1));

    _dates =
        List.generate(widget.daysToShow, (i) => start.add(Duration(days: i)));
    _selected = widget.selectedDate ?? _dates.last;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Small delay to ensure list has laid out its scroll extent on various devices.
      await Future.delayed(const Duration(milliseconds: 50));
      if (!_controller.hasClients) return;
      // If selected is at end use maxScrollExtent else scroll to selected index
      final idx = _dates.indexWhere((d) =>
          d.year == _selected.year &&
          d.month == _selected.month &&
          d.day == _selected.day);
      if (idx == -1) return;
      final target = (idx) * (widget.itemWidth + 8);
      final max = _controller.position.maxScrollExtent;
      _controller.jumpTo(target > max ? max : target);
    });
  }

  @override
  void didUpdateWidget(covariant TransactionHistoryTabtime oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != null) {
      final sel = DateTime(widget.selectedDate!.year,
          widget.selectedDate!.month, widget.selectedDate!.day);
      if (sel.year != _selected.year ||
          sel.month != _selected.month ||
          sel.day != _selected.day) {
        setState(() => _selected = sel);
        // animate to the new index
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_controller.hasClients) return;
          final idx = _dates.indexWhere((d) =>
              d.year == _selected.year &&
              d.month == _selected.month &&
              d.day == _selected.day);
          if (idx == -1) return;
          final target = (idx) * (widget.itemWidth + 8);
          final max = _controller.position.maxScrollExtent;
          final t = target > max ? max : target;
          try {
            _controller.animateTo(t,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut);
          } catch (_) {}
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = (d.year % 100).toString().padLeft(2, '0');
    return '$dd/$mm/$yy';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: ListView.separated(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final date = _dates[index];
          final isSelected = date.year == _selected.year &&
              date.month == _selected.month &&
              date.day == _selected.day;

          return InkWell(
            onTap: () {
              setState(() => _selected = date);
              widget.onDateSelected?.call(date);
            },
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: widget.itemWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4, top: 8),
                    child: Text(
                      _formatDate(date),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppColors.sbBlue : null,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // underline
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 3,
                    width: widget.itemWidth * 0.6,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.sbBlue : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
