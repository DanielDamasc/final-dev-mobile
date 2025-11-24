import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {

  // Variáveis Básicas
  final storage = FlutterSecureStorage();
  final String? BASE_URL = dotenv.env["BASE_URL"];
  final String TOKEN_KEY = 'auth_token';

  // Retorna o token do usuário autenticado.
  Future<String?> getToken() async {
    try {
      String? token = await storage.read(key: TOKEN_KEY);
      
      if (token == null) {
        return null;
      }
      return token;

    } catch (e) {

      print('Erro ao recuperar token: $e');
      return null;
    }
  }

  // Deleta o token do usuário autenticado.
  Future<void> deleteToken() async {
    await storage.delete(key: TOKEN_KEY);
  }

  // Retorna os headers padrão para requisições protegidas.
  Future<Map<String, dynamic>> getAuthHeaders() async {
    final token = await getToken();
    if (token == null) {
      throw Exception("Token de autenticação não encontrado.");
    }
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }
}