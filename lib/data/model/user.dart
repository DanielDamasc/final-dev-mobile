import 'package:final_mobile/data/banco.dart';

class User {
  final String email;
  final String name;
  final String password;

  User({required this.email, required this.name, required this.password});

  factory User.fromMap(Map<String, dynamic> map) {
    return User(email: map['email'], name: map['name'], password: map['password']);
  }

  static Future<User?> login(String email, String password) async {
    try {
      final db = await Banco.instance.database;

      final String sql = '''
        SELECT * FROM user
        WHERE email = ? AND password = ?
        LIMIT 1
      ''';

      final List<Map<String, dynamic>> result = await db.rawQuery(
        sql, [
        email,
        password,
      ]);

      if (result.isNotEmpty) {
        return User.fromMap(result.first);
      } else {
        return null;
      }

    } catch (e) {
      print('Erro ao tentar fazer login: $e');
      return null;
    }
  }
}
