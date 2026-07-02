import 'dart:async';
import 'package:agro_app/app/utils/utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:agro_app/domain/models/get_all_attandance_model.dart' as get_all_model;
import 'package:agro_app/domain/models/get_one_attandance_model.dart' as get_one_model;
import 'package:agro_app/domain/models/get_all_users_model.dart' as user_model;
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
  DateTime? filterFromDate;
  DateTime? filterToDate;
  String? filterStatus;
  String? filterCreatedBy; // Store User ID string of creator
  List<user_model.Doc> usersList = [];
  bool isLoadingUsers = false;

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

  String editingAttendanceId = '';
  Timer? _searchTimer;
  bool isLocationLoading = false;

  @override
  void onInit() {
    super.onInit();
    fetchAttendance(isRefresh: true);
    fetchUsers();
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

    try {
      final response = await Get.find<Repository>().getAttendanceListApi(
        page: currentPage,
        limit: limit,
        search: searchQuery,
        fromDate: filterFromDate != null ? DateFormat('yyyy-MM-dd').format(filterFromDate!) : "",
        toDate: filterToDate != null ? DateFormat('yyyy-MM-dd').format(filterToDate!) : "",
        status: filterStatus ?? "",
        createdBy: filterCreatedBy ?? "",
        isLoading: isRefresh,
      );

      if (response != null && response.isSuccess == true && response.data != null) {
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

  void setFilters({
    DateTime? fromDate,
    DateTime? toDate,
    String? status,
    String? createdBy,
  }) {
    filterFromDate = fromDate;
    filterToDate = toDate;
    filterStatus = status;
    filterCreatedBy = createdBy;
    fetchAttendance(isRefresh: true);
  }

  void clearFilters() {
    filterFromDate = null;
    filterToDate = null;
    filterStatus = null;
    filterCreatedBy = null;
    fetchAttendance(isRefresh: true);
  }

  Future<void> fetchUsers() async {
    isLoadingUsers = true;
    update();
    try {
      final response = await Get.find<Repository>().getUsersListApi(
        page: 1,
        limit: 100, // Load users for creator selection
        type: 'user',
        isLoading: false,
      );
      if (response != null && response.isSuccess) {
        usersList = response.data.docs;
      }
    } catch (e) {
      debugPrint('[AttendanceController] fetchUsers error: $e');
    }
    isLoadingUsers = false;
    update();
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
          Utility.snacBar('Location permissions are permanently denied.', Colors.red);
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
        Utility.snacBar('Location coordinates fetched successfully.', Colors.green);
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
        "Latitude": lat,
        "Longitude": lon,
      };

      // Format display dd-MM-yyyy to API yyyy-MM-dd
      String apiDate = dateCtrl.text.trim();
      try {
        final parsed = DateFormat('dd-MM-yyyy').parse(apiDate);
        apiDate = DateFormat('yyyy-MM-dd').format(parsed);
      } catch (_) {}

      final response = await Get.find<Repository>().createAttendanceApi(
        attendanceid:
            editingAttendanceId.isNotEmpty ? editingAttendanceId : null,
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
      if (response != null && response.isSuccess == true && response.data != null) {
        setupForm(response.data);
        Get.toNamed<void>('/attendanceForm');
      }
    } catch (e) {
      debugPrint('[AttendanceController] fetchAttendanceDetailsAndOpenForm error: $e');
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
}
