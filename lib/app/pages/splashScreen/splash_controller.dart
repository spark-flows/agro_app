import 'dart:async';
import 'dart:convert';

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
        var profileResponse = await Get.find<Repository>().getProfileApi(isLoading: false);
        if (profileResponse != null && profileResponse.data != null) {
          final profileData = profileResponse.data!.userData;
          
          Get.find<Repository>().saveSecureValue(
            LocalKeys.distributorId,
            profileData.id,
          );
          
          Get.find<Repository>().saveSecureValue(
            LocalKeys.profileData,
            json.encode(profileData.toJson()),
          );
          
          Get.find<Repository>().saveSecureValue(
            LocalKeys.roleName,
            profileData.rolename,
          );
        }
        RouteManagement.goToBottomScreen();
      } else {
        RouteManagement.goToAuthScreen();
      }
    });
    update();
  }
}
