import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';

class TransactionState {
  final String? error;
  final bool isLoading;
  final String orderNote;
  final int? activeNoteId;
  final String? searchQuery;
  final String activeCategory;
  final TransactionEntity? transaction;
  final List<TransactionDetailEntity> details;

  TransactionState({
    this.error,
    this.searchQuery,
    this.activeNoteId,
    this.orderNote = "",
    this.isLoading = false,
    this.transaction,
    List<TransactionDetailEntity>? details,
    this.activeCategory = "All",
  }) : details = details ?? const [];

  TransactionState copyWith({
    String? error,
    bool? isLoading,
    String? orderNote,
    int? activeNoteId,
    String? searchQuery,
    String? activeCategory,
    TransactionEntity? transaction,
    List<TransactionDetailEntity>? details,
  }) {
    return TransactionState(
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      activeCategory: activeCategory ?? this.activeCategory,
      transaction: transaction ?? this.transaction,
      details: details ?? this.details,
      orderNote: orderNote ?? this.orderNote,
      activeNoteId: activeNoteId ?? this.activeNoteId,
    );
  }
}
