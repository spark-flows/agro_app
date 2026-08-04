import 'package:intl/intl.dart';
import 'package:agro_app/app/app.dart';
import 'package:agro_app/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CollectionController>(
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
            title: Text('Collections', style: Styles.txtBlackColorW70020),
          ),
          floatingActionButton: isAllowed
              ? FloatingActionButton.extended(
                  backgroundColor: ColorsValue.primary,
                  onPressed: () {
                    controller.prepareForm();
                    RouteManagement.goToCollectionForm();
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text('Add Collection', style: Styles.whiteColorW60016),
                )
              : null,
          body: controller.isLoading && controller.collections.isEmpty
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
                  onRefresh: () => controller.fetchCollections(isRefresh: true),
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
                                  hintText: 'Search by party name or mode...',
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

                      // ── Collection List ──
                      Expanded(
                        child: controller.isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: ColorsValue.primary,
                                ),
                              )
                            : controller.filteredCollections.isEmpty
                            ? Center(
                                child: Text(
                                  'No collections found.',
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
                                    controller.filteredCollections.length +
                                    (controller.isFetchingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index ==
                                      controller.filteredCollections.length) {
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
                                      controller.filteredCollections[index];
                                  return _buildCollectionCard(
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

  Widget _buildCollectionCard(
    BuildContext context,
    CollectionController controller,
    CollectionDoc item,
  ) {
    final status = item.paymentstatus?.toLowerCase().trim() ?? 'pending';
    Color statusBgColor = Colors.orange.shade100;
    Color statusTextColor = Colors.orange.shade900;

    if (status == 'received') {
      statusBgColor = Colors.green.shade100;
      statusTextColor = Colors.green.shade900;
    } else if (status == 'return') {
      statusBgColor = Colors.red.shade100;
      statusTextColor = Colors.red.shade900;
    }

    final mode = item.paymentmode?.toUpperCase() ?? 'N/A';

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
                    item.partyname ?? 'Unknown Party',
                    style: Styles.txtBlackColorW70016,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Amount: ₹${item.amount ?? '0'}',
                  style: TextStyle(
                    color: ColorsValue.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('Mode: $mode', style: Styles.txtBlackColorW70012),
                ),
              ],
            ),
            const SizedBox(height: 6),

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
                      controller.formatCollectionDate(item.date),
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
            if (item.remark != null && item.remark!.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Remark: ${item.remark}', style: Styles.txtGreyColorW40012),
            ],
            const Divider(height: 16),

            // ── Action Buttons ──
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Change Status Button
                PopupMenuButton<String>(
                  onSelected: (String newStatus) {
                    final collectionId = item.id ?? item.collectionid ?? '';
                    if (collectionId.isNotEmpty) {
                      controller.changeStatus(collectionId, newStatus);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'received',
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text('Received'),
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
                    const PopupMenuItem(
                      value: 'return',
                      child: Row(
                        children: [
                          Icon(
                            Icons.cancel_outlined,
                            color: Colors.red,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text('Return'),
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
                    RouteManagement.goToCollectionForm();
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
    CollectionController controller,
    CollectionDoc item,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete Collection'),
          content: const Text(
            'Are you sure you want to delete this collection entry?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                final collectionId = item.id ?? item.collectionid ?? '';
                if (collectionId.isNotEmpty) {
                  controller.deleteCollection(collectionId);
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
    CollectionController controller,
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
                          'Filter Collections',
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
                          value: 'received',
                          child: Text('Received'),
                        ),
                        DropdownMenuItem(
                          value: 'pending',
                          child: Text('Pending'),
                        ),
                        DropdownMenuItem(
                          value: 'return',
                          child: Text('Return'),
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
