import 'package:core/core.dart';
import 'package:product/data/datasources/packet_local.datasource.dart';
import 'package:product/data/datasources/product_local.datasource.dart';
import 'package:product/data/datasources/product_remote.datasource.dart';
import 'package:product/data/repositories/packet.repository.impl.dart';
import 'package:product/data/repositories/product.repository.impl.dart';
import 'package:product/presentation/providers/product_repository.provider.dart';
import 'package:setting/data/datasources/setting_local.data_source.dart';
import 'package:setting/data/services/bluetooth_printer.facade.dart';
import 'package:setting/presentation/providers/setting.provider.dart';
import 'package:transaction/data/datasources/transaction_local.data_source.dart';
import 'package:transaction/data/datasources/transaction_remote.data_source.dart';
import 'package:transaction/data/datasources/cashier_remote.data_source.dart';
import 'package:transaction/data/repositories/cashier_remote.repository_impl.dart';
import 'package:transaction/data/datasources/shift_remote.data_source.dart';
import 'package:transaction/data/repositories/shift.repository_impl.dart';
import 'package:transaction/data/repositories/transaction.repository_impl.dart';
import 'package:transaction/presentation/providers/open_cashier.provider.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/providers/transaction_repository.provider.dart';

import 'package:expense/data/repositories/expense.repository.impl.dart';
import 'package:expense/data/datasources/expense_local.datasource.dart';
import 'package:expense/data/datasources/expense_remote.datasource.dart';
import 'package:expense/presentation/providers/expense.providers.dart';


Future<List<Override>> buildAppRepositoryOverrides({
  SettingLocalDataSource? settingLocalDataSource,
  BluetoothPrinterClient? bluetoothPrinterClient,
  PrinterFacade? printerFacade,
}) async {
  final localSettingDataSource =
      settingLocalDataSource ?? SettingLocalDataSource();
  final resolvedPrinterFacade = printerFacade ??
      BluetoothPrinterFacade(
        localDataSource: localSettingDataSource,
        client: bluetoothPrinterClient,
      );

  if (resolvedPrinterFacade is BluetoothPrinterFacade) {
    await resolvedPrinterFacade.bootstrap();
  }

  return [
    settingLocalDataSourceProvider.overrideWithValue(localSettingDataSource),
    printerFacadeProvider.overrideWithValue(
      resolvedPrinterFacade,
    ),
    productRepositoryProvider.overrideWith(
      (ref) => ProductRepositoryImpl(
        remote: ProductRemoteDataSource(),
        local: ProductLocalDataSource(),
        networkInfo: NetworkInfoImpl(Connectivity()),
      ),
    ),
    packetRepositoryProvider.overrideWith(
      (ref) => PacketRepositoryImpl(
        local: PacketLocalDataSource(),
      ),
    ),
    transactionRepositoryProvider.overrideWith(
      (ref) => TransactionRepositoryImpl(
        remote: TransactionRemoteDataSource(),
        local: TransactionLocalDataSource(),
      ),
    ),
    cashierRemoteRepositoryProvider.overrideWith(
      (ref) => CashierRemoteRepositoryImpl(
        remote: CashierRemoteDataSource(),
      ),
    ),
    shiftRepositoryProvider.overrideWith(
      (ref) => ShiftRepositoryImpl(
        remote: ShiftRemoteDataSource(),
      ),
    ),
    expenseRepositoryProvider.overrideWith(
      (ref) => ExpenseRepositoryImpl(
        remote: ExpenseRemoteDataSource(),
        local: ExpenseLocalDataSource(),
      ),
    ),
  ];
}

