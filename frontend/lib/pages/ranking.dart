import 'package:dio/dio.dart';
import 'package:final_mobile/API/ApiService.dart';
import 'package:final_mobile/pages/login.dart';
import 'package:flutter/material.dart';

class Ranking extends StatefulWidget {
  const Ranking({super.key});

  @override
  State<Ranking> createState() => _RankingState();
}

class _RankingState extends State<Ranking> {

  final dio = Dio();
  final ApiService _apiService = ApiService();

  Future<String?> getToken() async {
    return _apiService.getToken();
  }

  Future<List<Map<String, dynamic>>?> _buildRanking() async {

    final headers = await _apiService.getAuthHeaders();

    try {
      Response res = await dio.get(
        '${_apiService.BASE_URL}/ranking',
        options: Options(
            headers: headers,
            validateStatus: (status) => status != null && status < 500,
          ),
      );

      if (res.statusCode == 200) {

        final List<Map<String, dynamic>> rank = (res.data as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();

        return rank;
      }

      else if (res.statusCode == 404) {
        final List<Map<String, dynamic>> rank = [];

        return rank;
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Ranking", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      body: FutureBuilder<List<Map<String, dynamic>>?> (
        future: _buildRanking(), 
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar o ranking: ${snapshot.error.toString()}',
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (snapshot.hasData) {
            final List<Map<String, dynamic>> fetchedRanking = snapshot.data!;

            if (fetchedRanking.isEmpty) {
              return Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                color: const Color.fromARGB(255, 10, 10, 10),
                child: Center(
                  child: Text(
                    "Nenhum jogo encontrado para o ranking.",
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    Text(
                      "Seus Jogos Favoritos",
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    SizedBox(height: 20),

                    ListView.separated(
                      itemCount: fetchedRanking.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      
                      itemBuilder: (BuildContext context, int index) {
                        final game = fetchedRanking[index];
                        final int position = game["position"];
                        final String name = game["name"];
                        final double rating = game["rating"];
                    
                        return ListTile(
                          minTileHeight: 80,
                          leading: Container(
                            width: 40,
                            child: Center(
                                child: Text(
                                    '#${position.toString()}', 
                                    style: TextStyle(color: Colors.grey, fontSize: 20)),
                            ),
                          ),
                          
                          title: Text(
                              name,
                              style: TextStyle(color: Colors.white, fontSize: 18)),
                          
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,

                            children: [
                              Text(
                                  rating.toStringAsFixed(1),
                                  style: TextStyle(color: Colors.white, fontSize: 18)),

                              SizedBox(width: 4),

                              Icon(Icons.star, color: Colors.purpleAccent, size: 20)
                            ],
                          ),
                        );
                      },

                      separatorBuilder: (BuildContext context, int index) {
                        return Divider(
                          color: Colors.deepPurple,
                          thickness: 1,
                          height: 1,
                        );
                      },
                    ),

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
