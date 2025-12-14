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
  late final ScrollController _ctrl;
  final List<GlobalKey> _itemKeys = [];

  @override
  void initState() {
    super.initState();
    _ctrl = ScrollController();
    // scroll to right (end) so "today" is visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_ctrl.hasClients) {
        _ctrl.jumpTo(_ctrl.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _labelFor(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(d.year, d.month, d.day);
    if (date == today) return 'Hari ini';
    if (date == today.subtract(const Duration(days: 1))) return 'Kemarin';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd/$mm/$yyyy';
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
      child: SingleChildScrollView(
        controller: _ctrl,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
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
                child: ChoiceChip(
                  label: Text(_labelFor(d)),
                  selected: isActive,
                  onSelected: (_) {
                    widget.onSelected(d);
                    // small scroll to center the tapped tab (keep balance)
                    final ctx = _itemKeys[idx].currentContext;
                    if (!mounted || ctx == null) return;
                    Scrollable.ensureVisible(ctx,
                        duration: const Duration(milliseconds: 280),
                        alignment: 0.5,
                        curve: Curves.easeInOut);
                  },
                  selectedColor: AppColors.sbBlue,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isActive ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
