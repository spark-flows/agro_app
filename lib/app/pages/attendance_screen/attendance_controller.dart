import 'dart:async';
import 'dart:io';

import 'package:agro_app/app/services/background_location_service.dart';

import 'package:agro_app/app/theme/theme.dart';
import 'package:agro_app/app/utils/utility.dart';
import 'package:agro_app/domain/models/get_all_attandance_model.dart'
    as get_all_model;
import 'package:agro_app/domain/models/get_one_attandance_model.dart'
    as get_one_model;
import 'package:agro_app/domain/domain.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class AttendanceController extends GetxController with WidgetsBindingObserver {
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
    isAdmin = roleName?.toLowerCase() == 'admin';
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
  final searchCtrl = TextEditingController();
  String selectedStatus = 'present'; // Default: present
  String existingLatitude = '';
  String existingLongitude = '';
  bool isAdmin = false;
  List<Doc> userList = [];
  String? selectedUserId;
  String editingAttendanceId = '';
  Timer? _searchTimer;
  bool isLocationLoading = false;

  final RxString selfiePath = "".obs;
  final RxString odometerPhotoPath = "".obs;
  final RxBool isOdometerUploading = false.obs;
  final odometerReadingCtrl = TextEditingController();
  final vehicleNoCtrl = TextEditingController();
  final RxString timeinPhoto = "".obs;
  final RxString timeoutPhoto = "".obs;
  final timeinOdometerCtrl = TextEditingController();
  final timeoutOdometerCtrl = TextEditingController();
  Timer? _trackingTimer;
  bool _isResumingTracking = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    fetchAttendance(isRefresh: true);
    checkAdminRole();
    _resumeTrackingIfActive();
  }

  Future<void> checkAdminRole() async {
    final role = Get.find<Repository>().getStringValue(LocalKeys.roleHiveName);
    isAdmin = role.toLowerCase() == 'admin';
    if (isAdmin) {
      fetchUserList();
    }
    update();
  }

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
        update();
      }
    } catch (e) {
      debugPrint('fetchUserList error: $e');
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchTimer?.cancel();
    _trackingTimer?.cancel();
    dateCtrl.dispose();
    timeInCtrl.dispose();
    timeOutCtrl.dispose();
    breakStartCtrl.dispose();
    breakEndCtrl.dispose();
    remarkCtrl.dispose();
    latitudeCtrl.dispose();
    longitudeCtrl.dispose();
    odometerReadingCtrl.dispose();
    vehicleNoCtrl.dispose();
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

  String formatTo12Hour(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty || timeStr == "00:00") {
      return '';
    }
    try {
      if (timeStr.toLowerCase().contains('am') ||
          timeStr.toLowerCase().contains('pm')) {
        return timeStr;
      }
      if (timeStr.contains('T')) {
        final parsed = DateTime.parse(timeStr).toLocal();
        return DateFormat('hh:mm a').format(parsed);
      }
      final parts = timeStr.trim().split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1].split(' ')[0]);
        final dt = DateTime(2026, 1, 1, hour, minute);
        return DateFormat('hh:mm a').format(dt);
      }
    } catch (_) {}
    return timeStr;
  }

  // ── Setup Form State ───────────────────────────────────────────────────────
  void setupForm(get_one_model.GetAttendanceData? attendance) {
    if (attendance == null) {
      editingAttendanceId = '';
      selectedUserId = null;
      dateCtrl.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
      timeInCtrl.text = DateFormat('hh:mm a').format(DateTime.now());
      timeOutCtrl.clear();
      breakStartCtrl.clear();
      breakEndCtrl.clear();
      remarkCtrl.clear();
      latitudeCtrl.clear();
      longitudeCtrl.clear();
      existingLatitude = '';
      existingLongitude = '';
      selectedStatus = 'present';
      odometerReadingCtrl.clear();
      selfiePath.value = '';
      timeinOdometerCtrl.clear();
      timeoutOdometerCtrl.clear();
      timeinPhoto.value = '';
      timeoutPhoto.value = '';
    } else {
      editingAttendanceId = attendance.id ?? '';
      selectedUserId = attendance.userid?.id;
      remarkCtrl.text = attendance.remark ?? '';
      selectedStatus = attendance.status ?? 'present';
      odometerReadingCtrl.text = attendance.odometer != null
          ? attendance.odometer.toString()
          : '';
      selfiePath.value = attendance.photo ?? '';

      String? parsedTimeInPhoto;
      int? parsedTimeInOdometer;
      String? parsedTimeOutPhoto;
      int? parsedTimeOutOdometer;

      if (attendance.punching != null && attendance.punching!.isNotEmpty) {
        for (var p in attendance.punching!) {
          if (p.timeinphoto != null && p.timeinphoto!.isNotEmpty) {
            parsedTimeInPhoto = p.timeinphoto;
          }
          if (p.timeinodometer != null && p.timeinodometer != 0) {
            parsedTimeInOdometer = p.timeinodometer;
          }
          if (p.timeoutphoto != null && p.timeoutphoto!.isNotEmpty) {
            parsedTimeOutPhoto = p.timeoutphoto;
          }
          if (p.timeoutodometer != null && p.timeoutodometer != 0) {
            parsedTimeOutOdometer = p.timeoutodometer;
          }
        }
      }

      timeinPhoto.value =
          parsedTimeInPhoto ??
          (attendance.timeinphoto ?? (attendance.photo ?? ''));
      if (timeinPhoto.value.trim().isEmpty) timeinPhoto.value = '';

      int? timeInOdo =
          parsedTimeInOdometer ??
          (attendance.timeinodometer ?? attendance.odometer);
      timeinOdometerCtrl.text = (timeInOdo != null && timeInOdo != 0)
          ? timeInOdo.toString()
          : '';

      timeoutPhoto.value =
          parsedTimeOutPhoto ?? (attendance.timeoutphoto ?? '');
      if (timeoutPhoto.value.trim().isEmpty) timeoutPhoto.value = '';

      int? timeOutOdo = parsedTimeOutOdometer ?? attendance.timeoutodometer;
      timeoutOdometerCtrl.text = (timeOutOdo != null && timeOutOdo != 0)
          ? timeOutOdo.toString()
          : '';

      String? rawTimeIn = attendance.timein;
      if ((rawTimeIn == null || rawTimeIn.isEmpty) &&
          attendance.punching != null &&
          attendance.punching!.isNotEmpty) {
        for (var p in attendance.punching!) {
          if (p.timein != null && p.timein != "00:00" && p.timein!.isNotEmpty) {
            rawTimeIn = p.timein;
            break;
          }
        }
      }

      String? rawTimeOut = attendance.timeout;
      if ((rawTimeOut == null || rawTimeOut.isEmpty) &&
          attendance.punching != null &&
          attendance.punching!.isNotEmpty) {
        for (var p in attendance.punching!.reversed) {
          if (p.timeout != null &&
              p.timeout != "00:00" &&
              p.timeout!.isNotEmpty) {
            rawTimeOut = p.timeout;
            break;
          }
        }
      }

      String? rawBreakStart = attendance.breakstart;
      if ((rawBreakStart == null || rawBreakStart.isEmpty) &&
          attendance.breaks != null &&
          attendance.breaks!.isNotEmpty) {
        for (var b in attendance.breaks!) {
          if (b.breakstart != null &&
              b.breakstart != "00:00" &&
              b.breakstart!.isNotEmpty) {
            rawBreakStart = b.breakstart;
            break;
          }
        }
      }

      String? rawBreakEnd = attendance.breakend;
      if ((rawBreakEnd == null || rawBreakEnd.isEmpty) &&
          attendance.breaks != null &&
          attendance.breaks!.isNotEmpty) {
        for (var b in attendance.breaks!.reversed) {
          if (b.breakend != null &&
              b.breakend != "00:00" &&
              b.breakend!.isNotEmpty) {
            rawBreakEnd = b.breakend;
            break;
          }
        }
      }

      timeInCtrl.text = formatTo12Hour(rawTimeIn);
      timeOutCtrl.text = formatTo12Hour(rawTimeOut);
      breakStartCtrl.text = formatTo12Hour(rawBreakStart);
      breakEndCtrl.text = formatTo12Hour(rawBreakEnd);

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
        dateCtrl.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
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
    if (isAdmin && (selectedUserId == null || selectedUserId!.isEmpty)) {
      Utility.showMessage('Please select user', MessageType.error, null, '');
      return;
    }

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
        userid: selectedUserId,
        date: apiDate,
        timein: timeInCtrl.text.trim(),
        timeout: timeOutCtrl.text.trim(),
        coordinates: coordinatesPayload,
        breakstart: breakStartCtrl.text.trim(),
        breakend: breakEndCtrl.text.trim(),
        remark: remarkCtrl.text.trim(),
        status: selectedStatus,
        photo: selfiePath.value.isNotEmpty ? selfiePath.value : null,
        odometer: odometerReadingCtrl.text.isNotEmpty
            ? int.tryParse(odometerReadingCtrl.text)
            : null,
        timeinphoto: timeinPhoto.value.isNotEmpty ? timeinPhoto.value : null,
        timeinodometer: timeinOdometerCtrl.text.isNotEmpty
            ? int.tryParse(timeinOdometerCtrl.text)
            : null,
        timeoutphoto: timeoutPhoto.value.isNotEmpty ? timeoutPhoto.value : null,
        timeoutodometer: timeoutOdometerCtrl.text.isNotEmpty
            ? int.tryParse(timeoutOdometerCtrl.text)
            : null,
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
          Position? position;
          try {
            position = await Geolocator.getLastKnownPosition();
          } catch (_) {}
          if (position == null) {
            position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
              timeLimit: const Duration(seconds: 3),
            );
          }
          lat = position.latitude.toString();
          lon = position.longitude.toString();
        }
      }
    } catch (e) {
      debugPrint('[AttendanceController] getCurrentCoordinates error: $e');
    }
    return {"latitude": lat, "longitude": lon};
  }

  Future<Map<String, String>> _getResolvedCoordinates(
    get_all_model.GetAllAttendanceDoc? record,
  ) async {
    try {
      final profile = await _getProfileWithCache();
      final requiresLiveTracking = profile?.data.userData.liveTracking ?? false;
      if (!requiresLiveTracking) {
        return {"latitude": "", "longitude": ""};
      }
    } catch (_) {}
    if (record != null) {
      return await _getCurrentCoordinates();

      // return {
      //   "latitude": record.coordinates?.latitude ?? '',
      //   "longitude": record.coordinates?.longitude ?? '',
      // };
    }
    return await _getCurrentCoordinates();
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

  String getLocalAttendanceStatus() {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final savedDate = Get.find<Repository>().getStringValue('attendance_date');
    if (savedDate == todayStr) {
      return Get.find<Repository>().getStringValue('attendance_status');
    }
    return 'none';
  }

  void setLocalAttendanceStatus(String status) {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    Get.find<Repository>().saveValue('attendance_date', todayStr);
    Get.find<Repository>().saveValue('attendance_status', status);
    update();
  }

  bool isClockedInToday(get_all_model.GetAllAttendanceDoc? record) {
    final localStatus = getLocalAttendanceStatus();
    if (localStatus != 'none') {
      return localStatus == 'clocked_in' || localStatus == 'paused';
    }
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
    final localStatus = getLocalAttendanceStatus();
    if (localStatus != 'none') {
      return localStatus == 'clocked_out';
    }
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
    final localStatus = getLocalAttendanceStatus();
    if (localStatus != 'none') {
      return localStatus == 'paused';
    }
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
    final hasPermission = await Utility.handleLocationPermission();
    if (!hasPermission) return;
    try {
      Utility.showLoader();
      final profile = await Get.find<Repository>().getProfileApi(
        isLoading: false,
      );
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final timeStr = DateFormat('hh:mm a').format(DateTime.now());
      final record = getTodayRecord();
      final coordinates = await _getResolvedCoordinates(record);

      bool requiresOdometer = false;
      if (profile != null &&
          profile.isSuccess == true &&
          profile.data != null) {
        requiresOdometer = profile.data.userData.odometer ?? false;
      }

      Utility.closeLoader();

      List<Map<String, String>> punchingPayload = [];
      if (record != null && record.punching != null) {
        for (var p in record.punching!) {
          punchingPayload.add({
            "timein": p.timein ?? "00:00",
            "timeout": (p.timeout == null || p.timeout!.isEmpty)
                ? "00:00"
                : p.timeout!,
          });
        }
      }
      punchingPayload.add({"timein": timeStr, "timeout": "00:00"});

      final List<Map<String, String>> breaksPayload = [];
      if (record != null && record.breaks != null) {
        for (var b in record.breaks!) {
          breaksPayload.add({
            "breakstart": b.breakstart ?? "00:00",
            "breakend": b.breakend ?? "00:00",
          });
        }
      }

      if (requiresOdometer) {
        _showOdometerVerificationDialog(
          todayStr: todayStr,
          timeStr: timeStr,
          coordinates: coordinates,
          punchingPayload: punchingPayload,
          isClockOut: false,
        );
      } else {
        Utility.showLoader();
        final response = await Get.find<Repository>().createAttendanceApi(
          attendanceid: record?.id,
          date: todayStr,
          timein: timeStr,
          timeout: '',
          coordinates: coordinates,
          breakstart: '',
          breakend: '',
          remark: '',
          status: 'present',
          punching: punchingPayload,
          breaks: breaksPayload,
          isLoading: false,
        );

        Utility.closeLoader();
        if (response != null && response.isSuccess == true) {
          Get.find<Repository>().saveValue('saved_timein_$todayStr', timeStr);
          setLocalAttendanceStatus('clocked_in');
          await fetchAttendance(isRefresh: false);
          Utility.snacBar('Clocked in successfully', Colors.green);
          _triggerStartTracking(coordinates);
        }
      }
    } catch (e) {
      Utility.closeLoader();
      debugPrint('[AttendanceController] quickClockIn error: $e');
    }
  }

  void _showOdometerVerificationDialog({
    required String todayStr,
    required String timeStr,
    required Map<String, String> coordinates,
    required List<Map<String, String>> punchingPayload,
    bool isClockOut = false,
    get_all_model.GetAllAttendanceDoc? record,
  }) {
    selfiePath.value = "";
    odometerReadingCtrl.clear();
    vehicleNoCtrl.clear();
    isOdometerUploading.value = false;

    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ColorsValue.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.speed_outlined,
                        color: ColorsValue.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Odometer Verification",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ColorsValue.txtBlackColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isClockOut
                                ? "Daily Punch-Out Verification"
                                : "Daily Punch-In Verification",
                            style: TextStyle(
                              fontSize: 12,
                              color: ColorsValue.txtGreyColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Selfie Photo Box (Only Selfie, No Odometer Photo) ──
                Obx(() {
                  final hasImage = selfiePath.value.isNotEmpty;
                  return GestureDetector(
                    onTap: () async {
                      final hasPermission =
                          await Utility.cameraPermissionCheack(Get.context!);
                      if (!hasPermission) return;
                      final picker = ImagePicker();
                      final file = await picker.pickImage(
                        source: ImageSource.camera,
                        preferredCameraDevice: CameraDevice.front,
                        imageQuality: 85,
                      );
                      if (file != null) {
                        selfiePath.value = file.path;
                      }
                    },
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: hasImage
                              ? ColorsValue.primary
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: hasImage
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  kIsWeb
                                      ? Image.network(
                                          selfiePath.value,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(selfiePath.value),
                                          fit: BoxFit.cover,
                                        ),
                                  Positioned(
                                    right: 6,
                                    top: 6,
                                    child: GestureDetector(
                                      onTap: () => selfiePath.value = "",
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.camera_front_outlined,
                                  color: ColorsValue.primary,
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Take Selfie",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: ColorsValue.txtBlackColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Front Camera",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: ColorsValue.txtGreyColor,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  );
                }),
                const SizedBox(height: 24),

                // ── Vehicle Number Input (Punch-In Only) ──────────────
                if (!isClockOut) ...[
                  TextField(
                    controller: vehicleNoCtrl,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ColorsValue.txtBlackColor,
                    ),
                    decoration: InputDecoration(
                      labelText: "Vehicle Number",
                      labelStyle: TextStyle(
                        color: ColorsValue.txtGreyColor,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.directions_car_outlined,
                        color: ColorsValue.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: ColorsValue.primary,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Odometer Reading Input ─────────────────────────────
                TextField(
                  controller: odometerReadingCtrl,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ColorsValue.txtBlackColor,
                  ),
                  decoration: InputDecoration(
                    labelText: "Odometer Reading (KM)",
                    labelStyle: TextStyle(
                      color: ColorsValue.txtGreyColor,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.speed_outlined,
                      color: ColorsValue.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: ColorsValue.primary,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 28),

                // ── Action Buttons ────────────────────────────────────
                Obx(
                  () => isOdometerUploading.value
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: CircularProgressIndicator(
                              color: ColorsValue.primary,
                            ),
                          ),
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Get.back(),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(color: Colors.grey.shade300),
                                  foregroundColor: ColorsValue.txtGreyColor,
                                ),
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (selfiePath.value.isEmpty) {
                                    Utility.errorMessage(
                                      "Please capture a Selfie",
                                    );
                                    return;
                                  }
                                  if (!isClockOut &&
                                      vehicleNoCtrl.text.trim().isEmpty) {
                                    Utility.errorMessage(
                                      "Please enter Vehicle Number",
                                    );
                                    return;
                                  }
                                  if (odometerReadingCtrl.text.trim().isEmpty) {
                                    Utility.errorMessage(
                                      "Please enter Odometer Reading",
                                    );
                                    return;
                                  }

                                  isOdometerUploading.value = true;

                                  // Upload selfie file
                                  final selfieUrl = await Get.find<Repository>()
                                      .uploadAttendanceMediaApi(
                                        selfiePath.value,
                                      );

                                  if (selfieUrl == null) {
                                    isOdometerUploading.value = false;
                                    Utility.errorMessage(
                                      "Failed to upload verification photo",
                                    );
                                    return;
                                  }

                                  final odoValue =
                                      int.tryParse(
                                        odometerReadingCtrl.text.trim(),
                                      ) ??
                                      0;

                                  final currentRecord =
                                      record ?? getTodayRecord();
                                  final List<Map<String, String>>
                                  breaksPayload = [];
                                  if (currentRecord != null &&
                                      currentRecord.breaks != null) {
                                    for (var b in currentRecord.breaks!) {
                                      breaksPayload.add({
                                        "breakstart": b.breakstart ?? "00:00",
                                        "breakend": b.breakend ?? "00:00",
                                      });
                                    }
                                  }

                                  // Call the API with selfieUrl, odoValue, and vehicalno
                                  final response = await Get.find<Repository>()
                                      .createAttendanceApi(
                                        attendanceid: currentRecord?.id,
                                        date: todayStr,
                                        timein: isClockOut
                                            ? (currentRecord?.timein ?? '')
                                            : timeStr,
                                        timeout: isClockOut ? timeStr : '',
                                        coordinates: coordinates,
                                        breakstart: isClockOut
                                            ? (currentRecord?.breakstart ?? '')
                                            : '',
                                        breakend: isClockOut
                                            ? (currentRecord?.breakend ?? '')
                                            : '',
                                        remark: isClockOut
                                            ? (currentRecord?.remark ?? '')
                                            : '',
                                        status: 'present',
                                        punching: punchingPayload,
                                        breaks: breaksPayload,
                                        photo: selfieUrl,
                                        odometer: odoValue,
                                        vehicalno: !isClockOut
                                            ? vehicleNoCtrl.text
                                                  .trim()
                                                  .toUpperCase()
                                            : null,
                                        isLoading: false,
                                      );

                                  isOdometerUploading.value = false;
                                  Get.back(); // close dialog

                                  if (response != null &&
                                      response.isSuccess == true) {
                                    if (isClockOut) {
                                      Get.find<Repository>().saveValue(
                                        'saved_timeout_$todayStr',
                                        timeStr,
                                      );
                                    } else {
                                      Get.find<Repository>().saveValue(
                                        'saved_timein_$todayStr',
                                        timeStr,
                                      );
                                    }
                                    setLocalAttendanceStatus(
                                      isClockOut ? 'clocked_out' : 'clocked_in',
                                    );
                                    await fetchAttendance(isRefresh: false);
                                    Utility.snacBar(
                                      isClockOut
                                          ? 'Clocked out successfully'
                                          : 'Clocked in successfully',
                                      Colors.green,
                                    );
                                    Get.find<Repository>().saveValue(
                                      LocalKeys.lastOdometer,
                                      odoValue.toString(),
                                    );
                                    Get.find<Repository>().saveValue(
                                      LocalKeys.lastSelfieUrl,
                                      selfieUrl,
                                    );
                                    if (isClockOut) {
                                      _triggerStopTracking(coordinates);
                                    } else {
                                      _triggerStartTracking(coordinates);
                                    }
                                  } else {
                                    Utility.errorMessage(
                                      isClockOut
                                          ? "Failed to Clock Out"
                                          : "Failed to Clock In",
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorsValue.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "Submit",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<Map<String, dynamic>> _getSavedOdometerData() async {
    final profile = await Get.find<Repository>().getProfileApi(
      isLoading: false,
    );
    bool requiresOdometer = false;
    if (profile != null && profile.isSuccess == true && profile.data != null) {
      requiresOdometer = profile.data.userData.odometer ?? false;
    }
    if (requiresOdometer) {
      final odoStr = Get.find<Repository>().getStringValue(
        LocalKeys.lastOdometer,
      );
      final selfieUrl = Get.find<Repository>().getStringValue(
        LocalKeys.lastSelfieUrl,
      );
      return {
        "photo": selfieUrl.isNotEmpty ? selfieUrl : null,
        "odometer": int.tryParse(odoStr),
      };
    }
    return {};
  }

  Future<void> quickClockOut(get_all_model.GetAllAttendanceDoc? record) async {
    final hasPermission = await Utility.handleLocationPermission();
    if (!hasPermission) return;
    try {
      Utility.showLoader();
      final profile = await Get.find<Repository>().getProfileApi(
        isLoading: false,
      );
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final timeStr = DateFormat('hh:mm a').format(DateTime.now());

      final List<Map<String, String>> punchingPayload = [];
      if (record != null && record.punching != null) {
        for (var p in record.punching!) {
          punchingPayload.add({
            "timein": p.timein ?? "00:00",
            "timeout": (p.timeout == null || p.timeout!.isEmpty)
                ? "00:00"
                : p.timeout!,
          });
        }
      }
      punchingPayload.add({"timein": "00:00", "timeout": timeStr});

      final List<Map<String, String>> breaksPayload = [];
      if (record != null && record.breaks != null) {
        for (var b in record.breaks!) {
          breaksPayload.add({
            "breakstart": b.breakstart ?? "00:00",
            "breakend": b.breakend ?? "00:00",
          });
        }
      }

      final Map<String, String> coordinates = await _getResolvedCoordinates(
        record,
      );

      bool requiresOdometer = false;
      if (profile != null &&
          profile.isSuccess == true &&
          profile.data != null) {
        requiresOdometer = profile.data.userData.odometer ?? false;
      }

      Utility.closeLoader();

      if (requiresOdometer) {
        _showOdometerVerificationDialog(
          todayStr: todayStr,
          timeStr: timeStr,
          coordinates: coordinates,
          punchingPayload: punchingPayload,
          isClockOut: true,
          record: record,
        );
      } else {
        Utility.showLoader();
        final odoData = await _getSavedOdometerData();

        final response = await Get.find<Repository>().createAttendanceApi(
          attendanceid: record?.id,
          date: todayStr,
          timein: record?.timein ?? '',
          timeout: timeStr,
          coordinates: coordinates,
          breakstart: record?.breakstart ?? '',
          breakend: record?.breakend ?? '',
          remark: record?.remark ?? '',
          status: 'present',
          punching: punchingPayload,
          breaks: breaksPayload,
          photo: odoData['photo'] as String?,
          odometer: odoData['odometer'] as int?,
          isLoading: false,
        );

        Utility.closeLoader();
        if (response != null && response.isSuccess == true) {
          Get.find<Repository>().saveValue('saved_timeout_$todayStr', timeStr);
          setLocalAttendanceStatus('clocked_out');
          await fetchAttendance(isRefresh: false);
          Utility.snacBar('Clocked out successfully', Colors.green);
          _triggerStopTracking(coordinates);
        }
      }
    } catch (e) {
      Utility.closeLoader();
      debugPrint('[AttendanceController] quickClockOut error: $e');
    }
  }

  Future<void> quickBreakIn(get_all_model.GetAllAttendanceDoc? record) async {
    Utility.showLoader();
    try {
      final nowTime = DateFormat('HH:mm').format(DateTime.now());
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      Get.find<Repository>().saveValue('saved_breakstart_$todayStr', nowTime);
      setLocalAttendanceStatus('paused');

      int existingOdometer = 0;
      if (record?.punching != null && record!.punching!.isNotEmpty) {
        for (var p in record.punching!) {
          if (p.timeinodometer != null && p.timeinodometer! > 0) {
            existingOdometer = p.timeinodometer!;
            break;
          }
          if (p.timeoutodometer != null && p.timeoutodometer! > 0) {
            existingOdometer = p.timeoutodometer!;
            break;
          }
        }
      }

      try {
        await Get.find<Repository>().createAttendanceApi(
          attendanceid: record?.id,
          date: todayStr,
          timein: record?.timein ?? '',
          timeout: record?.timeout ?? '',
          coordinates: {"latitude": "", "longitude": ""},
          breakstart: nowTime,
          breakend: record?.breakend ?? '',
          remark: record?.remark ?? '',
          status: 'present',
          odometer: existingOdometer,
          isLoading: false,
        );
      } catch (ex) {
        debugPrint('[AttendanceController] quickBreakIn API call error: $ex');
      }

      await fetchAttendance(isRefresh: false);
    } catch (e) {
      debugPrint('[AttendanceController] quickBreakIn error: $e');
    } finally {
      Utility.closeLoader();
    }

    await Future.delayed(const Duration(milliseconds: 150));
    Utility.snacBar('Shift paused successfully', Colors.green);
  }

  Future<void> quickBreakOut(get_all_model.GetAllAttendanceDoc? record) async {
    Utility.showLoader();
    try {
      final nowTime = DateFormat('HH:mm').format(DateTime.now());
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      Get.find<Repository>().saveValue('saved_breakend_$todayStr', nowTime);
      setLocalAttendanceStatus('clocked_in');

      int existingOdometer = 0;
      if (record?.punching != null && record!.punching!.isNotEmpty) {
        for (var p in record.punching!) {
          if (p.timeinodometer != null && p.timeinodometer! > 0) {
            existingOdometer = p.timeinodometer!;
            break;
          }
          if (p.timeoutodometer != null && p.timeoutodometer! > 0) {
            existingOdometer = p.timeoutodometer!;
            break;
          }
        }
      }

      try {
        await Get.find<Repository>().createAttendanceApi(
          attendanceid: record?.id,
          date: todayStr,
          timein: record?.timein ?? '',
          timeout: record?.timeout ?? '',
          coordinates: {"latitude": "", "longitude": ""},
          breakstart: record?.breakstart ?? '',
          breakend: nowTime,
          remark: record?.remark ?? '',
          status: 'present',
          odometer: existingOdometer,
          isLoading: false,
        );
      } catch (ex) {
        debugPrint('[AttendanceController] quickBreakOut API call error: $ex');
      }

      await fetchAttendance(isRefresh: false);
    } catch (e) {
      debugPrint('[AttendanceController] quickBreakOut error: $e');
    } finally {
      Utility.closeLoader();
    }

    await Future.delayed(const Duration(milliseconds: 150));
    Utility.snacBar('Shift resumed successfully', Colors.green);
  }

  ProfileDataModel? _cachedProfile;
  DateTime? _lastProfileFetchTime;

  Future<ProfileDataModel?> _getProfileWithCache({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        _cachedProfile != null &&
        _lastProfileFetchTime != null &&
        DateTime.now().difference(_lastProfileFetchTime!) <
            const Duration(minutes: 5)) {
      return _cachedProfile;
    }
    try {
      final profile = await Get.find<Repository>().getProfileApi(
        isLoading: false,
      );
      if (profile != null) {
        _cachedProfile = profile;
        _lastProfileFetchTime = DateTime.now();
      }
      return _cachedProfile ?? profile;
    } catch (_) {
      return _cachedProfile;
    }
  }

  Future<String> _getEffectiveUserId() async {
    String userId = await Utility.getSecureValue(LocalKeys.distributorId);
    if (userId.isEmpty) {
      userId = await Utility.getSecureValue(LocalKeys.userIds);
    }
    if (userId.isEmpty) {
      try {
        final profile = await _getProfileWithCache();
        userId = profile?.data.userData.id ?? '';
      } catch (_) {}
    }
    return userId;
  }

  void _startPeriodicLocationUpdates(String trackingId) async {
    _trackingTimer?.cancel();
    _trackingTimer = null;

    var isNotificationGranted = await Permission.notification.isGranted;
    if (!isNotificationGranted) {
      final status = await Permission.notification.request();
      isNotificationGranted = status.isGranted;
    }

    if (!isNotificationGranted) {
      debugPrint(
        '[AttendanceController] Notification permission is not granted. Cannot start background service.',
      );
      return;
    }

    // Start background service for tracking (runs in its own foreground service isolate)
    try {
      final userId = await _getEffectiveUserId();
      final authToken = await Get.find<Repository>().getSecureValue(
        LocalKeys.authToken,
      );
      debugPrint(
        '[AttendanceController] Starting background service for userId: $userId',
      );
      await BackgroundLocationService.startTracking(
        userId: userId,
        authToken: authToken,
      );
      debugPrint('[AttendanceController] Background location service started');
    } catch (e) {
      debugPrint(
        '[AttendanceController] Failed to start background service: $e',
      );
    }

    _startForegroundTimer();
  }

  void _startForegroundTimer() {
    _trackingTimer?.cancel();
    _trackingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final profile = await _getProfileWithCache();
        if (profile?.data.userData.liveTracking != true) {
          debugPrint(
            '[AttendanceController] liveTracking is off, cancelling foreground timer',
          );
          timer.cancel();
          return;
        }
        final record = getTodayRecord();
        if (!isClockedInToday(record) || isClockedOutToday(record)) {
          debugPrint(
            '[AttendanceController] User not clocked in, cancelling foreground timer',
          );
          timer.cancel();
          return;
        }

        final coords = await _getCurrentCoordinates();
        final lat = double.tryParse(coords['latitude'] ?? '0') ?? 0.0;
        final lng = double.tryParse(coords['longitude'] ?? '0') ?? 0.0;
        if (lat != 0.0 && lng != 0.0) {
          final userId = await _getEffectiveUserId();
          final timeStr = DateTime.now().toUtc().toIso8601String();
          final success = await Get.find<Repository>().updateLocationApi(
            userId: userId,
            latitude: lat,
            longitude: lng,
            timestamp: timeStr,
            isLoading: false,
          );
          debugPrint(
            '[AttendanceController] Foreground updateLocationApi ($lat, $lng) success: $success',
          );
        } else {
          debugPrint(
            '[AttendanceController] Coordinates (0,0) - skipping foreground update',
          );
        }
      } catch (e) {
        debugPrint(
          '[AttendanceController] Foreground location update error: $e',
        );
      }
    });
  }

  void _stopPeriodicLocationUpdates() async {
    _trackingTimer?.cancel();
    _trackingTimer = null;

    // Stop background service
    try {
      await BackgroundLocationService.stopTracking();
      debugPrint('[AttendanceController] Background location service stopped');
    } catch (e) {
      debugPrint(
        '[AttendanceController] Failed to stop background service: $e',
      );
    }
  }

  void _resumeTrackingIfActive() async {
    if (_isResumingTracking) return;
    _isResumingTracking = true;

    try {
      await Future.delayed(const Duration(seconds: 2));
      try {
        final profile = await _getProfileWithCache();
        if (profile == null ||
            profile.isSuccess != true ||
            profile.data.userData.liveTracking != true) {
          return;
        }
      } catch (_) {
        return;
      }
      final record = getTodayRecord();
      final isClockedIn = isClockedInToday(record);
      final isClockedOut = isClockedOutToday(record);
      if (isClockedIn && !isClockedOut) {
        final storedTrackingId = Get.find<Repository>().getStringValue(
          LocalKeys.trackingId,
        );
        _startPeriodicLocationUpdates(
          storedTrackingId.isNotEmpty ? storedTrackingId : "active",
        );
      } else {
        // User is not clocked in or already clocked out, stop background service
        final isRunning = await BackgroundLocationService.isRunning();
        if (isRunning) {
          await BackgroundLocationService.stopTracking();
        }
      }
    } finally {
      _isResumingTracking = false;
    }
  }

  Future<void> _triggerStartTracking(Map<String, String> coordinates) async {
    try {
      final profile = await _getProfileWithCache(forceRefresh: true);
      if (profile == null ||
          profile.isSuccess != true ||
          profile.data.userData.liveTracking != true) {
        debugPrint(
          '[AttendanceController] _triggerStartTracking skipped: liveTracking is false or profile null',
        );
        return;
      }
      final userId = await _getEffectiveUserId();
      final lat = double.tryParse(coordinates['latitude'] ?? '0') ?? 0.0;
      final lng = double.tryParse(coordinates['longitude'] ?? '0') ?? 0.0;
      final timeStr = DateTime.now().toUtc().toIso8601String();

      final trackingId = await Get.find<Repository>().startTrackingApi(
        userId: userId,
        latitude: lat,
        longitude: lng,
        time: timeStr,
      );

      final validTrackingId = (trackingId != null && trackingId.isNotEmpty)
          ? trackingId
          : "active";
      Get.find<Repository>().saveValue(LocalKeys.trackingId, validTrackingId);
      _startPeriodicLocationUpdates(validTrackingId);
    } catch (e) {
      debugPrint('[AttendanceController] start tracking error: $e');
    }
  }

  Future<void> _triggerStopTracking(Map<String, String> coordinates) async {
    try {
      _stopPeriodicLocationUpdates();
      final profile = await _getProfileWithCache();
      if (profile == null ||
          profile.isSuccess != true ||
          profile.data.userData.liveTracking != true) {
        return;
      }
      final userId = await _getEffectiveUserId();
      final lat = double.tryParse(coordinates['latitude'] ?? '0') ?? 0.0;
      final lng = double.tryParse(coordinates['longitude'] ?? '0') ?? 0.0;
      final timeStr = DateTime.now().toUtc().toIso8601String();

      await Get.find<Repository>().stopTrackingApi(
        userId: userId,
        latitude: lat,
        longitude: lng,
        time: timeStr,
      );

      Get.find<Repository>().saveValue(LocalKeys.trackingId, "");
    } catch (e) {
      debugPrint('[AttendanceController] stop tracking error: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint(
        '[AttendanceController] App resumed to foreground, checking and resuming tracking if active...',
      );
      _resumeTrackingIfActive();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      debugPrint(
        '[AttendanceController] App going to background/closing, background service will continue tracking...',
      );
      // Cancel foreground timer - background service handles it from here
      _trackingTimer?.cancel();
      _trackingTimer = null;
    }
  }
}
