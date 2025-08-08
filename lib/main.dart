import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/home_page.dart';
import 'pages/about_page.dart';

void main() {
  runApp(const MessageBetaApp());
}

class MessageBetaApp extends StatelessWidget {
  const MessageBetaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MessageBeta',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const HomePage(),
      routes: {
        '/about': (context) => const AboutPage(),
      },
    );
  }
}
