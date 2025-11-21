import 'package:final_mobile/pages/login.dart';
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
      },
    );
  }
}
