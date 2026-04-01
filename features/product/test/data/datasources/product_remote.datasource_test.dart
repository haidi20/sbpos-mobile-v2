import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:core/core.dart';
import 'package:product/data/datasources/product_remote.datasource.dart';

class MockApiHelper extends Mock implements ApiHelper {}

void main() {
  late MockApiHelper mockApiHelper;
  late ProductRemoteDataSource dataSource;

  setUp(() {
    mockApiHelper = MockApiHelper();
    dataSource = ProductRemoteDataSource(apiHelper: mockApiHelper);
  });

  group('ProductRemoteDataSource', () {
    test('fetchProducts harus mengembalikan ProductResponse jika sukses', () async {
      final jsonResponse = {
        'success': true,
        'message': 'Success',
        'data': [
          {'id': 1, 'name': 'Produk A'}
        ]
      };
      
      when(() => mockApiHelper.get(url: any(named: 'url'), params: any(named: 'params')))
          .thenAnswer((_) async => http.Response(jsonEncode(jsonResponse), 200));

      final result = await dataSource.fetchProducts();

      expect(result.success, true);
      expect(result.data?.length, 1);
      expect(result.data?.first.name, 'Produk A');
    });

    test('fetchProducts harus throw ServerException jika status code bukan 2xx', () async {
      final jsonResponse = {'success': false, 'message': 'Error Server'};
      
      when(() => mockApiHelper.get(url: any(named: 'url'), params: any(named: 'params')))
          .thenAnswer((_) async => http.Response(jsonEncode(jsonResponse), 500));

      expect(() => dataSource.fetchProducts(), throwsA(isA<ServerException>()));
    });
  });
}
