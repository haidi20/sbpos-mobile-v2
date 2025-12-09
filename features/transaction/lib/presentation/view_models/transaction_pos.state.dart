import 'package:customer/domain/entities/customer.entity.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';

class TransactionPosState {
  final String? error;
  final bool isLoading;
  final String orderNote;
  final int? activeNoteId;
  final String? searchQuery;
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
    List<TransactionDetailEntity>? details,
  }) : details = details ?? const [];

  TransactionPosState copyWith({
    String? error,
    bool? isLoading,
    String? orderNote,
    int? activeNoteId,
    String? searchQuery,
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
      searchQuery: searchQuery ?? this.searchQuery,
      transaction: transaction ?? this.transaction,
      activeNoteId: activeNoteId ?? this.activeNoteId,
      activeCategory: activeCategory ?? this.activeCategory,
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
    );
  }
}
