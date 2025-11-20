import 'package:dio/dio.dart';
import 'package:final_mobile/components/card_game.dart';
import 'package:final_mobile/pages/game_register.dart';
import 'package:final_mobile/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final dio = Dio();
  final storage = FlutterSecureStorage();
  final String TOKEN_KEY = 'auth_token';

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

  void _showSnackbar(String message, Color color) {
    if (message.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<List<Map<String, dynamic>>?> _getGames() async {

    String? token = await storage.read(key: TOKEN_KEY);

    try {
      Response res = await dio.get(
        'http://localhost:8000/api/games',
        options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
            validateStatus: (status) => status != null && status < 500,
          ),
      );

      if (res.statusCode == 200) {

        final List<Map<String, dynamic>> fetchedGames = (res.data as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
          
        return fetchedGames;
      }

      _showSnackbar("Erro: Código ${res.statusCode}", Colors.red);
      throw Exception("Erro: Código ${res.statusCode}");

    } on DioException catch (e) {
      _showSnackbar("Erro de conexão", Colors.red);
      throw Exception("Erro de conexão");
    }
  }

  @override
  void initState() {
    super.initState();

    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(Duration.zero); 
  
    final token = await getToken();
    if (token == null) {
      if (mounted) {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => Login()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Home", style: TextStyle(color: Colors.white)),

      ),

      body: FutureBuilder<List<Map<String, dynamic>>?> (
        future: _getGames(), 
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar jogos: ${snapshot.error.toString()}',
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (snapshot.hasData) {
            final List<Map<String, dynamic>> fetchedGames = snapshot.data!;

            if (fetchedGames.isEmpty) {
              return Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                color: const Color.fromARGB(255, 10, 10, 10),
                child: Center(
                  child: Text(
                    "Nenhum jogo encontrado.",
                    style: TextStyle(color: Colors.grey, fontSize: 16)),
                ),
              );
            }

            return SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                color: const Color.fromARGB(255, 10, 10, 10),
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    ...fetchedGames.map((game) => Column(
                      children: [
                        Cardgame(game: game),
                        SizedBox(height: 24),
                      ],
                    )).toList(),
                  ],
                ),
              ),
            );
          }

          return Center(child: Text("Inicializando...", style: TextStyle(color: Colors.white)));
        }
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => GameRegister()),
          );
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
