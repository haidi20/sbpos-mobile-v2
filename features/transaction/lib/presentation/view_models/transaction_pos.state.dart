import 'package:customer/domain/entities/customer.entity.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';

enum ETypeChart {
  main,
  confirm,
  checkout,
}

enum EOrderType {
  dineIn,
  online,
  takeAway,
}

class TransactionPosState {
  final String? error;
  final bool isLoading;
  final String orderNote;
  final int? activeNoteId;
  final String? searchQuery;
  final ETypeChart typeChart;
  // UI state for payment flow
  final EOrderType orderType; // 'dine_in' | 'take_away' | 'online'
  final String ojolProvider; // e.g. 'GoFood', 'GrabFood'
  final String paymentMethod; // 'cash' | 'qris' | 'transfer'
  final int cashReceived;
  final String viewMode; // 'cart' | 'checkout'
  final bool showErrorSnackbar;
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
    this.typeChart = ETypeChart.main,
    this.orderType = EOrderType.dineIn,
    this.ojolProvider = '',
    this.paymentMethod = 'cash',
    this.cashReceived = 0,
    this.viewMode = 'cart',
    this.showErrorSnackbar = false,
    List<TransactionDetailEntity>? details,
  }) : details = details ?? const [];

  TransactionPosState copyWith({
    String? error,
    bool? isLoading,
    String? viewMode,
    int? cashReceived,
    String? orderNote,
    int? activeNoteId,
    String? searchQuery,
    EOrderType? orderType,
    String? ojolProvider,
    String? paymentMethod,
    ETypeChart? typeChart,
    String? activeCategory,
    bool? showErrorSnackbar,
    TransactionEntity? transaction,
    CustomerEntity? selectedCustomer,
    List<TransactionDetailEntity>? details,
  }) {
    return TransactionPosState(
      error: error ?? this.error,
      details: details ?? this.details,
      isLoading: isLoading ?? this.isLoading,
      orderNote: orderNote ?? this.orderNote,
      orderType: orderType ?? this.orderType,
      ojolProvider: ojolProvider ?? this.ojolProvider,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      cashReceived: cashReceived ?? this.cashReceived,
      viewMode: viewMode ?? this.viewMode,
      showErrorSnackbar: showErrorSnackbar ?? this.showErrorSnackbar,
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
      // reset UI state to defaults
      orderType: EOrderType.dineIn,
      ojolProvider: '',
      paymentMethod: 'cash',
      cashReceived: 0,
      viewMode: 'cart',
      showErrorSnackbar: false,
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
