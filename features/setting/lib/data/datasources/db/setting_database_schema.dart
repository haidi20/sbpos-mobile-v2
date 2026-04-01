import 'package:core/data/datasources/core_database_schema_registry.dart';
import 'package:setting/data/datasources/db/setting.table.dart';

void configureSettingDatabaseSchema() {
  CoreDatabaseSchemaRegistry.instance.registerTable(
    const CoreDatabaseSchemaTable(
      name: SettingTable.tableName,
      createTableQuery: SettingTable.createTableQuery,
    ),
  );
}
