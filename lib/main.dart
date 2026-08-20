import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/sound_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final soundService = SoundService();
  await soundService.init();

  runApp(TamabrawlerApp(soundService: soundService));
}

class TamabrawlerApp extends StatelessWidget {
  final SoundService soundService;

  const TamabrawlerApp({Key? key, required this.soundService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tamabrawler',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF673AB7),
          secondary: Colors.redAccent,
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(soundService: soundService),
      debugShowCheckedModeBanner: false,
    );
  }
}
