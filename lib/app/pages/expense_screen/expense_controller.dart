import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:agro_app/app/utils/utility.dart';
import 'package:agro_app/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class ExpenseController extends GetxController {
  // ── List & Pagination State ──────────────────────────────────────────────
  List<ExpenseDoc> expenses = [];
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

  // ── Role & User Context ──────────────────────────────────────────────────
  String roleName = '';
  String userId = '';

  // ── Form Controllers & State ─────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();
  final dateCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final remarkCtrl = TextEditingController();

  String selectedParticularId = '';
  File? selectedImage;
  String? existingImageUrl;

  String editingExpenseId = '';
  Timer? _searchTimer;

  List<ParticularDoc> particulars = [];

  @override
  void onInit() {
    super.onInit();
    _loadUserContext().then((_) {
      fetchParticulars();
      fetchExpenses(isRefresh: true);
    });
  }

  Future<void> fetchParticulars() async {
    try {
      final res = await Get.find<Repository>().getParticularListApi(
        isLoading: false,
      );
      if (res != null && res.data != null) {
        particulars = res.data!;
        update();
      }
    } catch (e) {
      debugPrint('fetchParticulars error: $e');
    }
  }

  @override
  void onClose() {
    _searchTimer?.cancel();
    dateCtrl.dispose();
    amountCtrl.dispose();
    remarkCtrl.dispose();
    super.onClose();
  }

  // ── Load Role & User ID from Storage / Profile API ─────────────────────────
  Future<void> _loadUserContext() async {
    roleName = await Get.find<Repository>().getSecureValue(LocalKeys.roleName);

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
    update();
  }

  // ── Fetch Expenses ────────────────────────────────────────────────────────
  Future<void> fetchExpenses({bool isRefresh = true}) async {
    if (isRefresh) {
      currentPage = 1;
      expenses.clear();
      isLoading = true;
    } else {
      if (currentPage >= totalPages) return;
      currentPage++;
      isFetchingMore = true;
    }
    update();

    try {
      final response = await Get.find<Repository>().getExpenseListApi(
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
          expenses = docs;
        } else {
          expenses.addAll(docs);
        }
        totalPages = response.data!.totalPages ?? 1;
      }
    } catch (e) {
      debugPrint('fetchExpenses error: $e');
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
      fetchExpenses(isRefresh: true);
    });
  }

  void setDateRange(DateTime? from, DateTime? to) {
    filterFromDate = from;
    filterToDate = to;
    fetchExpenses(isRefresh: true);
  }

  String? filterStatus;

  void applyFilters(DateTime? from, DateTime? to, String? status) {
    filterFromDate = from;
    filterToDate = to;
    filterStatus = status;
    fetchExpenses(isRefresh: true);
  }

  List<ExpenseDoc> get filteredExpenses {
    if (filterStatus == null || filterStatus!.isEmpty) {
      return expenses;
    }
    return expenses
        .where(
          (e) =>
              e.status?.toLowerCase().trim() ==
              filterStatus!.toLowerCase().trim(),
        )
        .toList();
  }

  // ── Image Picker Helpers ──────────────────────────────────────────────────
  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      selectedImage = File(image.path);
      update();
    }
  }

  void removeImage() {
    selectedImage = null;
    existingImageUrl = null;
    update();
  }

  // ── Prepare Form Page ─────────────────────────────────────────────────────
  void prepareForm([ExpenseDoc? expense]) {
    if (expense != null) {
      editingExpenseId = expense.id ?? expense.expenseid ?? '';
      if (expense.date != null && expense.date!.isNotEmpty) {
        final parsedDate = DateTime.tryParse(expense.date!);
        if (parsedDate != null) {
          dateCtrl.text = DateFormat('yyyy-MM-dd').format(parsedDate.toLocal());
        } else {
          dateCtrl.text = expense.date!;
        }
      } else {
        dateCtrl.text = '';
      }
      amountCtrl.text = expense.amount ?? '';
      remarkCtrl.text = expense.remark ?? '';
      selectedParticularId = expense.particularid?.id ?? '';
      existingImageUrl = expense.image ?? '';
      selectedImage = null;
    } else {
      editingExpenseId = '';
      dateCtrl.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
      amountCtrl.clear();
      remarkCtrl.clear();
      selectedParticularId = particulars.isNotEmpty
          ? particulars.first.id ?? ''
          : '';
      selectedImage = null;
      existingImageUrl = null;
    }
    update();
  }

  // ── Submit Expense Form (Add / Edit) ──────────────────────────────────────
  Future<void> submitExpense() async {
    if (formKey.currentState != null && !formKey.currentState!.validate()) {
      return;
    }

    if (selectedParticularId.isEmpty) {
      Utility.showMessage(
        'Please select a particular',
        MessageType.error,
        null,
        '',
      );
      return;
    }

    Utility.showLoader();

    // 1. Upload image if a new one is selected
    String finalImageUrl = existingImageUrl ?? '';
    if (selectedImage != null) {
      final uploadRes = await Get.find<Repository>().uploadExpenseImageApi(
        selectedImage!,
        isLoading: false,
      );
      if (uploadRes != null &&
          uploadRes.data != null &&
          uploadRes.data!.url != null) {
        finalImageUrl = uploadRes.data!.url!;
      } else {
        Utility.closeDialog();
        Utility.showMessage(
          'Failed to upload image. Please try again.',
          MessageType.error,
          null,
          '',
        );
        return;
      }
    }

    String effectiveUserId = '';
    if (RoleUtils.isUser(roleName)) {
      effectiveUserId = userId;
    } else if (RoleUtils.isAdmin(roleName)) {
      effectiveUserId = '';
    }

    final result = await Get.find<Repository>().createExpenseApi(
      expenseid: editingExpenseId.isNotEmpty ? editingExpenseId : '',
      date: dateCtrl.text.trim(),
      userid: effectiveUserId,
      particularid: selectedParticularId,
      amount: amountCtrl.text.trim(),
      image: finalImageUrl,
      remark: remarkCtrl.text.trim(),
      isLoading: false,
    );

    Utility.closeLoader();

    if (result != null) {
      Utility.showMessage(
        editingExpenseId.isNotEmpty
            ? 'Expense updated successfully'
            : 'Expense created successfully',
        MessageType.information,
        null,
        '',
      );
      Get.back();
      fetchExpenses(isRefresh: true);
    }
  }

  // ── Delete Expense ────────────────────────────────────────────────────────
  Future<void> deleteExpense(String expenseId) async {
    Utility.showLoader();
    final success = await Get.find<Repository>().deleteExpenseApi(
      expenseid: expenseId,
      isLoading: false,
    );
    Utility.closeLoader();

    if (success) {
      Utility.showMessage(
        'Expense deleted successfully',
        MessageType.information,
        null,
        '',
      );
      fetchExpenses(isRefresh: true);
    }
  }

  // ── Change Status ─────────────────────────────────────────────────────────
  Future<void> changeStatus(String expenseId, String newStatus) async {
    Utility.showLoader();
    final success = await Get.find<Repository>().changeExpenseStatusApi(
      expenseid: expenseId,
      status: newStatus,
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
      fetchExpenses(isRefresh: true);
    }
  }
}
