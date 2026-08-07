import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:agro_app/app/app.dart';
import 'package:agro_app/domain/domain.dart';

class LedgerStatementScreen extends StatefulWidget {
  const LedgerStatementScreen({super.key});

  @override
  State<LedgerStatementScreen> createState() => _LedgerStatementScreenState();
}

class _LedgerStatementScreenState extends State<LedgerStatementScreen> {
  late String ledgerName;
  late String savedBranchId;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    ledgerName = args['partyName'] ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      savedBranchId = await Get.find<Repository>().getSecureValue(
        LocalKeys.selectedBranchId,
      );
      Get.find<LedgersController>().fetchStatement(
        ledgerName,
        savedBranchId,
        isRefresh: true,
      );
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      Get.find<LedgersController>().fetchStatement(
        ledgerName,
        savedBranchId,
        isRefresh: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LedgersController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.bgMain,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Get.back(),
            ),
            title: Text(
              "Ledger",
              style: Styles.txtBlackColorW70020,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              if (controller.statementEntries.isNotEmpty &&
                  !controller.isStatementLoading)
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.picture_as_pdf,
                    color: ColorsValue.primary,
                  ),
                  onSelected: (value) {
                    if (value == 'normal') {
                      controller.generateAndPreviewPdf(
                        ledgerName,
                        savedBranchId,
                        isDetailed: false,
                      );
                    } else if (value == 'detailed') {
                      controller.generateAndPreviewPdf(
                        ledgerName,
                        savedBranchId,
                        isDetailed: true,
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'normal',
                      child: Text('Normal'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'detailed',
                      child: Text('Detailed'),
                    ),
                  ],
                ),
              const SizedBox(width: 8),
            ],
          ),
          body: controller.isStatementLoading
              ? const Center(
                  child: CircularProgressIndicator(color: ColorsValue.primary),
                )
              : Column(
                  children: [
                    // Summary Header Card
                    _buildSummaryCard(controller),

                    // Date Filter Row
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: controller.statementFromDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  controller.statementFromDate = picked;
                                  controller.fetchStatement(ledgerName, savedBranchId, isRefresh: true);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      controller.statementFromDate == null
                                          ? 'From Date'
                                          : DateFormat('dd-MM-yyyy').format(controller.statementFromDate!),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: controller.statementFromDate != null ? Colors.black87 : Colors.grey,
                                      ),
                                    ),
                                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('to', style: TextStyle(color: Colors.grey)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: controller.statementToDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  controller.statementToDate = picked;
                                  controller.fetchStatement(ledgerName, savedBranchId, isRefresh: true);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      controller.statementToDate == null
                                          ? 'To Date'
                                          : DateFormat('dd-MM-yyyy').format(controller.statementToDate!),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: controller.statementToDate != null ? Colors.black87 : Colors.grey,
                                      ),
                                    ),
                                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Ledger entries list
                    Expanded(
                      child: controller.statementEntries.isEmpty
                          ? const Center(
                              child: Text(
                                'No entries found in this ledger.',
                                style: TextStyle(color: ColorsValue.textMuted),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () => controller.fetchStatement(
                                ledgerName,
                                savedBranchId,
                                isRefresh: true,
                              ),
                              child: ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.only(bottom: 24),
                                itemCount:
                                    controller.statementEntries.length +
                                    (controller.isFetchingMoreStatement
                                        ? 1
                                        : 0),
                                itemBuilder: (context, index) {
                                  if (index ==
                                      controller.statementEntries.length) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: ColorsValue.primary,
                                        ),
                                      ),
                                    );
                                  }
                                  final item =
                                      controller.statementEntries[index];
                                  return _buildEntryRow(controller, item);
                                },
                              ),
                            ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildSummaryCard(LedgersController controller) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            ledgerName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ColorsValue.textH1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Total Debits',
                      style: TextStyle(
                        fontSize: 11,
                        color: ColorsValue.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₹${controller.totalDebit.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: ColorsValue.textH2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 26, color: Colors.grey.shade300),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Total Credits',
                      style: TextStyle(
                        fontSize: 11,
                        color: ColorsValue.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₹${controller.totalCredit.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: ColorsValue.textH2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEntryRow(LedgersController controller, LedgerEntryDoc item) {
    final deb = double.tryParse(item.debit?.toString() ?? '0') ?? 0.0;
    final cred = double.tryParse(item.credit?.toString() ?? '0') ?? 0.0;
    final dateStr = controller.formatEntryDate(item.date, item.dateString);

    final isDebit = deb > 0;
    final amount = isDebit ? deb : cred;
    final typeText =
        item.vouchertype?.toUpperCase() ?? (isDebit ? 'DEBIT' : 'CREDIT');

    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showTransactionDetailsBottomSheet(context, item),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: isDebit
                    ? ColorsValue.statusCancelled.withValues(alpha: 0.1)
                    : ColorsValue.statusComplete.withValues(alpha: 0.1),
                child: Icon(
                  isDebit ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isDebit
                      ? ColorsValue.statusCancelled
                      : ColorsValue.statusComplete,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.particulars?.isNotEmpty == true
                          ? item.particulars!
                          : (item.particular?.isNotEmpty == true
                                ? item.particular!
                                : 'Ledger Transaction'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: ColorsValue.textH2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            typeText,
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        if (item.voucherno != null &&
                            item.voucherno!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            '#${item.voucherno}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: ColorsValue.textBody,
                            ),
                          ),
                        ],
                        const SizedBox(width: 8),
                        Text(
                          dateStr,
                          style: const TextStyle(
                            fontSize: 10,
                            color: ColorsValue.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDebit
                          ? ColorsValue.statusCancelled
                          : ColorsValue.statusComplete,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => _shareEntryDetails(controller, item),
                    child: Icon(
                      Icons.share,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareEntryDetails(LedgersController controller, LedgerEntryDoc item) async {
    try {
      Utility.showLoader();
      final pdfBytes = await controller.generateSingleEntryPdf(
        item,
        item.ledgerName ?? ledgerName,
      );
      Utility.closeDialog();

      final safeName = (item.ledgerName ?? ledgerName)
          .replaceAll(RegExp(r'[^\w\s\-]'), '')
          .replaceAll(' ', '_');
      final safeVoucherNo = (item.voucherno ?? "N_A")
          .replaceAll(RegExp(r'[^\w\s\-]'), '_')
          .replaceAll(' ', '_');
      final fileName = 'Voucher_${safeName}_$safeVoucherNo.pdf';

      // Write bytes to temporary cache directory
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pdfBytes);

      final params = ShareParams(
        files: [
          XFile(file.path),
        ],
      );
      await SharePlus.instance.share(params);
    } catch (e) {
      Utility.closeDialog();
      Utility.showMessage(
        'Failed to generate shareable PDF: $e',
        MessageType.error,
        null,
        '',
      );
    }
  }

  void _showTransactionDetailsBottomSheet(
    BuildContext context,
    LedgerEntryDoc item,
  ) {
    final voucherno = item.voucherno ?? '';
    final deb = double.tryParse(item.debit?.toString() ?? '0') ?? 0.0;
    final cred = double.tryParse(item.credit?.toString() ?? '0') ?? 0.0;
    final isDebit = deb > 0;
    final amount = isDebit ? deb : cred;
    final particularText = item.particulars?.isNotEmpty == true
        ? item.particulars!
        : (item.particular?.isNotEmpty == true
              ? item.particular!
              : 'Ledger Transaction Details');

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.vouchertype?.toUpperCase() ?? 'VOUCHER DETAIL',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: ColorsValue.primary,
                          ),
                        ),
                        if (voucherno.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            '#$voucherno',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ColorsValue.textH1,
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '₹${amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDebit
                            ? ColorsValue.statusCancelled
                            : ColorsValue.statusComplete,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                const Text(
                  'Particulars:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: ColorsValue.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  particularText,
                  style: const TextStyle(
                    fontSize: 13,
                    color: ColorsValue.textH2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Date:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: ColorsValue.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Get.find<LedgersController>().formatEntryDate(
                    item.date,
                    item.dateString,
                  ),
                  style: const TextStyle(
                    fontSize: 13,
                    color: ColorsValue.textH2,
                  ),
                ),
                const SizedBox(height: 16),
                if (item.items != null && item.items!.isNotEmpty) ...[
                  const Divider(height: 16),
                  Text(
                    'Items (${item.items!.length}):',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: ColorsValue.textH1,
                    ),
                  ),
                  const SizedBox(height: 8),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: item.items!.length,
                    itemBuilder: (context, idx) {
                      final orderItem = item.items![idx];
                      final pName = orderItem.productName?.isNotEmpty == true
                          ? orderItem.productName!
                          : 'Product ${idx + 1}';
                      final qty =
                          double.tryParse(
                            orderItem.quantity?.toString() ?? '0',
                          ) ??
                          0.0;
                      final price =
                          double.tryParse(orderItem.rate?.toString() ?? '0') ??
                          0.0;
                      final itemAmt =
                          double.tryParse(
                            orderItem.amount?.toString() ?? '0',
                          ) ??
                          (qty * price);

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ColorsValue.bgMain,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: ColorsValue.textH2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${qty.toStringAsFixed(0)} x ₹${price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: ColorsValue.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '₹${itemAmt.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: ColorsValue.textH2,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ] else ...[
                  const Divider(height: 16),
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        'No items associated with this entry type.',
                        style: TextStyle(
                          fontSize: 11,
                          color: ColorsValue.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
