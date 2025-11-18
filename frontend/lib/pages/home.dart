import 'package:final_mobile/components/card_game.dart';
import 'package:final_mobile/data/games.dart';
import 'package:final_mobile/pages/profile.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, Object>> dados = games;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Home", style: TextStyle(color: Colors.white)),
        actions: [
          // IconButton(
          //   onPressed: () => Navigator.push(
          //     context,
          //     MaterialPageRoute(builder: (context) => Profile(user: widget.user)),
          //   ),
          //   icon: Icon(Icons.account_circle),
          // ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          color: const Color.fromARGB(255, 10, 10, 10),
          padding: EdgeInsets.all(20),
          child: Column(
            spacing: 12,
            children: [
              Text(
                "Lista dos Jogos",
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Column(
                spacing: 24,
                children: dados.map((game) => Cardgame(game: game)).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
