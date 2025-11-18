import 'package:final_mobile/pages/cadastro.dart';
import 'package:final_mobile/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final dio = Dio();
  final storageToken = const FlutterSecureStorage();

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

      res = await dio.post('http://localhost:8000/api/login',
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

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },

      child: Scaffold(

        appBar: AppBar(
          title: Text("Games.io", style: TextStyle(color: Colors.white)),
        ),

        body: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  (kToolbarHeight + MediaQuery.of(context).padding.top),
            ),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 10, 10, 10),
            ),
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Olá, seja bem-vindo ao Games.io",
                  style: TextStyle(fontSize: 32, color: Colors.white),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 20),

                Text(
                  "Faça seu Login",
                  style: TextStyle(fontSize: 24, color: Colors.grey),
                ),

                SizedBox(height: 20),

                Column(
                  children: [
                    TextField(
                      style: TextStyle(color: Colors.white),
                      controller: emailCtrl,
                      decoration: InputDecoration(
                        hintText: 'E-mail',
                        hintStyle: TextStyle(color: Colors.deepPurple),
                      ),
                    ),

                    SizedBox(height: 20),

                    TextField(
                      style: TextStyle(color: Colors.white),
                      controller: senhaCtrl,
                      obscureText: escondeSenha,
                      decoration: InputDecoration(
                        hintText: 'Senha',
                        hintStyle: TextStyle(color: Colors.deepPurple),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              escondeSenha = !escondeSenha;
                            });
                          },

                          icon: Icon(
                            escondeSenha ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    if (errorMessage.isNotEmpty)
                      Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                      ),

                      onPressed: isLoading ? null : login,
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.white,)
                          : Text('Login'),
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
                                color: Colors.deepPurpleAccent,
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
    );
  }
}
