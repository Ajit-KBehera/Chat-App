import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();

    Future.delayed(
      const Duration(seconds: 4),
      () {
        if (mounted) {
          if (firebaseUser != null) {
            Navigator.pushReplacementNamed(
              context,
              'Home Screen',
            );
          } else {
            Navigator.pushReplacementNamed(
              context,
              'Login Screen',
            );
          }
        }
      },
    );

    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Lottie.asset("assets/splash_animation.json"),
      ),
    );
  }
}
