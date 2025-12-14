import 'package:core/core.dart';
import 'package:transaction/domain/usecases/get_transactions.usecase.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';

class GetTransactionsOffline extends GetTransactionsUsecase {
  GetTransactionsOffline(TransactionRepository repository) : super(repository);
}
