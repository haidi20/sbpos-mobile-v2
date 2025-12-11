import 'package:core/core.dart';
import '../entities/outlet.entity.dart';

abstract class OutletRepository {
  Future<Either<Failure, List<OutletEntity>>> getDataOutlets();
}
