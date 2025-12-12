import 'package:customer/domain/entities/customer.entity.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';

enum TypeChart {
  main,
  checkout,
}

class TransactionPosState {
  final String? error;
  final bool isLoading;
  final String orderNote;
  final int? activeNoteId;
  final String? searchQuery;
  final TypeChart typeChart;
  final String activeCategory;
  final TransactionEntity? transaction;
  final CustomerEntity? selectedCustomer;
  final List<TransactionDetailEntity> details;

  TransactionPosState({
    this.error,
    this.transaction,
    this.searchQuery,
    this.activeNoteId,
    this.orderNote = "",
    this.selectedCustomer,
    this.isLoading = false,
    this.activeCategory = "All",
    this.typeChart = TypeChart.main,
    List<TransactionDetailEntity>? details,
  }) : details = details ?? const [];

  TransactionPosState copyWith({
    String? error,
    bool? isLoading,
    String? orderNote,
    int? activeNoteId,
    String? searchQuery,
    TypeChart? typeChart,
    String? activeCategory,
    TransactionEntity? transaction,
    CustomerEntity? selectedCustomer,
    List<TransactionDetailEntity>? details,
  }) {
    return TransactionPosState(
      error: error ?? this.error,
      details: details ?? this.details,
      isLoading: isLoading ?? this.isLoading,
      orderNote: orderNote ?? this.orderNote,
      typeChart: typeChart ?? this.typeChart,
      searchQuery: searchQuery ?? this.searchQuery,
      transaction: transaction ?? this.transaction,
      activeNoteId: activeNoteId ?? this.activeNoteId,
      activeCategory: activeCategory ?? this.activeCategory,
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
    );
  }

  // Clear all state back to initial defaults
  factory TransactionPosState.cleared() {
    return TransactionPosState(
      error: null,
      transaction: null,
      searchQuery: null,
      activeNoteId: null,
      orderNote: "",
      selectedCustomer: null,
      isLoading: false,
      activeCategory: "All",
      details: const [],
    );
  }
}

// Utilitas opsional: null-kan field tertentu secara dinamis tanpa copyWith
extension TransactionPosStateClearX on TransactionPosState {
  TransactionPosState clear({
    bool clearError = false,
    bool clearTransaction = false,
    bool clearSearchQuery = false,
    bool clearActiveNoteId = false,
    bool clearOrderNote = false,
    bool clearSelectedCustomer = false,
    bool clearDetails = false,
    bool resetIsLoading = false,
    bool resetActiveCategory = false,
  }) {
    return TransactionPosState(
      error: clearError ? null : error,
      transaction: clearTransaction ? null : transaction,
      searchQuery: clearSearchQuery ? null : searchQuery,
      activeNoteId: clearActiveNoteId ? null : activeNoteId,
      orderNote: clearOrderNote ? "" : orderNote,
      selectedCustomer: clearSelectedCustomer ? null : selectedCustomer,
      isLoading: resetIsLoading ? false : isLoading,
      activeCategory: resetActiveCategory ? "All" : activeCategory,
      details: clearDetails ? const [] : details,
    );
  }
}
