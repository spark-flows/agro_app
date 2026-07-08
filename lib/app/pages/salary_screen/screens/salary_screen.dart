import 'package:agro_app/app/app.dart';
import 'package:agro_app/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';

class SalaryScreen extends StatefulWidget {
  const SalaryScreen({super.key});

  @override
  State<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends State<SalaryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDisplayDate(String? dateStr) {
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

  Color _getPaymentStatusColor(String? status) {
    if (status == null) return Colors.grey;
    switch (status.toLowerCase().trim()) {
      case 'paid':
        return ColorsValue.statusComplete;
      case 'pending':
        return ColorsValue.statusPending;
      default:
        return Colors.grey;
    }
  }

  Color _getPaymentStatusBgColor(String? status) {
    if (status == null) return Colors.grey.shade50;
    switch (status.toLowerCase().trim()) {
      case 'paid':
        return ColorsValue.statusCompleteBg;
      case 'pending':
        return ColorsValue.statusPendingBg;
      default:
        return Colors.grey.shade50;
    }
  }

  String _getMonthName(String? month) {
    if (month == null || month.isEmpty) return '';
    try {
      final monthNum = int.parse(month);
      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      if (monthNum >= 1 && monthNum <= 12) return months[monthNum - 1];
      return month;
    } catch (_) {
      return month;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SalaryController>(
      initState: (state) {
        var controller = Get.find<SalaryController>();
        controller.salaryPagingController = PagingController(firstPageKey: 1);
        controller.salaryPagingController.addPageRequestListener((pageKey) {
          controller.postSalaryListApi(pageKey);
        });
      },
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.bgMain,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black87),
            title: Text('Salary', style: Styles.txtBlackColorW70020),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ── Search Bar + Filter Button ─────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: controller.searchSalary,
                        decoration: InputDecoration(
                          hintText: 'Search by name, remark...',
                          hintStyle: Styles.txtGreyColorW40014,
                          prefixIcon: const Icon(
                            Icons.search,
                            color: ColorsValue.primary,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    controller.searchSalary('');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: ColorsValue.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: controller.isFilterActive
                                  ? ColorsValue.primary
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.filter_list_rounded,
                              color: controller.isFilterActive
                                  ? ColorsValue.primary
                                  : Colors.grey.shade600,
                            ),
                            onPressed: () =>
                                _showFilterBottomSheet(context, controller),
                          ),
                        ),
                        if (controller.isFilterActive)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: ColorsValue.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Salary List ────────────────────────────────────────────
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      controller.salaryPagingController.refresh();
                    },
                    color: ColorsValue.primary,
                    child: PagedListView<int, SalaryDoc>(
                      pagingController: controller.salaryPagingController,
                      builderDelegate: PagedChildBuilderDelegate<SalaryDoc>(
                        firstPageProgressIndicatorBuilder: (_) => const Center(
                          child: CircularProgressIndicator(
                            color: ColorsValue.primary,
                          ),
                        ),
                        newPageProgressIndicatorBuilder: (_) => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              color: ColorsValue.primary,
                            ),
                          ),
                        ),
                        noItemsFoundIndicatorBuilder: (_) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 64,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No salary records found',
                                style: Styles.txtGreyColorW40014,
                              ),
                            ],
                          ),
                        ),
                        itemBuilder: (context, salary, index) {
                          final statusColor = _getPaymentStatusColor(
                            salary.paymentstatus,
                          );
                          final statusBgColor = _getPaymentStatusBgColor(
                            salary.paymentstatus,
                          );

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey.shade100,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.02,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 20,
                                      right: 16,
                                      top: 16,
                                      bottom: 16,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // ── Header: User Avatar + Name + Action Buttons ──
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: ColorsValue
                                                  .primary
                                                  .withValues(alpha: 0.1),
                                              radius: 18,
                                              child: Text(
                                                (salary.userid?.name ?? 'U')
                                                    .substring(0, 1)
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                  color: ColorsValue.primary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    salary.userid?.name ??
                                                        'Unknown',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                      color: Colors.black87,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    '${_getMonthName(salary.month)} ${salary.year ?? ''}',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade600,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Edit Button
                                            IconButton(
                                              constraints:
                                                  const BoxConstraints(),
                                              padding: const EdgeInsets.all(6),
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                                color: ColorsValue.primary,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                controller.populateSalaryForm(
                                                  salary,
                                                );
                                                Get.to(
                                                  () => const AddSalaryScreen(),
                                                );
                                              },
                                            ),
                                            // Delete Button
                                            IconButton(
                                              constraints:
                                                  const BoxConstraints(),
                                              padding: const EdgeInsets.all(6),
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.red,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                Utility.showDeleteDialog(
                                                  title: 'Delete Salary',
                                                  message:
                                                      'Are you sure you want to delete the salary record for "${salary.userid?.name ?? 'Unknown'}"?',
                                                  onConfirm: () {
                                                    controller.deleteSalaryApi(
                                                      salaryid: salary.id ?? '',
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        const Divider(height: 1),
                                        const SizedBox(height: 12),

                                        // ── Salary Breakdown Info Row ──
                                        Row(
                                          children: [
                                            _buildInfoChip(
                                              icon: Icons.currency_rupee,
                                              label: 'Basic',
                                              value:
                                                  '₹${salary.basicsalary ?? 0}',
                                              color: ColorsValue.primary,
                                            ),
                                            const SizedBox(width: 8),
                                            _buildInfoChip(
                                              icon:
                                                  Icons.card_giftcard_outlined,
                                              label: 'Bonus',
                                              value: '₹${salary.bonus ?? 0}',
                                              color: Colors.orange,
                                            ),
                                            const SizedBox(width: 8),
                                            _buildInfoChip(
                                              icon: Icons.remove_circle_outline,
                                              label: 'Deduction',
                                              value:
                                                  '₹${salary.deduction ?? 0}',
                                              color: Colors.red,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),

                                        // ── Net Salary & Work Days Container ──
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: ColorsValue.primarySurface,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons
                                                        .account_balance_wallet_outlined,
                                                    color: ColorsValue.primary,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Net Salary',
                                                        style: TextStyle(
                                                          color: Colors
                                                              .grey
                                                              .shade600,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      Text(
                                                        '₹${salary.netsalary ?? 0}',
                                                        style: const TextStyle(
                                                          color: ColorsValue
                                                              .primaryDark,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.work_outline,
                                                    color: ColorsValue.primary,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Work Days',
                                                        style: TextStyle(
                                                          color: Colors
                                                              .grey
                                                              .shade600,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${salary.workdays ?? 0} days',
                                                        style: const TextStyle(
                                                          color: ColorsValue
                                                              .primaryDark,
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              // Status Badge
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: statusBgColor,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: statusColor,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Text(
                                                  (salary.paymentstatus ??
                                                          'Pending')
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                    color: statusColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // ── Payment Mode, Transaction ID & Remark ──
                                        if ((salary.paymentmode != null &&
                                                salary
                                                    .paymentmode!
                                                    .isNotEmpty) ||
                                            (salary.remark != null &&
                                                salary.remark!.isNotEmpty) ||
                                            (salary.date != null)) ...[
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              if (salary.date != null) ...[
                                                Icon(
                                                  Icons.date_range_outlined,
                                                  size: 14,
                                                  color: Colors.grey.shade600,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  _formatDisplayDate(
                                                    salary.date,
                                                  ),
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                              if (salary.paymentmode != null &&
                                                  salary
                                                      .paymentmode!
                                                      .isNotEmpty) ...[
                                                if (salary.date != null)
                                                  const SizedBox(width: 12),
                                                Icon(
                                                  Icons.payment_outlined,
                                                  size: 14,
                                                  color: Colors.grey.shade600,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  salary.paymentmode!,
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                              if (salary.transactionid !=
                                                      null &&
                                                  salary
                                                      .transactionid!
                                                      .isNotEmpty) ...[
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    'Txn: ${salary.transactionid}',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade500,
                                                      fontSize: 11,
                                                      fontFamily: 'monospace',
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          if (salary.remark != null &&
                                              salary.remark!.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.notes_outlined,
                                                  size: 14,
                                                  color: Colors.grey.shade600,
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    salary.remark!,
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade600,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              controller.clearSalaryForm();
              Get.to(() => const AddSalaryScreen());
            },
            backgroundColor: ColorsValue.primary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Add Salary',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Filter Bottom Sheet ──────────────────────────────────────────────────
  void _showFilterBottomSheet(
    BuildContext context,
    SalaryController controller,
  ) {
    DateTime? tempDate = controller.filterDate;
    String? tempPaymentStatus = controller.filterPaymentStatus;

    String formatDate(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          Future<void> pickDate() async {
            final picked = await showDatePicker(
              context: context,
              initialDate: tempDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: ColorsValue.primary,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setSheetState(() => tempDate = picked);
            }
          }

          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text('Filter Salary', style: Styles.txtBlackColorW70020),
                  const SizedBox(height: 20),

                  // ── Date Filter ─────────────────────────────────────────
                  Text('Date', style: Styles.txtBlackColorW60014),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: ColorsValue.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              tempDate != null
                                  ? formatDate(tempDate!)
                                  : 'Select Date',
                              style: TextStyle(
                                color: tempDate != null
                                    ? Colors.black87
                                    : Colors.grey.shade500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          if (tempDate != null)
                            InkWell(
                              onTap: () {
                                setSheetState(() => tempDate = null);
                              },
                              child: Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.grey.shade500,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Payment Status ─────────────────────────────────────
                  Text('Payment Status', style: Styles.txtBlackColorW60014),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Paid', 'Pending'].map((status) {
                      final isSelected = tempPaymentStatus == status;
                      return ChoiceChip(
                        label: Text(status),
                        selected: isSelected,
                        selectedColor: ColorsValue.primary.withValues(
                          alpha: 0.2,
                        ),
                        onSelected: (selected) {
                          setSheetState(() {
                            tempPaymentStatus = selected ? status : null;
                          });
                        },
                        labelStyle: TextStyle(
                          color: isSelected
                              ? ColorsValue.primary
                              : Colors.grey.shade700,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // ── Action Buttons ─────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            controller.clearFilters();
                            Get.back();
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            'Clear All',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            controller.filterDate = tempDate;
                            controller.filterPaymentStatus = tempPaymentStatus;
                            controller.applyFilters();
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorsValue.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Apply Filters',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  /// Small filter chip with remove button
  Widget _buildFilterChip({
    required String label,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ColorsValue.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorsValue.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: ColorsValue.primary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 14,
              color: ColorsValue.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// Small info chip for salary breakdown values
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
