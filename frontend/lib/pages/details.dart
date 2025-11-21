import 'package:dio/dio.dart';
import 'package:final_mobile/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Details extends StatefulWidget {
  final int gameId;
  const Details({super.key, required this.gameId});

  @override
  State<Details> createState() => DetailsState();
}

class DetailsState extends State<Details> {

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

  Future<Map<String, dynamic>?> _getGame() async {

    String? token = await storage.read(key: TOKEN_KEY);
    int gameId = widget.gameId;

    try {
      Response res = await dio.get(
        'http://localhost:8000/api/game/$gameId',
        options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
            validateStatus: (status) => status != null && status < 500,
          ),
      );

      if (res.statusCode == 200) {

        final Map<String, dynamic> fetchedGame = res.data;
          
        return fetchedGame;
      }

      else if (res.statusCode == 404) {
         throw Exception(res.data["message"] ?? "Jogo não encontrado");
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
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white)
        ),
        centerTitle: true,
        title: Text("Detalhes", style: TextStyle(color: Colors.white)),
      ),

      body: FutureBuilder<Map<String, dynamic>?> (
        future: _getGame(), 
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar detalhes do jogo: ${snapshot.error.toString()}',
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (snapshot.hasData) {
            final Map<String, dynamic> fetchedGame = snapshot.data!;
            final List<dynamic> genres = fetchedGame["genres"];

            return SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                color: const Color.fromARGB(255, 10, 10, 10),
                child: Column(
                  children: [
                    Image.network(
                      fetchedGame["background_image"],
                      height: 240,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return Container(
                          height: 360,
                          color: Colors.grey,
                          child: Center(
                            child: CircularProgressIndicator(color: Colors.deepPurple),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 24),

                    Container(
                      margin: EdgeInsets.all(20.0),
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
                                      fetchedGame["name"],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Lançamento: ${fetchedGame["released"]}',
                                      style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                                    ),
                                  ],
                                )
                              ),

                              SizedBox(
                                height: 40.0,
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: RatingBar.builder(
                                    initialRating: fetchedGame["favorite"] == null ? 0 : 1,
                                    minRating: 0,
                                    maxRating: 1,
                                    direction: Axis.horizontal,
                                    itemCount: 1,
                                    unratedColor: Colors.grey,
                                    itemBuilder: (context, _) {
                                      return Icon(Icons.star, color: Colors.purpleAccent);
                                    },
                                    onRatingUpdate: (favorite) {
                                      
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 20),

                          Text(
                            fetchedGame["description"],
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              height: 1.5
                            ),
                          ),

                          SizedBox(height: 20),

                          Text(
                            'Gêneros:',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8.0, 
                            runSpacing: 4.0, 
                            children: genres.map((genre) {
                              return Chip(
                                backgroundColor: Colors.deepPurpleAccent,
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
                    )
                    
                  ],
                ),
              ),
            );
          }

          return Center(child: Text("Inicializando...", style: TextStyle(color: Colors.white)));
        }
      ),
    );
  }
}
