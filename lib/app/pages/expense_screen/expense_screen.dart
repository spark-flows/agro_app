import 'dart:io';
import 'package:intl/intl.dart';
import 'package:agro_app/app/app.dart';
import 'package:agro_app/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExpenseController>(
      builder: (controller) {
        final isAllowed =
            RoleUtils.isAdmin(controller.roleName) ||
            RoleUtils.isUser(controller.roleName);

        return Scaffold(
          backgroundColor: ColorsValue.bgMain,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Get.back(),
            ),
            title: Text('Expenses', style: Styles.txtBlackColorW70020),
          ),
          floatingActionButton: isAllowed
              ? FloatingActionButton.extended(
                  backgroundColor: ColorsValue.primary,
                  onPressed: () {
                    controller.prepareForm();
                    RouteManagement.goToExpenseForm();
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text('Add Expense', style: Styles.whiteColorW60016),
                )
              : null,
          body: controller.isLoading && controller.expenses.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(color: ColorsValue.primary),
                )
              : !isAllowed
              ? Center(
                  child: Text(
                    'Access restricted to Admin & User roles.',
                    style: Styles.redColor50014,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => controller.fetchExpenses(isRefresh: true),
                  child: Column(
                    children: [
                      // ── Search & Filter Bar ──
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                onChanged: controller.onSearchChanged,
                                decoration: InputDecoration(
                                  hintText: 'Search by particular or amount...',
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    color: Colors.grey,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 0,
                                    horizontal: 16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            InkWell(
                              onTap: () =>
                                  _showFilterBottomSheet(context, controller),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Icon(
                                  Icons.filter_list,
                                  color:
                                      (controller.filterFromDate != null ||
                                          controller.filterStatus != null)
                                      ? ColorsValue.primary
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Expense List ──
                      Expanded(
                        child: controller.isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: ColorsValue.primary,
                                ),
                              )
                            : controller.filteredExpenses.isEmpty
                            ? Center(
                                child: Text(
                                  'No expenses found.',
                                  style: Styles.txtGreyColorW40014,
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.only(
                                  left: 12,
                                  right: 12,
                                  bottom: 80,
                                ),
                                itemCount:
                                    controller.filteredExpenses.length +
                                    (controller.isFetchingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index ==
                                      controller.filteredExpenses.length) {
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
                                      controller.filteredExpenses[index];
                                  return _buildExpenseCard(
                                    context,
                                    controller,
                                    item,
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildExpenseCard(
    BuildContext context,
    ExpenseController controller,
    ExpenseDoc item,
  ) {
    final particularName = item.particularid?.name ?? 'Unknown Expense';
    final amount = item.amount ?? '0';
    final date = item.date ?? 'N/A';
    final remark = item.remark ?? '';
    final imageUrl = item.image;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    particularName,
                    style: Styles.txtBlackColorW70016,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '₹$amount',
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      controller.formatExpenseDate(date),
                      style: Styles.txtGreyColorW40012,
                    ),
                  ],
                ),
                if (item.userid?.name != null &&
                    item.userid!.name!.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.userid!.name!,
                        style: Styles.txtGreyColorW40012,
                      ),
                    ],
                  ),
                ],
              ],
            ),

            if (remark.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Remark: $remark', style: Styles.txtGreyColorW40012),
            ],

            if (imageUrl != null && imageUrl.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl.startsWith('http')
                    ? Image.network(
                        imageUrl,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(),
                      )
                    : Image.file(
                        File(imageUrl),
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(),
                      ),
              ),
            ],

            const Divider(height: 16),

            // ── Action Buttons ──
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Change Status Button
                PopupMenuButton<String>(
                  onSelected: (String newStatus) {
                    final expenseId = item.id ?? item.expenseid ?? '';
                    if (expenseId.isNotEmpty) {
                      controller.changeStatus(expenseId, newStatus);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'accept',
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text('Accept'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'reject',
                      child: Row(
                        children: [
                          Icon(
                            Icons.cancel_outlined,
                            color: Colors.red,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text('Reject'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'pending',
                      child: Row(
                        children: [
                          Icon(
                            Icons.hourglass_empty,
                            color: Colors.orange,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text('Pending'),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.published_with_changes_outlined,
                          size: 18,
                          color: ColorsValue.primary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Status',
                          style: TextStyle(
                            color: ColorsValue.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // PDF Button
                TextButton.icon(
                  onPressed: () {
                    controller.generateAndDownloadPdf(item);
                  },
                  icon: const Icon(
                    Icons.visibility_outlined,
                    size: 18,
                    color: ColorsValue.primary,
                  ),
                  label: const Text(
                    'PDF',
                    style: TextStyle(
                      color: ColorsValue.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Edit Button
                TextButton.icon(
                  onPressed: () {
                    controller.prepareForm(item);
                    RouteManagement.goToExpenseForm();
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: ColorsValue.primary,
                  ),
                  label: const Text(
                    'Edit',
                    style: TextStyle(
                      color: ColorsValue.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Delete Button
                TextButton.icon(
                  onPressed: () {
                    _showDeleteConfirmDialog(context, controller, item);
                  },
                  icon: const Icon(
                    Icons.delete_outline_outlined,
                    size: 18,
                    color: Colors.red,
                  ),
                  label: const Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    ExpenseController controller,
    ExpenseDoc item,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete Expense'),
          content: const Text(
            'Are you sure you want to delete this expense entry?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                final expenseId = item.id ?? item.expenseid ?? '';
                if (expenseId.isNotEmpty) {
                  controller.deleteExpense(expenseId);
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showFilterBottomSheet(
    BuildContext context,
    ExpenseController controller,
  ) {
    DateTime? tempFromDate = controller.filterFromDate;
    DateTime? tempToDate = controller.filterToDate;
    String? tempStatus = controller.filterStatus;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            String dateText = 'Choose Date';
            if (tempFromDate != null && tempToDate != null) {
              dateText =
                  '${DateFormat('dd/MM/yyyy').format(tempFromDate!)} - ${DateFormat('dd/MM/yyyy').format(tempToDate!)}';
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 10,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filter Expenses',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Text('Select Date', style: Styles.txtBlackColorW60014),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                          initialDateRange:
                              tempFromDate != null && tempToDate != null
                              ? DateTimeRange(
                                  start: tempFromDate!,
                                  end: tempToDate!,
                                )
                              : null,
                        );
                        if (picked != null) {
                          setModalState(() {
                            tempFromDate = picked.start;
                            tempToDate = picked.end;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: ColorsValue.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                dateText,
                                style: dateText == 'Choose Date'
                                    ? Styles.txtGreyColorW40014
                                    : Styles.txtBlackColorW60014,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text('Status', style: Styles.txtBlackColorW60014),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: tempStatus,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      hint: Text(
                        'Select Status',
                        style: Styles.txtGreyColorW40014,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'accept',
                          child: Text('Accepted'),
                        ),
                        DropdownMenuItem(
                          value: 'reject',
                          child: Text('Rejected'),
                        ),
                        DropdownMenuItem(
                          value: 'pending',
                          child: Text('Pending'),
                        ),
                      ],
                      onChanged: (val) {
                        setModalState(() {
                          tempStatus = val;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              setModalState(() {
                                tempFromDate = null;
                                tempToDate = null;
                                tempStatus = null;
                              });
                            },
                            child: const Text(
                              'Clear All',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorsValue.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              controller.applyFilters(
                                tempFromDate,
                                tempToDate,
                                tempStatus,
                              );
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Apply Filters',
                              style: Styles.whiteColorW60016,
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
        );
      },
    );
  }
}
