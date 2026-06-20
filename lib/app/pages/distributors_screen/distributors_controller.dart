import 'package:agro_app/domain/models/get_all_roll_model.dart';
import 'package:agro_app/domain/models/get_all_users_model.dart';
import 'package:agro_app/domain/models/get_one_user_model.dart';
import 'package:agro_app/domain/repositories/repository.dart';
import 'package:agro_app/app/utils/utility.dart';
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
  final RxBool isPasswordHidden = true.obs;
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
      type: 'dealer',
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
    isPasswordHidden.value = true;
    update();
  }

  Future<void> setupEdit(Doc user) async {
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
    isPasswordHidden.value = true;
    update();

    Utility.showLoader();
    try {
      final GetOneUserModel? userModel = await Get.find<Repository>()
          .getOneUserApi(userid: user.id, isLoading: false);
      if (userModel != null && userModel.data != null) {
        final data = userModel.data!;
        nameCtrl.text = data.name ?? '';
        surnameCtrl.text = data.surname ?? '';
        fathernameCtrl.text = data.fathername ?? '';
        emailCtrl.text = data.email ?? '';
        phoneCtrl.text = data.mobile ?? '';
        passwordCtrl.text = data.password ?? '';
        addressCtrl.text = data.location ?? '';
        gstnumberCtrl.text = data.gstnumber ?? '';
        locationCtrl.text = data.location ?? '';
        banknameCtrl.text = data.bankname ?? '';
        bankaccountnumberCtrl.text = data.bankaccountnumber ?? '';
        bankifscodeCtrl.text = data.bankifsscode ?? '';
        selectedRoleId = data.roleid?.id;
        update();
      }
    } catch (e) {
      print("Error fetching distributor details: $e");
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
      Utility.snacBar(
        editingUserId.value.isNotEmpty
            ? 'Distributor updated'
            : 'Distributor added',
        Colors.green,
      );
      fetchUsers(isRefresh: true);
    } else {
      Utility.errorMessage(errorMsg);
    }
  }
}
