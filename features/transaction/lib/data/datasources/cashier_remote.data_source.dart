import 'package:core/core.dart';
import 'package:transaction/data/models/cashier_category.model.dart';
import 'package:transaction/data/models/edit_order_check.model.dart';
import 'package:transaction/data/models/ojol_option.model.dart';
import 'package:transaction/data/models/order_type_model.dart';
import 'package:transaction/data/models/transaction.model.dart';
import 'package:transaction/data/models/transaction_action.model.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';

class CashierRemoteDataSource with BaseErrorHelper {
  final String host;
  final String api;
  final ApiHelper _apiHelper;
  final Logger _logger = Logger('CashierRemoteDataSource');

  CashierRemoteDataSource({
    String? host,
    String? api,
    ApiHelper? apiHelper,
  })  : host = host ?? HOST,
        api = api ?? API,
        _apiHelper = apiHelper ?? ApiHelper();

  Future<Map<String, dynamic>> _decodeResponse(
    Future<dynamic> Function() request,
    String label,
  ) async {
    try {
      final response = await handleApiResponse(() async => await request());
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e, st) {
      _logger.warning('$label failed: $e', e, st);
      rethrow;
    }
  }

  void _ensureSuccess(Map<String, dynamic> json, {String? fallbackMessage}) {
    final success = _toBool(json['success']) ??
        _toBool(json['status']) ??
        _toBool(json['data']) ??
        true;
    if (success) return;

    throw ServerValidation(
      (json['message'] ?? fallbackMessage ?? 'Permintaan gagal').toString(),
    );
  }

  List<Map<String, dynamic>> _extractList(dynamic value) {
    if (value is List) {
      return value.whereType<Map<String, dynamic>>().toList();
    }
    return const [];
  }

  Map<String, dynamic>? _extractMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    return null;
  }

  Future<bool> checkTransactionQty({
    required int productId,
    required int qty,
  }) async {
    final json = await _decodeResponse(
      () => _apiHelper.post(
        url: '$host/$api/transaction/check-qty',
        body: {
          'product_id': productId.toString(),
          'qty': qty.toString(),
        },
      ),
      'checkTransactionQty',
    );

    final data = json['data'];
    final allowed = _toBool(data) ??
        _toBool(_extractMap(data)?['allowed']) ??
        _toBool(_extractMap(data)?['is_valid']) ??
        _toBool(json['success']) ??
        false;

    if (!allowed) {
      throw ServerValidation(
        (json['message'] ?? 'Stok produk tidak mencukupi').toString(),
      );
    }

    return true;
  }

  Future<List<CashierCategoryModel>> getCustomCategories() async {
    final json = await _decodeResponse(
      () => _apiHelper.get(url: '$host/$api/customCategories'),
      'getCustomCategories',
    );
    _ensureSuccess(json, fallbackMessage: 'Gagal mengambil kategori kasir');
    return _extractList(json['data'])
        .map(CashierCategoryModel.fromJson)
        .toList();
  }

  Future<List<OrderTypeModel>> getOrderTypes() async {
    final json = await _decodeResponse(
      () => _apiHelper.get(url: '$host/$api/transaction/order-types'),
      'getOrderTypes',
    );
    _ensureSuccess(json, fallbackMessage: 'Gagal mengambil jenis pesanan');
    return _extractList(json['data']).map(OrderTypeModel.fromJson).toList();
  }

  Future<List<OjolOptionModel>> getOjolOptions() async {
    final json = await _decodeResponse(
      () => _apiHelper.get(url: '$host/$api/ojol'),
      'getOjolOptions',
    );
    _ensureSuccess(json, fallbackMessage: 'Gagal mengambil data ojol');
    return _extractList(json['data']).map(OjolOptionModel.fromJson).toList();
  }

  Future<TransactionModel> checkoutTransaction(
    TransactionEntity transaction, {
    required bool isOnline,
  }) async {
    final url = isOnline
        ? '$host/$api/transaction/online'
        : '$host/$api/transaction';
    final json = await _decodeResponse(
      () => _apiHelper.post(
        url: url,
        body: _buildCheckoutPayload(transaction),
      ),
      'checkoutTransaction',
    );
    _ensureSuccess(json, fallbackMessage: 'Gagal memproses transaksi');

    final data = json['data'];
    if (data is List && data.isNotEmpty && data.first is Map<String, dynamic>) {
      return TransactionModel.fromJson(data.first as Map<String, dynamic>);
    }

    final dataMap = _extractMap(data);
    if (dataMap != null) {
      final transactionMap = _extractMap(dataMap['transaction']) ?? dataMap;
      return TransactionModel.fromJson(transactionMap);
    }

    throw const ServerValidation('Respons transaksi dari server tidak valid');
  }

  Future<List<TransactionModel>> getNotPaidTransactions() async {
    final json = await _decodeResponse(
      () => _apiHelper.get(url: '$host/$api/transaction/not-paid'),
      'getNotPaidTransactions',
    );
    _ensureSuccess(json, fallbackMessage: 'Gagal mengambil order gantung');
    return _extractList(json['data']).map(TransactionModel.fromJson).toList();
  }

  Future<TransactionActionModel> requestCancelTransaction({
    required int transactionId,
    required String reason,
  }) async {
    final json = await _decodeResponse(
      () => _apiHelper.post(
        url: '$host/$api/transaction/cancel-request',
        body: {
          'transaction_id': transactionId.toString(),
          'reason': reason,
        },
      ),
      'requestCancelTransaction',
    );
    final model = TransactionActionModel.fromJson(json);
    if (!model.success) {
      throw ServerValidation(
        model.message.isEmpty ? 'Gagal meminta OTP pembatalan' : model.message,
      );
    }
    return model;
  }

  Future<TransactionActionModel> confirmCancelTransaction({
    required int transactionId,
    required String otp,
  }) async {
    final json = await _decodeResponse(
      () => _apiHelper.put(
        url: '$host/$api/transaction/$transactionId/cancel',
        body: {
          'otp': otp,
        },
      ),
      'confirmCancelTransaction',
    );
    final model = TransactionActionModel.fromJson(json);
    if (!model.success) {
      throw ServerValidation(
        model.message.isEmpty ? 'OTP pembatalan tidak valid' : model.message,
      );
    }
    return model;
  }

  Future<EditOrderCheckModel> checkEditOrder(int transactionId) async {
    final json = await _decodeResponse(
      () => _apiHelper.get(
        url: '$host/$api/edit-order/check',
        params: {
          'transaction_id': transactionId.toString(),
        },
      ),
      'checkEditOrder',
    );
    final model = EditOrderCheckModel.fromJson(json);
    if (!model.canEdit) {
      throw ServerValidation(
        model.message.isEmpty ? 'Order tidak dapat diedit' : model.message,
      );
    }
    return model;
  }

  Map<String, dynamic> _buildCheckoutPayload(TransactionEntity transaction) {
    final paidAmount = transaction.paidAmount ??
        transaction.totalAmount + transaction.changeMoney;

    return {
      'customer': transaction.customerSelected?.name ?? '',
      'order_type_id': transaction.orderTypeId.toString(),
      'payment_method': transaction.paymentMethod ?? '',
      'sub_total': transaction.totalAmount.toString(),
      'total': transaction.totalAmount.toString(),
      'cash': paidAmount.toString(),
      'change': transaction.changeMoney.toString(),
      'category_order': transaction.categoryOrder ?? '',
      'ojol_provider': transaction.ojolProvider ?? '',
      'number_table': transaction.numberTable?.toString() ?? '',
      'notes': transaction.notes ?? '',
      'items': jsonEncode(
        (transaction.details ?? const [])
            .map(
              (detail) => {
                'product_id': detail.productId,
                'packet_id': detail.packetId,
                'qty': detail.qty ?? 0,
                'price': detail.productPrice ?? detail.packetPrice ?? 0,
                'total_price': detail.subtotal ??
                    ((detail.productPrice ?? detail.packetPrice ?? 0) *
                        (detail.qty ?? 0)),
                'note': detail.note ?? '',
              },
            )
            .toList(),
      ),
    };
  }

  static bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      if (value == '1') return true;
      if (value == '0') return false;
      return value.toLowerCase() == 'true';
    }
    return null;
  }
}
