import 'package:final_mobile/pages/cadastro.dart';
import 'package:final_mobile/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final dio = Dio();
  final storageToken = const FlutterSecureStorage();
  final String? BASE_URL = dotenv.env["BASE_URL"];

  TextEditingController emailCtrl = TextEditingController();
  TextEditingController senhaCtrl = TextEditingController();

  bool escondeSenha = true;
  String errorMessage = '';
  bool isLoading = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> login() async {

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {

      Response res;

      res = await dio.post('$BASE_URL/login',
       data: {
        'email': emailCtrl.text, 
        'password': senhaCtrl.text
        },

       options: Options(
        validateStatus: (status) {
          // Aceita os status code < que 500.
          return status != null && status < 500;
        },
       ),

      );
      
      // Sucesso
      if (res.statusCode == 200) {
        String token = res.data['token'];

        // Salva o token.
        await storageToken.write(key: 'auth_token', value: token);

        if (mounted) {
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(
              builder: (context) => Home(),
            ),
          );
        }
      }

      // Erro de validação ou de credenciais.
      else if (res.statusCode == 422 || res.statusCode == 401) {
        final error = res.data['message'];

        setState(() {
          errorMessage = error;
        });
      }

      else {
        setState(() {
          errorMessage = 'Ocorreu um erro inesperado.';
        });
      }

    } on DioException catch (e) {

      setState(() {
          errorMessage = 'Erro de conexão.';
        });

    } finally {
      
      setState(() {
        isLoading = false;
      });

    }
  }

  @override
  Widget build(BuildContext context) {

    const Color primaryPurple = Colors.deepPurpleAccent;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },

      child: SafeArea(
        child: Scaffold(
          backgroundColor: Color.fromARGB(255, 10, 10, 10),
        
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text("Gamerank", style: TextStyle(color: Colors.white, fontSize: 32)),
            centerTitle: true,
          ),
        
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 8.0),
            child: Container(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    (kToolbarHeight + MediaQuery.of(context).padding.top + 16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sports_esports,
                    color: primaryPurple,
                    size: 80,
                  ),
        
                  SizedBox(height: 20),
        
                  Text(
                    "Um espaço para adicionar, ver e ranquear seus jogos favoritos. Mostre quais jogos estão no topo!",
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
        
                  SizedBox(height: 30), 
        
                  Text(
                    "Faça seu Login",
                    style: TextStyle(fontSize: 28, color: primaryPurple, fontWeight: FontWeight.bold),
                  ),
        
                  SizedBox(height: 30),
        
                  Column(
                    children: [
                      TextField(
                        style: TextStyle(color: Colors.black),
                        controller: emailCtrl,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email_outlined, color: primaryPurple),
                          hintText: 'E-mail',
                          hintStyle: TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: primaryPurple, width: 2.0)
                          )
                        ),
                      ),
        
                      SizedBox(height: 20),
        
                      TextField(
                        style: TextStyle(color: Colors.black),
                        controller: senhaCtrl,
                        obscureText: escondeSenha,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock_outline, color: primaryPurple),
                          hintText: 'Senha',
                          hintStyle: TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: primaryPurple, width: 2.0)
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                escondeSenha = !escondeSenha;
                              });
                            },
        
                            icon: Icon(
                              escondeSenha ? Icons.visibility_off : Icons.visibility,
                              color: primaryPurple,
                            ),
                          ),
                        ),
                      ),
        
                      SizedBox(height: 30),
        
                      if (errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Text(
                            errorMessage,
                            style: TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
        
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryPurple,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 5,
                        ),
        
                        onPressed: isLoading ? null : login,
                        child: isLoading
                            ? CircularProgressIndicator(color: Colors.white,)
                            : Text('Login', style: TextStyle(fontSize: 16)),
                      ),
        
                      SizedBox(height: 20),
        
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(
                              builder: (context) => const Register() 
                            ),
                          );
                        }, 
                        child: RichText(
                          text: TextSpan(
                            text: 'Não tem uma conta? ',
                            style: TextStyle(color: Colors.grey),
                            children: [
                              TextSpan(
                                text: 'Cadastre-se',
                                style: TextStyle(
                                  color: primaryPurple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
