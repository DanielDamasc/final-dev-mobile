import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Banco {
  static final Banco instance = Banco._();
  static Database? _database;

  Banco._();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();

    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), 'final-dev-mobile');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.transaction((txn) async {
      // Cria a tabela de user.
      await txn.execute('''
          CREATE TABLE user (
            email VARCHAR PRIMARY KEY,
            name VARCHAR,
            password VARCHAR
          )
        ''');

      // Insere o registro inicial.
      int id1 = await txn.rawInsert('''
        INSERT INTO user (email, name, password) 
        VALUES ("asd@mail.com", "Administrador", "asdasdasd")
      ''');

      print('$id1');
    });
  }
}
