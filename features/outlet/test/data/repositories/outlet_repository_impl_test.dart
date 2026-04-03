import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:outlet/data/datasources/outlet_local.data_source.dart';
import 'package:outlet/data/datasources/outlet_remote.data_source.dart';
import 'package:outlet/data/models/outlet.model.dart';
import 'package:outlet/data/repositories/outlet.repository_impl.dart';
import 'package:outlet/data/responses/outlet.response.dart';
import 'package:outlet/domain/entities/outlet.entity.dart';

class MockRemoteDataSource extends Mock implements OutletRemoteDataSource {}
class MockLocalDataSource extends Mock implements OutletLocalDataSource {}
class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late OutletRepositoryImpl repository;
  late MockRemoteDataSource mockRemote;
  late MockLocalDataSource mockLocal;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemote = MockRemoteDataSource();
    mockLocal = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = OutletRepositoryImpl(
      remote: mockRemote,
      local: mockLocal,
      networkInfo: mockNetworkInfo,
    );
  });

  final tOutletModel = OutletModel(
    id: 1,
    idServer: 9,
    name: 'Test Outlet',
  );
  
  final tOutletEntity = tOutletModel.toEntity();
  final List<OutletModel> tOutletList = [tOutletModel];
  final List<OutletEntity> tEntityList = [tOutletEntity];

  group('getDataOutlets', () {
    test('should check if device is online', () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemote.fetchOutlets()).thenAnswer((_) async => OutletResponse(success: true, message: 'Success', data: tOutletList));
      when(() => mockLocal.insertSyncOutlets(outlets: any(named: 'outlets'))).thenAnswer((_) async => tOutletList);
      
      // act
      await repository.getDataOutlets();
      
      // assert
      verify(() => mockNetworkInfo.isConnected);
    });

    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should return remote data when call to remote is successful and save to local', () async {
        // arrange
        when(() => mockRemote.fetchOutlets()).thenAnswer((_) async => OutletResponse(success: true, message: 'Success', data: tOutletList));
        when(() => mockLocal.insertSyncOutlets(outlets: any(named: 'outlets'))).thenAnswer((_) async => tOutletList);
        
        // act
        final result = await repository.getDataOutlets();
        
        // assert
        verify(() => mockRemote.fetchOutlets());
        verify(() => mockLocal.insertSyncOutlets(outlets: tOutletList));
        expect(result.isRight(), true);
        result.fold((l) => fail('Should be right'), (r) => expect(r, tEntityList));
      });

      test('should fallback to local when call to remote is unsuccessful', () async {
        // arrange
        when(() => mockRemote.fetchOutlets()).thenAnswer((_) async => OutletResponse(success: false, message: 'Failed'));
        when(() => mockLocal.getOutlets()).thenAnswer((_) async => tOutletList);
        
        // act
        final result = await repository.getDataOutlets();
        
        // assert
        verify(() => mockRemote.fetchOutlets());
        verify(() => mockLocal.getOutlets());
        expect(result.isRight(), true);
        result.fold((l) => fail('Should be right'), (r) => expect(r, tEntityList));
      });
    });

    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test('should return local data when local data is present', () async {
        // arrange
        when(() => mockLocal.getOutlets()).thenAnswer((_) async => tOutletList);
        
        // act
        final result = await repository.getDataOutlets();
        
        // assert
        verifyZeroInteractions(mockRemote);
        verify(() => mockLocal.getOutlets());
        expect(result.isRight(), true);
        result.fold((l) => fail('Should be right'), (r) => expect(r, tEntityList));
      });

      test('should return NetworkFailure when local data is absent', () async {
        // arrange
        when(() => mockLocal.getOutlets()).thenAnswer((_) async => []);
        
        // act
        final result = await repository.getDataOutlets();
        
        // assert
        expect(result, equals(Left<Failure, List<OutletEntity>>(const NetworkFailure())));
      });
    });
  });
}
