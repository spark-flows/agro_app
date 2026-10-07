import 'dart:convert';
import 'package:agro_app/app/navigators/routes_management.dart';
import 'package:agro_app/app/utils/utility.dart';
import 'package:agro_app/device/device.dart';
import 'package:agro_app/domain/domain.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final RxBool isLoading = false.obs;
  ProfileDataUserData? userData;

  @override
  void onInit() {
    super.onInit();
    _loadFromLocal();
    fetchProfile();
  }

  Future<void> _loadFromLocal() async {
    String localData = await Get.find<Repository>().getSecureValue(
      LocalKeys.profileData,
    );
    if (localData.isNotEmpty) {
      try {
        userData = ProfileDataUserData.fromJson(json.decode(localData));
        update();
      } catch (e) {
        // invalid JSON
      }
    }
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    var response = await Get.find<Repository>().getProfileApi(isLoading: false);
    if (response != null && response.data != null) {
      userData = response.data.userData;
      await Utility.saveUserSession(userData: userData!);
    }
    isLoading.value = false;
    update();
  }

  void logout() async {
    await Utility.logout();
  }
}
