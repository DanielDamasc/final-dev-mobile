import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class GameRegister extends StatefulWidget {
  const GameRegister({super.key});

  @override
  State<GameRegister> createState() => _GameRegisterState();
}

class _GameRegisterState extends State<GameRegister> {

  final dio = Dio();
  final String apiKey = 'f6c09fc6667947218a853f3cfa386bcf';

  final TextEditingController nameCtrl = TextEditingController();
  List<dynamic> results = [];
  bool _isLoading = false;

  Future<void> _searchData(String query) async {
    if (query.isEmpty) { 
      setState(() {
        results = [];
      });
      return ;
    }

    setState(() {
      _isLoading = true;
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
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
                  suffixIcon: _isLoading
                    ? CircularProgressIndicator(strokeWidth: 2)
                    : Icon(Icons.search, color: Colors.white),
                  border: OutlineInputBorder(),
                  hintText: 'Digite para buscar o jogo...',
                ),
                onChanged: (value) {
                  _searchData(value);
                },
                validator: (value) {
                  if (value == null) {
                    return 'O nome do jogo é obrigatório';
                  }
                  return null;
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
                          setState(() {
                            nameCtrl.text = game['name'];
                            results = [];
                          });
                        },
                      );
                      
                    }
                  ),
                ),

              const SizedBox(height: 20),

              TextFormField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'A descrição é obrigatória';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Data de Lançamento',
                  labelStyle: TextStyle(color: Colors.grey),
                  suffixIcon: Icon(Icons.calendar_today, color: Colors.white),
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'A data de lançamento é obrigatória';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),




            ],
          )
        ),
      ),
    );
  }
}