import 'package:dio/dio.dart';
import 'package:final_mobile/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final dio = Dio();
  final storageToken = const FlutterSecureStorage();

  // Controllers
  final TextEditingController nomeCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController senhaCtrl = TextEditingController();
  final TextEditingController confirmarSenhaCtrl = TextEditingController();

  bool escondeSenha = true;
  String errorMessage = '';
  bool isLoading = false;

  @override
  void dispose() {
    nomeCtrl.dispose();
    emailCtrl.dispose();
    senhaCtrl.dispose();
    confirmarSenhaCtrl.dispose();

    super.dispose();
  }

  Future<void> _onCadastrar() async {

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      Response res = await dio.post('http://localhost:8000/api/register',
        data: {
          "name": nomeCtrl.text,
          "foto": null,
          "email": emailCtrl.text,
          "password": senhaCtrl.text,
          "password_confirmation": confirmarSenhaCtrl.text,
        },
        options: Options(
          headers: {'Accept': 'application/json'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (res.statusCode == 201) {
        String token = res.data['token'];
        await storageToken.write(key: 'auth_token', value: token);

        if (mounted) {
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (context) => Home())
          );
        }

      } else if (res.statusCode == 422) {
        errorMessage = res.data['message'] ?? 'Erro de validação.';
      } else {
        setState(() {
          errorMessage = 'Erro inesperado.';
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
          centerTitle: true,
          title: Text("Cadastro", style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
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
                  "Crie sua Conta",
                  style: TextStyle(fontSize: 24, color: Colors.grey),
                ),

                SizedBox(height: 20),

                Column(
                  children: [
                    TextField(
                      style: TextStyle(color: Colors.white),
                      controller: nomeCtrl,
                      decoration: InputDecoration(
                        hintText: 'Nome',
                        hintStyle: TextStyle(color: Colors.deepPurple),
                      ),
                    ),
                    
                    SizedBox(height: 20),

                    TextField(
                      style: TextStyle(color: Colors.white),
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
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

                    TextField(
                      style: TextStyle(color: Colors.white),
                      controller: confirmarSenhaCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Confirmar Senha',
                        hintStyle: TextStyle(color: Colors.deepPurple),
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
                      onPressed: _onCadastrar,
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Cadastrar'),
                    ),

                    SizedBox(height: 20),

                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: RichText(
                        text: TextSpan(
                          text: 'Já tem uma conta? ',
                          style: TextStyle(color: Colors.grey),
                          children: [
                            TextSpan(
                              text: 'Faça login.',
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