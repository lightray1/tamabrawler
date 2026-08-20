import 'package:flutter/material.dart';
import 'models/pet.dart';
import 'views/home_screen.dart';

void main() {
  runApp(const TamabrawlerApp());
}

class TamabrawlerApp extends StatefulWidget {
  const TamabrawlerApp({super.key});

  @override
  State<TamabrawlerApp> createState() => _TamabrawlerAppState();
}

class _TamabrawlerAppState extends State<TamabrawlerApp> {
  late Pet _myPet;

  @override
  void initState() {
    super.initState();
    _myPet = Pet();
  }

  @override
  void dispose() {
    _myPet.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tamabrawler',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
        fontFamily: 'Courier',
      ),
      home: HomeScreen(pet: _myPet),
    );
  }
}
