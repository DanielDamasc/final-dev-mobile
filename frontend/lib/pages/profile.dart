import 'package:dio/dio.dart';
import 'package:final_mobile/API/ApiService.dart';
import 'package:final_mobile/pages/login.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  
  final dio = Dio();
  final ApiService _apiService = ApiService();

  Future<String?> getToken() async {
    return _apiService.getToken();
  }

  Future<Map<String, dynamic>?> _getUser() async {

    final headers = await _apiService.getAuthHeaders();

    try {
      Response res = await dio.get(
        '${_apiService.BASE_URL}/user',
        options: Options(
            headers: headers,
            validateStatus: (status) => status != null && status < 500,
          ),
      );

      if (res.statusCode == 200) {

        final Map<String, dynamic> fetchUser = res.data;
          
        return fetchUser;
      }

      throw Exception("Erro: Código ${res.statusCode}");

    } on DioException catch (e) {
      throw Exception("Erro de conexão");
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

  Future<void> _logout() async {

    final headers = await _apiService.getAuthHeaders();

    try {
      Response res = await dio.post(
        '${_apiService.BASE_URL}/logout',
        options: Options(
            headers: headers,
            validateStatus: (status) => status != null && status < 500,
          ),
      );

      if (res.statusCode == 200) {
        // Deleta o token e redireciona para o login.
        await _apiService.deleteToken();
        _checkAuth();
        _showSnackbar(res.data["message"].toString(), Colors.green);
      }

    } on DioException catch (e) {
      _showSnackbar("Erro de conexão", Colors.red);

    }
  }

  Future<void> _deleteUser() async {

    final headers = await _apiService.getAuthHeaders();

    try {
      Response res = await dio.delete(
        '${_apiService.BASE_URL}/user/delete',
        options: Options(
            headers: headers,
            validateStatus: (status) => status != null && status < 500,
          ),
      );

      if (res.statusCode == 204) {
        await _apiService.deleteToken();
        _checkAuth();
        _showSnackbar("Conta deletada com sucesso", Colors.green);
      }

    } on DioException catch (e) {
      _showSnackbar("Erro de conexão", Colors.red);
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
        title: Text("Perfil", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white)
        ),
      ),

      body: FutureBuilder<Map<String, dynamic>?>(
        future: _getUser(), 
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar user: ${snapshot.error.toString()}',
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (snapshot.hasData) {
            final Map<String, dynamic> fetchedUser = snapshot.data!;
            final String fotoUrl = fetchedUser["foto_url"] ?? '';

            if (fetchedUser.isEmpty) {
              return Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                color: const Color.fromARGB(255, 10, 10, 10),
                child: Center(
                  child: Text(
                    "Nenhum user foi encontrado.",
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
                    Row(
                      children: [

                        ClipOval(
                          child: fotoUrl.isNotEmpty
                            ? Image.network(
                                fotoUrl,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            : Icon(
                                Icons.account_circle,
                                color: Colors.deepPurple,
                                size: 100,
                              ),
                        ),

                        SizedBox(width: 20),
                        
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fetchedUser["name"] ?? "Nome não encontrado",
                                style: TextStyle(
                                  fontSize: 28,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                fetchedUser["email"] ?? "Email não encontrado",
                                style: TextStyle(fontSize: 20, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),

                    SizedBox(height: 20),

                    Divider(color: Colors.deepPurple, height: 1),

                    SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text(
                          "Logout",
                          style: TextStyle(fontSize: 18, color: Colors.red),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _deleteUser,
                        icon: const Icon(Icons.delete_forever, color: Colors.white),
                        label: const Text(
                          "Excluir Conta",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

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
