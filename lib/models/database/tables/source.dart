part of '../database.dart';

class SourceTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();
  TextColumn get description => text()();
  TextColumn get author => text()();
  TextColumn get homepage => text()();
  TextColumn get version => text()();

  TextColumn get rawScript => text()();

  BoolColumn get enable => boolean()();
}
