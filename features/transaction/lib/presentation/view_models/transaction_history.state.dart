import 'package:transaction/domain/entitties/transaction.entity.dart';

class TransactionHistoryState {
  final List<TransactionEntity> transactions;
  final bool isLoading;
  final String? error;
  final String? searchQuery;
  final DateTime? selectedDate;

  TransactionHistoryState({
    List<TransactionEntity>? transactions,
    this.isLoading = false,
    this.error,
    this.searchQuery,
    DateTime? selectedDate,
  })  : transactions = transactions ?? const [],
        selectedDate = selectedDate ??
            DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
            );

  TransactionHistoryState._internal({
    required this.transactions,
    this.isLoading = false,
    this.error,
    this.searchQuery,
    this.selectedDate,
  });

  factory TransactionHistoryState.create({
    List<TransactionEntity>? transactions,
    bool isLoading = false,
    String? error,
    String? searchQuery,
    DateTime? selectedDate,
  }) {
    final now = DateTime.now();
    final sel = selectedDate ?? DateTime(now.year, now.month, now.day);
    return TransactionHistoryState._internal(
      transactions: transactions ?? const [],
      isLoading: isLoading,
      error: error,
      searchQuery: searchQuery,
      selectedDate: sel,
    );
  }

  TransactionHistoryState copyWith(
      {List<TransactionEntity>? transactions,
      bool? isLoading,
      String? error,
      String? searchQuery,
      DateTime? selectedDate}) {
    return TransactionHistoryState._internal(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}
