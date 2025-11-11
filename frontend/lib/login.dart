import 'package:final_mobile/data/model/user.dart';
import 'package:final_mobile/home.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController senhaCtrl = TextEditingController();
  bool escondeSenha = true;
  String erro = '';

  @override
  void initState() {
    super.initState();
    //ler API, iniciar banco
  }

  @override
  void dispose() {
    super.dispose();
    emailCtrl.dispose();
    senhaCtrl.dispose();
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
              color: const Color.fromARGB(255, 10, 10, 10),
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

                SizedBox(height: 60),

                Column(
                  spacing: 20,
                  children: [
                    Text(
                      "Faça seu Login",
                      style: TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                    TextField(
                      style: TextStyle(color: Colors.white),
                      controller: emailCtrl,
                      decoration: InputDecoration(
                        hintText: 'E-mail',
                        hintStyle: TextStyle(color: Colors.deepPurple),
                      ),
                    ),
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
                          icon: Icon(Icons.visibility),
                        ),
                      ),
                    ),

                    Text(erro, style: TextStyle(color: Colors.red)),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        foregroundColor: Colors.white,
                      ),

                      onPressed: () async {
                        String email = emailCtrl.text;
                        String senha = senhaCtrl.text;

                        User? user = await User.login(email, senha);

                        if (user != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Home(user: user),
                            ),
                          );
                        } else {
                          setState(() {
                            erro = 'E-mail ou senha inválidos.';
                          });
                        }
                      },
                      child: Text("Login"),
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
