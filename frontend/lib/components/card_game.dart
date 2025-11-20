import 'package:flutter/material.dart';

class Cardgame extends StatelessWidget {

  final Map<String, dynamic> game;

  const Cardgame({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {

    final String name = game['name'] ?? 'Nome Desconhecido';
    final String imageUrl = game['background_image'] ?? '';
    final String released = game['released'] ?? 'N/A';
    final List<String> genres = List<String>.from(game['genres'] ?? []); 

    return GestureDetector(
      // onTap: () {},

      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 30, 30, 30),
          borderRadius: BorderRadius.circular(10),
        ),
        
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.network(
                imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Container(
                    height: 180,
                    color: Colors.grey,
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.deepPurple),
                    ),
                  );
                },
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Lançamento: $released',
                              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: 40.0,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurpleAccent,
                              minimumSize: Size.zero,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(8.0))
                            ),
                            child: Icon(Icons.info, color: Colors.white, size: 24)
                          ),
                        ),
                      ),

                      SizedBox(width: 8),

                      SizedBox(
                        height: 40.0,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              minimumSize: Size.zero,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(8.0))
                            ),
                            child: Icon(Icons.delete, color: Colors.white, size: 24)
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  
                  Text(
                    'Gêneros:',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8.0, 
                    runSpacing: 4.0, 
                    children: genres.map((genre) {
                      return Chip(
                        backgroundColor: Colors.deepPurple,
                        label: Text(
                          genre,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}