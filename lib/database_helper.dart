import 'package:flutter/foundation.dart';
import 'todo_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance=DatabaseHelper._internal();
  static Database? _database;
  factory DatabaseHelper() {
    return _instance;
  }
  DatabaseHelper._internal();
  Future<Database> get database async {
    if (_database != null) {
      debugPrint('Database getter: cached instance');
      return _database!;
    }
    _database = await _initDatabase();
    debugPrint('Database getter: initialized');
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path;
    if (kIsWeb) {
      path = 'todo_app_web.db';
    } else {
      try {
        // preferir getDatabasesPath() do sqflite (menos dependências/risco de bloqueio)
        final databasesPath = await getDatabasesPath();
        path = join(databasesPath, 'todo_app.db');
      } catch (e, st) {
        debugPrint('getDatabasesPath falhou: $e\n$st\nTentando fallback com path_provider...');
        final documentsDirectory = await getApplicationDocumentsDirectory();
        path = join(documentsDirectory.path, 'todo_app.db');
      }
    }
    debugPrint('Database path: $path');
    try {
      return await openDatabase(path, version: 1, onCreate: _onCreate);
    } catch (e, st) {
      debugPrint('Erro ao abrir banco: $e\n$st');
      rethrow;
    }
  }
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE table todos(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      description TEXT,
      isDone INTEGER
      )
    ''');
  }
  // CRUD

  Future<int> insertTodo(Todo todo) async {
    final db = await database;
    try {
      final map = Map<String, dynamic>.from(todo.toMap());
      // Garantir que isDone esteja como inteiro 0/1
      if (map['isDone'] is bool) {
        map['isDone'] = (map['isDone'] as bool) ? 1 : 0;
      } else if (map['isDone'] == null) {
        map['isDone'] = 0;
      }
      debugPrint('insertTodo payload: $map');
      final id = await db.insert('todos', map,
          conflictAlgorithm: ConflictAlgorithm.replace);
      debugPrint('insertTodo result id: $id');
      return id;
    } catch (e, st) {
      debugPrint('insertTodo erro: $e\n$st');
      rethrow;
    }
  }
  Future<List<Todo>> getTodos() async {
    final db = await database;
    final List<Map<String,dynamic>> maps = await db.query('todos');
    return List.generate(maps.length, (i) {
      return Todo.fromMap(maps[i]);
    });
  }
  Future<Todo?> getTodoById( int id ) async {
    final db = await database;
    final List<Map<String,dynamic>> maps = await db.query(
      'todos',
      where: 'id=?',
      whereArgs: [id]
    );
    if(maps.isNotEmpty) {
      return Todo.fromMap(maps.first);
    }
    return null;
  }
  Future<int> updateTodo(Todo todo) async {
    final db = await database;
    try {
      final map = Map<String, dynamic>.from(todo.toMap());
      if (map['isDone'] is bool) {
        map['isDone'] = (map['isDone'] as bool) ? 1 : 0;
      } else if (map['isDone'] == null) {
        map['isDone'] = 0;
      }
      debugPrint('updateTodo payload: $map');
      final res = await db.update('todos', map,where:'id=?',whereArgs: [todo.id]);
      debugPrint('updateTodo result: $res');
      return res;
    } catch (e, st) {
      debugPrint('updateTodo erro: $e\n$st');
      rethrow;
    }
  }
  Future<int> deleteTodo(int  id) async {
    final db = await database;
    return await db.delete('todos',where:'id=?',whereArgs: [id]);
  }
}