import 'package:dio/dio.dart';
import 'package:final_mobile/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final dio = Dio();
  final storageToken = const FlutterSecureStorage();
  final ImagePicker picker = ImagePicker();
  final String? BASE_URL = dotenv.env["BASE_URL"];

  // Controllers
  final TextEditingController nomeCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController senhaCtrl = TextEditingController();
  final TextEditingController confirmarSenhaCtrl = TextEditingController();
  XFile? imageFile;


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

  Future<void> _pickImage() async {
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery
    );

    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile;
      });
    }
  }

  Future<void> _onCadastrar() async {

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      Map<String, dynamic> data = {
        "name": nomeCtrl.text,
        "foto": null,
        "email": emailCtrl.text,
        "password": senhaCtrl.text,
        "password_confirmation": confirmarSenhaCtrl.text,
      };

      if (imageFile != null) {
        final bytes = await imageFile!.readAsBytes();

        data["foto"] = MultipartFile.fromBytes(
          bytes,
          filename: imageFile!.path.split('/').last,
        );
      }

      FormData formData = FormData.fromMap(data);

      Response res = await dio.post('$BASE_URL/register',
        data: formData,
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

    const Color primaryPurple = Colors.deepPurpleAccent;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },

      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 10, 10, 10),

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
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

                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: primaryPurple,

                    child: imageFile == null
                        ? 
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Adicionar Foto...", style: TextStyle(fontSize: 12, color: Colors.grey.shade300)),
                              Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 50,
                              ),
                            ],
                          )
                        : FutureBuilder (
                          future: imageFile!.readAsBytes(), 
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                              return ClipOval(
                                child: Image.memory(
                                  snapshot.data!,
                                  fit: BoxFit.cover,
                                  width: 120,
                                  height: 120,
                                ),
                              );
                            }
                            return CircularProgressIndicator(color: Colors.white);
                          }
                        ),
                  ),
                ),

                SizedBox(height: 20),

                Text(
                  "Crie sua Conta",
                  style: TextStyle(fontSize: 28, color: primaryPurple, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 20),

                Column(
                  children: [
                    TextField(
                      style: TextStyle(color: Colors.black),
                      controller: nomeCtrl,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person, color: primaryPurple),
                        hintText: 'Nome',
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
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
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

                    SizedBox(height: 20),

                    TextField(
                      style: TextStyle(color: Colors.black),
                      controller: confirmarSenhaCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline, color: primaryPurple),
                        hintText: 'Confirmar Senha',
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

                      onPressed: _onCadastrar,
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Cadastrar', style: TextStyle(fontSize: 16)),
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
    );
  }
}