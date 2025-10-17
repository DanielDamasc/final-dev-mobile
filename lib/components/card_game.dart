import 'package:final_mobile/details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class Cardgame extends StatefulWidget {
  final Map<String, Object> game;
  const Cardgame({super.key, required this.game});

  @override
  State<Cardgame> createState() => _CardgameState();
}

class _CardgameState extends State<Cardgame> {
  @override
  Widget build(BuildContext context) {
    bool fav = widget.game["fav"] as bool;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        color: const Color.fromARGB(255, 30, 30, 30),
      ),
      padding: EdgeInsets.all(20),

      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(12),
              child: Image.asset(
                'assets/images/${widget.game["imagem"].toString()}',
                width: 320,
                height: 280,
                fit: BoxFit.cover,
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  widget.game["nome"].toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              RatingBar.builder(
                initialRating: fav == true ? 1 : 0,
                minRating: 0,
                direction: Axis.horizontal,
                itemCount: 1,
                itemSize: 32,
                unratedColor: Colors.grey,
                itemBuilder: (context, _) =>
                    Icon(Icons.star, color: Colors.purpleAccent),
                onRatingUpdate: (rating) {
                  setState(() {
                    rating == 1.0
                        ? widget.game["fav"] = true
                        : widget.game["fav"] = false;
                  });
                },
              ),
            ],
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Desenvolvedor: ${widget.game["desenvolvedor"].toString()}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                "Gênero: ${widget.game["genero"].toString()}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.deepPurpleAccent),
                  ),
                  fixedSize: Size(160, 40),
                ),
                onPressed: () async {
                  final res = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Details(game: widget.game),
                    ),
                  );
                  if (res != null) {
                    setState(() {
                      widget.game["fav"] = res;
                    });
                  }
                },
                child: Text("Ver Detalhes", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
