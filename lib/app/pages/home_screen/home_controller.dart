import 'dart:convert';
import 'package:get/get.dart';
import 'package:agro_app/domain/domain.dart';
import 'package:agro_app/domain/models/get_profille_model.dart';
import 'package:agro_app/app/navigators/routes_management.dart';

class HomeController extends GetxController {
  String roleName = '';

  @override
  void onInit() {
    super.onInit();
    _loadRoleFromLocal();
  }

  Future<void> _loadRoleFromLocal() async {
    final localData = await Get.find<Repository>().getSecureValue(
      LocalKeys.profileData,
    );
    if (localData.isNotEmpty) {
      try {
        final userData = ProfileDataUserData.fromJson(json.decode(localData));
        roleName = userData.rolename;
        update();
      } catch (e) {
        // ignore invalid JSON
      }
    }
  }

  void goToCustomers() => RouteManagement.goToCustomersScreen();
  void goToOrders() => RouteManagement.goToOrdersScreen();
  void goToProfile() => RouteManagement.goToProfileScreen();
  void goToUsers() => RouteManagement.goToUserListScreen();
}
