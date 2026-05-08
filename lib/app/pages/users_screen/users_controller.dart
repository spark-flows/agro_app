import 'package:agro_app/domain/models/get_all_roll_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agro_app/domain/models/get_all_users_model.dart';
import 'package:agro_app/domain/repositories/repository.dart';

class UsersController extends GetxController {
  List<Doc> users = [];
  bool isLoading = false;
  bool isFetchingMore = false;

  int currentPage = 1;
  int totalPages = 1;
  int limit = 10;
  final RxString _searchQuery = "".obs;
  String get searchQuery => _searchQuery.value;

  final addFormKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  final RxString editingUserId = "".obs;
  String? selectedRoleId;
  List<GetAllRolesDatum> roles = [];

  // To debounce search calls
  Worker? _searchWorker;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
    fetchRoles();

    // Initialize search worker
    _searchWorker = debounce(
      _searchQuery,
      (_) => fetchUsers(isRefresh: true),
      time: const Duration(milliseconds: 500),
    );
  }

  @override
  void onClose() {
    _searchWorker?.dispose();
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passwordCtrl.dispose();
    addressCtrl.dispose();
    super.onClose();
  }

  void searchUsers(String query) {
    _searchQuery.value = query;
  }

  Future<void> fetchRoles() async {
    var response = await Get.find<Repository>().getAllRolesApi();
    if (response != null && response.isSuccess) {
      roles = response.data;
      update();
    }
  }

  Future<void> fetchUsers({bool isRefresh = true}) async {
    if (isRefresh) {
      currentPage = 1;
      users.clear();
      isLoading = true;
    } else {
      if (currentPage >= totalPages) return;
      currentPage++;
      isFetchingMore = true;
    }
    update();

    var response = await Get.find<Repository>().getUsersListApi(
      page: currentPage,
      limit: limit,
      search: searchQuery,
      isLoading: isRefresh,
    );

    if (response != null && response.isSuccess) {
      if (isRefresh) {
        users = response.data.docs;
      } else {
        users.addAll(response.data.docs);
      }
      totalPages = response.data.totalPages;
    }

    isLoading = false;
    isFetchingMore = false;
    update();
  }

  void clearAddForm() {
    editingUserId.value = "";
    nameCtrl.clear();
    emailCtrl.clear();
    phoneCtrl.clear();
    passwordCtrl.clear();
    addressCtrl.clear();
    selectedRoleId = null;
    update();
  }

  void setupEdit(Doc user) {
    editingUserId.value = user.id;
    nameCtrl.text = user.name;
    emailCtrl.text = user.email;
    phoneCtrl.text = user.mobile;
    passwordCtrl.clear(); // Usually leave empty on edit unless changing
    addressCtrl.text = user.address ?? '';
    selectedRoleId = user.roleid.id;
    update();
  }

  Future<void> saveUser() async {
    if (selectedRoleId == null) {
      Get.snackbar(
        'Error',
        'Please select a role',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final errorMsg = await Get.find<Repository>().createUserApi(
      userid: editingUserId.value.isNotEmpty ? editingUserId.value : null,
      name: nameCtrl.text.trim(),
      email: emailCtrl.text.trim(),
      countrycode: "+91",
      mobile: phoneCtrl.text.trim(),
      password: passwordCtrl.text.trim(),
      address: addressCtrl.text.trim(),
      roleid: selectedRoleId!,
      isLoading: true,
    );

    if (errorMsg == null) {
      Get.back();
      Get.snackbar(
        'Success',
        editingUserId.value.isNotEmpty ? 'User updated' : 'User added',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      fetchUsers(isRefresh: true);
    } else {
      Get.snackbar(
        'Error',
        errorMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  Future<void> deleteUser(String id) async {
    final success = await Get.find<Repository>().deleteUsersApi(
      userid: id,
      isLoading: true,
    );
    if (success) {
      Get.snackbar(
        'Success',
        'User deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      fetchUsers(isRefresh: true);
    } else {
      Get.snackbar(
        'Error',
        'Failed to delete user',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
