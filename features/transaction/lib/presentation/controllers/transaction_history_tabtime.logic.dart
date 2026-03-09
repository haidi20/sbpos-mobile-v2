enum TabSwipeDirection {
  left,
  right,
}

class PreparedDates {
  const PreparedDates({
    required this.dates,
    required this.initialIndex,
  });

  final List<DateTime> dates;
  final int initialIndex;
}

class TabSelectionChange {
  const TabSelectionChange({
    required this.date,
    required this.direction,
  });

  final DateTime date;
  final TabSwipeDirection direction;
}

class TransactionHistoryTabtimeLogic {
  static DateTime normalizeDate(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static String labelForDate(
    DateTime date, {
    DateTime? now,
  }) {
    final today = normalizeDate(now ?? DateTime.now());
    final normalized = normalizeDate(date);
    final yesterday = today.subtract(const Duration(days: 1));

    if (normalized == today) {
      return 'Hari ini';
    }
    if (normalized == yesterday) {
      return 'Kemarin';
    }

    final dd = normalized.day.toString().padLeft(2, '0');
    final mm = normalized.month.toString().padLeft(2, '0');
    final yy = (normalized.year % 100).toString().padLeft(2, '0');
    return '$dd/$mm/$yy';
  }

  static List<DateTime> generateDateList(
    int daysToShow, {
    DateTime? selectedDate,
    DateTime? now,
  }) {
    final base = normalizeDate(selectedDate ?? now ?? DateTime.now());
    return List.generate(
      daysToShow,
      (i) => base.subtract(Duration(days: daysToShow - 1 - i)),
    );
  }

  static DateTime? dateAtIndex(List<DateTime>? dates, int idx) {
    if (dates == null || idx < 0 || idx >= dates.length) {
      return null;
    }
    return dates[idx];
  }

  static int findIndexForDate(List<DateTime> dates, DateTime date) {
    final normalized = normalizeDate(date);
    return dates.indexWhere((current) => normalizeDate(current) == normalized);
  }

  static DateTime resolveInitialSelected({
    required DateTime? selectedDate,
    required DateTime? provided,
    required List<DateTime> dates,
  }) {
    if (selectedDate != null) {
      return normalizeDate(selectedDate);
    }
    if (provided != null) {
      return normalizeDate(provided);
    }
    return dates.last;
  }

  static PreparedDates prepareDates(
    int daysToShow, {
    required DateTime? selectedDate,
    DateTime? providedSelected,
    DateTime? now,
  }) {
    final dates = generateDateList(
      daysToShow,
      selectedDate: selectedDate,
      now: now,
    );
    final initialSelected = resolveInitialSelected(
      selectedDate: selectedDate,
      provided: providedSelected,
      dates: dates,
    );
    final idx = findIndexForDate(dates, initialSelected);
    return PreparedDates(
      dates: dates,
      initialIndex: idx == -1 ? dates.length - 1 : idx,
    );
  }

  static TabSelectionChange? selectionForIndex({
    required int idx,
    required int lastIndex,
    required List<DateTime>? dates,
  }) {
    final date = dateAtIndex(dates, idx);
    if (date == null || idx == lastIndex) {
      return null;
    }
    return TabSelectionChange(
      date: date,
      direction:
          idx > lastIndex ? TabSwipeDirection.left : TabSwipeDirection.right,
    );
  }

  static bool isSelected({
    required DateTime? selectedDate,
    required DateTime? provided,
    required DateTime date,
  }) {
    final candidate = selectedDate ?? provided;
    if (candidate == null) {
      return false;
    }
    return normalizeDate(candidate) == normalizeDate(date);
  }
}
