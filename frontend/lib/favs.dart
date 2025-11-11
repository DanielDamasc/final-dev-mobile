import 'package:final_mobile/data/games.dart';
import 'package:flutter/material.dart';

class Favs extends StatefulWidget {
  const Favs({super.key});

  @override
  State<Favs> createState() => _FavsState();
}

class _FavsState extends State<Favs> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, Object>> dados = games;
    final List<Map<String, Object>> favs = [];

    for (var data in dados) {
      if (data["fav"] == true) {
        favs.add(data);
      }
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 10, 10, 10),
      appBar: AppBar(centerTitle: true, title: Text("Favoritos", style: TextStyle(color: Colors.white))),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Lista dos Jogos",
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              favs.isEmpty
                  ? Text(
                      "Não há jogos favoritados",
                      style: TextStyle(color: Colors.grey),
                    )
                  : Expanded(
                      child: ListView(
                        children: favs
                            .map(
                              (game) => ListTile(
                                minTileHeight: 80,
                                leading: Icon(
                                  Icons.star,
                                  color: Colors.purpleAccent,
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      game["nome"].toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      game["genero"].toString(),
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
