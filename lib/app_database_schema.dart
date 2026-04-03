import 'package:core/data/datasources/core_database_schema_registry.dart';
import 'package:customer/data/datasources/db/customer.table.dart';
import 'package:outlet/data/datasources/db/outlet.table.dart';
import 'package:product/data/datasources/db/packet.table.dart';
import 'package:product/data/datasources/db/packet_item.table.dart';
import 'package:product/data/datasources/db/product.table.dart';
import 'package:setting/data/datasources/db/setting.table.dart';
import 'package:transaction/data/datasources/db/transaction.table.dart';
import 'package:transaction/data/datasources/db/transaction_detail.table.dart';
import 'package:expense/data/datasources/db/expense.table.dart';


void configureAppDatabaseSchema() {
  CoreDatabaseSchemaRegistry.instance.registerTables([
    const CoreDatabaseSchemaTable(
      name: OutletTable.tableName,
      createTableQuery: OutletTable.createTableQuery,
    ),
    const CoreDatabaseSchemaTable(
      name: PacketTable.tableName,
      createTableQuery: PacketTable.createTableQuery,
    ),
    const CoreDatabaseSchemaTable(
      name: ProductTable.tableName,
      createTableQuery: ProductTable.createTableQuery,
      createIndexQueries: [ProductTable.createIndexName],
    ),
    const CoreDatabaseSchemaTable(
      name: PacketItemTable.tableName,
      createTableQuery: PacketItemTable.createTableQuery,
    ),
    const CoreDatabaseSchemaTable(
      name: CustomerTable.tableName,
      createTableQuery: CustomerTable.createTableQuery,
      createIndexQueries: [CustomerTable.createIndexName],
    ),
    const CoreDatabaseSchemaTable(
      name: SettingTable.tableName,
      createTableQuery: SettingTable.createTableQuery,
    ),
    const CoreDatabaseSchemaTable(
      name: TransactionTable.tableName,
      createTableQuery: TransactionTable.createTableQuery,
      createIndexQueries: [
        TransactionTable.createIndexSequenceNumber,
        TransactionTable.createIndexNumberTable,
        TransactionTable.createIndexDate,
      ],
    ),
    const CoreDatabaseSchemaTable(
      name: TransactionDetailTable.tableName,
      createTableQuery: TransactionDetailTable.createTableQuery,
      createIndexQueries: [
        TransactionDetailTable.createUniqueIndexProduct,
        TransactionDetailTable.createUniqueIndexPacket,
        TransactionDetailTable.createIndexProductId,
        TransactionDetailTable.createIndexProductName,
      ],
    ),
    const CoreDatabaseSchemaTable(
      name: ExpenseTable.tableName,
      createTableQuery: ExpenseTable.createTableQuery,
      createIndexQueries: [ExpenseTable.createIndexDate],
    ),
  ]);
}

