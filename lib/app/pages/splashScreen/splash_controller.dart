import 'dart:async';

import 'package:get/get.dart';
import 'package:agro_app/app/app.dart';
import 'package:agro_app/domain/domain.dart';

class SplashController extends GetxController {
  SplashController(this.splashPresenter);

  final SplashPresenter splashPresenter;

  @override
  void onInit() {
    super.onInit();
    startTimer();
  }

  String? appUrl;

  void startTimer() async {
    Future.delayed(const Duration(seconds: 3)).then((value) async {
      String token = await Get.find<Repository>().getSecureValue(LocalKeys.authToken);
      if (token.isNotEmpty) {
        RouteManagement.goToBottomScreen();
      } else {
        RouteManagement.goToAuthScreen();
      }
    });
    update();
  }
}
