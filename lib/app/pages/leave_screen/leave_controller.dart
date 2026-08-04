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
  ProfileDataUserData? profileData;

  // ── Form Controllers & State ───────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();
  final fromDateCtrl = TextEditingController();
  final toDateCtrl = TextEditingController();
  final totalDaysCtrl = TextEditingController();
  final totalHoursCtrl = TextEditingController();
  final reasonCtrl = TextEditingController();

  String selectedLeaveType = 'full'; // Default: full
  String selectedStatus = 'pending'; // Default: pending
  String selectedSession = 'session1'; // Default: session1
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
    fromDateCtrl.dispose();
    toDateCtrl.dispose();
    totalDaysCtrl.dispose();
    totalHoursCtrl.dispose();
    reasonCtrl.dispose();
    super.onClose();
  }

  // ── Load Role & User ID from Local Storage ─────────────────────────────────
  Future<void> _loadUserContext() async {
    // Try reading cached profile JSON
    final profileJson = await Get.find<Repository>().getSecureValue(
      LocalKeys.profileData,
    );
    if (profileJson.isNotEmpty) {
      try {
        final decoded = json.decode(profileJson);
        final userDataJson =
            decoded['Data']?['userData'] ?? decoded['userData'] ?? decoded;
        profileData = ProfileDataUserData.fromJson(userDataJson);
      } catch (_) {}
    }

    // 1. Try reading role from secure storage
    roleName = await Get.find<Repository>().getSecureValue(LocalKeys.roleName);

    // 2. Try reading role from cached profile JSON
    if (roleName.isEmpty && profileData != null) {
      roleName = profileData!.rolename;
    }

    // 3. Fetch profile API directly to get latest timings/role
    try {
      final profileRes = await Get.find<Repository>().getProfileApi(
        isLoading: false,
      );
      if (profileRes != null && profileRes.data != null) {
        profileData = profileRes.data.userData;
        roleName = profileRes.data.userData.rolename.isNotEmpty
            ? profileRes.data.userData.rolename
            : roleName;
        Get.find<Repository>().saveSecureValue(
          LocalKeys.roleName,
          profileRes.data.userData.roleid.rolename ?? roleName,
        );
        Get.find<Repository>().saveSecureValue(
          LocalKeys.profileData,
          json.encode(profileRes.data.userData.toJson()),
        );
      }
    } catch (_) {}

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
        userList = docs.where((u) => RoleUtils.isUser(u.roleid.rolename)).toList();
        selectedUserId ??= userList.isNotEmpty ? userList.first.id : null;
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

  String formatHoursToDisplay(dynamic hoursVal) {
    if (hoursVal == null) return '';
    final double? hours = double.tryParse(hoursVal.toString());
    if (hours == null) return '';
    final hoursInt = hours.toInt();
    final minutes = ((hours - hoursInt) * 60).round();
    if (minutes == 0) {
      return hoursInt.toString();
    }
    return '$hoursInt.${minutes.toString().padLeft(2, '0')}';
  }

  double parseHoursFromDisplay(String text) {
    final clean = text.trim();
    if (clean.isEmpty) return 0.0;
    final parts = clean.split('.');
    if (parts.length == 2) {
      final hoursPart = int.tryParse(parts[0]) ?? 0;
      final minsStr = parts[1].padRight(2, '0').substring(0, 2);
      final minutesPart = int.tryParse(minsStr) ?? 0;
      return hoursPart + (minutesPart / 60.0);
    }
    return double.tryParse(clean) ?? 0.0;
  }

  // ── Setup Form for Creation or Editing ─────────────────────────────────────
  void setupForm(dynamic doc) {
    if (RoleUtils.isAdmin(roleName) && userList.isEmpty) {
      fetchUserList();
    }
    if (doc == null) {
      editingLeaveId = '';
      fromDateCtrl.clear();
      toDateCtrl.clear();
      totalDaysCtrl.clear();
      totalHoursCtrl.clear();
      reasonCtrl.clear();
      selectedLeaveType = 'full';
      selectedStatus = 'pending'; // User defaults to pending
      selectedSession = 'session1';
      selectedUserId = RoleUtils.isAdmin(roleName)
          ? (userList.isNotEmpty ? userList.first.id : null)
          : userId;
    } else {
      if (doc is LeaveDoc) {
        editingLeaveId = doc.id ?? '';
        fromDateCtrl.text = _formatDateString(doc.fromdate);
        toDateCtrl.text = _formatDateString(doc.todate);
        totalDaysCtrl.text = doc.totaldays?.toString() ?? '';
        totalHoursCtrl.text = formatHoursToDisplay(doc.totalhours);
        reasonCtrl.text = doc.reason ?? '';
        selectedLeaveType = doc.leavetype ?? 'full';
        selectedStatus = doc.status ?? 'pending';
        selectedSession = doc.session ?? 'session1';
        selectedUserId = doc.userid?.id ?? userId;
      } else if (doc is CreateLeaveModel) {
        final data = doc.data;
        editingLeaveId = data?.id ?? '';
        fromDateCtrl.text = _formatDateString(data?.fromdate);
        toDateCtrl.text = _formatDateString(data?.todate);
        totalDaysCtrl.text = data?.totaldays?.toString() ?? '';
        totalHoursCtrl.text = formatHoursToDisplay(data?.totalhours);
        reasonCtrl.text = data?.reason ?? '';
        selectedLeaveType = data?.leavetype ?? 'full';
        selectedStatus = data?.status ?? 'pending';
        selectedSession = data?.session ?? 'session1';
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
  double calculateWorkHoursPerDay({
    String? starttime,
    String? endtime,
    String? breakstart,
    String? breakend,
  }) {
    if (starttime == null ||
        starttime.isEmpty ||
        endtime == null ||
        endtime.isEmpty) {
      return 8.0;
    }

    DateTime? parseTimeString(String timeStr) {
      final formats = [
        DateFormat('hh:mm a'),
        DateFormat('HH:mm:ss'),
        DateFormat('HH:mm'),
        DateFormat('h:mm a'),
      ];
      for (var format in formats) {
        try {
          return format.parse(timeStr.trim());
        } catch (_) {}
      }
      final parts = timeStr.trim().split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]);
        var minute = 0;
        var isPm = false;
        if (parts[1].toLowerCase().contains('pm')) {
          isPm = true;
        }
        final minPart = parts[1].replaceAll(RegExp(r'[^0-9]'), '');
        minute = int.tryParse(minPart) ?? 0;
        if (hour != null) {
          var h = hour;
          if (isPm && h < 12) h += 12;
          if (!isPm && h == 12) h = 0;
          return DateTime(2000, 1, 1, h, minute);
        }
      }
      return null;
    }

    final start = parseTimeString(starttime);
    final end = parseTimeString(endtime);

    if (start == null || end == null) {
      return 8.0;
    }

    var diffMinutes = end.difference(start).inMinutes;
    if (diffMinutes < 0) {
      diffMinutes += 24 * 60;
    }

    var breakMinutes = 0;
    if (breakstart != null &&
        breakstart.isNotEmpty &&
        breakend != null &&
        breakend.isNotEmpty) {
      final bStart = parseTimeString(breakstart);
      final bEnd = parseTimeString(breakend);
      if (bStart != null && bEnd != null) {
        var bDiff = bEnd.difference(bStart).inMinutes;
        if (bDiff < 0) {
          bDiff += 24 * 60;
        }
        breakMinutes = bDiff;
      }
    }

    final netMinutes = diffMinutes - breakMinutes;
    if (netMinutes <= 0) {
      return 8.0;
    }

    return netMinutes / 60.0;
  }

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

      // Determine timings based on selected user (if admin) or self
      String? start;
      String? end;
      String? bStart;
      String? bEnd;

      if (RoleUtils.isAdmin(roleName) && selectedUserId != null) {
        final selectedUserList = userList
            .where((u) => u.id == selectedUserId)
            .toList();
        final selectedUser = selectedUserList.isNotEmpty
            ? selectedUserList.first
            : null;
        if (selectedUser != null) {
          start = selectedUser.starttime;
          end = selectedUser.endtime;
          bStart = selectedUser.breakstart;
          bEnd = selectedUser.breakend;
        }
      }

      // Fallback to logged-in user profile data if not found/admin not matching
      if (start == null || end == null) {
        start = profileData?.starttime;
        end = profileData?.endtime;
        bStart = profileData?.breakstart;
        bEnd = profileData?.breakend;
      }

      final hoursPerDay = calculateWorkHoursPerDay(
        starttime: start,
        endtime: end,
        breakstart: bStart,
        breakend: bEnd,
      );

      String formatHours(double hours) {
        final hoursInt = hours.toInt();
        final minutes = ((hours - hoursInt) * 60).round();
        if (minutes == 0) {
          return hoursInt.toString();
        }
        return '$hoursInt.${minutes.toString().padLeft(2, '0')}';
      }

      if (selectedLeaveType == 'half') {
        final double days = daysDiff * 0.5;
        totalDaysCtrl.text = days.toStringAsFixed(1);
        totalHoursCtrl.text = formatHours(daysDiff * 0.5 * hoursPerDay);
      } else {
        totalDaysCtrl.text = daysDiff.toString();
        totalHoursCtrl.text = formatHours(daysDiff * hoursPerDay);
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
    try {
      fromParsed = DateFormat('dd-MM-yyyy').parse(fromDateCtrl.text);
      toParsed = DateFormat('dd-MM-yyyy').parse(toDateCtrl.text);
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
    final double parsedHours = parseHoursFromDisplay(totalHoursCtrl.text);

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
      session: selectedLeaveType == 'half' ? selectedSession : null,
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
