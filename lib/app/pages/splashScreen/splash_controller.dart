import 'dart:async';
import 'dart:convert';

import 'package:agro_app/app/app.dart';
import 'package:agro_app/domain/domain.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashController extends GetxController {
  SplashController(this.splashPresenter);

  final SplashPresenter splashPresenter;

  @override
  void onInit() {
    super.onInit();
    FirebaseApi.onAppTerminateMode();
    startTimer();
  }

  String? appUrl;

  void startTimer() async {
    try {
      await Permission.notification.request();
    } catch (_) {}

    Future.delayed(const Duration(seconds: 3)).then((value) async {
      String token = await Get.find<Repository>().getSecureValue(
        LocalKeys.authToken,
      );
      if (token.isNotEmpty) {
        var profileResponse = await Get.find<Repository>().getProfileApi(
          isLoading: false,
        );
        if (profileResponse != null) {
          final profileData = profileResponse.data.userData;
          await Utility.saveUserSession(userData: profileData);
          RouteManagement.goToBottomScreen();
          FirebaseApi.processPendingNotification();
        } else {
          // If offline or profile fetch failed, check if we have cached profile data
          String cachedProfile = await Get.find<Repository>().getSecureValue(
            LocalKeys.profileData,
          );
          if (cachedProfile.isNotEmpty) {
            try {
              final cachedData = ProfileDataUserData.fromJson(
                json.decode(cachedProfile),
              );
              await Utility.saveUserSession(userData: cachedData);
              RouteManagement.goToBottomScreen();
              FirebaseApi.processPendingNotification();
              return;
            } catch (_) {}
          }
          FirebaseApi.clearPendingNotification();
          await Utility.logout();
        }
      } else {
        FirebaseApi.clearPendingNotification();
        RouteManagement.goToAuthScreen();
      }
    });
    update();
  }
}
