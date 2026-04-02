import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:transaction/data/datasources/shift_remote.data_source.dart';
import 'package:transaction/data/models/close_cashier_request.model.dart';

class _FakeApiHelper implements ApiHelper {
  http.Response? nextGetResponse;
  http.Response? nextPostResponse;
  String? lastGetUrl;
  String? lastPostUrl;
  Map<String, dynamic>? lastGetParams;
  Map<String, dynamic>? lastPostBody;

  @override
  Future<http.Response> get({
    required String url,
    Map<String, dynamic>? params,
  }) async {
    lastGetUrl = url;
    lastGetParams = params;
    return nextGetResponse ??
        http.Response(
          jsonEncode({
            'success': true,
            'message': 'Kasir dapat ditutup',
            'data': {'can_close': true, 'pending_orders': 0},
          }),
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
          jsonEncode({
            'success': true,
            'message': 'Tutup kasir berhasil',
            'data': {
              'id': 10,
              'shift_number': 1,
              'closing_balance': 350000,
              'is_closed': true,
            },
          }),
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
  late ShiftRemoteDataSource dataSource;

  setUp(() {
    apiHelper = _FakeApiHelper();
    dataSource = ShiftRemoteDataSource(
      host: 'https://example.com',
      api: 'api',
      apiHelper: apiHelper,
    );
  });

  test('getCloseCashierStatus memanggil endpoint closable dan parse payload map',
      () async {
    apiHelper.nextGetResponse = http.Response(
      jsonEncode({
        'success': true,
        'message': 'Masih ada order pending',
        'data': {
          'can_close': false,
          'pending_orders': 2,
        },
      }),
      200,
    );

    final result = await dataSource.getCloseCashierStatus();

    expect(
      apiHelper.lastGetUrl,
      equals('https://example.com/api/shift/closable'),
    );
    expect(result.success, isTrue);
    expect(result.canClose, isFalse);
    expect(result.pendingOrders, equals(2));
    expect(result.message, equals('Masih ada order pending'));
  });

  test('getCloseCashierStatus tetap bisa parse payload boolean sederhana',
      () async {
    apiHelper.nextGetResponse = http.Response(
      jsonEncode({
        'success': true,
        'message': 'Kasir dapat ditutup',
        'data': true,
      }),
      200,
    );

    final result = await dataSource.getCloseCashierStatus();

    expect(result.canClose, isTrue);
    expect(result.pendingOrders, equals(0));
  });

  test('closeCashier mengirim cash_in_drawer ke endpoint close cashier',
      () async {
    apiHelper.nextPostResponse = http.Response(
      jsonEncode({
        'success': true,
        'message': 'Tutup kasir berhasil',
        'data': {
          'id': 11,
          'shift_number': 2,
          'closing_balance': 500000,
          'is_closed': true,
        },
      }),
      200,
    );

    final result = await dataSource.closeCashier(
      const CloseCashierRequestModel(cashInDrawer: 500000),
    );

    expect(
      apiHelper.lastPostUrl,
      equals('https://example.com/api/close_cashier/close'),
    );
    expect(
      apiHelper.lastPostBody,
      equals({'cash_in_drawer': 500000}),
    );
    expect(result.success, isTrue);
    expect(result.message, equals('Tutup kasir berhasil'));
    expect(result.shift?.closingBalance, equals(500000));
    expect(result.shift?.isClosed, isTrue);
  });
}
