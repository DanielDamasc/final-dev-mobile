import 'package:dio/dio.dart';
import 'package:final_mobile/components/card_game.dart';
import 'package:final_mobile/pages/game_register.dart';
import 'package:final_mobile/pages/login.dart';
import 'package:final_mobile/pages/profile.dart';
import 'package:final_mobile/pages/ranking.dart';
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

      throw Exception("Erro: Código ${res.statusCode}");

    } on DioException catch (e) {
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
        // Necessário para remover as rotas da pilha de navegação antes de ir para Login.
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Login()),
            (Route<dynamic> route) => false,
        );
      }
    }
  }

  Future<void> _logout() async {

    String? token = await storage.read(key: TOKEN_KEY);

    try {
      Response res = await dio.post(
        'http://localhost:8000/api/logout',
        options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
            validateStatus: (status) => status != null && status < 500,
          ),
      );

      if (res.statusCode == 200) {
        // Deleta o token e redireciona para o login.
        await storage.delete(key: TOKEN_KEY);

        _checkAuth();
      }

    } on DioException catch (e) {
      throw Exception("Erro de conexão");
    }
  }

  Key _futureBuilderKey = UniqueKey();

  void _reloadGames() {
    setState(() {
      // Altera a key do FutureBuilder, que força o builder a ser executado novamente.
      _futureBuilderKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Home", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          onPressed: () {
            _logout();
          },
          icon: Icon(Icons.logout, color: Colors.white)
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => Profile())
              );
            }, 
            icon: Icon(Icons.person, color: Colors.white)
          )
        ],
      ),

      body: FutureBuilder<List<Map<String, dynamic>>?> (
        key: _futureBuilderKey,
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
                        Cardgame(
                          game: game,
                          reloadGames: _reloadGames,  
                        ),
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

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'btn-ranking',
            onPressed: () async {
              await Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => Ranking()),
              );
          
              _reloadGames();
            },
            backgroundColor: Colors.blueGrey,
            child: Icon(Icons.leaderboard, color: Colors.white),
          ),

          SizedBox(height: 8.0),

          FloatingActionButton(
            heroTag: 'btn-register',
            onPressed: () async {
              await Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => GameRegister()),
              );
          
              _reloadGames();
            },
            backgroundColor: Colors.green,
            child: Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
