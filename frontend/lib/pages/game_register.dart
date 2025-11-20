import 'package:dio/dio.dart';
import 'package:final_mobile/pages/home.dart';
import 'package:final_mobile/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GameRegister extends StatefulWidget {
  const GameRegister({super.key});

  @override
  State<GameRegister> createState() => _GameRegisterState();
}

class _GameRegisterState extends State<GameRegister> {

  final dio = Dio();
  final String apiKey = 'f6c09fc6667947218a853f3cfa386bcf';
  bool isLoading = false;

  // Recuperar o token.
  final storage = FlutterSecureStorage();
  final String TOKEN_KEY = 'auth_token';

  final TextEditingController idCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController descriptionCtrl = TextEditingController();
  String background_image = '';
  final TextEditingController releasedCtrl = TextEditingController();
  List<dynamic> genres = [];
  List<String> genreNames = [];
  List<dynamic> results = [];
  Map<String, dynamic> details = {};

  Future<void> _searchData(String query) async {
    if (query.isEmpty) { 
      setState(() {
        results = [];
      });
      return ;
    }

    setState(() {
      isLoading = true;
    });

    Response res;

    try {
      res = await dio.get(
        'https://api.rawg.io/api/games',
        queryParameters: {
          'key': apiKey,
          'search': query,
          'page_size': 5,
        }
      );

      setState(() {
        results = res.data["results"];
      });

    } catch (e) {
      debugPrint("Erro na busca: $e");

      results = [];
      
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _gameDetails(int id) async {
    if (id == 0) { 
      setState(() {
        details = {};
      });
      return ;
    }

    setState(() {
      isLoading = true;
    });

    Response res;

    try {
      res = await dio.get(
        'https://api.rawg.io/api/games/$id',
        queryParameters: {
          'key': apiKey,
        }
      );

      setState(() {
        details = res.data;

        // Limpa o HTML da resposta da API.
        String descriptionHtml = details["description"] ?? '';

        String descriptionClean = descriptionHtml.replaceAll(RegExp(r'<[^>]*>|&[a-z]+;|&#[0-9]+;'), '');

        descriptionCtrl.text = descriptionClean;

        // Recebe a imagem.
        background_image = details['background_image'] ?? '';

        // Recebe a lista com os gêneros.
        genres = details['genres'];

        // Itera para armazenar somente o nome deles em um array.
        genreNames = genres.map((genre) => genre["name"] as String).toList();
      });

    } catch (e) {
      debugPrint("Erro na busca: $e");

      details = {};
      
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

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

  Future<void> _onGameRegister() async {

    // Recebe o token.
    final token = await getToken();
    print(token);

    // Mensagem da SnackBar.
    String msg;
    
    // Verifica se os campos estão todos preenchidos.
    if (idCtrl.text.isEmpty || nameCtrl.text.isEmpty || descriptionCtrl.text.isEmpty
      || background_image.isEmpty || releasedCtrl.text.isEmpty || genreNames.isEmpty) {
          
          _showSnackbar('Todos os campos são obrigatórios', Colors.red);
        return ;
    }

    setState(() {
      isLoading = true;
    });

    Response res;

    try {
      res = await dio.post(
        'http://localhost:8000/api/gameRegister',
        data: {
          "rawg_id": int.parse(idCtrl.text),
          "name": nameCtrl.text,
          "description": descriptionCtrl.text,
          "background_image": background_image,
          "released": releasedCtrl.text,
          "genres": genreNames,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (res.statusCode == 201) {
        msg = res.data["message"] ?? 'Jogo registrado com sucesso!';
        _showSnackbar(msg, Colors.green);

        if (mounted) {
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (context) => Home())
          );
        }
      } else {
        String detailedError = 'Erro: ${res.statusCode}.';

        if (res.data["errors"] != null) {
          final Map<String, dynamic> errors = res.data["errors"];

          detailedError = errors.values.first[0] ?? detailedError;
        }

        _showSnackbar(detailedError, Colors.red);
      }

    } on DioException catch (e) {
      print(e);
      _showSnackbar("Erro de conexão", Colors.red);

    } finally {
      setState(() {
        isLoading = false;
      });
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
  void dispose() {
    idCtrl.dispose();
    nameCtrl.dispose();
    descriptionCtrl.dispose();
    releasedCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Registrar Novo Jogo", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      body: Container(
        color: const Color.fromARGB(255, 10, 10, 10),
        padding: EdgeInsets.all(20),
        child: Form(
          // key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameCtrl,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nome do Jogo',
                  labelStyle: TextStyle(color: Colors.grey),
                  suffixIcon: isLoading
                    ? CircularProgressIndicator(strokeWidth: 2)
                    : Icon(Icons.search, color: Colors.white),
                  border: OutlineInputBorder(),
                  hintText: 'Digite para buscar o jogo...',
                ),
                onChanged: (value) {
                  _searchData(value);
                },
              ),

              if (results.isNotEmpty)
                Container(
                  constraints: BoxConstraints(minHeight: 250),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 30, 30, 30),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final game = results[index];
                      return ListTile(
                        title: Text(
                          game['name'], style: TextStyle(color: Colors.white)
                        ),
                        onTap: () {

                          final int gameId = game['id'];

                          setState(() {
                            idCtrl.text = gameId.toString();
                            nameCtrl.text = game['name'];
                            releasedCtrl.text = game['released'];
                            results = [];

                            _gameDetails(gameId);
                          });
                        },
                      );
                      
                    }
                  ),
                ),

              const SizedBox(height: 20),

              if (background_image.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Imagem de Fundo do Jogo:',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey)
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          background_image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text('Falha ao carregar imagem', style: TextStyle(color: Colors.red)),
                            );
                          },
                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {return child;}
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),

              TextFormField(
                controller: descriptionCtrl,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                readOnly: true,
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: releasedCtrl,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Data de Lançamento',
                  labelStyle: TextStyle(color: Colors.grey),
                  suffixIcon: Icon(Icons.calendar_today, color: Colors.white),
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              ),

              const SizedBox(height: 20),

              if (genreNames.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gêneros:',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8.0, // Espaço horizontal entre as tags
                      runSpacing: 4.0, // Espaço vertical entre as tags
                      children: genreNames.map((name) {
                        return Chip(
                          backgroundColor: Colors.deepPurple, 
                          label: Text(
                            name,
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _onGameRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, 
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Cadastrar Jogo',
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),

            ],
          )
        ),
      ),
    );
  }
}