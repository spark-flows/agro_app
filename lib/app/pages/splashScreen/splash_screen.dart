import 'package:agro_app/app/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(child: Image.asset(AssetConstants.logo)),
        );
      },
    );
  }
}
