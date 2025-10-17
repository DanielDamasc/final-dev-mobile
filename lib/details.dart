import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class Details extends StatefulWidget {
  final Map<String, Object> game;
  const Details({super.key, required this.game});

  @override
  State<Details> createState() => DetailsState();
}

class DetailsState extends State<Details> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 10, 10, 10),
      appBar: AppBar(
        centerTitle: true,
        title: Text("Detalhes", style: TextStyle(color: Colors.white)),
        leading: IconButton(
            onPressed: () => Navigator.pop(context, widget.game["fav"]),
            icon: Icon(Icons.arrow_back),
          ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 10, 10, 10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/${widget.game["imagem"].toString()}',
                  width: double.maxFinite,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),

              Container(
                margin: EdgeInsets.all(20.0),
                child: Column(
                  spacing: 20,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          //Clara
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.game["nome"].toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              Text(
                                "Lançamento: ${widget.game["lancamento"].toString()}",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        RatingBar.builder(
                          initialRating: widget.game["fav"] == true ? 1 : 0,
                          minRating: 0,
                          direction: Axis.horizontal,
                          itemCount: 1,
                          unratedColor: Colors.grey,
                          itemBuilder: (context, _) =>
                              Icon(Icons.star, color: Colors.purpleAccent),
                          onRatingUpdate: (rating) {
                            rating == 1.0
                                ? widget.game["fav"] = true
                                : widget.game["fav"] = false;
                          },
                        ),
                      ],
                    ),

                    Text(
                      widget.game["sinopse"].toString(),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    Text(
                      "Gênero: ${widget.game["genero"].toString()}",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    Text(
                      "Desenvolvedor: ${widget.game["desenvolvedor"].toString()}",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
