import 'package:core/core.dart';
import '../entities/outlet_entity.dart';
import '../repositories/outlet_repository.dart';

class GetOutlets {
  final OutletRepository repository;

  GetOutlets(this.repository);

  Future<Either<Failure, List<OutletEntity>>> call() async {
    return await repository.getDataOutlets();
  }
}
