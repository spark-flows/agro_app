import 'dart:convert';

import 'package:agro_app/app/navigators/routes_management.dart';
import 'package:agro_app/domain/domain.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  String roleName = '';

  @override
  void onInit() {
    super.onInit();
    _loadRoleFromLocal();
  }

  Future<void> _loadRoleFromLocal() async {
    // 1. Try reading from secure storage first (fastest path)
    final storedRole = await Get.find<Repository>().getSecureValue(
      LocalKeys.roleName,
    );
    if (storedRole.isNotEmpty) {
      roleName = storedRole;
      update();
      return;
    }

    // 2. Try reading from cached profile JSON
    final localData = await Get.find<Repository>().getSecureValue(
      LocalKeys.profileData,
    );
    if (localData.isNotEmpty) {
      try {
        final userData = ProfileDataUserData.fromJson(json.decode(localData));
        if (userData.rolename.isNotEmpty) {
          roleName = userData.rolename;
          update();
          return;
        }
      } catch (_) {
        // invalid cached JSON — continue to API fallback
      }
    }

    // 3. Fallback: fetch profile API directly and save everything
    final response = await Get.find<Repository>().getProfileApi(
      isLoading: false,
    );
    if (response != null && response.data != null) {
      final userData = response.data.userData;
      roleName = userData.rolename;

      Get.find<Repository>().saveSecureValue(
        LocalKeys.distributorId,
        userData.id,
      );
      Get.find<Repository>().saveSecureValue(
        LocalKeys.roleName,
        userData.roleid.rolename,
      );
      Get.find<Repository>().saveSecureValue(
        LocalKeys.profileData,
        json.encode(userData.toJson()),
      );
      update();
    }
  }

  void goToCustomers() => RouteManagement.goToCustomersScreen();
  void goToDistributors() => RouteManagement.goToDistributorsScreen();
  void goToOrders() => RouteManagement.goToOrdersScreen();
  void goToProducts() => RouteManagement.goToProductsScreen();
  void goToProfile() => RouteManagement.goToProfileScreen();
  void goToUsers() => RouteManagement.goToUserListScreen();
}
