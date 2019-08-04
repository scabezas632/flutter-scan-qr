import 'dart:io';
import 'dart:async';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:qr_reader_app/src/models/scan_model.dart';
export 'package:qr_reader_app/src/models/scan_model.dart';

class DBProvider {

  static Database _database;
  static final DBProvider db = DBProvider._();

  // Constructor privado
  DBProvider._();

  Future<Database> get database async {

    if (_database != null) return _database;

    _database = await initDB();

    return _database;
  }

  initDB() async {
    // Obtener el directorio en donde se guarda la base de datos (para android e ios)
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    // Al path de la base de datos se añade el string 'ScansDB.db'
    String path = join( documentsDirectory.path, 'ScansDB.db' );

    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute(
          'CREATE TABLE Scans ('
          ' id INTEGER PRIMARY KEY,'
          ' tipo TEXT,'
          ' valor TEXT'
          ')'
        );
      }
    );
  }

  // CREAR registros
  nuevoScanRaw(ScanModel nuevoScan) async {
    final db = await database;

    final resp = await db.rawInsert(
      "INSERT INTO Scans (id, tipo, valor) "
      "VALUES (${nuevoScan.id}, '${nuevoScan.tipo}', '${nuevoScan.valor}')"
    );

    return resp;
  }

  nuevoScan(ScanModel nuevoScan) async {
    final db = await database;

    final resp = db.insert('Scans', nuevoScan.toJson());
    
    return resp;
  }

  // SELECT - Obtener información
  Future<ScanModel> getScanId(int id) async {

    final db = await database;
  
    final resp = await db.query('Scans', where: 'id = ?', whereArgs: [id]);

    return resp.isNotEmpty ? ScanModel.fromJson(resp.first) : null;
  }

  Future<List<ScanModel>> getTodosScans() async {
    final db = await database;

    final resp = await db.query('Scans');

    List<ScanModel> lista = resp.isNotEmpty
                              ? resp.map((scan) => ScanModel.fromJson(scan)).toList()
                              : [];

    return lista;
  }

  Future<List<ScanModel>> getScansPorTipo( String tipo ) async {
    final db = await database;

    final resp = await db.rawQuery("SELECT * FROM Scans WHERE tipo='$tipo'");

    List<ScanModel> lista = resp.isNotEmpty
                              ? resp.map((scan) => ScanModel.fromJson(scan)).toList()
                              : [];

    return lista;
  }

  // Actualizar registros
  Future<int> updateScan(ScanModel nuevoScan) async {
    final db = await database;

    final resp = await db.update('Scans', nuevoScan.toJson(), where: 'id = ?', whereArgs: [nuevoScan.id]);

    return resp;
  }

  // Eliminar registros
  Future<int> deleteScan(int id) async {
    final db = await database;

    final resp = await db.delete('Scans', where: 'id = ?', whereArgs: [id]);

    return resp;
  }

  // Eliminar registros
  Future<int> deleteAll() async {
    final db = await database;

    final resp = await db.delete('Scans');

    return resp;
  }

}