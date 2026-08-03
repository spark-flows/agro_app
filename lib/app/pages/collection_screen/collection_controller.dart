import 'dart:async';
import 'dart:convert';
import 'package:agro_app/app/utils/utility.dart';
import 'package:agro_app/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CollectionController extends GetxController {
  // ── List & Pagination State ──────────────────────────────────────────────
  List<CollectionDoc> collections = [];
  bool isLoading = true;
  bool isFetchingMore = false;

  int currentPage = 1;
  int totalPages = 1;
  int limit = 10;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // ── Filters State ────────────────────────────────────────────────────────
  DateTime? filterFromDate;
  DateTime? filterToDate;
  String? filterStatus; // null/empty = all, or 'received', 'pending', 'return'

  // ── Role & User Context ──────────────────────────────────────────────────
  String roleName = '';
  String userId = '';
  List<Doc> userList = [];
  String? selectedUserId;

  // ── Form Controllers & State ─────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();
  final dateCtrl = TextEditingController();
  final partyNameCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final remarkCtrl = TextEditingController();

  // Dropdown values:
  // Payment mode options: 'cash', 'check', 'rtgs/neft'
  String selectedPaymentMode = 'cash';
  // Payment status options: 'received', 'pending', 'return'
  String selectedPaymentStatus = 'pending';

  String editingCollectionId = '';
  Timer? _searchTimer;

  static const List<String> paymentModeOptions = ['cash', 'check', 'rtgs/neft'];
  static const List<String> paymentStatusOptions = [
    'received',
    'pending',
    'return',
  ];

  @override
  void onInit() {
    super.onInit();
    _loadUserContext().then((_) {
      fetchCollections(isRefresh: true);
    });
  }

  @override
  void onClose() {
    _searchTimer?.cancel();
    dateCtrl.dispose();
    partyNameCtrl.dispose();
    amountCtrl.dispose();
    remarkCtrl.dispose();
    super.onClose();
  }

  // ── Load Role & User ID from Storage / Profile API ─────────────────────────
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
        userList = docs.where((u) => RoleUtils.isUser(u.roleid.rolename)).toList();
        update();
      }
    } catch (e) {
      debugPrint('fetchUserList error: $e');
    }
  }

  // ── Fetch Collections ─────────────────────────────────────────────────────
  Future<void> fetchCollections({bool isRefresh = true}) async {
    if (isRefresh) {
      currentPage = 1;
      collections.clear();
      isLoading = true;
    } else {
      if (currentPage >= totalPages) return;
      currentPage++;
      isFetchingMore = true;
    }
    update();

    try {
      final response = await Get.find<Repository>().getCollectionListApi(
        page: currentPage,
        limit: limit,
        search: searchQuery,
        fromDate: filterFromDate != null
            ? DateFormat('yyyy-MM-dd').format(filterFromDate!)
            : '',
        toDate: filterToDate != null
            ? DateFormat('yyyy-MM-dd').format(filterToDate!)
            : '',
        userid: RoleUtils.isUser(roleName) ? userId : '',
        isLoading: false,
      );

      if (response != null && response.data != null) {
        final docs = response.data!.docs ?? [];
        if (isRefresh) {
          collections = docs;
        } else {
          collections.addAll(docs);
        }
        totalPages = response.data!.totalPages ?? 1;
      }
    } catch (e) {
      debugPrint('fetchCollections error: $e');
    } finally {
      isLoading = false;
      isFetchingMore = false;
      update();
    }
  }

  // ── Search & Filter ────────────────────────────────────────────────────────
  void onSearchChanged(String query) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      _searchQuery = query.trim();
      fetchCollections(isRefresh: true);
    });
  }

  void setDateRange(DateTime? from, DateTime? to) {
    filterFromDate = from;
    filterToDate = to;
    fetchCollections(isRefresh: true);
  }

  void setStatusFilter(String? status) {
    filterStatus = status;
    update();
  }

  void applyFilters(DateTime? from, DateTime? to, String? status) {
    filterFromDate = from;
    filterToDate = to;
    filterStatus = status;
    fetchCollections(isRefresh: true);
  }

  List<CollectionDoc> get filteredCollections {
    if (filterStatus == null || filterStatus!.isEmpty) {
      return collections;
    }
    return collections
        .where(
          (c) =>
              c.paymentstatus?.toLowerCase().trim() ==
              filterStatus!.toLowerCase().trim(),
        )
        .toList();
  }

  // ── Prepare Form Page ─────────────────────────────────────────────────────
  void prepareForm([CollectionDoc? collection]) {
    if (collection != null) {
      editingCollectionId = collection.id ?? collection.collectionid ?? '';
      if (collection.date != null && collection.date!.isNotEmpty) {
        final parsedDate = DateTime.tryParse(collection.date!);
        if (parsedDate != null) {
          dateCtrl.text = DateFormat('yyyy-MM-dd').format(parsedDate.toLocal());
        } else {
          dateCtrl.text = collection.date!;
        }
      } else {
        dateCtrl.text = '';
      }
      partyNameCtrl.text = collection.partyname ?? '';
      amountCtrl.text = collection.amount ?? '';
      remarkCtrl.text = collection.remark ?? '';

      final mode = collection.paymentmode?.toLowerCase().trim() ?? '';
      if (paymentModeOptions.contains(mode)) {
        selectedPaymentMode = mode;
      } else {
        selectedPaymentMode = paymentModeOptions.first;
      }

      final status = collection.paymentstatus?.toLowerCase().trim() ?? '';
      if (paymentStatusOptions.contains(status)) {
        selectedPaymentStatus = status;
      } else {
        selectedPaymentStatus = paymentStatusOptions.first;
      }
      selectedUserId = collection.userid?.id;
    } else {
      editingCollectionId = '';
      dateCtrl.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
      partyNameCtrl.clear();
      amountCtrl.clear();
      remarkCtrl.clear();
      selectedPaymentMode = 'cash';
      selectedPaymentStatus = 'pending';
      selectedUserId = null;
    }
    update();
  }

  // ── Submit Collection Form (Add / Edit) ───────────────────────────────────
  Future<void> submitCollection() async {
    if (formKey.currentState != null && !formKey.currentState!.validate()) {
      return;
    }

    // Determine userid based on requirement:
    // If logged in as User role: send the logged-in User's User ID
    // If logged in as Admin role: send selected user's ID
    String effectiveUserId = '';
    if (RoleUtils.isUser(roleName)) {
      effectiveUserId = userId;
    } else if (RoleUtils.isAdmin(roleName)) {
      if (selectedUserId == null || selectedUserId!.isEmpty) {
        Utility.showMessage('Please select a user', MessageType.error, null, '');
        return;
      }
      effectiveUserId = selectedUserId!;
    }

    Utility.showLoader();

    final result = await Get.find<Repository>().createCollectionApi(
      collectionid: editingCollectionId.isNotEmpty ? editingCollectionId : '',
      date: dateCtrl.text.trim(),
      userid: effectiveUserId,
      partyname: partyNameCtrl.text.trim(),
      amount: amountCtrl.text.trim(),
      paymentmode: selectedPaymentMode,
      paymentstatus: selectedPaymentStatus,
      remark: remarkCtrl.text.trim(),
      isLoading: false,
    );

    Utility.closeLoader();

    if (result != null) {
      Utility.showMessage(
        editingCollectionId.isNotEmpty
            ? 'Collection updated successfully'
            : 'Collection created successfully',
        MessageType.information,
        null,
        '',
      );
      Get.back();
      fetchCollections(isRefresh: true);
    }
  }

  // ── Change Payment Status ──────────────────────────────────────────────────
  Future<void> changeStatus(String collectionId, String newStatus) async {
    Utility.showLoader();
    final success = await Get.find<Repository>().changeCollectionStatusApi(
      collectionid: collectionId,
      paymentstatus: newStatus,
      isLoading: false,
    );
    Utility.closeLoader();

    if (success) {
      Utility.showMessage(
        'Status updated successfully',
        MessageType.information,
        null,
        '',
      );
      fetchCollections(isRefresh: true);
    }
  }

  // ── Delete Collection ──────────────────────────────────────────────────────
  Future<void> deleteCollection(String collectionId) async {
    Utility.showLoader();
    final success = await Get.find<Repository>().deleteCollectionApi(
      collectionid: collectionId,
      isLoading: false,
    );
    Utility.closeLoader();

    if (success) {
      Utility.showMessage(
        'Collection deleted successfully',
        MessageType.information,
        null,
        '',
      );
      fetchCollections(isRefresh: true);
    }
  }

  // ── Fetch One Collection ───────────────────────────────────────────────────
  Future<CollectionDoc?> getOneCollection(String collectionId) async {
    Utility.showLoader();
    final res = await Get.find<Repository>().getOneCollectionApi(
      collectionid: collectionId,
      isLoading: false,
    );
    Utility.closeLoader();
    return res?.data;
  }
}
