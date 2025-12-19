import 'package:customer/domain/entities/customer.entity.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/presentation/ui_models/ojol_provider.um.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';
import 'package:product/domain/entities/packet.entity.dart';

enum ETypeCart {
  main,
  confirm,
  checkout,
}

enum EOrderType {
  dineIn,
  takeAway,
  online,
}

enum EViewMode {
  cart,
  checkout,
}

enum EPaymentMethod {
  cash,
  qris,
  transfer,
}

class TransactionPosState {
  final String? error;
  final bool isLoading;
  final bool isLoadingContent;
  final bool isLoadingPersistent;
  final String orderNote;
  final int? activeNoteId;
  final String? searchQuery;
  final ETypeCart typeCart;
  final EOrderType orderType;
  final String ojolProvider; // e.g. 'GoFood', 'GrabFood'
  final List<OjolProviderUiModel> ojolProviders;
  final EPaymentMethod paymentMethod;
  final int cashReceived;
  final EViewMode viewMode;
  final bool isPaid;
  final bool showErrorSnackbar;
  final String activeCategory;
  final TransactionEntity? transaction;
  final CustomerEntity? selectedCustomer;
  final List<PacketEntity> packets;
  final List<TransactionDetailEntity> details;

  TransactionPosState({
    this.error,
    this.transaction,
    this.searchQuery,
    this.activeNoteId,
    this.orderNote = "",
    this.selectedCustomer,
    this.isLoading = false,
    this.isLoadingContent = false,
    this.isLoadingPersistent = false,
    this.activeCategory = "Semua",
    this.typeCart = ETypeCart.main,
    this.orderType = EOrderType.dineIn,
    this.ojolProvider = '',
    List<OjolProviderUiModel>? ojolProviders,
    this.paymentMethod = EPaymentMethod.cash,
    this.cashReceived = 0,
    this.viewMode = EViewMode.cart,
    this.isPaid = false,
    this.showErrorSnackbar = false,
    List<TransactionDetailEntity>? details,
    List<PacketEntity>? packets,
  })  : details = details ?? const [],
        packets = packets ?? const [],
        ojolProviders = (ojolProviders != null && ojolProviders.isNotEmpty)
            ? ojolProviders
            : ojolProviderList;

  TransactionPosState copyWith({
    String? error,
    bool? isLoading,
    bool? isLoadingContent,
    bool? isLoadingPersistent,
    EViewMode? viewMode,
    int? cashReceived,
    String? orderNote,
    int? activeNoteId,
    String? searchQuery,
    EOrderType? orderType,
    String? ojolProvider,
    List<OjolProviderUiModel>? ojolProviders,
    EPaymentMethod? paymentMethod,
    ETypeCart? typeCart,
    String? activeCategory,
    bool? showErrorSnackbar,
    TransactionEntity? transaction,
    CustomerEntity? selectedCustomer,
    List<TransactionDetailEntity>? details,
    List<PacketEntity>? packets,
    bool? isPaid,
  }) {
    return TransactionPosState(
      error: error ?? this.error,
      details: details ?? this.details,
      packets: packets ?? this.packets,
      isLoading: isLoading ?? this.isLoading,
      isLoadingContent: isLoadingContent ?? this.isLoadingContent,
      isLoadingPersistent: isLoadingPersistent ?? this.isLoadingPersistent,
      orderNote: orderNote ?? this.orderNote,
      orderType: orderType ?? this.orderType,
      ojolProvider: ojolProvider ?? this.ojolProvider,
      ojolProviders: ojolProviders ?? this.ojolProviders,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      cashReceived: cashReceived ?? this.cashReceived,
      viewMode: viewMode ?? this.viewMode,
      isPaid: isPaid ?? this.isPaid,
      showErrorSnackbar: showErrorSnackbar ?? this.showErrorSnackbar,
      typeCart: typeCart ?? this.typeCart,
      searchQuery: searchQuery ?? this.searchQuery,
      transaction: transaction ?? this.transaction,
      activeNoteId: activeNoteId ?? this.activeNoteId,
      activeCategory: activeCategory ?? this.activeCategory,
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
    );
  }

  // Clear Semua state back to initial defaults
  factory TransactionPosState.cleared() {
    return TransactionPosState(
      error: null,
      transaction: null,
      searchQuery: null,
      activeNoteId: null,
      orderNote: "",
      selectedCustomer: null,
      isLoading: false,
      isLoadingContent: false,
      isLoadingPersistent: false,
      activeCategory: "Semua",
      details: const [],
      packets: const [],
      // reset UI state to defaults
      orderType: EOrderType.dineIn,
      ojolProvider: '',
      ojolProviders: ojolProviderList,
      typeCart: ETypeCart.main,
      paymentMethod: EPaymentMethod.cash,
      cashReceived: 0,
      viewMode: EViewMode.cart,
      isPaid: false,
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
    bool resetIsLoadingContent = false,
    bool resetIsLoadingPersistent = false,
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
      isLoadingContent: resetIsLoadingContent ? false : isLoadingContent,
      isLoadingPersistent:
          resetIsLoadingPersistent ? false : isLoadingPersistent,
      activeCategory: resetActiveCategory ? "Semua" : activeCategory,
      details: clearDetails ? const [] : details,
      packets: clearDetails ? const [] : packets,
    );
  }
}
