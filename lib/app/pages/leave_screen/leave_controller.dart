import 'dart:async';
import 'dart:convert';
import 'package:agro_app/app/utils/utility.dart';
import 'package:agro_app/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LeaveController extends GetxController {
  // ── Leaves list & pagination state ──────────────────────────────────────────
  List<LeaveDoc> leaves = [];
  bool isLoading = false;
  bool isFetchingMore = false;

  int currentPage = 1;
  int totalPages = 1;
  int limit = 10;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // ── Filter State ───────────────────────────────────────────────────────────
  DateTime? filterFromDate;
  DateTime? filterToDate;
  String? filterStatus;

  // ── User Selection for Admin ────────────────────────────────────────────────
  List<Doc> userList = [];
  String? selectedUserId;

  // ── Role State ────────────────────────────────────────────────────────────
  String roleName = '';
  String userId = '';

  // ── Form Controllers & State ───────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();
  final leaveDateCtrl = TextEditingController();
  final fromDateCtrl = TextEditingController();
  final toDateCtrl = TextEditingController();
  final totalDaysCtrl = TextEditingController();
  final totalHoursCtrl = TextEditingController();
  final reasonCtrl = TextEditingController();

  String selectedLeaveType = 'full'; // Default: full
  String selectedStatus = 'pending'; // Default: pending
  String editingLeaveId = '';
  Timer? _searchTimer;

  @override
  void onInit() {
    super.onInit();
    _loadUserContext().then((_) {
      fetchLeaves(isRefresh: true);
    });
  }

  @override
  void onClose() {
    _searchTimer?.cancel();
    leaveDateCtrl.dispose();
    fromDateCtrl.dispose();
    toDateCtrl.dispose();
    totalDaysCtrl.dispose();
    totalHoursCtrl.dispose();
    reasonCtrl.dispose();
    super.onClose();
  }

  // ── Load Role & User ID from Local Storage ─────────────────────────────────
  Future<void> _loadUserContext() async {
    // 1. Try reading from secure storage
    roleName = await Get.find<Repository>().getSecureValue(LocalKeys.roleName);

    // 2. Try reading from cached profile JSON
    if (roleName.isEmpty) {
      final profileJson = await Get.find<Repository>().getSecureValue(
        LocalKeys.profileData,
      );
      if (profileJson.isNotEmpty) {
        try {
          final decoded = json.decode(profileJson);
          final userData =
              decoded['Data']?['userData'] ?? decoded['userData'] ?? decoded;
          roleName =
              userData['roleid']?['rolename']?.toString() ??
              userData['rolename']?.toString() ??
              userData['role']?.toString() ??
              '';
        } catch (_) {}
      }
    }

    // 3. Fallback: fetch profile API directly
    if (roleName.isEmpty) {
      try {
        final profileRes = await Get.find<Repository>().getProfileApi(
          isLoading: false,
        );
        if (profileRes != null &&
            profileRes.data.userData.rolename.isNotEmpty) {
          roleName = profileRes.data.userData.rolename;
          Get.find<Repository>().saveSecureValue(
            LocalKeys.roleName,
            profileRes.data.userData.roleid.rolename ?? roleName,
          );
        }
      } catch (_) {}
    }

    userId = await Get.find<Repository>().getSecureValue(LocalKeys.userIds);
    if (userId.isEmpty) {
      userId = await Get.find<Repository>().getSecureValue(
        LocalKeys.distributorId,
      );
    }
    if (RoleUtils.isAdmin(roleName)) {
      fetchUserList();
    }
    update();
  }

  // ── Fetch Users for Admin Selection ───────────────────────────────────────
  Future<void> fetchUserList() async {
    try {
      final response = await Get.find<Repository>().getUsersListApi(
        page: 1,
        limit: 1000,
        isLoading: false,
      );
      final docs = response?.data.docs;
      if (docs != null && docs.isNotEmpty) {
        userList = docs;
        selectedUserId ??= userList.first.id;
        update();
      }
    } catch (e) {
      debugPrint('fetchUserList error: $e');
    }
  }

  // ── Fetch Leaves with Pagination & Filters ─────────────────────────────────
  Future<void> fetchLeaves({bool isRefresh = true}) async {
    if (isRefresh) {
      currentPage = 1;
      leaves.clear();
      isLoading = true;
    } else {
      if (currentPage >= totalPages) return;
      currentPage++;
      isFetchingMore = true;
    }
    update();

    try {
      final response = await Get.find<Repository>().getLeaveListApi(
        page: currentPage,
        limit: limit,
        search: searchQuery,
        fromDate: filterFromDate != null
            ? DateFormat('yyyy-MM-dd').format(filterFromDate!)
            : "",
        toDate: filterToDate != null
            ? DateFormat('yyyy-MM-dd').format(filterToDate!)
            : "",
        status: filterStatus ?? "",
        userid: "",
        leavetype: "",
        isLoading: isRefresh,
      );

      if (response != null &&
          response.isSuccess == true &&
          response.data != null) {
        final docs = response.data!.docs ?? [];
        if (isRefresh) {
          leaves = docs;
        } else {
          leaves.addAll(docs);
        }
        totalPages = response.data!.totalPages ?? 1;
      }
    } catch (e) {
      debugPrint('[LeaveController] fetchLeaves error: $e');
    }

    isLoading = false;
    isFetchingMore = false;
    update();
  }

  // ── Search with Debounce ───────────────────────────────────────────────────
  void onSearchChanged(String query) {
    _searchQuery = query;
    if (_searchTimer?.isActive ?? false) _searchTimer!.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      fetchLeaves(isRefresh: true);
    });
  }

  // ── Set & Clear Filters ────────────────────────────────────────────────────
  void setFilters({DateTime? fromDate, DateTime? toDate, String? status}) {
    filterFromDate = fromDate;
    filterToDate = toDate;
    filterStatus = status;
    fetchLeaves(isRefresh: true);
  }

  void clearFilters() {
    filterFromDate = null;
    filterToDate = null;
    filterStatus = null;
    fetchLeaves(isRefresh: true);
  }

  // ── Setup Form for Creation or Editing ─────────────────────────────────────
  void setupForm(dynamic doc) {
    if (RoleUtils.isAdmin(roleName) && userList.isEmpty) {
      fetchUserList();
    }
    if (doc == null) {
      editingLeaveId = '';
      leaveDateCtrl.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
      fromDateCtrl.clear();
      toDateCtrl.clear();
      totalDaysCtrl.clear();
      totalHoursCtrl.clear();
      reasonCtrl.clear();
      selectedLeaveType = 'full';
      selectedStatus = 'pending'; // User defaults to pending
      selectedUserId = RoleUtils.isAdmin(roleName)
          ? (userList.isNotEmpty ? userList.first.id : null)
          : userId;
    } else {
      if (doc is LeaveDoc) {
        editingLeaveId = doc.id ?? '';
        leaveDateCtrl.text = _formatDateString(doc.leavedate);
        fromDateCtrl.text = _formatDateString(doc.fromdate);
        toDateCtrl.text = _formatDateString(doc.todate);
        totalDaysCtrl.text = doc.totaldays?.toString() ?? '';
        totalHoursCtrl.text = doc.totalhours?.toString() ?? '';
        reasonCtrl.text = doc.reason ?? '';
        selectedLeaveType = doc.leavetype ?? 'full';
        selectedStatus = doc.status ?? 'pending';
        selectedUserId = doc.userid?.id ?? userId;
      } else if (doc is CreateLeaveModel) {
        final data = doc.data;
        editingLeaveId = data?.id ?? '';
        leaveDateCtrl.text = _formatDateString(data?.leavedate);
        fromDateCtrl.text = _formatDateString(data?.fromdate);
        toDateCtrl.text = _formatDateString(data?.todate);
        totalDaysCtrl.text = data?.totaldays?.toString() ?? '';
        totalHoursCtrl.text = data?.totalhours?.toString() ?? '';
        reasonCtrl.text = data?.reason ?? '';
        selectedLeaveType = data?.leavetype ?? 'full';
        selectedStatus = data?.status ?? 'pending';
        selectedUserId = data?.userid?.id ?? userId;
      }
    }
    update();
  }

  String _formatDateString(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final parsed = DateTime.parse(dateStr);
      return DateFormat('dd-MM-yyyy').format(parsed);
    } catch (_) {
      try {
        final parsed = DateFormat('yyyy-MM-dd').parse(dateStr);
        return DateFormat('dd-MM-yyyy').format(parsed);
      } catch (_) {
        return dateStr;
      }
    }
  }

  // ── Calculation of Duration ────────────────────────────────────────────────
  void calculateDuration() {
    if (fromDateCtrl.text.isEmpty || toDateCtrl.text.isEmpty) return;
    try {
      final from = DateFormat('dd-MM-yyyy').parse(fromDateCtrl.text);
      final to = DateFormat('dd-MM-yyyy').parse(toDateCtrl.text);
      if (to.isBefore(from)) {
        totalDaysCtrl.text = '';
        totalHoursCtrl.text = '';
        return;
      }
      final daysDiff = to.difference(from).inDays + 1;
      if (selectedLeaveType == 'half') {
        final double days = daysDiff * 0.5;
        totalDaysCtrl.text = days.toStringAsFixed(1);
        totalHoursCtrl.text = (daysDiff * 4).toString();
      } else {
        totalDaysCtrl.text = daysDiff.toString();
        totalHoursCtrl.text = (daysDiff * 8).toString();
      }
    } catch (_) {}
  }

  // ── Save Leave (Create / Update) ───────────────────────────────────────────
  Future<void> saveLeave() async {
    if (!formKey.currentState!.validate()) return;

    if (fromDateCtrl.text.isEmpty || toDateCtrl.text.isEmpty) {
      Utility.showMessage(
        'Please select From and To dates',
        MessageType.information,
        null,
        '',
      );
      return;
    }

    DateTime fromParsed;
    DateTime toParsed;
    DateTime leaveDateParsed;
    try {
      fromParsed = DateFormat('dd-MM-yyyy').parse(fromDateCtrl.text);
      toParsed = DateFormat('dd-MM-yyyy').parse(toDateCtrl.text);
      leaveDateParsed = DateFormat('dd-MM-yyyy').parse(leaveDateCtrl.text);
    } catch (e) {
      Utility.showMessage(
        'Invalid date format. Use DD-MM-YYYY',
        MessageType.error,
        null,
        '',
      );
      return;
    }

    if (toParsed.isBefore(fromParsed)) {
      Utility.showMessage(
        'To Date cannot be before From Date',
        MessageType.information,
        null,
        '',
      );
      return;
    }

    final double parsedDays = double.tryParse(totalDaysCtrl.text) ?? 0;
    final double parsedHours = double.tryParse(totalHoursCtrl.text) ?? 0;

    // For the User role, status is forced to pending and cannot be modified.
    final finalStatus = RoleUtils.isUser(roleName) ? 'pending' : selectedStatus;
    final targetUserId = RoleUtils.isAdmin(roleName)
        ? (selectedUserId ?? userId)
        : userId;

    Utility.showLoader();

    final result = await Get.find<Repository>().createLeaveApi(
      leaveid: editingLeaveId,
      userid: targetUserId,
      fromdate: DateFormat('yyyy-MM-dd').format(fromParsed),
      todate: DateFormat('yyyy-MM-dd').format(toParsed),
      totaldays: parsedDays,
      totalhours: parsedHours,
      leavetype: selectedLeaveType,
      reason: reasonCtrl.text.trim(),
      status: finalStatus,
      isLoading: false,
    );

    Utility.closeLoader();

    if (result != null && result.isSuccess == true) {
      Utility.showMessage(
        editingLeaveId.isNotEmpty
            ? 'Leave updated successfully'
            : 'Leave applied successfully',
        MessageType.information,
        null,
        '',
      );
      Get.back();
      fetchLeaves(isRefresh: true);
    }
  }

  // ── Delete Leave ───────────────────────────────────────────────────────────
  Future<void> deleteLeave(String leaveId) async {
    Utility.showLoader();
    final success = await Get.find<Repository>().deleteLeaveApi(
      leaveid: leaveId,
      isLoading: false,
    );
    Utility.closeLoader();

    if (success) {
      Utility.showMessage(
        'Leave request deleted',
        MessageType.information,
        null,
        '',
      );
      fetchLeaves(isRefresh: true);
    }
  }

  // ── Change Status (Admin Only) ─────────────────────────────────────────────
  Future<void> changeLeaveStatus(String leaveId, String newStatus) async {
    Utility.showLoader();
    final success = await Get.find<Repository>().changeLeaveStatusApi(
      leaveid: leaveId,
      status: newStatus,
      isLoading: false,
    );
    Utility.closeLoader();

    if (success) {
      Utility.showMessage(
        'Status updated to ${newStatus.toUpperCase()}',
        MessageType.success,
        null,
        '',
      );
      fetchLeaves(isRefresh: true);
    }
  }

  // ── Fetch Leave Details & Open Form (via getone API) ───────────────────────
  Future<void> fetchLeaveDetailsAndOpenForm(String id) async {
    try {
      final response = await Get.find<Repository>().getOneLeaveApi(
        leaveid: id,
        isLoading: true,
      );
      if (response != null &&
          response.isSuccess == true &&
          response.data != null) {
        setupForm(response.data);
        Get.toNamed<void>('/leaveForm');
      }
    } catch (e) {
      debugPrint('[LeaveController] fetchLeaveDetailsAndOpenForm error: $e');
    }
  }
}
