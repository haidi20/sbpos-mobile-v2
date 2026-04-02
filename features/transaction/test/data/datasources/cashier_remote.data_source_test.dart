import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:transaction/data/datasources/cashier_remote.data_source.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';

class _FakeApiHelper implements ApiHelper {
  http.Response? nextGetResponse;
  http.Response? nextPostResponse;
  http.Response? nextPutResponse;
  String? lastGetUrl;
  String? lastPostUrl;
  String? lastPutUrl;
  Map<String, dynamic>? lastGetParams;
  Map<String, dynamic>? lastPostBody;
  Map<String, dynamic>? lastPutBody;

  @override
  Future<http.Response> get({
    required String url,
    Map<String, dynamic>? params,
  }) async {
    lastGetUrl = url;
    lastGetParams = params;
    return nextGetResponse ??
        http.Response(
          jsonEncode({'success': true, 'data': []}),
          200,
        );
  }

  @override
  Future<http.Response> post({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    lastPostUrl = url;
    lastPostBody = body;
    return nextPostResponse ??
        http.Response(
          jsonEncode({'success': true, 'data': true}),
          200,
        );
  }

  @override
  Future<http.Response> put({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    lastPutUrl = url;
    lastPutBody = body;
    return nextPutResponse ??
        http.Response(
          jsonEncode({'success': true, 'message': 'ok'}),
          200,
        );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

void main() {
  late _FakeApiHelper apiHelper;
  late CashierRemoteDataSource dataSource;

  setUp(() {
    apiHelper = _FakeApiHelper();
    dataSource = CashierRemoteDataSource(
      host: 'https://example.com',
      api: 'api',
      apiHelper: apiHelper,
    );
  });

  test('getCustomCategories memanggil endpoint kategori kasir', () async {
    apiHelper.nextGetResponse = http.Response(
      jsonEncode({
        'success': true,
        'data': [
          {'id': 1, 'title': 'MAKANAN'},
          {'id': 2, 'title': 'MINUMAN'},
        ],
      }),
      200,
    );

    final result = await dataSource.getCustomCategories();

    expect(
      apiHelper.lastGetUrl,
      equals('https://example.com/api/customCategories'),
    );
    expect(result.map((item) => item.title).toList(), ['MAKANAN', 'MINUMAN']);
  });

  test('getOrderTypes memanggil endpoint jenis pesanan', () async {
    apiHelper.nextGetResponse = http.Response(
      jsonEncode({
        'success': true,
        'data': [
          {'id': 1, 'name': 'Dine In', 'icon': 'restaurant'},
          {'id': 2, 'name': 'Take Away', 'icon': 'shopping_bag'},
        ],
      }),
      200,
    );

    final result = await dataSource.getOrderTypes();

    expect(
      apiHelper.lastGetUrl,
      equals('https://example.com/api/transaction/order-types'),
    );
    expect(result.first.name, equals('Dine In'));
    expect(result.last.name, equals('Take Away'));
  });

  test('getOjolOptions memanggil endpoint ojol', () async {
    apiHelper.nextGetResponse = http.Response(
      jsonEncode({
        'success': true,
        'data': [
          {'id': 'gofood', 'name': 'Go Food', 'fee_percent': 20},
          {'id': 'grabfood', 'name': 'Grab Food', 'fee_percent': 18},
        ],
      }),
      200,
    );

    final result = await dataSource.getOjolOptions();

    expect(apiHelper.lastGetUrl, equals('https://example.com/api/ojol'));
    expect(result.first.id, equals('gofood'));
    expect(result.first.feePercent, equals(20));
  });

  test('checkTransactionQty mengirim product_id dan qty ke endpoint', () async {
    apiHelper.nextPostResponse = http.Response(
      jsonEncode({
        'success': true,
        'data': {'allowed': true},
      }),
      200,
    );

    final result = await dataSource.checkTransactionQty(
      productId: 9,
      qty: 2,
    );

    expect(
      apiHelper.lastPostUrl,
      equals('https://example.com/api/transaction/check-qty'),
    );
    expect(
      apiHelper.lastPostBody,
      equals({'product_id': '9', 'qty': '2'}),
    );
    expect(result, isTrue);
  });

  test('checkTransactionQty melempar validasi saat stok tidak cukup', () async {
    apiHelper.nextPostResponse = http.Response(
      jsonEncode({
        'success': false,
        'message': 'Stok kurang',
        'data': {'allowed': false},
      }),
      200,
    );

    expect(
      () => dataSource.checkTransactionQty(productId: 9, qty: 10),
      throwsA(isA<ServerValidation>()),
    );
  });

  test('checkoutTransaction memilih endpoint normal', () async {
    apiHelper.nextPostResponse = http.Response(
      jsonEncode({
        'success': true,
        'data': {
          'id': 99,
          'sequence_number': 100,
          'order_type_id': 1,
          'warehouse_id': 1,
          'date': '2026-04-02T10:00:00.000',
          'total_amount': 25000,
          'total_qty': 2,
          'status': 'lunas',
          'details': [
            {
              'product_id': 1,
              'product_name': 'Americano',
              'product_price': 25000,
              'qty': 1,
              'subtotal': 25000,
            }
          ],
        },
      }),
      200,
    );

    final result = await dataSource.checkoutTransaction(
      TransactionEntity(
        outletId: 1,
        sequenceNumber: 1,
        orderTypeId: 1,
        date: DateTime(2026, 4, 2, 10),
        totalAmount: 25000,
        totalQty: 1,
        paidAmount: 30000,
        changeMoney: 5000,
        paymentMethod: 'cash',
        details: const [
          TransactionDetailEntity(
            productId: 1,
            productName: 'Americano',
            productPrice: 25000,
            qty: 1,
            subtotal: 25000,
          ),
        ],
      ),
      isOnline: false,
    );

    expect(
      apiHelper.lastPostUrl,
      equals('https://example.com/api/transaction'),
    );
    expect(apiHelper.lastPostBody?['payment_method'], equals('cash'));
    expect(result.idServer, equals(99));
    expect(result.totalAmount, equals(25000));
  });

  test('checkoutTransaction memilih endpoint online', () async {
    apiHelper.nextPostResponse = http.Response(
      jsonEncode({
        'success': true,
        'data': {
          'id': 101,
          'sequence_number': 88,
          'order_type_id': 3,
          'warehouse_id': 1,
          'date': '2026-04-02T12:00:00.000',
          'total_amount': 40000,
          'total_qty': 2,
          'status': 'pending',
        },
      }),
      200,
    );

    await dataSource.checkoutTransaction(
      TransactionEntity(
        outletId: 1,
        sequenceNumber: 1,
        orderTypeId: 3,
        date: DateTime(2026, 4, 2, 12),
        totalAmount: 40000,
        totalQty: 2,
        paymentMethod: 'qris',
        details: const [],
      ),
      isOnline: true,
    );

    expect(
      apiHelper.lastPostUrl,
      equals('https://example.com/api/transaction/online'),
    );
  });

  test('getNotPaidTransactions memanggil endpoint order gantung', () async {
    apiHelper.nextGetResponse = http.Response(
      jsonEncode({
        'success': true,
        'data': [
          {
            'id': 11,
            'sequence_number': 10,
            'order_type_id': 1,
            'warehouse_id': 1,
            'date': '2026-04-02T14:00:00.000',
            'total_amount': 15000,
            'total_qty': 1,
            'status': 'pending',
          }
        ],
      }),
      200,
    );

    final result = await dataSource.getNotPaidTransactions();

    expect(
      apiHelper.lastGetUrl,
      equals('https://example.com/api/transaction/not-paid'),
    );
    expect(result.first.idServer, equals(11));
  });

  test('requestCancelTransaction mengirim alasan batal ke endpoint OTP',
      () async {
    apiHelper.nextPostResponse = http.Response(
      jsonEncode({
        'success': true,
        'message': 'OTP supervisor telah dikirim',
      }),
      200,
    );

    final result = await dataSource.requestCancelTransaction(
      transactionId: 77,
      reason: 'Customer berubah pikiran',
    );

    expect(
      apiHelper.lastPostUrl,
      equals('https://example.com/api/transaction/cancel-request'),
    );
    expect(
      apiHelper.lastPostBody,
      equals({
        'transaction_id': '77',
        'reason': 'Customer berubah pikiran',
      }),
    );
    expect(result.success, isTrue);
    expect(result.message, contains('OTP'));
  });

  test('confirmCancelTransaction mengirim OTP ke endpoint batal final',
      () async {
    apiHelper.nextPutResponse = http.Response(
      jsonEncode({
        'success': true,
        'message': 'Pesanan berhasil dibatalkan',
      }),
      200,
    );

    final result = await dataSource.confirmCancelTransaction(
      transactionId: 77,
      otp: '123456',
    );

    expect(
      apiHelper.lastPutUrl,
      equals('https://example.com/api/transaction/77/cancel'),
    );
    expect(
      apiHelper.lastPutBody,
      equals({'otp': '123456'}),
    );
    expect(result.success, isTrue);
    expect(result.message, contains('dibatalkan'));
  });

  test('checkEditOrder mengirim query transaction_id ke endpoint edit check',
      () async {
    apiHelper.nextGetResponse = http.Response(
      jsonEncode({
        'success': true,
        'message': 'Order bisa diedit',
        'data': {
          'can_edit': true,
          'transaction': {
            'id': 44,
            'sequence_number': 501,
            'order_type_id': 1,
            'warehouse_id': 1,
            'date': '2026-04-02T15:00:00.000',
            'total_amount': 32000,
            'total_qty': 2,
            'status': 'pending',
          },
        },
      }),
      200,
    );

    final result = await dataSource.checkEditOrder(44);

    expect(
      apiHelper.lastGetUrl,
      equals('https://example.com/api/edit-order/check'),
    );
    expect(
      apiHelper.lastGetParams,
      equals({'transaction_id': '44'}),
    );
    expect(result.canEdit, isTrue);
    expect(result.transaction?.idServer, equals(44));
  });
}
