import 'package:core/core.dart';
import 'package:transaction/presentation/controllers/transaction_history_tabtime.controller.dart';

class TransactionHistoryTabtime extends ConsumerStatefulWidget {
  /// Jumlah tanggal berturut-turut yang ditampilkan (termasuk hari ini).
  final double height;
  final int daysToShow;
  final double itemWidth;
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onSwipeLeft;
  final ValueChanged<DateTime>? onSwipeRight;
  final ValueChanged<DateTime>? onDateSelected;

  final Widget Function({
    required WidgetRef ref,
    required DateTime date,
    required BuildContext context,
  }) bodyBuilder;

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
  late List<DateTime> _dates;
  late final TabController _tabController;
  late final TransactionHistoryTabtimeController _ctrl;

  @override
  void initState() {
    super.initState();

    _ctrl = TransactionHistoryTabtimeController();

    // Minta controller mempersiapkan daftar tanggal dan indeks awal
    final datesInit = _ctrl.prepareDates(
      ref,
      widget.daysToShow,
      providedSelected: widget.selectedDate,
    );

    _dates = datesInit.dates;
    final initIdx = datesInit.initialIndex;

    _tabController = TabController(
      vsync: this,
      length: _dates.length,
      initialIndex: initIdx == -1 ? (_dates.length - 1) : initIdx,
    );

    // initial index tracked inside controller now
    // Delegate tab controller wiring to controller
    _ctrl.attachTabController(
      _tabController,
      ref,
      _dates,
      onDateSelected: (d) => widget.onDateSelected?.call(d),
      onSwipeLeft: (d) => widget.onSwipeLeft?.call(d),
      onSwipeRight: (d) => widget.onSwipeRight?.call(d),
    );
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
    // ref.listen now handled by controller via attachTabController

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
                    _ctrl.handleTapIndex(
                      ref,
                      idx,
                      onDateSelected: (d) => widget.onDateSelected?.call(d),
                    );
                  },
                  tabs: List.generate(
                    _dates.length,
                    (idx) {
                      final d = _dates[idx];

                      // label via controller
                      final label = _ctrl.labelForDate(d);

                      final isSelected =
                          _ctrl.isSelected(ref, widget.selectedDate, d);

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
                children: List.generate(
                  _dates.length,
                  (idx) => widget.bodyBuilder(
                    ref: ref,
                    context: context,
                    date: _dates[idx],
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
