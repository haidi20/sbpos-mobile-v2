library transaction_pos_vm;

import 'package:core/core.dart';
import 'package:product/domain/entities/packet.entity.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:transaction/data/dummy/order_type_dummy.dart';
import 'package:customer/domain/entities/customer.entity.dart';
import 'package:product/domain/usecases/get_packets.usecase.dart';
import 'package:product/domain/usecases/get_products.usecase.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/entitties/content_item.entity.dart';
import 'package:product/domain/entities/packet_selected_item.entity.dart';
import 'package:transaction/domain/entitties/combined_content.entity.dart';
import 'package:transaction/presentation/ui_models/order_type_item.um.dart';
import 'package:transaction/presentation/ui_models/payment_method.um.dart';
import 'package:transaction/presentation/ui_models/ojol_provider.um.dart';
import 'package:transaction/domain/usecases/update_transaction.usecase.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';
import 'package:transaction/domain/usecases/create_transaction.usecase.dart';
import 'package:transaction/domain/usecases/delete_transaction.usecase.dart';
import 'package:transaction/presentation/helpers/order_type_icon.helper.dart';
import 'package:transaction/presentation/view_models/transaction_pos/transaction_pos.state.dart';
import 'package:transaction/domain/usecases/get_transaction_active.usecase.dart';
import 'package:transaction/domain/usecases/get_last_secuence_number_transaction.usecase.dart';
import 'package:transaction/presentation/view_models/transaction_pos/transaction_pos.persistence.dart';
import 'package:transaction/presentation/view_models/transaction_pos/transaction_pos.calculations.dart';

part 'transaction_pos.getters.dart';
part 'transaction_pos.setters.dart';
part 'transaction_pos.actions.dart';

// Usecase Product/Paket disediakan oleh composition root (provider)
// dan diinjeksi ke ViewModel ini. Jangan membuat repository palsu di sini.

class TransactionPosViewModel extends StateNotifier<TransactionPosState>
    with
        TransactionPosViewModelGetters,
        TransactionPosViewModelSetters,
        TransactionPosViewModelActions {
  final CreateTransaction _createTransaction;
  final UpdateTransaction _updateTransaction;
  final DeleteTransaction _deleteTransaction;
  final GetTransactionActive _getTransactionActive;
  final GetLastSequenceNumberTransaction? _getLastSequenceNumber;
  late final GetPackets? _getPacketsUsecase;
  late final GetProducts? _getProductsUsecase;
  List<ProductEntity> _cachedProducts = [];
  List<ProductEntity> get cachedProducts => _cachedProducts;
  // Cache konten gabungan (paket + produk) agar UI tidak menghitung ulang berulang kali
  List<ContentItemEntity> _combinedCache = [];

  // Pembungkus yang mengekspos daftar dan flag muating supaya UI dapat merespon
  // status muating konten gabungan tanpa harus mengakses flag internal VM.
  CombinedContent get combinedContent => CombinedContent(
        isLoadingCombined: state.isLoadingContent,
        items: _combinedCache,
      );
  final _logger = Logger('TransactionPosViewModel');
  late final TransactionPersistence _persistence;
  // Guard untuk mencegah pembuatan transaksi pending secara bersamaan
  Completer<void>? _createTxCompleter;
  // Guard untuk mencegah pemanggilan refreshProductsAndPackets yang bersamaan/terlalu cepat
  bool _isRefreshing = false;
  // Timer debounce untuk pembaruan catatan (catatan)
  Timer? _orderNoteDebounce;
  final Map<int, Timer> _itemNoteDebounces = {};

  TransactionPosViewModel(
    this._createTransaction,
    this._updateTransaction,
    this._deleteTransaction,
    this._getTransactionActive, [
    this._getLastSequenceNumber,
    GetPackets? getPackets,
    GetProducts? getProducts,
  ]) : super(TransactionPosState()) {
    // Inisialisasi layanan persistensi dan muat transaksi lokal dari database
    _persistence = TransactionPersistence(
      _createTransaction,
      _updateTransaction,
      _deleteTransaction,
      _logger,
      getLastSequenceUsecase: _getLastSequenceNumber,
    );
    _getPacketsUsecase = getPackets;
    _getProductsUsecase = getProducts;
    (() async {
      // await _persistence.muatLocalTransaction(
      //   _getTransactionActive,
      //   () => state,
      //   (s) => state = s,
      // );
    })();
  }

  @override
  void dispose() {
    try {
      _orderNoteDebounce?.cancel();
      for (final t in _itemNoteDebounces.values) {
        try {
          t.cancel();
        } catch (_) {}
      }
      _itemNoteDebounces.clear();

      if (_createTxCompleter != null && !(_createTxCompleter!.isCompleted)) {
        try {
          _createTxCompleter!.complete();
        } catch (_) {}
      }
    } finally {
      super.dispose();
    }
  }
}
