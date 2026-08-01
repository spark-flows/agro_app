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
            actions: [
              IconButton(
                icon: const Icon(Icons.date_range, color: ColorsValue.primary),
                onPressed: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                    initialDateRange:
                        controller.filterFromDate != null &&
                            controller.filterToDate != null
                        ? DateTimeRange(
                            start: controller.filterFromDate!,
                            end: controller.filterToDate!,
                          )
                        : null,
                  );
                  if (picked != null) {
                    controller.setDateRange(picked.start, picked.end);
                  }
                },
              ),
              if (controller.filterFromDate != null ||
                  controller.filterToDate != null)
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.red),
                  onPressed: () {
                    controller.setDateRange(null, null);
                  },
                ),
            ],
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
          body: !isAllowed
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
                      // ── Search Bar ──
                      Padding(
                        padding: const EdgeInsets.all(12.0),
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

                      // ── Status Filter Chips ──
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          children: [
                            _buildStatusFilterChip(controller, null, 'All'),
                            const SizedBox(width: 8),
                            _buildStatusFilterChip(
                              controller,
                              'received',
                              'Received',
                            ),
                            const SizedBox(width: 8),
                            _buildStatusFilterChip(
                              controller,
                              'pending',
                              'Pending',
                            ),
                            const SizedBox(width: 8),
                            _buildStatusFilterChip(
                              controller,
                              'return',
                              'Return',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

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

  Widget _buildStatusFilterChip(
    CollectionController controller,
    String? statusKey,
    String label,
  ) {
    final isSelected = controller.filterStatus == statusKey;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: ColorsValue.primary,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      onSelected: (_) {
        controller.setStatusFilter(statusKey);
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
                    Text(item.date ?? 'N/A', style: Styles.txtGreyColorW40012),
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
                TextButton.icon(
                  onPressed: () {
                    _showChangeStatusDialog(context, controller, item);
                  },
                  icon: const Icon(
                    Icons.change_circle_outlined,
                    size: 18,
                    color: ColorsValue.primary,
                  ),
                  label: const Text('Status'),
                ),
                // Edit Button
                TextButton.icon(
                  onPressed: () {
                    controller.prepareForm(item);
                    RouteManagement.goToCollectionForm();
                  },
                  icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                  label: const Text('Edit'),
                ),
                // Delete Button
                TextButton.icon(
                  onPressed: () {
                    _showDeleteConfirmDialog(context, controller, item);
                  },
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  label: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeStatusDialog(
    BuildContext context,
    CollectionController controller,
    CollectionDoc item,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Change Payment Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: CollectionController.paymentStatusOptions.map((st) {
              String label = st;
              if (st == 'received') label = 'Received';
              if (st == 'pending') label = 'Pending';
              if (st == 'return') label = 'Return';

              final isCurrent = item.paymentstatus?.toLowerCase().trim() == st;

              return ListTile(
                title: Text(label),
                trailing: isCurrent
                    ? const Icon(Icons.check, color: ColorsValue.primary)
                    : null,
                onTap: () {
                  Navigator.pop(ctx);
                  final collectionId = item.id ?? item.collectionid ?? '';
                  if (collectionId.isNotEmpty) {
                    controller.changeStatus(collectionId, st);
                  }
                },
              );
            }).toList(),
          ),
        );
      },
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
}
