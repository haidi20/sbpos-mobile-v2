import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:outlet/domain/entities/outlet.entity.dart';
import 'package:outlet/domain/usecases/get_outlets.usecase.dart';
import 'package:outlet/presentation/view_models/outlet.vm.dart';

class MockGetOutlets extends Mock implements GetOutlets {}

void main() {
  late OutletViewModel viewModel;
  late MockGetOutlets mockGetOutlets;

  setUp(() {
    mockGetOutlets = MockGetOutlets();
    // Use a flag to prevent auto-fetch during initialization if needed, 
    // but the current VM does Future.microtask(fetchOutlets).
  });

  final tOutletEntity = OutletEntity(
    id: 1,
    idServer: 9,
    name: 'Test Outlet',
  );
  final List<OutletEntity> tOutletList = [tOutletEntity];

  group('OutletViewModel', () {
    test('initial state should be empty with initial status', () {
      // Since the VM auto-fetches, we might need to handle the initial state carefully
      // or change the VM to not auto-fetch in tests if we want to test 'initial'.
      // For now, let's just test the result.
      when(() => mockGetOutlets.call()).thenAnswer((_) async => Right(tOutletList));
      
      viewModel = OutletViewModel(mockGetOutlets);
      
      expect(viewModel.state.outlets, []);
      expect(viewModel.state.status, OutletStatus.initial);
    });

    test('should emit loading then success when fetching data is successful', () async {
      // arrange
      when(() => mockGetOutlets.call()).thenAnswer((_) async => Right(tOutletList));
      
      // act
      viewModel = OutletViewModel(mockGetOutlets);
      
      // We need to wait for the microtask
      await Future.delayed(Duration.zero);

      // assert
      expect(viewModel.state.outlets, tOutletList);
      expect(viewModel.state.status, OutletStatus.success);
      verify(() => mockGetOutlets.call()).called(1);
    });

    test('should emit loading then error when fetching data fails', () async {
      // arrange
      when(() => mockGetOutlets.call()).thenAnswer((_) async => const Left(ServerFailure()));
      
      // act
      viewModel = OutletViewModel(mockGetOutlets);
      
      // wait for microtask
      await Future.delayed(Duration.zero);

      // assert
      expect(viewModel.state.status, OutletStatus.error);
      expect(viewModel.state.errorMessage, isA<String>());
      verify(() => mockGetOutlets.call()).called(1);
    });
  });
}
