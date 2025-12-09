import 'package:core/core.dart';
import 'package:customer/domain/entities/customer.entity.dart';

final customerListProvider = StateProvider<List<CustomerEntity>>((ref) => []);
