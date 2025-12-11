import 'package:core/core.dart';
import '../entities/outlet_entity.dart';

abstract class OutletRepository {
  Future<Either<Failure, List<OutletEntity>>> getDataOutlets();
}
