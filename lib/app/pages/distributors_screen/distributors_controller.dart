import 'package:agro_app/domain/models/get_all_roll_model.dart';
import 'package:agro_app/domain/models/get_all_users_model.dart';
import 'package:agro_app/domain/repositories/repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DistributorsController extends GetxController {
  List<Doc> users = [];
  bool isLoading = false;
  bool isFetchingMore = false;

  int currentPage = 1;
  int totalPages = 1;
  int limit = 10;
  final RxString _searchQuery = "".obs;
  String get searchQuery => _searchQuery.value;

  final addFormKey = GlobalKey<FormState>();

  // ── Basic fields ──────────────────────────────────────────────────────────
  final nameCtrl = TextEditingController();
  final surnameCtrl = TextEditingController();
  final fathernameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  // ── Distributor-specific fields ───────────────────────────────────────────
  final gstnumberCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final banknameCtrl = TextEditingController();
  final bankaccountnumberCtrl = TextEditingController();
  final bankifscodeCtrl = TextEditingController();

  final RxString editingUserId = "".obs;
  String? selectedRoleId;
  List<GetAllRolesDatum> roles = [];

  // Distributor role ID — fixed filter for this screen
  static const String _distributorRoleId =
      'cf4527b2-86df-4470-a14d-37288a536e37';

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
    surnameCtrl.dispose();
    fathernameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passwordCtrl.dispose();
    addressCtrl.dispose();
    gstnumberCtrl.dispose();
    locationCtrl.dispose();
    banknameCtrl.dispose();
    bankaccountnumberCtrl.dispose();
    bankifscodeCtrl.dispose();
    super.onClose();
  }

  void searchUsers(String query) {
    _searchQuery.value = query;
  }

  Future<void> fetchRoles() async {
    var response = await Get.find<Repository>().getAllRolesApi();
    if (response != null && response.isSuccess) {
      // Deduplicate by ID to avoid DropdownButton assertion errors
      final seen = <String>{};
      roles = response.data.where((r) => seen.add(r.id)).toList();
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
      roleid: _distributorRoleId,
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
    surnameCtrl.clear();
    fathernameCtrl.clear();
    emailCtrl.clear();
    phoneCtrl.clear();
    passwordCtrl.clear();
    addressCtrl.clear();
    gstnumberCtrl.clear();
    locationCtrl.clear();
    banknameCtrl.clear();
    bankaccountnumberCtrl.clear();
    bankifscodeCtrl.clear();
    selectedRoleId = _distributorRoleId;
    update();
  }

  void setupEdit(Doc user) {
    editingUserId.value = user.id;
    nameCtrl.text = user.name;
    surnameCtrl.text = user.surname ?? '';
    fathernameCtrl.text = user.fathername ?? '';
    emailCtrl.text = user.email;
    phoneCtrl.text = user.mobile;
    passwordCtrl.clear();
    addressCtrl.text = user.address ?? '';
    // Extra fields from model (nullable – safe default to empty)
    gstnumberCtrl.clear();
    locationCtrl.clear();
    banknameCtrl.clear();
    bankaccountnumberCtrl.clear();
    bankifscodeCtrl.clear();
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
      roleid: 'cf4527b2-86df-4470-a14d-37288a536e37', // selectedRoleId!,
      surname: surnameCtrl.text.trim(),
      fathername: fathernameCtrl.text.trim(),
      gstnumber: gstnumberCtrl.text.trim(),
      location: locationCtrl.text.trim(),
      bankname: banknameCtrl.text.trim(),
      bankaccountnumber: bankaccountnumberCtrl.text.trim(),
      bankifsscode: bankifscodeCtrl.text.trim(),
      isLoading: true,
    );

    if (errorMsg == null) {
      Get.back();
      Get.snackbar(
        'Success',
        editingUserId.value.isNotEmpty
            ? 'Distributor updated'
            : 'Distributor added',
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
}
