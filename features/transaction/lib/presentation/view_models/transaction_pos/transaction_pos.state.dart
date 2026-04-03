import 'package:customer/domain/entities/customer.entity.dart';
import 'package:transaction/domain/entitties/cashier_category.entity.dart';
import 'package:transaction/domain/entitties/order_type.entity.dart';
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

enum EPaymentMethod {
  cash,
  qris,
  transfer,
}

enum ETransactionMode {
  create,
  edit,
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
  final String ojolProvider;
  final List<OjolProviderUiModel> ojolProviders;
  final List<CashierCategoryEntity> customCategories;
  final List<OrderTypeEntity> orderTypes;
  final EPaymentMethod paymentMethod;
  final int cashReceived;
  final ETransactionMode transactionMode;
  final bool isPaid;
  final bool showErrorSnackbar;
  final bool isSyncingMasterData;
  final bool isCheckingOut;
  final String activeCategory;
  final TransactionEntity? transaction;
  final CustomerEntity? selectedCustomer;
  final List<PacketEntity> packets;
  final List<TransactionDetailEntity> details;
  final bool useTableNumber;
  final int? tableNumber;

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
    List<CashierCategoryEntity>? customCategories,
    List<OrderTypeEntity>? orderTypes,
    this.paymentMethod = EPaymentMethod.cash,
    this.cashReceived = 0,
    this.transactionMode = ETransactionMode.create,
    this.isPaid = false,
    this.showErrorSnackbar = false,
    this.isSyncingMasterData = false,
    this.isCheckingOut = false,
    List<TransactionDetailEntity>? details,
    List<PacketEntity>? packets,
    this.useTableNumber = false,
    this.tableNumber,
  })  : details = details ?? const [],
        packets = packets ?? const [],
        customCategories = customCategories ?? const [],
        orderTypes = orderTypes ?? const [],
        ojolProviders = (ojolProviders != null && ojolProviders.isNotEmpty)
            ? ojolProviders
            : ojolProviderList;

  TransactionPosState copyWith({
    String? error,
    bool? isLoading,
    bool? isLoadingContent,
    bool? isLoadingPersistent,
    ETransactionMode? transactionMode,
    int? cashReceived,
    String? orderNote,
    int? activeNoteId,
    String? searchQuery,
    EOrderType? orderType,
    String? ojolProvider,
    List<OjolProviderUiModel>? ojolProviders,
    List<CashierCategoryEntity>? customCategories,
    List<OrderTypeEntity>? orderTypes,
    EPaymentMethod? paymentMethod,
    ETypeCart? typeCart,
    String? activeCategory,
    bool? showErrorSnackbar,
    bool? isSyncingMasterData,
    bool? isCheckingOut,
    TransactionEntity? transaction,
    CustomerEntity? selectedCustomer,
    List<TransactionDetailEntity>? details,
    List<PacketEntity>? packets,
    bool? isPaid,
    bool? useTableNumber,
    int? tableNumber,
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
      customCategories: customCategories ?? this.customCategories,
      orderTypes: orderTypes ?? this.orderTypes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      cashReceived: cashReceived ?? this.cashReceived,
      transactionMode: transactionMode ?? this.transactionMode,
      isPaid: isPaid ?? this.isPaid,
      showErrorSnackbar: showErrorSnackbar ?? this.showErrorSnackbar,
      isSyncingMasterData: isSyncingMasterData ?? this.isSyncingMasterData,
      isCheckingOut: isCheckingOut ?? this.isCheckingOut,
      typeCart: typeCart ?? this.typeCart,
      searchQuery: searchQuery ?? this.searchQuery,
      transaction: transaction ?? this.transaction,
      activeNoteId: activeNoteId ?? this.activeNoteId,
      activeCategory: activeCategory ?? this.activeCategory,
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
      useTableNumber: useTableNumber ?? this.useTableNumber,
      tableNumber: tableNumber ?? this.tableNumber,
    );
  }

  // Bersihkan semua state kembali ke nilai awal (default)
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
      // mengatur kembali state UI ke nilai default
      orderType: EOrderType.dineIn,
      ojolProvider: '',
      ojolProviders: ojolProviderList,
      typeCart: ETypeCart.main,
      paymentMethod: EPaymentMethod.cash,
      cashReceived: 0,
      customCategories: const [],
      orderTypes: const [],
      transactionMode: ETransactionMode.create,
      isPaid: false,
      showErrorSnackbar: false,
      isSyncingMasterData: false,
      isCheckingOut: false,
      useTableNumber: false,
      tableNumber: null,
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
      transactionMode: ETransactionMode.create,
    );
  }
}
