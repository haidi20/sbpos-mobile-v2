import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:transaction/data/datasources/shift_remote.data_source.dart';
import 'package:transaction/data/models/open_cashier_request.model.dart';
import 'package:transaction/data/models/shift.model.dart';

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
          jsonEncode({'success': true, 'message': 'ok', 'data': true}),
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
          jsonEncode({'success': true, 'message': 'ok', 'data': true}),
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

  test('getShiftStatus memanggil endpoint check dan parse payload map',
      () async {
    apiHelper.nextGetResponse = http.Response(
      jsonEncode({
        'success': true,
        'message': 'Shift belum dibuka',
        'data': {
          'is_open': false,
          'shift': {
            'id': 7,
            'shift_number': 1,
            'opening_balance': 0,
            'is_closed': false,
          },
        },
      }),
      200,
    );

    final result = await dataSource.getShiftStatus();

    expect(apiHelper.lastGetUrl, equals('https://example.com/api/shift/check'));
    expect(result.success, isTrue);
    expect(result.message, equals('Shift belum dibuka'));
    expect(result.isOpen, isFalse);
    expect(result.shift?.idServer, equals(7));
    expect(result.shift?.shiftNumber, equals(1));
  });

  test('getShiftStatus tetap bisa parse payload boolean sederhana', () async {
    apiHelper.nextGetResponse = http.Response(
      jsonEncode({
        'success': true,
        'message': 'Shift sudah dibuka',
        'data': true,
      }),
      200,
    );

    final result = await dataSource.getShiftStatus();

    expect(result.success, isTrue);
    expect(result.isOpen, isTrue);
    expect(result.shift, isNull);
  });

  test('openCashier mengirim initial_balance ke endpoint shift open', () async {
    apiHelper.nextPostResponse = http.Response(
      jsonEncode({
        'success': true,
        'message': 'Buka kasir berhasil',
        'data': {
          'id': 9,
          'shift_number': 2,
          'opening_balance': 250000,
          'is_closed': false,
        },
      }),
      200,
    );

    final result = await dataSource.openCashier(
      const OpenCashierRequestModel(initialBalance: 250000),
    );

    expect(apiHelper.lastPostUrl, equals('https://example.com/api/shift/open'));
    expect(
      apiHelper.lastPostBody,
      equals({'initial_balance': 250000}),
    );
    expect(result.success, isTrue);
    expect(result.message, equals('Buka kasir berhasil'));
    expect(result.shift?.openingBalance, equals(250000));
  });

  test('getLatestShift memanggil endpoint latest dan parse shift terakhir',
      () async {
    apiHelper.nextGetResponse = http.Response(
      jsonEncode({
        'success': true,
        'message': 'Shift terakhir ditemukan',
        'data': {
          'id': 17,
          'shift_number': 4,
          'opening_balance': 180000,
          'date': '2026-04-01T08:00:00.000',
        },
      }),
      200,
    );

    final result = await dataSource.getLatestShift();

    expect(apiHelper.lastGetUrl, equals('https://example.com/api/shift/latest'));
    expect(result, isA<ShiftModel>());
    expect(result?.idServer, equals(17));
    expect(result?.openingBalance, equals(180000));
  });
}
