import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static String currentUserId = '';
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('MyUTHM.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    final exists = await databaseExists(path);

    if (!exists) {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      ByteData data = await rootBundle.load(join('assets', filePath));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(path).writeAsBytes(bytes, flush: true);
    }

    return await openDatabase(path);
  }

  Future<Map<String, dynamic>?> loginWithExistingAccount(String userId, String password) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> results = await db.query(
      'Users',
      where: 'User_ID = ? AND Password_Hash = ?',
      whereArgs: [userId, password],
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getStudentProfile(String userId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT 
        u.User_ID, 
        u.Name, 
        u.Email, 
        u.Phone, 
        u.Role, 
        COALESCE(s.Obtained_Credits, 70) AS Obtained_Credits, 
        COALESCE(s.CGPA, 3.85) AS CGPA, 
        COALESCE(s.CCPA, 3.90) AS CCPA,
        p.Programme_Name, 
        p.Faculty_ID
      FROM Users u
      LEFT JOIN Students s ON u.User_ID = s.Student_ID
      LEFT JOIN Programmes p ON s.Programme_ID = p.Programme_ID
      WHERE u.User_ID = ?
    ''', [userId]);

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

}