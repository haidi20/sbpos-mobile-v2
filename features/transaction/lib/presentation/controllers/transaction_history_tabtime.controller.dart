import 'package:core/core.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';

/// Controller for TransactionHistoryTabtime UI concerns that need a
/// BuildContext or local TextEditingController (search input, date picker).
class TransactionHistoryTabtimeController {
  final TextEditingController searchController = TextEditingController();

  void dispose() {
    searchController.dispose();
  }

  /// Show a date picker and apply the selected date to the ViewModel.
  Future<void> showDatePickerAndSelect(
    BuildContext context,
    WidgetRef ref, {
    DateTime? initialDate,
  }) async {
    final now = DateTime.now();
    final init = initialDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      await ref
          .read(transactionHistoryViewModelProvider.notifier)
          .setSelectedDate(DateTime(picked.year, picked.month, picked.day));
    }
  }

  /// Return a display label for a date (Hari ini / Kemarin / dd/MM/yy).
  String labelForDate(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (d.year == today.year && d.month == today.month && d.day == today.day) {
      return 'Hari ini';
    }
    if (d.year == yesterday.year &&
        d.month == yesterday.month &&
        d.day == yesterday.day) {
      return 'Kemarin';
    }
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = (d.year % 100).toString().padLeft(2, '0');
    return '$dd/$mm/$yy';
  }

  /// Selects the given date in the ViewModel (normalizes to date-only).
  Future<void> selectDate(WidgetRef ref, DateTime d) async {
    final sel = DateTime(d.year, d.month, d.day);
    await ref
        .read(transactionHistoryViewModelProvider.notifier)
        .setSelectedDate(sel);
  }
}
