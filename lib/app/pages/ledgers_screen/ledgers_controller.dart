import 'dart:async';
import 'package:agro_app/app/app.dart';
import 'package:agro_app/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class LedgersController extends GetxController {
  // ── Ledgers list state ────────────────────────────────────────────────────
  List<LedgerDoc> ledgers = [];
  bool isLoading = false;
  bool isFetchingMore = false;
  int currentPage = 1;
  int totalPages = 1;
  int limit = 15;
  String searchQuery = '';
  Timer? _debounceTimer;

  // ── Statement/Entries state ──────────────────────────────────────────────
  List<LedgerEntryDoc> statementEntries = [];
  bool isStatementLoading = false;
  bool isFetchingMoreStatement = false;
  int statementCurrentPage = 1;
  int statementTotalPages = 1;
  int statementTotalDocs = 0;
  int statementLimit = 15;

  double totalDebit = 0.0;
  double totalCredit = 0.0;
  double outstandingBalance = 0.0;

  @override
  void onInit() {
    super.onInit();
    fetchLedgers(isRefresh: true);
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  void onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      searchQuery = query;
      fetchLedgers(isRefresh: true);
    });
  }

  Future<void> fetchLedgers({bool isRefresh = true}) async {
    if (isRefresh) {
      currentPage = 1;
      ledgers.clear();
      isLoading = true;
    } else {
      if (currentPage >= totalPages) return;
      currentPage++;
      isFetchingMore = true;
    }
    update();

    try {
      final savedBranchId = await Get.find<Repository>().getSecureValue(
        LocalKeys.selectedBranchId,
      );
      final branchId = savedBranchId.isNotEmpty
          ? savedBranchId
          : 'e86c9627-2d96-4eab-9784-6afe9a6811d8';

      final res = await Get.find<Repository>().getLedgerListApi(
        page: currentPage,
        limit: limit,
        search: searchQuery,
        branchid: branchId,
        name: [],
        parent: [],
        isLoading: false,
      );

      if (res != null && res.data != null && res.data!.docs != null) {
        if (isRefresh) {
          ledgers = res.data!.docs!;
        } else {
          ledgers.addAll(res.data!.docs!);
        }
        totalPages = res.data!.totalPages ?? 1;
      }
    } catch (e) {
      debugPrint('[LedgersController] fetchLedgers error: $e');
    } finally {
      isLoading = false;
      isFetchingMore = false;
      update();
    }
  }

  // ── Fetch Detailed Ledger Entries from api/ledgerentry/list ──────────────────
  Future<void> fetchStatement(String ledgerName, String branchId, {bool isRefresh = true}) async {
    if (isRefresh) {
      statementCurrentPage = 1;
      statementEntries.clear();
      isStatementLoading = true;
      totalDebit = 0.0;
      totalCredit = 0.0;
      outstandingBalance = 0.0;
    } else {
      if (statementCurrentPage >= statementTotalPages) return;
      statementCurrentPage++;
      isFetchingMoreStatement = true;
    }
    update();

    try {
      final actualBranchId = branchId.isNotEmpty
          ? branchId
          : 'e86c9627-2d96-4eab-9784-6afe9a6811d8';

      final res = await Get.find<Repository>().getLedgerEntryListApi(
        ledgerName: ledgerName,
        branchid: actualBranchId,
        page: statementCurrentPage,
        limit: statementLimit,
        particulars: [],
        vouchertypes: [],
        voucherno: [],
        isLoading: false,
      );

      if (res != null && res.data != null && res.data!.docs != null) {
        if (isRefresh) {
          statementEntries = res.data!.docs!;
        } else {
          statementEntries.addAll(res.data!.docs!);
        }
        statementTotalPages = res.data!.totalPages ?? 1;
        statementTotalDocs = res.data!.totalDocs ?? statementEntries.length;

        // Calculate running totals on all fetched items
        totalDebit = 0.0;
        totalCredit = 0.0;
        for (var entry in statementEntries) {
          final deb = double.tryParse(entry.debit?.toString() ?? '0') ?? 0.0;
          final cred = double.tryParse(entry.credit?.toString() ?? '0') ?? 0.0;
          totalDebit += deb;
          totalCredit += cred;
        }

        // Outstanding Balance is the balance of the most recent transaction entry
        if (statementEntries.isNotEmpty) {
          final lastEntry = statementEntries.first; // APIs usually return newest or oldest first
          outstandingBalance = double.tryParse(lastEntry.balance?.toString() ?? '0') ?? (totalDebit - totalCredit);
        } else {
          outstandingBalance = totalDebit - totalCredit;
        }
      }
    } catch (e) {
      debugPrint('[LedgersController] fetchStatement error: $e');
    } finally {
      isStatementLoading = false;
      isFetchingMoreStatement = false;
      update();
    }
  }

  // Helper method to format date cleanly
  String formatEntryDate(String? rawDate, String? dateStr) {
    if (dateStr != null && dateStr.isNotEmpty) return dateStr;
    if (rawDate == null || rawDate.isEmpty) return 'N/A';
    try {
      final parsed = DateTime.parse(rawDate);
      return DateFormat('dd MMM yyyy').format(parsed);
    } catch (_) {
      return rawDate;
    }
  }

  // ── PDF statement generation ──────────────────────────────────────────────
  Future<void> generateAndPreviewPdf(String ledgerName, String branchId) async {
    try {
      Utility.showLoader();

      // Step 1: Fetch ALL entries by calling API with page=1 and limit=totalDocs
      final fetchLimit = statementTotalDocs > 0 ? statementTotalDocs : 10000;
      final actualBranchId = branchId.isNotEmpty
          ? branchId
          : 'e86c9627-2d96-4eab-9784-6afe9a6811d8';

      final res = await Get.find<Repository>().getLedgerEntryListApi(
        ledgerName: ledgerName,
        branchid: actualBranchId,
        page: 1,
        limit: fetchLimit,
        particulars: [],
        vouchertypes: [],
        voucherno: [],
        isLoading: false,
      );

      List<LedgerEntryDoc> allEntries = [];
      if (res != null && res.data != null && res.data!.docs != null) {
        allEntries = res.data!.docs!;
      }

      if (allEntries.isEmpty) {
        Utility.closeDialog();
        Utility.showMessage('No entries found to generate PDF', MessageType.error, null, '');
        return;
      }

      // Calculate totals from all fetched entries
      double pdfTotalDebit = 0.0;
      double pdfTotalCredit = 0.0;
      for (var entry in allEntries) {
        final deb = double.tryParse(entry.debit?.toString() ?? '0') ?? 0.0;
        final cred = double.tryParse(entry.credit?.toString() ?? '0') ?? 0.0;
        pdfTotalDebit += deb;
        pdfTotalCredit += cred;
      }

      // Extract branch/company name from entries branchid object
      String companyName = ledgerName;
      if (allEntries.isNotEmpty && allEntries.first.branchid is Map) {
        companyName = allEntries.first.branchid['name']?.toString() ?? ledgerName;
      }

      final todayDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

      // Step 2: Build PDF matching the reference design
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageTheme: pw.PageTheme(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(24),
            buildBackground: (context) => pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 1.5),
              ),
            ),
          ),
          build: (context) => [
            pw.Container(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  // Company name header
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(vertical: 16),
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(color: PdfColors.black, width: 1),
                      ),
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        companyName.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Ledger name + Date row
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          ledgerName,
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Date: $todayDate',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Table
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(1.5),  // Date
                      1: const pw.FlexColumnWidth(3.5),  // Particulars
                      2: const pw.FlexColumnWidth(1.8),  // Voucher Type
                      3: const pw.FlexColumnWidth(1.5),  // Voucher No
                      4: const pw.FlexColumnWidth(1.5),  // Debit (DR)
                      5: const pw.FlexColumnWidth(1.5),  // Credit (CR)
                    },
                    children: [
                      // Header row
                      pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#F5F5F5'),
                        ),
                        children: [
                          _pdfHeaderCell('DATE'),
                          _pdfHeaderCell('PARTICULARS'),
                          _pdfHeaderCell('VOUCHER TYPE'),
                          _pdfHeaderCell('VOUCHER NO'),
                          _pdfHeaderCell('DEBIT (DR)'),
                          _pdfHeaderCell('CREDIT (CR)'),
                        ],
                      ),
                      // Data rows
                      ...allEntries.map((txn) {
                        final deb = double.tryParse(txn.debit?.toString() ?? '0') ?? 0.0;
                        final cred = double.tryParse(txn.credit?.toString() ?? '0') ?? 0.0;
                        final particularsText = txn.particulars?.isNotEmpty == true
                            ? txn.particulars!
                            : (txn.particular ?? '');

                        return pw.TableRow(
                          children: [
                            _pdfDataCell(formatEntryDate(txn.date, txn.dateString)),
                            _pdfDataCell(particularsText),
                            _pdfDataCell(txn.vouchertype ?? ''),
                            _pdfDataCell(txn.voucherno ?? ''),
                            _pdfDataCell(deb > 0 ? deb.toStringAsFixed(2) : ''),
                            _pdfDataCell(cred > 0 ? cred.toStringAsFixed(2) : ''),
                          ],
                        );
                      }),
                      // Totals row
                      pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#F5F5F5'),
                        ),
                        children: [
                          _pdfHeaderCell(''),
                          _pdfHeaderCell(''),
                          _pdfHeaderCell(''),
                          _pdfHeaderCell('TOTAL'),
                          _pdfHeaderCell(pdfTotalDebit.toStringAsFixed(2)),
                          _pdfHeaderCell(pdfTotalCredit.toStringAsFixed(2)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );

      final pdfBytes = await pdf.save();
      Utility.closeDialog();

      final safeName = ledgerName.replaceAll(RegExp(r'[^\w\s\-]'), '').replaceAll(' ', '_');
      RouteManagement.goToLedgerPdfPreviewScreen(
        pdfBytes,
        'Statement_${safeName}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
      );
    } catch (e) {
      Utility.closeDialog();
      Utility.showMessage('Failed to generate PDF: $e', MessageType.error, null, '');
    }
  }

  // ── PDF helper widgets ────────────────────────────────────────────────────
  pw.Widget _pdfHeaderCell(String text, {PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: pw.FontWeight.bold,
          color: color ?? PdfColors.black,
        ),
      ),
    );
  }

  pw.Widget _pdfDataCell(String text, {PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 7,
          color: color,
        ),
      ),
    );
  }
}
