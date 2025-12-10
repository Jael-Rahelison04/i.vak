import 'dart:async';
import 'package:annuaire_scolaire/pages/home.dart';
// ignore: unused_import
import 'package:annuaire_scolaire/services/data_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    SystemChannels.platform.setMethodCallHandler((call) async {
      if (call.method == 'SystemSound.play') return; // bloque les sons
      return null;
    });

    // Initialiser l'animation pour la barre de progression
    _controller = AnimationController(
      duration: const Duration(seconds: 3), // Durée de l'animation
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    // Démarrer l'animation
    _controller.forward();

    // Rediriger vers HomePage après 4 secondes
    Timer(const Duration(seconds: 3), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false, // supprime tout l’historique
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fond blanc pour le splash screen
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset('assets/i_vak.png', width: 80, height: 80),

            const SizedBox(height: 10),

            SizedBox(
              width: 150,
              child: LinearProgressIndicator(
                value: _animation.value,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xff036B54),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
