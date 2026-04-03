import 'package:core/data/datasources/operational_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('OperationalRemoteDataSource', () {
    test('checkServiceStatus parses boolean data payload', () async {
      final dataSource = OperationalRemoteDataSource(
        host: 'https://example.com',
        api: 'api',
        getRequest: ({required url, params}) async {
          expect(url, 'https://example.com/api/service/check');
          return http.Response(
            '{"success":true,"message":"Layanan aktif","data":true}',
            200,
          );
        },
      );

      final result = await dataSource.checkServiceStatus();

      expect(result.success, isTrue);
      expect(result.isAllowed, isTrue);
      expect(result.message, 'Layanan aktif');
    });

    test('checkSubscriptionStatus parses map payload', () async {
      final dataSource = OperationalRemoteDataSource(
        host: 'https://example.com',
        api: 'api',
        getRequest: ({required url, params}) async {
          expect(url, 'https://example.com/api/subscription/status');
          return http.Response(
            '{"success":true,"message":"Langganan berakhir","data":{"active":false}}',
            200,
          );
        },
      );

      final result = await dataSource.checkSubscriptionStatus();

      expect(result.success, isTrue);
      expect(result.isAllowed, isFalse);
      expect(result.message, 'Langganan berakhir');
    });
  });
}
