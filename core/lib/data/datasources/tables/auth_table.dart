// lib/data/drift/entities/user_auth.dart
import 'package:drift/drift.dart';

class UserAuths extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text().nullable()();
  TextColumn get password => text()();
  TextColumn get token => text().nullable()();
  TextColumn get email => text().unique()();
}
