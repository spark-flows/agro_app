import 'dart:async';
import 'package:agro_app/app/utils/utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:agro_app/domain/models/get_all_attandance_model.dart'
    as get_all_model;
import 'package:agro_app/domain/models/get_one_attandance_model.dart'
    as get_one_model;
import 'package:agro_app/domain/repositories/local_storage_keys.dart';
import 'package:agro_app/domain/repositories/repository.dart';

class AttendanceController extends GetxController {
  // ── List & Pagination State ───────────────────────────────────────────────
  List<get_all_model.GetAllAttendanceDoc> attendanceRecords = [];
  bool isLoading = false;
  bool isFetchingMore = false;

  int currentPage = 1;
  int totalPages = 1;
  int limit = 10; // Page limit is 10 as requested

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // ── Filter State ───────────────────────────────────────────────────────────
  DateTime? filterDate;
  String? filterStatus;

  String? roleName;
  void loadRoleName() async {
    roleName = Get.find<Repository>().getStringValue(LocalKeys.roleHiveName);
    update();
  }

  // ── Form State ─────────────────────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();
  final dateCtrl = TextEditingController();
  final timeInCtrl = TextEditingController();
  final timeOutCtrl = TextEditingController();
  final breakStartCtrl = TextEditingController();
  final breakEndCtrl = TextEditingController();
  final remarkCtrl = TextEditingController();
  final latitudeCtrl = TextEditingController();
  final longitudeCtrl = TextEditingController();
  String selectedStatus = 'present'; // Default: present

  String existingLatitude = '';
  String existingLongitude = '';

  bool isAdmin = false;
  String editingAttendanceId = '';
  Timer? _searchTimer;
  bool isLocationLoading = false;

  @override
  void onInit() {
    super.onInit();
    fetchAttendance(isRefresh: true);
    checkAdminRole();
  }

  Future<void> checkAdminRole() async {
    final role = Get.find<Repository>().getStringValue(LocalKeys.roleHiveName);
    isAdmin = role.toLowerCase() == 'admin';
    update();
  }

  @override
  void onClose() {
    _searchTimer?.cancel();
    dateCtrl.dispose();
    timeInCtrl.dispose();
    timeOutCtrl.dispose();
    breakStartCtrl.dispose();
    breakEndCtrl.dispose();
    remarkCtrl.dispose();
    latitudeCtrl.dispose();
    longitudeCtrl.dispose();
    super.onClose();
  }

  // ── Fetch Attendance records with Pagination ──────────────────────────────
  Future<void> fetchAttendance({bool isRefresh = true}) async {
    if (isRefresh) {
      currentPage = 1;
      attendanceRecords.clear();
      isLoading = true;
    } else {
      if (currentPage >= totalPages) return;
      currentPage++;
      isFetchingMore = true;
    }
    update();

    var userId = await Utility.getSecureValue(LocalKeys.distributorId);
    var role = Get.find<Repository>().getStringValue(LocalKeys.roleHiveName);

    try {
      final response = await Get.find<Repository>().getAttendanceListApi(
        page: currentPage,
        limit: limit,
        search: searchQuery,
        date: filterDate != null
            ? DateFormat('yyyy-MM-dd').format(filterDate!)
            : "",
        userid: role == "Admin" ? "" : userId,
        status: filterStatus ?? "",
        isLoading: isRefresh,
      );

      if (response != null &&
          response.isSuccess == true &&
          response.data != null) {
        final docs = response.data!.docs ?? [];
        if (isRefresh) {
          attendanceRecords = docs;
        } else {
          attendanceRecords.addAll(docs);
        }
        totalPages = response.data!.totalPages ?? 1;
      }
    } catch (e) {
      debugPrint('[AttendanceController] fetchAttendance error: $e');
    }

    isLoading = false;
    isFetchingMore = false;
    update();
  }

  // ── Search & Filter ────────────────────────────────────────────────────────
  void searchAttendance(String query) {
    _searchQuery = query;
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      fetchAttendance(isRefresh: true);
    });
  }

  void setFilters({DateTime? date, String? status}) {
    filterDate = date;
    filterStatus = status;
    fetchAttendance(isRefresh: true);
  }

  void clearFilters() {
    filterDate = null;
    filterStatus = null;
    fetchAttendance(isRefresh: true);
  }

  // ── DMS Coordinates Formatter ──────────────────────────────────────────────
  String convertToDms(double val) {
    final degrees = val.truncate();
    final minutesFraction = (val.abs() - degrees.abs()) * 60;
    final minutes = minutesFraction.truncate();
    final seconds = (minutesFraction - minutes) * 60;
    return "$degrees°$minutes'${seconds.toStringAsFixed(1)}\"";
  }

  // ── Get Current Geolocation Coordinates ─────────────────────────────────────
  Future<void> getCurrentCoordinates({bool showFeedback = true}) async {
    isLocationLoading = true;
    update();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (showFeedback) {
          Utility.snacBar('Location services are disabled.', Colors.red);
        }
        isLocationLoading = false;
        update();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (showFeedback) {
            Utility.snacBar('Location permissions are denied.', Colors.red);
          }
          isLocationLoading = false;
          update();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (showFeedback) {
          Utility.snacBar(
            'Location permissions are permanently denied.',
            Colors.red,
          );
        }
        isLocationLoading = false;
        update();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      latitudeCtrl.text = convertToDms(position.latitude);
      longitudeCtrl.text = convertToDms(position.longitude);

      if (showFeedback) {
        Utility.snacBar(
          'Location coordinates fetched successfully.',
          Colors.green,
        );
      }
    } catch (e) {
      debugPrint('[AttendanceController] getCurrentCoordinates error: $e');
      if (showFeedback) {
        Utility.snacBar('Failed to fetch location coordinates.', Colors.red);
      }
    }

    isLocationLoading = false;
    update();
  }

  // ── Setup Form State ───────────────────────────────────────────────────────
  void setupForm(get_one_model.GetAttendanceData? attendance) {
    if (attendance == null) {
      editingAttendanceId = '';
      dateCtrl.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
      timeInCtrl.clear();
      timeOutCtrl.clear();
      breakStartCtrl.clear();
      breakEndCtrl.clear();
      remarkCtrl.clear();
      latitudeCtrl.clear();
      longitudeCtrl.clear();
      existingLatitude = '';
      existingLongitude = '';
      selectedStatus = 'present';
    } else {
      editingAttendanceId = attendance.id ?? '';
      remarkCtrl.text = attendance.remark ?? '';
      selectedStatus = attendance.status ?? 'present';
      timeInCtrl.text = attendance.timein ?? '';
      timeOutCtrl.text = attendance.timeout ?? '';
      breakStartCtrl.text = attendance.breakstart ?? '';
      breakEndCtrl.text = attendance.breakend ?? '';

      // Format Date
      if (attendance.date != null && attendance.date!.isNotEmpty) {
        try {
          final parsed = DateTime.parse(attendance.date!);
          dateCtrl.text = DateFormat('dd-MM-yyyy').format(parsed);
        } catch (_) {
          try {
            final parsed = DateFormat('yyyy-MM-dd').parse(attendance.date!);
            dateCtrl.text = DateFormat('dd-MM-yyyy').format(parsed);
          } catch (_) {
            dateCtrl.text = attendance.date ?? '';
          }
        }
      } else {
        dateCtrl.text = '';
      }

      // Format coordinates
      existingLatitude = attendance.coordinates?.latitude ?? '';
      existingLongitude = attendance.coordinates?.longitude ?? '';
      latitudeCtrl.text = existingLatitude;
      longitudeCtrl.text = existingLongitude;
    }
    update();
  }

  // ── Save Attendance (Create/Update) ────────────────────────────────────────
  Future<void> saveAttendance() async {
    if (!formKey.currentState!.validate()) return;

    try {
      Utility.showLoader();

      String lat = '';
      String lon = '';

      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          if (permission != LocationPermission.denied &&
              permission != LocationPermission.deniedForever) {
            final position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
              timeLimit: const Duration(seconds: 5),
            );
            lat = position.latitude.toString();
            lon = position.longitude.toString();
          }
        }
      } catch (e) {
        debugPrint('[AttendanceController] Auto coordinates fetch error: $e');
      }

      if (lat.isEmpty && editingAttendanceId.isNotEmpty) {
        lat = existingLatitude;
      }
      if (lon.isEmpty && editingAttendanceId.isNotEmpty) {
        lon = existingLongitude;
      }

      final coordinatesPayload = {
        "latitude": lat,
        "longitude": lon,
        // "Latitude": lat,
        // "Longitude": lon,
      };

      // Format display dd-MM-yyyy to API yyyy-MM-dd
      String apiDate = dateCtrl.text.trim();
      if (apiDate.isEmpty) {
        apiDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      } else {
        try {
          final parsed = DateFormat('dd-MM-yyyy').parse(apiDate);
          apiDate = DateFormat('yyyy-MM-dd').format(parsed);
        } catch (_) {}
      }

      final response = await Get.find<Repository>().createAttendanceApi(
        attendanceid: editingAttendanceId.isNotEmpty
            ? editingAttendanceId
            : null,
        date: apiDate,
        timein: timeInCtrl.text.trim(),
        timeout: timeOutCtrl.text.trim(),
        coordinates: coordinatesPayload,
        breakstart: breakStartCtrl.text.trim(),
        breakend: breakEndCtrl.text.trim(),
        remark: remarkCtrl.text.trim(),
        status: selectedStatus,
        isLoading: false,
      );

      Utility.closeLoader();

      if (response != null && response.isSuccess == true) {
        Get.back();
        fetchAttendance(isRefresh: true);
        Utility.snacBar(
          editingAttendanceId.isEmpty
              ? 'Attendance added successfully'
              : 'Attendance updated successfully',
          Colors.green,
        );
      }
    } catch (e) {
      Utility.closeLoader();
      debugPrint('[AttendanceController] saveAttendance error: $e');
    }
  }

  // ── Delete Attendance ──────────────────────────────────────────────────────
  Future<void> deleteAttendance(String id) async {
    try {
      final success = await Get.find<Repository>().deleteAttendanceApi(
        attendanceid: id,
        isLoading: true,
      );
      if (success) {
        fetchAttendance(isRefresh: true);
        Utility.snacBar('Attendance deleted successfully', Colors.green);
      }
    } catch (e) {
      debugPrint('[AttendanceController] deleteAttendance error: $e');
    }
  }

  // ── Fetch Attendance Details & Open Form (via getone API) ──────────────────
  Future<void> fetchAttendanceDetailsAndOpenForm(String id) async {
    try {
      final response = await Get.find<Repository>().getOneAttendanceApi(
        attendanceid: id,
        isLoading: true,
      );
      if (response != null &&
          response.isSuccess == true &&
          response.data != null) {
        setupForm(response.data);
        Get.toNamed<void>('/attendanceForm');
      }
    } catch (e) {
      debugPrint(
        '[AttendanceController] fetchAttendanceDetailsAndOpenForm error: $e',
      );
    }
  }

  // ── Change Attendance Status (via changestatus API) ─────────────────────────
  Future<void> changeAttendanceStatus(String id, String status) async {
    try {
      final success = await Get.find<Repository>().changeAttendanceStatusApi(
        attendanceid: id,
        status: status,
        isLoading: true,
      );
      if (success) {
        final index = attendanceRecords.indexWhere((r) => r.id == id);
        if (index != -1) {
          attendanceRecords[index].status = status;
        }
        update();
        Utility.snacBar('Attendance status updated successfully', Colors.green);
      }
    } catch (e) {
      debugPrint('[AttendanceController] changeAttendanceStatus error: $e');
    }
  }

  Future<Map<String, String>> _getCurrentCoordinates() async {
    String lat = '';
    String lon = '';
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission != LocationPermission.denied &&
            permission != LocationPermission.deniedForever) {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 5),
          );
          lat = position.latitude.toString();
          lon = position.longitude.toString();
        }
      }
    } catch (e) {
      debugPrint('[AttendanceController] getCurrentCoordinates error: $e');
    }
    return {"latitude": lat, "longitude": lon};
  }

  get_all_model.GetAllAttendanceDoc? getTodayRecord() {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    for (var record in attendanceRecords) {
      if (record.date == todayStr) {
        return record;
      }
      if (record.date != null) {
        try {
          final parsedDate = DateTime.parse(record.date!);
          if (DateFormat('yyyy-MM-dd').format(parsedDate) == todayStr) {
            return record;
          }
        } catch (_) {
          try {
            final parsedDate = DateFormat('dd-MM-yyyy').parse(record.date!);
            if (DateFormat('yyyy-MM-dd').format(parsedDate) == todayStr) {
              return record;
            }
          } catch (_) {}
        }
      }
    }
    return null;
  }

  bool isClockedInToday(get_all_model.GetAllAttendanceDoc? record) {
    if (record == null) return false;
    if (record.timein != null &&
        record.timein!.isNotEmpty &&
        (record.timeout == null || record.timeout!.isEmpty)) {
      return true;
    }
    if (record.punching != null && record.punching!.isNotEmpty) {
      final lastPunch = record.punching!.last;
      final timeinStr = lastPunch.timein ?? "00:00";
      final timeoutStr = lastPunch.timeout ?? "00:00";
      if (timeinStr != "00:00" &&
          (timeoutStr == "00:00" || timeoutStr.isEmpty)) {
        return true;
      }
    }
    return false;
  }

  bool isClockedOutToday(get_all_model.GetAllAttendanceDoc? record) {
    if (record == null) return false;
    if (record.timeout != null && record.timeout!.isNotEmpty) {
      return true;
    }
    if (record.punching != null && record.punching!.isNotEmpty) {
      final lastPunch = record.punching!.last;
      final timeoutStr = lastPunch.timeout ?? "00:00";
      if (timeoutStr != "00:00" && timeoutStr.isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  bool isOnBreakToday(get_all_model.GetAllAttendanceDoc? record) {
    if (record == null) return false;
    if (record.breakstart != null &&
        record.breakstart!.isNotEmpty &&
        (record.breakend == null || record.breakend!.isEmpty)) {
      return true;
    }
    if (record.breaks != null && record.breaks!.isNotEmpty) {
      final lastBreak = record.breaks!.last;
      final breakstartStr = lastBreak.breakstart ?? "00:00";
      final breakendStr = lastBreak.breakend ?? "00:00";
      if (breakstartStr != "00:00" &&
          (breakendStr == "00:00" || breakendStr.isEmpty)) {
        return true;
      }
    }
    return false;
  }

  Future<void> quickClockIn() async {
    try {
      Utility.showLoader();
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final timeStr = DateFormat('hh:mm a').format(DateTime.now());
      final coordinates = await _getCurrentCoordinates();

      List<Map<String, String>> punchingPayload = [
        {"timein": timeStr, "timeout": "00:00"},
      ];

      final response = await Get.find<Repository>().createAttendanceApi(
        date: todayStr,
        timein: timeStr,
        timeout: '',
        coordinates: coordinates,
        breakstart: '',
        breakend: '',
        remark: '',
        status: 'present',
        punching: punchingPayload,
        breaks: [],
        isLoading: false,
      );

      Utility.closeLoader();
      if (response != null && response.isSuccess == true) {
        fetchAttendance(isRefresh: true);
        Utility.snacBar('Clocked in successfully', Colors.green);
      }
    } catch (e) {
      Utility.closeLoader();
      debugPrint('[AttendanceController] quickClockIn error: $e');
    }
  }

  Future<void> quickClockOut(get_all_model.GetAllAttendanceDoc record) async {
    try {
      Utility.showLoader();
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final timeStr = DateFormat('hh:mm a').format(DateTime.now());

      final List<Map<String, String>> punchingPayload = [];
      if (record.punching != null) {
        for (var p in record.punching!) {
          punchingPayload.add({
            "timein": p.timein ?? "00:00",
            "timeout": p.timeout ?? "00:00",
          });
        }
      }
      punchingPayload.add({"timein": "00:00", "timeout": timeStr});

      final List<Map<String, String>> breaksPayload = [];
      if (record.breaks != null) {
        for (var b in record.breaks!) {
          breaksPayload.add({
            "breakstart": b.breakstart ?? "00:00",
            "breakend": b.breakend ?? "00:00",
          });
        }
      }

      final Map<String, String> coordinates = {
        "latitude": record.coordinates?.latitude ?? '',
        "longitude": record.coordinates?.longitude ?? '',
      };

      final response = await Get.find<Repository>().createAttendanceApi(
        attendanceid: record.id,
        date: todayStr,
        timein: record.timein ?? '',
        timeout: timeStr,
        coordinates: coordinates,
        breakstart: record.breakstart ?? '',
        breakend: record.breakend ?? '',
        remark: record.remark ?? '',
        status: 'present',
        punching: punchingPayload,
        breaks: breaksPayload,
        isLoading: false,
      );

      Utility.closeLoader();
      if (response != null && response.isSuccess == true) {
        fetchAttendance(isRefresh: true);
        Utility.snacBar('Clocked out successfully', Colors.green);
      }
    } catch (e) {
      Utility.closeLoader();
      debugPrint('[AttendanceController] quickClockOut error: $e');
    }
  }

  Future<void> quickBreakIn(get_all_model.GetAllAttendanceDoc record) async {
    try {
      Utility.showLoader();
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final timeStr = DateFormat('hh:mm a').format(DateTime.now());

      final List<Map<String, String>> punchingPayload = [];
      if (record.punching != null) {
        for (var p in record.punching!) {
          punchingPayload.add({
            "timein": p.timein ?? "00:00",
            "timeout": p.timeout ?? "00:00",
          });
        }
      }

      final List<Map<String, String>> breaksPayload = [];
      if (record.breaks != null) {
        for (var b in record.breaks!) {
          breaksPayload.add({
            "breakstart": b.breakstart ?? "00:00",
            "breakend": b.breakend ?? "00:00",
          });
        }
      }
      breaksPayload.add({"breakstart": timeStr, "breakend": "00:00"});

      final Map<String, String> coordinates = {
        "latitude": record.coordinates?.latitude ?? '',
        "longitude": record.coordinates?.longitude ?? '',
      };

      final response = await Get.find<Repository>().createAttendanceApi(
        attendanceid: record.id,
        date: todayStr,
        timein: record.timein ?? '',
        timeout: record.timeout ?? '',
        coordinates: coordinates,
        breakstart: timeStr,
        breakend: '',
        remark: record.remark ?? '',
        status: 'present',
        punching: punchingPayload,
        breaks: breaksPayload,
        isLoading: false,
      );

      Utility.closeLoader();
      if (response != null && response.isSuccess == true) {
        fetchAttendance(isRefresh: true);
        Utility.snacBar('Break started successfully', Colors.green);
      }
    } catch (e) {
      Utility.closeLoader();
      debugPrint('[AttendanceController] quickBreakIn error: $e');
    }
  }

  Future<void> quickBreakOut(get_all_model.GetAllAttendanceDoc record) async {
    try {
      Utility.showLoader();
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final timeStr = DateFormat('hh:mm a').format(DateTime.now());

      final List<Map<String, String>> punchingPayload = [];
      if (record.punching != null) {
        for (var p in record.punching!) {
          punchingPayload.add({
            "timein": p.timein ?? "00:00",
            "timeout": p.timeout ?? "00:00",
          });
        }
      }

      final List<Map<String, String>> breaksPayload = [];
      if (record.breaks != null) {
        for (var b in record.breaks!) {
          breaksPayload.add({
            "breakstart": b.breakstart ?? "00:00",
            "breakend": b.breakend ?? "00:00",
          });
        }
      }
      breaksPayload.add({"breakstart": "00:00", "breakend": timeStr});

      final Map<String, String> coordinates = {
        "latitude": record.coordinates?.latitude ?? '',
        "longitude": record.coordinates?.longitude ?? '',
      };

      final response = await Get.find<Repository>().createAttendanceApi(
        attendanceid: record.id,
        date: todayStr,
        timein: record.timein ?? '',
        timeout: record.timeout ?? '',
        coordinates: coordinates,
        breakstart: record.breakstart ?? '',
        breakend: timeStr,
        remark: record.remark ?? '',
        status: 'present',
        punching: punchingPayload,
        breaks: breaksPayload,
        isLoading: false,
      );

      Utility.closeLoader();
      if (response != null && response.isSuccess == true) {
        fetchAttendance(isRefresh: true);
        Utility.snacBar('Break ended successfully', Colors.green);
      }
    } catch (e) {
      Utility.closeLoader();
      debugPrint('[AttendanceController] quickBreakOut error: $e');
    }
  }
}
