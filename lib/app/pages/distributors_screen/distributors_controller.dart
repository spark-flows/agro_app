import 'dart:convert';
import 'package:agro_app/domain/models/get_all_roll_model.dart';
import 'package:agro_app/domain/models/get_all_users_model.dart';
import 'package:agro_app/domain/models/get_one_user_model.dart';
import 'package:agro_app/domain/repositories/repository.dart';
import 'package:agro_app/domain/repositories/local_storage_keys.dart';
import 'package:agro_app/app/utils/utility.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:agro_app/app/pages/attendance_screen/attendance_controller.dart';

import 'package:agro_app/domain/services/enum.dart';
import 'package:agro_app/app/pages/home_screen/home_controller.dart';

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
  final RxBool liveTracking = false.obs;
  final RxBool odometer = false.obs;
  final RxnString selectedRoleId = RxnString();
  List<GetAllRolesDatum> roles = [];

  // Admin view & assigned users selection
  final RxBool isAdminView = true.obs;
  final RxList<Doc> selectableUsers = <Doc>[].obs;
  final RxBool isUsersLoading = false.obs;
  final RxList<String> selectedPermissionUserIds = <String>[].obs;

  // Shift action reactive loading states
  final RxBool isClockInLoading = false.obs;
  final RxBool isClockOutLoading = false.obs;

  // Distributor role ID — fixed filter for this screen
  static const String _distributorRoleId =
      'cf4527b2-86df-4470-a14d-37288a536e37';

  // To debounce search calls
  Worker? _searchWorker;

  bool loggedUserLiveTracking = true;
  bool loggedUserOdometer = false;

  Future<void> checkLoggedUserLiveTracking() async {
    try {
      final localData = await Get.find<Repository>().getSecureValue(
        LocalKeys.profileData,
      );
      if (localData.isNotEmpty) {
        final decoded = json.decode(localData);
        loggedUserLiveTracking = decoded['liveTracking'] as bool? ?? false;
        loggedUserOdometer = decoded['odometer'] as bool? ?? false;
      } else {
        final profile = await Get.find<Repository>().getProfileApi(
          isLoading: false,
        );
        if (profile?.data?.userData != null) {
          loggedUserLiveTracking =
              profile?.data?.userData?.liveTracking ?? false;
          loggedUserOdometer = profile?.data?.userData?.odometer ?? false;
        }
      }
    } catch (_) {
      loggedUserLiveTracking = true;
      loggedUserOdometer = false;
    }
    update();
  }

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
    fetchRoles();
    checkLoggedUserLiveTracking();
    checkAdminRole();

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

  Future<void> checkAdminRole() async {
    try {
      String role = '';
      if (Get.isRegistered<HomeController>()) {
        role = Get.find<HomeController>().roleName;
      }
      if (role.isEmpty) {
        role = await Get.find<Repository>().getSecureValue(LocalKeys.roleName);
      }
      if (role.isEmpty) {
        final localData = await Get.find<Repository>().getSecureValue(
          LocalKeys.profileData,
        );
        if (localData.isNotEmpty) {
          final decoded = json.decode(localData);
          role = (decoded['rolename'] ?? decoded['roleName'] ?? '').toString();
        }
      }
      if (role.isEmpty) {
        final profile = await Get.find<Repository>().getProfileApi(
          isLoading: false,
        );
        role = profile?.data?.userData?.rolename ?? '';
      }

      if (role.isNotEmpty) {
        isAdminView.value =
            RoleUtils.isAdmin(role) || role.toLowerCase().contains('admin');
      } else {
        isAdminView.value = true;
      }
    } catch (e) {
      debugPrint('[DistributorsController] checkAdminRole error: $e');
      isAdminView.value = true;
    }

    fetchSelectableUsers();
    update();
  }

  Future<void> fetchSelectableUsers() async {
    isUsersLoading.value = true;
    update();
    try {
      final response = await Get.find<Repository>().getUsersListApi(
        page: 1,
        limit: 1000,
        type: 'user',
        isLoading: false,
      );
      if (response != null && response.isSuccess) {
        selectableUsers.assignAll(
          response.data.docs.where((u) => u.status != false).toList(),
        );
      }
    } catch (e) {
      debugPrint('[DistributorsController] fetchSelectableUsers error: $e');
    } finally {
      isUsersLoading.value = false;
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
      _applySavedClockStates();
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
    selectedRoleId.value = _distributorRoleId;
    isPasswordHidden.value = true;
    liveTracking.value = false;
    odometer.value = false;
    selectedPermissionUserIds.clear();
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
    selectedRoleId.value = user.roleid.id;
    isPasswordHidden.value = true;
    selectedPermissionUserIds.clear();
    if (user.permissionuserid != null && user.permissionuserid!.isNotEmpty) {
      selectedPermissionUserIds.assignAll(user.permissionuserid!);
    }
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
        selectedRoleId.value = data.roleid?.id;
        liveTracking.value = data.liveTracking ?? false;
        odometer.value = data.odometer ?? false;
        if (data.permissionuserid != null &&
            data.permissionuserid!.isNotEmpty) {
          selectedPermissionUserIds.assignAll(data.permissionuserid!);
        }
        update();
      }
    } catch (e) {
      print("Error fetching distributor details: $e");
    } finally {
      Utility.closeLoader();
    }
  }

  bool isSaving = false;

  Future<void> saveUser() async {
    if (isSaving) return;
    isSaving = true;

    try {
      if (nameCtrl.text.trim().isEmpty) {
        Utility.errorMessage('Please enter First Name');
        return;
      }
      if (emailCtrl.text.trim().isEmpty) {
        Utility.errorMessage('Please enter Email Address');
        return;
      }
      if (!Utility.emailValidation(emailCtrl.text.trim())) {
        Utility.errorMessage('Please enter a valid Email Address');
        return;
      }
      if (phoneCtrl.text.trim().isEmpty) {
        Utility.errorMessage('Please enter Phone Number');
        return;
      }
      if (phoneCtrl.text.trim().length != 10) {
        Utility.errorMessage('Phone number must be exactly 10 digits');
        return;
      }
      if (editingUserId.value.isEmpty && passwordCtrl.text.trim().isEmpty) {
        Utility.errorMessage('Please enter Password');
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
        roleid:
            'cf4527b2-86df-4470-a14d-37288a536e37', // selectedRoleId.value!,
        surname: surnameCtrl.text.trim(),
        fathername: fathernameCtrl.text.trim(),
        gstnumber: gstnumberCtrl.text.trim(),
        location: locationCtrl.text.trim(),
        bankname: banknameCtrl.text.trim(),
        bankaccountnumber: bankaccountnumberCtrl.text.trim(),
        bankifsscode: bankifscodeCtrl.text.trim(),
        liveTracking: liveTracking.value,
        odometer: odometer.value,
        assigntoid: isAdminView.value
            ? selectedPermissionUserIds.toList()
            : null,
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
    } finally {
      isSaving = false;
    }
  }

  // ── Distributor shift actions (Separate from Attendance) ───────────────────
  Future<void> clockInDistributor(Doc user) async {
    if (isClockInLoading.value) return;
    isClockInLoading.value = true;
    bool success = false;
    String timein = DateTime.now().toUtc().toIso8601String();

    try {
      if (loggedUserLiveTracking && loggedUserOdometer) {
        bool isClockedIn = false;
        try {
          if (Get.isRegistered<AttendanceController>()) {
            final attendanceController = Get.find<AttendanceController>();
            final record = attendanceController.getTodayRecord();
            isClockedIn = attendanceController.isClockedInToday(record);
          } else {
            final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
            final savedDate = Get.find<Repository>().getStringValue(
              'attendance_date',
            );
            if (savedDate == todayStr) {
              final savedStatus = Get.find<Repository>().getStringValue(
                'attendance_status',
              );
              isClockedIn =
                  (savedStatus == 'clocked_in' || savedStatus == 'paused');
            }
          }
        } catch (e) {
          debugPrint(
            '[DistributorsController] Error checking attendance clock-in: $e',
          );
        }

        if (!isClockedIn) {
          isClockInLoading.value = false;
          Utility.errorMessage(
            'First you need to Clock In in the Attendance Screen.',
          );
          return;
        }
      }

      final hasPermission = await Utility.handleLocationPermission();
      if (!hasPermission) return;

      double lat = 0.0;
      double lon = 0.0;
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        );
        lat = position.latitude;
        lon = position.longitude;
      } catch (e) {
        debugPrint(
          '[DistributorsController] geolocator high accuracy error: $e',
        );
        try {
          final lastPosition = await Geolocator.getLastKnownPosition();
          if (lastPosition != null) {
            lat = lastPosition.latitude;
            lon = lastPosition.longitude;
          } else {
            final position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.medium,
              timeLimit: const Duration(seconds: 5),
            );
            lat = position.latitude;
            lon = position.longitude;
          }
        } catch (ex) {
          debugPrint('[DistributorsController] geolocator fallback error: $ex');
        }
      }

      String userId = await Get.find<Repository>().getSecureValue(
        LocalKeys.userIds,
      );
      if (userId.trim().isEmpty) {
        userId = await Get.find<Repository>().getSecureValue(
          LocalKeys.distributorId,
        );
      }
      if (userId.trim().isEmpty) {
        try {
          final profileJson = await Get.find<Repository>().getSecureValue(
            LocalKeys.profileData,
          );
          if (profileJson.isNotEmpty) {
            final decoded = json.decode(profileJson);
            final userData =
                decoded['userData'] ?? decoded['UserData'] ?? decoded;
            userId =
                (userData['_id'] ?? userData['id'] ?? '')?.toString() ?? '';
          }
        } catch (_) {}
      }

      final Map<String, dynamic> body = {
        "userId": userId,
        "dealerId": user.id,
        "latitude": lat,
        "longitude": lon,
        "timein": timein,
      };

      debugPrint('[DistributorsController] clockInDistributor payload: $body');

      success = await Get.find<Repository>().pauseTrackingApi(
        body: body,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('[DistributorsController] clockInDistributor error: $e');
    } finally {
      isClockInLoading.value = false;
    }

    if (success) {
      user.isClockedIn = true;
      user.isClockedOut = false;
      user.clockInTime = timein;
      _saveClockState(
        user.id,
        isClockedIn: true,
        isClockedOut: false,
        clockInTime: timein,
      );
      update();
      Utility.snacBar('Clocked in successfully', Colors.green);
    } else {
      Utility.errorMessage('Clock In failed. Please try again.');
    }
  }

  Future<void> clockOutDistributor(Doc user) async {
    if (isClockOutLoading.value) return;
    isClockOutLoading.value = true;
    bool success = false;
    String timeout = DateTime.now().toUtc().toIso8601String();

    try {
      final hasPermission = await Utility.handleLocationPermission();
      if (!hasPermission) return;

      double lat = 0.0;
      double lon = 0.0;
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        );
        lat = position.latitude;
        lon = position.longitude;
      } catch (e) {
        debugPrint(
          '[DistributorsController] geolocator high accuracy error: $e',
        );
        try {
          final lastPosition = await Geolocator.getLastKnownPosition();
          if (lastPosition != null) {
            lat = lastPosition.latitude;
            lon = lastPosition.longitude;
          }
        } catch (_) {}
      }

      String userId = await Get.find<Repository>().getSecureValue(
        LocalKeys.userIds,
      );
      if (userId.trim().isEmpty) {
        userId = await Get.find<Repository>().getSecureValue(
          LocalKeys.distributorId,
        );
      }
      if (userId.trim().isEmpty) {
        try {
          final profileJson = await Get.find<Repository>().getSecureValue(
            LocalKeys.profileData,
          );
          if (profileJson.isNotEmpty) {
            final decoded = json.decode(profileJson);
            final userData =
                decoded['userData'] ?? decoded['UserData'] ?? decoded;
            userId =
                (userData['_id'] ?? userData['id'] ?? '')?.toString() ?? '';
          }
        } catch (_) {}
      }

      final Map<String, dynamic> body = {
        "userId": userId,
        "dealerId": user.id,
        "latitude": lat,
        "longitude": lon,
        "timeout": timeout,
      };

      debugPrint('[DistributorsController] clockOutDistributor payload: $body');

      success = await Get.find<Repository>().pauseTrackingApi(
        body: body,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('[DistributorsController] clockOutDistributor error: $e');
    } finally {
      isClockOutLoading.value = false;
    }

    if (success) {
      user.isClockedOut = true;
      user.isClockedIn = false;
      user.clockOutTime = timeout;
      _saveClockState(
        user.id,
        isClockedIn: false,
        isClockedOut: true,
        clockOutTime: timeout,
      );
      update();
      Utility.snacBar('Clocked out successfully', Colors.green);
    } else {
      Utility.errorMessage('Clock Out failed. Please try again.');
    }
  }

  static const String _clockStateKey = "distributor_clock_states";

  Map<String, dynamic> _getSavedClockStates() {
    try {
      final jsonStr = Get.find<Repository>().getStringValue(_clockStateKey);
      if (jsonStr.isNotEmpty) {
        return json.decode(jsonStr) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('[DistributorsController] _getSavedClockStates error: $e');
    }
    return {};
  }

  void _saveClockState(
    String dealerId, {
    required bool isClockedIn,
    required bool isClockedOut,
    String? clockInTime,
    String? clockOutTime,
  }) {
    try {
      final states = _getSavedClockStates();
      states[dealerId] = {
        "isClockedIn": isClockedIn,
        "isClockedOut": isClockedOut,
        "clockInTime": clockInTime,
        "clockOutTime": clockOutTime,
      };
      Get.find<Repository>().saveValue(_clockStateKey, json.encode(states));
    } catch (e) {
      debugPrint('[DistributorsController] _saveClockState error: $e');
    }
  }

  void _applySavedClockStates() {
    final states = _getSavedClockStates();
    if (states.isEmpty) return;

    for (var user in users) {
      if (states.containsKey(user.id)) {
        final state = states[user.id] as Map<String, dynamic>;
        user.isClockedIn = state["isClockedIn"] == true;
        user.isClockedOut = state["isClockedOut"] == true;
        user.clockInTime = state["clockInTime"]?.toString();
        user.clockOutTime = state["clockOutTime"]?.toString();
      }
    }
  }
}
