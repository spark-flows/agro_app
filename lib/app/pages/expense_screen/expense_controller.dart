import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:agro_app/app/utils/utility.dart';
import 'package:agro_app/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'expense_pdf_preview_page.dart';

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
  List<Doc> userList = [];
  String? selectedUserId;

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
      selectedUserId = expense.userid?.id;
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
      selectedUserId = null;
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
      if (selectedUserId == null || selectedUserId!.isEmpty) {
        Utility.showMessage('Please select a user', MessageType.error, null, '');
        return;
      }
      effectiveUserId = selectedUserId!;
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

  // ── Format Date for Expense Screen ─────────────────────────────────────────
  String formatExpenseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final parsed = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(parsed);
    } catch (_) {
      try {
        final parsed = DateFormat('dd-MM-yyyy').parse(dateStr);
        return DateFormat('dd/MM/yyyy').format(parsed);
      } catch (_) {
        try {
          final parsed = DateFormat('yyyy-MM-dd').parse(dateStr);
          return DateFormat('dd/MM/yyyy').format(parsed);
        } catch (_) {
          return dateStr;
        }
      }
    }
  }

  // ── Format Date for PDF ────────────────────────────────────────────────────
  String _formatPdfDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final parsed = DateTime.parse(dateStr);
      return DateFormat('dd/M/yyyy').format(parsed);
    } catch (_) {
      try {
        final parsed = DateFormat('dd-MM-yyyy').parse(dateStr);
        return DateFormat('dd/M/yyyy').format(parsed);
      } catch (_) {
        try {
          final parsed = DateFormat('yyyy-MM-dd').parse(dateStr);
          return DateFormat('dd/M/yyyy').format(parsed);
        } catch (_) {
          return dateStr;
        }
      }
    }
  }

  // ── Table Row Helper ───────────────────────────────────────────────────────
  pw.TableRow _buildTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 11),
          ),
        ),
      ],
    );
  }

  // ── Generate and Download PDF ──────────────────────────────────────────────
  Future<void> generateAndDownloadPdf(ExpenseDoc item) async {
    try {
      Utility.showLoader();
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.copyWith(
            marginLeft: 20,
            marginRight: 20,
            marginTop: 20,
            marginBottom: 20,
          ),
          build: (pw.Context context) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400, width: 1),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Brand Header
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'AGRO APP',
                            style: pw.TextStyle(
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.red800,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Expense Voucher',
                            style: pw.TextStyle(
                              fontSize: 14,
                              color: PdfColors.grey600,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'Date: ${_formatPdfDate(item.date)}',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.Divider(thickness: 1.5, color: PdfColors.red800, height: 24),

                  // Voucher Details
                  pw.Text(
                    'Expense Details',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red800,
                    ),
                  ),
                  pw.SizedBox(height: 12),

                  // Table
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                    columnWidths: {
                      0: const pw.FixedColumnWidth(150),
                      1: const pw.FlexColumnWidth(),
                    },
                    children: [
                      _buildTableRow('Particular / Expense', item.particularid?.name ?? 'N/A'),
                      _buildTableRow('Amount', 'Rs. ${item.amount ?? '0'}'),
                      _buildTableRow('Status', (item.status ?? 'PENDING').toUpperCase()),
                      _buildTableRow('Remark', item.remark ?? 'N/A'),
                    ],
                  ),
                  pw.SizedBox(height: 24),

                  // Submitter Section
                  if (item.userid != null) ...[
                    pw.Text(
                      'Submitted By',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey800,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Table(
                      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                      columnWidths: {
                        0: const pw.FixedColumnWidth(150),
                        1: const pw.FlexColumnWidth(),
                      },
                      children: [
                        _buildTableRow('Name', item.userid?.name ?? 'N/A'),
                        _buildTableRow('Mobile', item.userid?.mobile ?? 'N/A'),
                        _buildTableRow('Email', item.userid?.email ?? 'N/A'),
                      ],
                    ),
                  ],

                  pw.Spacer(),
                  pw.Divider(thickness: 1, color: PdfColors.grey300),
                  pw.SizedBox(height: 8),
                  pw.Align(
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                       'Verified Expense Record.',
                       style: pw.TextStyle(
                         fontSize: 10,
                         fontStyle: pw.FontStyle.italic,
                         color: PdfColors.grey600,
                       ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      final pdfBytes = await pdf.save();
      final sanitizedParticular = (item.particularid?.name ?? 'unknown').replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final fileName = 'expense_${sanitizedParticular}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      Utility.closeLoader();
      Get.to(() => ExpensePdfPreviewPage(
            pdfBytes: pdfBytes,
            fileName: fileName,
          ));
    } catch (e) {
      Utility.closeLoader();
      Utility.showMessage('Failed to generate PDF: $e', MessageType.error, null, '');
    }
  }
}
