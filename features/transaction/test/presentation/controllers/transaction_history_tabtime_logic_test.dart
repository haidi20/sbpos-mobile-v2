import 'package:transaction/presentation/controllers/transaction_history_tabtime.logic.dart';

DateTime _date(int year, int month, int day) => DateTime(year, month, day);

DateTime _dayOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

class _TestFailure implements Exception {
  _TestFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

void _expectEqual(Object? actual, Object? expected, String label) {
  if (actual != expected) {
    throw _TestFailure('$label\nExpected: $expected\nActual:   $actual');
  }
}

void _expectTrue(bool value, String label) {
  if (!value) {
    throw _TestFailure('$label\nExpected: true\nActual:   false');
  }
}

void _expectFalse(bool value, String label) {
  if (value) {
    throw _TestFailure('$label\nExpected: false\nActual:   true');
  }
}

void _expectNull(Object? value, String label) {
  if (value != null) {
    throw _TestFailure('$label\nExpected: null\nActual:   $value');
  }
}

void _expectListEqual(
  List<DateTime> actual,
  List<DateTime> expected,
  String label,
) {
  if (actual.length != expected.length) {
    throw _TestFailure(
      '$label\nExpected length: ${expected.length}\nActual length:   ${actual.length}',
    );
  }
  for (var i = 0; i < actual.length; i++) {
    if (actual[i] != expected[i]) {
      throw _TestFailure(
        '$label\nMismatch at index $i\nExpected: ${expected[i]}\nActual:   ${actual[i]}',
      );
    }
  }
}

void main() {
  final cases = <String, void Function()>{
    'normalizeDate strips the time component': () {
      _expectEqual(
        TransactionHistoryTabtimeLogic.normalizeDate(
          DateTime(2024, 6, 10, 14, 45, 59),
        ),
        _date(2024, 6, 10),
        'normalizeDate',
      );
    },
    'labelForDate returns today, yesterday, and formatted fallback': () {
      final now = _date(2024, 6, 10);

      _expectEqual(
        TransactionHistoryTabtimeLogic.labelForDate(
          DateTime(2024, 6, 10, 20),
          now: now,
        ),
        'Hari ini',
        'label today',
      );
      _expectEqual(
        TransactionHistoryTabtimeLogic.labelForDate(
          DateTime(2024, 6, 9, 8),
          now: now,
        ),
        'Kemarin',
        'label yesterday',
      );
      _expectEqual(
        TransactionHistoryTabtimeLogic.labelForDate(
          _date(2024, 1, 2),
          now: now,
        ),
        '02/01/24',
        'label fallback',
      );
    },
    'generateDateList uses selected date or now as end date': () {
      _expectListEqual(
        TransactionHistoryTabtimeLogic.generateDateList(
          3,
          selectedDate: DateTime(2024, 6, 10, 9),
        ),
        <DateTime>[
          _date(2024, 6, 8),
          _date(2024, 6, 9),
          _date(2024, 6, 10),
        ],
        'generateDateList selectedDate',
      );

      _expectListEqual(
        TransactionHistoryTabtimeLogic.generateDateList(
          2,
          now: DateTime(2024, 6, 20, 23),
        ),
        <DateTime>[
          _date(2024, 6, 19),
          _date(2024, 6, 20),
        ],
        'generateDateList now',
      );
    },
    'dateAtIndex validates null and out-of-range indexes': () {
      final dates = <DateTime>[
        _date(2024, 6, 8),
        _date(2024, 6, 9),
      ];

      _expectNull(
        TransactionHistoryTabtimeLogic.dateAtIndex(null, 0),
        'dateAtIndex null dates',
      );
      _expectNull(
        TransactionHistoryTabtimeLogic.dateAtIndex(dates, -1),
        'dateAtIndex negative',
      );
      _expectNull(
        TransactionHistoryTabtimeLogic.dateAtIndex(dates, 2),
        'dateAtIndex overflow',
      );
      _expectEqual(
        TransactionHistoryTabtimeLogic.dateAtIndex(dates, 1),
        _date(2024, 6, 9),
        'dateAtIndex valid',
      );
    },
    'findIndexForDate compares by date only': () {
      final dates = <DateTime>[
        _date(2024, 6, 8),
        _date(2024, 6, 9),
        _date(2024, 6, 10),
      ];

      _expectEqual(
        TransactionHistoryTabtimeLogic.findIndexForDate(
          dates,
          DateTime(2024, 6, 9, 23, 59),
        ),
        1,
        'findIndexForDate match',
      );
      _expectEqual(
        TransactionHistoryTabtimeLogic.findIndexForDate(
          dates,
          _date(2024, 6, 12),
        ),
        -1,
        'findIndexForDate missing',
      );
    },
    'resolveInitialSelected prioritizes state then provided then last date':
        () {
      final dates = <DateTime>[
        _date(2024, 6, 8),
        _date(2024, 6, 9),
        _date(2024, 6, 10),
      ];

      _expectEqual(
        TransactionHistoryTabtimeLogic.resolveInitialSelected(
          selectedDate: DateTime(2024, 6, 9, 18),
          provided: _date(2024, 6, 8),
          dates: dates,
        ),
        _date(2024, 6, 9),
        'resolveInitialSelected state',
      );
      _expectEqual(
        TransactionHistoryTabtimeLogic.resolveInitialSelected(
          selectedDate: null,
          provided: DateTime(2024, 6, 8, 7),
          dates: dates,
        ),
        _date(2024, 6, 8),
        'resolveInitialSelected provided',
      );
      _expectEqual(
        TransactionHistoryTabtimeLogic.resolveInitialSelected(
          selectedDate: null,
          provided: null,
          dates: dates,
        ),
        dates.last,
        'resolveInitialSelected fallback',
      );
    },
    'prepareDates resolves the correct initial index and falls back to last':
        () {
      final prepared = TransactionHistoryTabtimeLogic.prepareDates(
        3,
        selectedDate: _date(2024, 6, 10),
      );

      _expectListEqual(
        prepared.dates,
        <DateTime>[
          _date(2024, 6, 8),
          _date(2024, 6, 9),
          _date(2024, 6, 10),
        ],
        'prepareDates dates',
      );
      _expectEqual(prepared.initialIndex, 2, 'prepareDates initialIndex');

      final fallback = TransactionHistoryTabtimeLogic.prepareDates(
        3,
        selectedDate: null,
        providedSelected: _date(2024, 1, 1),
        now: _date(2024, 6, 10),
      );
      _expectEqual(
        fallback.initialIndex,
        2,
        'prepareDates fallback index',
      );
    },
    'selectionForIndex validates index and tracks swipe direction': () {
      final dates = <DateTime>[
        _date(2024, 6, 8),
        _date(2024, 6, 9),
        _date(2024, 6, 10),
      ];

      _expectNull(
        TransactionHistoryTabtimeLogic.selectionForIndex(
          idx: 1,
          lastIndex: 1,
          dates: dates,
        ),
        'selectionForIndex same index',
      );
      _expectNull(
        TransactionHistoryTabtimeLogic.selectionForIndex(
          idx: -1,
          lastIndex: 0,
          dates: dates,
        ),
        'selectionForIndex invalid index',
      );

      final left = TransactionHistoryTabtimeLogic.selectionForIndex(
        idx: 2,
        lastIndex: 0,
        dates: dates,
      );
      _expectEqual(
          left?.date, _date(2024, 6, 10), 'selectionForIndex left date');
      _expectEqual(
        left?.direction,
        TabSwipeDirection.left,
        'selectionForIndex left direction',
      );

      final right = TransactionHistoryTabtimeLogic.selectionForIndex(
        idx: 0,
        lastIndex: 2,
        dates: dates,
      );
      _expectEqual(
        right?.date,
        _date(2024, 6, 8),
        'selectionForIndex right date',
      );
      _expectEqual(
        right?.direction,
        TabSwipeDirection.right,
        'selectionForIndex right direction',
      );
    },
    'isSelected prefers selectedDate and falls back to provided date': () {
      _expectTrue(
        TransactionHistoryTabtimeLogic.isSelected(
          selectedDate: DateTime(2024, 6, 10, 20),
          provided: _date(2024, 6, 9),
          date: _date(2024, 6, 10),
        ),
        'isSelected selectedDate',
      );
      _expectTrue(
        TransactionHistoryTabtimeLogic.isSelected(
          selectedDate: null,
          provided: DateTime(2024, 6, 9, 10),
          date: _date(2024, 6, 9),
        ),
        'isSelected provided',
      );
      _expectFalse(
        TransactionHistoryTabtimeLogic.isSelected(
          selectedDate: null,
          provided: null,
          date: _date(2024, 6, 9),
        ),
        'isSelected missing',
      );
    },
    'generateDateList always returns normalized dates': () {
      final generated = TransactionHistoryTabtimeLogic.generateDateList(
        3,
        now: DateTime(2024, 6, 20, 22, 30),
      );
      _expectListEqual(
        generated,
        generated.map(_dayOnly).toList(),
        'generateDateList normalized',
      );
    },
  };

  final failures = <String>[];

  for (final entry in cases.entries) {
    try {
      entry.value();
      print('PASS ${entry.key}');
    } on Object catch (error) {
      failures.add('FAIL ${entry.key}\n$error');
      print('FAIL ${entry.key}');
    }
  }

  if (failures.isNotEmpty) {
    throw _TestFailure(failures.join('\n\n'));
  }

  print('All ${cases.length} checks passed.');
}
