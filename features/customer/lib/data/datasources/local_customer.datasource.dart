import 'package:customer/data/models/customer.model.dart';

class LocalCustomerDataSource {
  Future<List<CustomerModel>> fetchCustomers() async {
    return const [];
  }

  Future<void> insertCustomer(CustomerModel customer) async {}
}
