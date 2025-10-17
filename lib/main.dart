import 'package:final_mobile/details.dart';
import 'package:final_mobile/favs.dart';
import 'package:final_mobile/home.dart';
import 'package:final_mobile/login.dart';
import 'package:final_mobile/profile.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          backgroundColor: Colors.deepPurpleAccent,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const Login(),
        '/home': (context) => const Home(user: {}),
        '/datails': (context) => const Details(game: {}),
        '/profile': (context) => const Profile(user: {}),
        '/favs': (context) => const Favs(),
      },
    );
  }
}
