import 'package:dio/dio.dart';
import 'package:final_mobile/pages/details.dart';
import 'package:final_mobile/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Cardgame extends StatefulWidget {
  final Map<String, dynamic> game;
  final VoidCallback reloadGames;

  const Cardgame({super.key, required this.game, required this.reloadGames});

  @override
  State<Cardgame> createState() => _CardgameState();
}

class _CardgameState extends State<Cardgame> {

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
  
  Future<void> _deleteGame() async {
    final int gameId = widget.game['id'];

    String? token = await storage.read(key: TOKEN_KEY);

    try {
      Response res = await dio.delete(
        'http://localhost:8000/api/game/delete/$gameId',
        options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
            validateStatus: (status) => status != null && status < 500,
          ),
      );

      if (res.statusCode == 204) {
        _showSnackbar("Jogo deletado com sucesso", Colors.green);

        widget.reloadGames();
      }

      else if (res.statusCode == 404) {
        _showSnackbar(res.data["message"], Colors.red);
      }

    } on DioException catch (e) {
      _showSnackbar("Erro de conexão", Colors.red);
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

  @override
  Widget build(BuildContext context) {
    // As propriedades devem ser acessadas através de widget.
    final Map<String, dynamic> game = widget.game;

    final String name = game['name'] ?? 'Nome Desconhecido';
    final String imageUrl = game['background_image'] ?? '';
    final String released = game['released'] ?? 'N/A';
    final List<String> genres = List<String>.from(game['genres'] ?? []);

    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 30, 30, 30),
        borderRadius: BorderRadius.circular(10),
      ),
      
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.network(
              imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return Container(
                  height: 180,
                  color: Colors.grey,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.deepPurple),
                  ),
                );
              },
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lançamento: $released',
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
    
                    SizedBox(
                      height: 40.0,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ElevatedButton(
                          onPressed: () async {
                            await Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (context) => Details(gameId: widget.game['id'])
                              )
                            );

                            widget.reloadGames();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent,
                            minimumSize: Size.zero,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(8.0))
                          ),
                          child: Icon(Icons.info, color: Colors.white, size: 24)
                        ),
                      ),
                    ),
    
                    SizedBox(width: 8),
    
                    SizedBox(
                      height: 40.0,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ElevatedButton(
                          onPressed: _deleteGame,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            minimumSize: Size.zero,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(8.0))
                          ),
                          child: Icon(Icons.delete, color: Colors.white, size: 24)
                        ),
                      ),
                    ),
                  ],
                ),
    
                const SizedBox(height: 12),
                
                Text(
                  'Gêneros:',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8.0, 
                  runSpacing: 4.0, 
                  children: genres.map((genre) {
                    return Chip(
                      backgroundColor: Colors.deepPurple,
                      label: Text(
                        genre,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}