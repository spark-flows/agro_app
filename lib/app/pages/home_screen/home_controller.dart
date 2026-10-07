import 'dart:convert';

import 'package:agro_app/app/navigators/routes_management.dart';
import 'package:agro_app/app/utils/utility.dart';
import 'package:agro_app/domain/domain.dart';
import 'package:agro_app/domain/models/get_all_branches_model.dart'
    as branch_model;
import 'package:get/get.dart';

class HomeController extends GetxController {
  String roleName = '';
  String userName = '';
  List<branch_model.Doc> branches = [];
  branch_model.Doc? selectedBranch;
  bool isBranchesLoading = false;
  int unreadNotificationCount = 0;

  @override
  void onInit() {
    super.onInit();
    _loadRoleFromLocal();
    fetchBranches();
    fetchUnreadNotificationsCount();
  }

  Future<void> _loadRoleFromLocal() async {
    // 1. Try reading role and username from storage
    final storedRole = await Utility.getRoleName();
    final storedUserName = await Get.find<Repository>().getSecureValue(
      LocalKeys.userName,
    );
    if (storedRole.isNotEmpty) {
      roleName = storedRole;
    }
    if (storedUserName.isNotEmpty) {
      userName = storedUserName;
    }
    if (roleName.isNotEmpty && userName.isNotEmpty) {
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
        final effRole = userData.effectiveRoleName;
        if (effRole.isNotEmpty) {
          roleName = effRole;
        }
        if (userData.name.isNotEmpty) {
          userName = userData.name;
        }
        if (roleName.isNotEmpty || userName.isNotEmpty) {
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
    if (response != null) {
      final userData = response.data.userData;
      roleName = userData.effectiveRoleName;
      userName = userData.name;

      await Utility.saveUserSession(userData: userData);
      update();
    }
  }

  void goToCustomers() => RouteManagement.goToCustomersScreen();
  void goToDistributors() => RouteManagement.goToDistributorsScreen();
  void goToOrders() => RouteManagement.goToOrdersScreen();
  void goToCustomerOrders() => RouteManagement.goToCustomerOrdersScreen();
  void goToProducts() => RouteManagement.goToProductsScreen();
  void goToProfile() => RouteManagement.goToProfileScreen();
  void goToUsers() => RouteManagement.goToUserListScreen();
  void goToTasks() => RouteManagement.goToTasksScreen();
  void goToAttendance() => RouteManagement.goToAttendanceScreen();
  void goToSalary() => RouteManagement.goToSalaryScreen();
  void goToLeaves() => RouteManagement.goToLeaveScreen();
  void goToCollection() => RouteManagement.goToCollectionScreen();
  void goToExpense() => RouteManagement.goToExpenseScreen();
  void goToLedgers() => RouteManagement.goToLedgersScreen();
  void goToNotifications() async {
    await RouteManagement.goToNotificationScreen();
    fetchUnreadNotificationsCount();
  }

  void setUnreadNotificationCount(int count) {
    unreadNotificationCount = count;
    update();
  }

  Future<void> fetchUnreadNotificationsCount() async {
    try {
      final count = await Get.find<Repository>().getNotificationUnreadCountApi(
        isLoading: false,
      );
      if (count != null) {
        unreadNotificationCount = count;
        update();
      }
    } catch (_) {}
  }

  Future<void> fetchBranches() async {
    isBranchesLoading = true;
    update();
    try {
      final response = await Get.find<Repository>().getAllBranchesApi(
        isLoading: false,
      );
      if (response != null &&
          response.data != null &&
          response.data!.docs != null) {
        branches = response.data!.docs!
            .where((b) => b.isDeleted != true)
            .toList();

        if (branches.isNotEmpty) {
          final savedBranchId = await Get.find<Repository>().getSecureValue(
            LocalKeys.selectedBranchId,
          );
          if (savedBranchId.isNotEmpty) {
            final matched = branches.firstWhereOrNull(
              (b) => b.id == savedBranchId,
            );
            if (matched != null) {
              selectedBranch = matched;
            } else {
              selectedBranch = branches.first;
              Get.find<Repository>().saveSecureValue(
                LocalKeys.selectedBranchId,
                selectedBranch!.id ?? '',
              );
            }
          } else {
            selectedBranch = branches.first;
            Get.find<Repository>().saveSecureValue(
              LocalKeys.selectedBranchId,
              selectedBranch!.id ?? '',
            );
          }
        }
      }
    } catch (e) {
      print("Error fetching branches: $e");
    } finally {
      isBranchesLoading = false;
      update();
    }
  }

  void selectBranch(branch_model.Doc? branch) {
    if (branch != null) {
      selectedBranch = branch;
      Get.find<Repository>().saveSecureValue(
        LocalKeys.selectedBranchId,
        branch.id ?? '',
      );
      update();
    }
  }
}
