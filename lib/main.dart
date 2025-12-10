import 'package:annuaire_scolaire/pages/school_bottom_sheet.dart';
import 'package:annuaire_scolaire/pages/splash_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: SchoolBottomSheet.navigatorKey,
      home: const SplashScreen(), // Démarrer avec l'ecran d'accueil'
    );
  }
}
