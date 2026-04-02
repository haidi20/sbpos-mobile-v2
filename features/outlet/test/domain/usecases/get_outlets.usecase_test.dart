import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:outlet/domain/entities/outlet.entity.dart';
import 'package:outlet/domain/repositories/outlet.repository.dart';
import 'package:outlet/domain/usecases/get_outlets.usecase.dart';

class FakeOutletRepository implements OutletRepository {
  FakeOutletRepository({this.onGetDataOutlets});

  final Future<Either<Failure, List<OutletEntity>>> Function()?
      onGetDataOutlets;

  static const sampleOutlet = OutletEntity(
    id: 1,
    idServer: 9,
    name: 'Outlet Pettarani',
    address: 'Jl. Pettarani',
    isActive: true,
  );

  @override
  Future<Either<Failure, List<OutletEntity>>> getDataOutlets() {
    final handler = onGetDataOutlets;
    if (handler == null) {
      return Future.value(const Right([sampleOutlet]));
    }
    return handler();
  }
}

Future<void> expectLeftFailure<T>(
  Future<Either<Failure, T>> Function() action,
  Matcher matcher,
) async {
  final result = await action();
  result.fold(
    (failure) => expect(failure, matcher),
    (_) => fail('Expected Left result'),
  );
}

void main() {
  group('GetOutlets', () {
    test('returns repository outlets on success', () async {
      final repository = FakeOutletRepository();

      final result = await GetOutlets(repository)();

      result.fold(
        (_) => fail('Expected Right result'),
        (outlets) => expect(outlets, const [FakeOutletRepository.sampleOutlet]),
      );
    });

    test('maps thrown Failure into Left', () async {
      const failure = ServerFailure();
      final repository = FakeOutletRepository(
        onGetDataOutlets: () => Future.error(failure),
      );

      await expectLeftFailure(
        () => GetOutlets(repository)(),
        same(failure),
      );
    });

    test('maps unexpected exception into UnknownFailure', () async {
      final repository = FakeOutletRepository(
        onGetDataOutlets: () => Future.error(Exception('boom')),
      );

      await expectLeftFailure(
        () => GetOutlets(repository)(),
        isA<UnknownFailure>(),
      );
    });
  });
}
