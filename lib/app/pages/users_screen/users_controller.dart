import 'package:agro_app/domain/models/get_all_roll_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agro_app/domain/models/get_all_users_model.dart';
import 'package:agro_app/domain/models/get_one_user_model.dart';
import 'package:agro_app/domain/repositories/repository.dart';
import 'package:agro_app/app/utils/utility.dart';

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
  final salaryCtrl = TextEditingController();
  final allowanceCtrl = TextEditingController();
  final RxBool liveTracking = false.obs;
  final RxBool odometer = false.obs;

  final RxString editingUserId = "".obs;
  final RxBool isPasswordHidden = true.obs;
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
    salaryCtrl.dispose();
    allowanceCtrl.dispose();
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
      type: 'user',
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
    salaryCtrl.clear();
    allowanceCtrl.clear();
    liveTracking.value = false;
    odometer.value = false;
    selectedRoleId = "b8fbadff-5201-4fce-9038-0873bc3a93c1";
    isPasswordHidden.value = true;
    update();
  }

  Future<void> setupEdit(Doc user) async {
    editingUserId.value = user.id;
    nameCtrl.text = user.name;
    emailCtrl.text = user.email;
    phoneCtrl.text = user.mobile;
    passwordCtrl.text = ''; // Clear password locally initially
    addressCtrl.text = user.address ?? '';
    selectedRoleId = user.roleid.id;
    isPasswordHidden.value = true;
    salaryCtrl.clear();
    allowanceCtrl.clear();
    liveTracking.value = false;
    odometer.value = false;
    update();

    Utility.showLoader();
    try {
      final GetOneUserModel? userModel = await Get.find<Repository>()
          .getOneUserApi(userid: user.id, isLoading: false);
      if (userModel != null && userModel.data != null) {
        final data = userModel.data!;
        nameCtrl.text = data.name ?? '';
        emailCtrl.text = data.email ?? '';
        phoneCtrl.text = data.mobile ?? '';
        passwordCtrl.text = data.password ?? '';
        addressCtrl.text = data.location ?? '';
        selectedRoleId = data.roleid?.id;
        salaryCtrl.text = data.salary?.toString() ?? '';
        allowanceCtrl.text = data.allowance?.toString() ?? '';
        liveTracking.value = data.liveTracking ?? false;
        odometer.value = data.odometer ?? false;
        update();
      }
    } catch (e) {
      print("Error fetching user details: $e");
    } finally {
      Utility.closeLoader();
    }
  }

  Future<void> saveUser() async {
    if (selectedRoleId == null) {
      Utility.errorMessage('Please select a role');
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
      salary: salaryCtrl.text.trim().isEmpty ? 0 : int.tryParse(salaryCtrl.text.trim()) ?? 0,
      allowance: allowanceCtrl.text.trim().isEmpty ? 0 : int.tryParse(allowanceCtrl.text.trim()) ?? 0,
      liveTracking: liveTracking.value,
      odometer: odometer.value,
      isLoading: true,
    );

    if (errorMsg == null) {
      Get.back();
      Utility.snacBar(
        editingUserId.value.isNotEmpty ? 'User updated' : 'User added',
        Colors.green,
      );
      fetchUsers(isRefresh: true);
    } else {
      Utility.errorMessage(errorMsg);
    }
  }

  Future<void> deleteUser(String id) async {
    final success = await Get.find<Repository>().deleteUsersApi(
      userid: id,
      isLoading: true,
    );
    if (success) {
      Utility.snacBar('User deleted successfully', Colors.green);
      fetchUsers(isRefresh: true);
    } else {
      Utility.errorMessage('Failed to delete user');
    }
  }
}
