import 'dart:convert';

import 'package:agro_app/app/navigators/routes_management.dart';
import 'package:agro_app/domain/domain.dart';
import 'package:agro_app/domain/models/get_all_branches_model.dart'
    as branch_model;
import 'package:get/get.dart';

class HomeController extends GetxController {
  String roleName = '';
  List<branch_model.Doc> branches = [];
  branch_model.Doc? selectedBranch;
  bool isBranchesLoading = false;

  @override
  void onInit() {
    super.onInit();
    _loadRoleFromLocal();
    fetchBranches();
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
    if (response != null) {
      final userData = response.data.userData;
      roleName = userData.rolename;

      Get.find<Repository>().saveSecureValue(
        LocalKeys.distributorId,
        userData.id,
      );
      Get.find<Repository>().saveSecureValue(
        LocalKeys.roleName,
        userData.roleid.rolename ?? "",
      );
      Get.find<Repository>().saveSecureValue(
        LocalKeys.profileData,
        json.encode(userData.toJson()),
      );

      // Pre-populate branchId so it's available for the first API calls
      if (userData.branchid != null && userData.branchid!.id.isNotEmpty) {
        Get.find<Repository>().saveSecureValue(
          LocalKeys.selectedBranchId,
          userData.branchid!.id,
        );
      }
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
