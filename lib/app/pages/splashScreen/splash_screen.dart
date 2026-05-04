import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agro_app/app/app.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.agriculture_rounded,
                  size: 100,
                  color: ColorsValue.primary,
                ),
                Dimens.boxHeight24,
                Text(
                  StringConstants.appName,
                  style: Styles.txtBlackColorW70022.copyWith(fontSize: 32),
                ),
                Dimens.boxHeight8,
                Text(
                  'ERP SYSTEM',
                  style: TextStyle(
                    color: ColorsValue.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
