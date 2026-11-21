import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'state/app_state.dart';

class PomeloApp extends StatefulWidget {
  const PomeloApp({super.key});

  @override
  State<PomeloApp> createState() => _PomeloAppState();
}

class _PomeloAppState extends State<PomeloApp> {
  final app = AppState();

  @override
  void initState() {
    super.initState();
    app.init();
  }

  @override
  void dispose() {
    app.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomelo',
      debugShowCheckedModeBanner: true,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFFFF7A45),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFFFF7A45),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: HomeScreen(app: app),
    );
  }
}
