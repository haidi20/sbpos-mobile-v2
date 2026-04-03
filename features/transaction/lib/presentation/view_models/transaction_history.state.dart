import 'package:transaction/domain/entitties/transaction.entity.dart';

enum TransactionHistoryMode {
  history,
  notPaid,
}

class TransactionHistoryState {
  final List<TransactionEntity> transactions;
  final List<TransactionEntity> notPaidTransactions;
  final bool isLoading;
  final bool isLoadingNotPaid;
  final String? error;
  final String? searchQuery;
  final DateTime? selectedDate;
  final TransactionHistoryMode mode;

  TransactionHistoryState({
    List<TransactionEntity>? transactions,
    List<TransactionEntity>? notPaidTransactions,
    this.isLoading = false,
    this.isLoadingNotPaid = false,
    this.error,
    this.searchQuery,
    DateTime? selectedDate,
    this.mode = TransactionHistoryMode.history,
  })  : transactions = transactions ?? const [],
        notPaidTransactions = notPaidTransactions ?? const [],
        selectedDate = selectedDate ??
            DateTime(
              DateTime.now().year,
              DateTime.now().month,
              DateTime.now().day,
            );

  TransactionHistoryState._internal({
    required this.transactions,
    required this.notPaidTransactions,
    this.isLoading = false,
    this.isLoadingNotPaid = false,
    this.error,
    this.searchQuery,
    this.selectedDate,
    this.mode = TransactionHistoryMode.history,
  });

  factory TransactionHistoryState.create({
    List<TransactionEntity>? transactions,
    List<TransactionEntity>? notPaidTransactions,
    bool isLoading = false,
    bool isLoadingNotPaid = false,
    String? error,
    String? searchQuery,
    DateTime? selectedDate,
    TransactionHistoryMode mode = TransactionHistoryMode.history,
  }) {
    final now = DateTime.now();
    final sel = selectedDate ?? DateTime(now.year, now.month, now.day);
    return TransactionHistoryState._internal(
      transactions: transactions ?? const [],
      notPaidTransactions: notPaidTransactions ?? const [],
      isLoading: isLoading,
      isLoadingNotPaid: isLoadingNotPaid,
      error: error,
      searchQuery: searchQuery,
      selectedDate: sel,
      mode: mode,
    );
  }

  TransactionHistoryState copyWith(
      {List<TransactionEntity>? transactions,
      List<TransactionEntity>? notPaidTransactions,
      bool? isLoading,
      bool? isLoadingNotPaid,
      String? error,
      String? searchQuery,
      DateTime? selectedDate,
      TransactionHistoryMode? mode}) {
    return TransactionHistoryState._internal(
      transactions: transactions ?? this.transactions,
      notPaidTransactions: notPaidTransactions ?? this.notPaidTransactions,
      isLoading: isLoading ?? this.isLoading,
      isLoadingNotPaid: isLoadingNotPaid ?? this.isLoadingNotPaid,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedDate: selectedDate ?? this.selectedDate,
      mode: mode ?? this.mode,
    );
  }
}
