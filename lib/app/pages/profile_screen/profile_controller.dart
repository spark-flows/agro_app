import 'dart:convert';
import 'package:get/get.dart';
import 'package:agro_app/domain/domain.dart';
import 'package:agro_app/app/navigators/routes_management.dart';

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

      Get.find<Repository>().saveSecureValue(
        LocalKeys.distributorId,
        userData?.id ?? '',
      );
      Get.find<Repository>().saveSecureValue(
        LocalKeys.profileData,
        json.encode(userData!.toJson()),
      );
      Get.find<Repository>().saveSecureValue(
        LocalKeys.roleName,
        userData?.roleid.rolename ?? '',
      );
    }
    isLoading.value = false;
    update();
  }

  void logout() {
    Get.find<Repository>().deleteSecuredValue(LocalKeys.authToken);
    Get.find<Repository>().deleteSecuredValue(LocalKeys.distributorId);
    Get.find<Repository>().deleteSecuredValue(LocalKeys.profileData);
    Get.find<Repository>().deleteSecuredValue(LocalKeys.roleName);
    RouteManagement.goToAuthScreen();
  }
}
