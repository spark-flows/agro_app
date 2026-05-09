import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agro_app/app/navigators/routes_management.dart';
import 'package:agro_app/app/pages/pages.dart';
import 'package:agro_app/app/utils/utility.dart';
import 'package:agro_app/domain/repositories/local_storage_keys.dart';
import 'package:agro_app/domain/repositories/repository.dart';
import 'package:validators/validators.dart';

class AuthController extends GetxController {
  AuthController(this.authPresenter);

  final AuthPresenter authPresenter;

  @override
  void onInit() async {
    getFCMToken();
    super.onInit();
  }

  var dailReCode = '+91';
  bool isReValid = false;

  ///========================================== AuthScreen =========================================

  GlobalKey<FormState> loginKey = GlobalKey<FormState>();
  TextEditingController userNameController = TextEditingController();
  TextEditingController passController = TextEditingController();
  var isPasswordHidden = true;
  var isCreatePasswordHidden = true;
  var isConfirmPasswordHidden = true;

  GlobalKey<FormState> resetKey = GlobalKey<FormState>();
  GlobalKey<FormState> registerKey = GlobalKey<FormState>();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  TextEditingController passwordRegisterController = TextEditingController();
  TextEditingController nameRegisterController = TextEditingController();
  TextEditingController mobileRegisterController = TextEditingController();
  TextEditingController emailRegisterController = TextEditingController();
  TextEditingController confirmPasswordRegisterController =
      TextEditingController();

  Future<void> postLoginApi() async {
    isLoginLoading = true;
    update();
    Utility.showLoader();
    var response = await authPresenter.loginApi(
      userName: userNameController.text,
      password: passController.text,
      fcmToken: fcmToken,
      isLoading: false,
    );
    Utility.closeLoader();
    isLoginLoading = false;
    update();

    if (response != null && response.status == 200) {
      if (response.data?.accessToken != null) {
        Get.find<Repository>().saveSecureValue(
          LocalKeys.authToken,
          response.data!.accessToken!,
        );
      }

      var profileResponse = await Get.find<Repository>().getProfileApi(
        isLoading: false,
      );
      if (profileResponse != null) {
        final profileData = profileResponse.data.userData;

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
          profileData.roleid.rolename,
        );
      }

      RouteManagement.goToBottomScreen();
    } else {
      Utility.errorMessage(
        response?.message ?? "Login failed. Please try again.",
      );
    }
  }

  TextEditingController otpTextEditingController = TextEditingController();
  TextEditingController emailForgotController = TextEditingController();
  GlobalKey<FormState> forgotKey = GlobalKey<FormState>();

  final GlobalKey<FormState> otpFormKey = GlobalKey<FormState>();

  int counter = 30;
  Timer? _timer;

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer?.cancel();
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (counter == 0) {
        _timer?.cancel();
        update();
      } else {
        counter--;
        update();
      }
    });
  }

  String? validotp(String value) {
    if (value.isEmpty) {
      return "Enter OTP".tr;
    } else if (!(isNumeric(value) && value.length == 6)) {
      return "Enter Valid OTP".tr;
    } else {
      return null;
    }
  }

  String? otpKey;
  String? otpMobile;

  bool isLoginLoading = false;
  String fcmToken = '';

  Future<void> getFCMToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    String? token = await messaging.getToken();
    fcmToken = token ?? '';
    print("FCM Token: $token");
    update();
  }

  void clearRegisterData() {
    emailRegisterController.clear();
    mobileRegisterController.clear();
    nameRegisterController.clear();
    confirmPasswordRegisterController.clear();
    passwordRegisterController.clear();
    update();
  }
}
