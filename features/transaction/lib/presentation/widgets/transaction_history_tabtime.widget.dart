import 'package:core/core.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/controllers/transaction_history_tabtime.controller.dart';
import 'package:transaction/presentation/view_models/transaction_history.state.dart';

class TransactionHistoryTabtime extends ConsumerStatefulWidget {
  /// Jumlah tanggal berturut-turut yang ditampilkan (termasuk hari ini).
  final int daysToShow;
  final ValueChanged<DateTime>? onDateSelected;
  final ValueChanged<DateTime>? onSwipeLeft;
  final ValueChanged<DateTime>? onSwipeRight;
  final DateTime? selectedDate;
  final double itemWidth;
  final double height;
  final Widget Function(BuildContext, WidgetRef, DateTime) bodyBuilder;

  const TransactionHistoryTabtime({
    super.key,
    this.daysToShow = 90,
    this.onDateSelected,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.selectedDate,
    this.itemWidth = 88,
    this.height = 72,
    required this.bodyBuilder,
  }) : assert(daysToShow > 0);

  @override
  ConsumerState<TransactionHistoryTabtime> createState() =>
      _TransactionHistoryTabtimeState();
}

class _TransactionHistoryTabtimeState
    extends ConsumerState<TransactionHistoryTabtime>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late List<DateTime> _dates;
  late final TransactionHistoryTabtimeController _ctrl;
  late int _lastIndex;

  @override
  void initState() {
    super.initState();

    _ctrl = TransactionHistoryTabtimeController();

    // Generate date list via ViewModel so logic lives in VM.
    _dates = ref
        .read(transactionHistoryViewModelProvider.notifier)
        .generateDateList(widget.daysToShow);
    // determine initial selected date (VM has precedence; cadangan to widget.selectedDate)
    final vmSel = ref.read(transactionHistoryViewModelProvider).selectedDate;
    final initialSelected = vmSel ?? widget.selectedDate ?? _dates.last;

    final initIdx = _dates.indexWhere((d) =>
        d.year == initialSelected.year &&
        d.month == initialSelected.month &&
        d.day == initialSelected.day);

    _tabController = TabController(
      length: _dates.length,
      vsync: this,
      initialIndex: initIdx == -1 ? (_dates.length - 1) : initIdx,
    );

    _lastIndex = _tabController.index;
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final idx = _tabController.index;
      if (idx < 0 || idx >= _dates.length) return;
      final d = _dates[idx];
      // Push selected date into VM state via controller
      _ctrl.selectDate(ref, d);
      widget.onDateSelected?.call(d);

      // detect swipe direction relative to lastIndex
      if (idx != _lastIndex) {
        if (idx > _lastIndex) {
          widget.onSwipeLeft?.call(d);
        } else {
          widget.onSwipeRight?.call(d);
        }
        _lastIndex = idx;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  // date formatting handled by controller now

  @override
  Widget build(BuildContext context) {
    // Listen to VM selectedDate changes and animate TabController accordingly.
    ref.listen<TransactionHistoryState>(transactionHistoryViewModelProvider,
        (previous, next) {
      final sel = next.selectedDate;
      if (sel == null) return;
      final idx = _dates.indexWhere((d) =>
          d.year == sel.year && d.month == sel.month && d.day == sel.day);
      if (idx != -1 && _tabController.index != idx) {
        try {
          _tabController.animateTo(idx,
              duration: const Duration(milliseconds: 220));
        } catch (_) {}
      }
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Fixed-height area for the date TabBar with per-tab underlines
        Material(
          color: AppColors.sbBg,
          child: SizedBox(
            height: widget.height,
            child: Stack(
              children: [
                // base TabBar
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  // gunakan indikator default Flutter untuk tab aktif (garis bawah)
                  indicatorColor: AppColors.sbBlue,
                  indicatorWeight: 3.0,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: AppColors.sbBlue,
                  unselectedLabelColor: AppColors.gray600,
                  onTap: (idx) {
                    if (idx < 0 || idx >= _dates.length) return;
                    final d = _dates[idx];
                    widget.onDateSelected?.call(d);
                    try {
                      _tabController.animateTo(idx);
                    } catch (_) {}
                  },
                  tabs: List.generate(
                    _dates.length,
                    (idx) {
                      final d = _dates[idx];

                      // label via controller (moved logic to controller)
                      final label = _ctrl.labelForDate(d);

                      final sel = ref
                              .watch(transactionHistoryViewModelProvider)
                              .selectedDate ??
                          widget.selectedDate ??
                          _dates.last;
                      final isSelected = sel.year == d.year &&
                          sel.month == d.month &&
                          sel.day == d.day;

                      return Tab(
                        child: SizedBox(
                          width: widget.itemWidth,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                label,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? AppColors.sbBlue
                                          : AppColors.gray700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // TabBarView: build a child per date using the provided bodyBuilder.
        Flexible(
          fit: FlexFit.loose,
          child: ClipRRect(
            borderRadius: BorderRadius.zero,
            child: Container(
              color: AppColors.sbBg,
              child: TabBarView(
                controller: _tabController,
                children: List.generate(_dates.length,
                    (idx) => widget.bodyBuilder(context, ref, _dates[idx])),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
