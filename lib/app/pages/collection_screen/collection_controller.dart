import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:agro_app/app/utils/utility.dart';
import 'package:agro_app/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'collection_pdf_preview_page.dart';

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

  List<Doc> distributors = [];
  String? selectedDistributorId;

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

  static const List<String> paymentModeOptions = [
    'cash',
    'cheque',
    'rtgs/neft',
  ];
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
      fetchDistributors();
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
        userList = docs
            .where((u) => RoleUtils.isUser(u.roleid.rolename))
            .toList();
        update();
      }
    } catch (e) {
      debugPrint('fetchUserList error: $e');
    }
  }

  // ── Fetch Distributors / Dealers ──────────────────────────────────────────
  Future<void> fetchDistributors() async {
    try {
      final response = await Get.find<Repository>().getUsersListApi(
        page: 1,
        limit: 100,
        type: 'dealer',
        isLoading: false,
      );
      if (response != null && response.isSuccess) {
        distributors = response.data.docs;
        _matchSelectedDistributor();
        update();
      }
    } catch (e) {
      debugPrint('[Collection] fetchDistributors error: $e');
    }
  }

  void _matchSelectedDistributor() {
    if (partyNameCtrl.text.isNotEmpty && (selectedDistributorId == null || selectedDistributorId!.isEmpty)) {
      // Try matching by ID first
      for (var d in distributors) {
        if (d.id == partyNameCtrl.text.trim()) {
          selectedDistributorId = d.id;
          partyNameCtrl.text = d.name;
          return;
        }
      }
      // Otherwise, match by name
      for (var d in distributors) {
        if (d.name.toLowerCase().trim() == partyNameCtrl.text.toLowerCase().trim()) {
          selectedDistributorId = d.id;
          break;
        }
      }
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
      editingCollectionId = collection.id ?? '';
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
      partyNameCtrl.text = collection.partyname?.name ?? '';
      selectedDistributorId = null;
      _matchSelectedDistributor();
      amountCtrl.text = collection.amount?.toString() ?? '';
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
      selectedDistributorId = null;
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
        Utility.showMessage(
          'Please select a user',
          MessageType.error,
          null,
          '',
        );
        return;
      }
      effectiveUserId = selectedUserId!;
    }

    Utility.showLoader();

    final result = await Get.find<Repository>().createCollectionApi(
      collectionid: editingCollectionId.isNotEmpty ? editingCollectionId : '',
      date: dateCtrl.text.trim(),
      userid: effectiveUserId,
      partyname: selectedDistributorId ?? partyNameCtrl.text.trim(),
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



  // ── Format Date for Collection Screen ──────────────────────────────────────
  String formatCollectionDate(String? dateStr) {
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
          child: pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
        ),
      ],
    );
  }

  // ── Generate and Download PDF ──────────────────────────────────────────────
  Future<void> generateAndDownloadPdf(CollectionDoc item) async {
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
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              item.branchid?.name != null
                                  ? Utility.cleanBranchName(item.branchid!.name!)
                                  : 'Collection Receipt',
                              style: pw.TextStyle(
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.green800,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'Collection Receipt',
                              style: pw.TextStyle(
                                fontSize: 12,
                                color: PdfColors.grey600,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 16),
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
                  pw.Divider(
                    thickness: 1.5,
                    color: PdfColors.green800,
                    height: 24,
                  ),

                  // Transaction Details Header
                  pw.Text(
                    'Transaction Details',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green800,
                    ),
                  ),
                  pw.SizedBox(height: 12),

                  // Details Table
                  pw.Table(
                    border: pw.TableBorder.all(
                      color: PdfColors.grey300,
                      width: 0.5,
                    ),
                    columnWidths: {
                      0: const pw.FixedColumnWidth(150),
                      1: const pw.FlexColumnWidth(),
                    },
                    children: [
                      _buildTableRow('Receipt No', item.receiptno ?? 'N/A'),
                      _buildTableRow('Party Name', item.partyname?.name ?? 'N/A'),
                      _buildTableRow('Amount', 'Rs. ${item.amount ?? 0}'),
                      _buildTableRow(
                        'Payment Mode',
                        (item.paymentmode ?? 'N/A').toUpperCase(),
                      ),
                      _buildTableRow(
                        'Payment Status',
                        (item.paymentstatus ?? 'N/A').toUpperCase(),
                      ),
                      _buildTableRow('Remark', item.remark ?? 'N/A'),
                    ],
                  ),
                  pw.SizedBox(height: 24),

                  // Collector Section
                  if (item.userid != null) ...[
                    pw.Text(
                      'Collected By',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey800,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Table(
                      border: pw.TableBorder.all(
                        color: PdfColors.grey300,
                        width: 0.5,
                      ),
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
                      'Thank you for your transaction.',
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
      final sanitizedParty = (item.partyname?.name ?? 'unknown').replaceAll(
        RegExp(r'[^a-zA-Z0-9]'),
        '_',
      );
      final fileName =
          'collection_${sanitizedParty}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      Utility.closeLoader();
      Get.to(
        () => CollectionPdfPreviewPage(pdfBytes: pdfBytes, fileName: fileName),
      );
    } catch (e) {
      Utility.closeLoader();
      Utility.showMessage(
        'Failed to generate PDF: $e',
        MessageType.error,
        null,
        '',
      );
    }
  }
}
