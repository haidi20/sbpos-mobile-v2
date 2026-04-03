import 'package:core/core.dart';
import 'package:outlet/domain/entities/outlet.entity.dart';

abstract class OutletRepository {
  Future<Either<Failure, List<OutletEntity>>> getDataOutlets();
}
