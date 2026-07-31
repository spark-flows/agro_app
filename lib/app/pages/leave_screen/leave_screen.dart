import 'package:agro_app/app/pages/leave_screen/leave_controller.dart';
import 'package:agro_app/app/theme/theme.dart';
import 'package:agro_app/domain/services/enum.dart';
import 'package:agro_app/app/utils/utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        Get.find<LeaveController>().fetchLeaves(isRefresh: false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
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

  Color _getStatusColor(String? status) {
    if (status == null) return ColorsValue.statusPending;
    switch (status.toLowerCase().trim()) {
      case 'accept':
        return ColorsValue.statusComplete;
      case 'reject':
        return ColorsValue.statusCancelled;
      case 'pending':
      default:
        return ColorsValue.statusPending;
    }
  }

  Color _getStatusBgColor(String? status) {
    if (status == null) return ColorsValue.statusPendingBg;
    switch (status.toLowerCase().trim()) {
      case 'accept':
        return ColorsValue.statusCompleteBg;
      case 'reject':
        return ColorsValue.statusCancelledBg;
      case 'pending':
      default:
        return ColorsValue.statusPendingBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LeaveController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.bgMain,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black87),
            title: Text('Leaves', style: Styles.txtBlackColorW70020),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.filter_alt_outlined,
                  color:
                      (controller.filterFromDate != null ||
                          controller.filterStatus != null)
                      ? ColorsValue.primary
                      : Colors.black87,
                ),
                onPressed: () => _showFilterBottomSheet(context, controller),
              ),
            ],
          ),
          body: Column(
            children: [
              // Search bar container
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: controller.onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search by reason...',
                    hintStyle: Styles.txtGreyColorW40014,
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              controller.onSearchChanged('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
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
                      borderSide: const BorderSide(color: ColorsValue.primary),
                    ),
                  ),
                ),
              ),

              // Active filters chips
              if (controller.filterFromDate != null ||
                  controller.filterStatus != null)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    children: [
                      if (controller.filterFromDate != null)
                        Chip(
                          backgroundColor: ColorsValue.primaryLight,
                          label: Text(
                            'Date: ${DateFormat('dd/MM').format(controller.filterFromDate!)}',
                            style: const TextStyle(
                              color: ColorsValue.primaryDark,
                              fontSize: 12,
                            ),
                          ),
                          onDeleted: () {
                            controller.setFilters(
                              fromDate: null,
                              toDate: null,
                              status: controller.filterStatus,
                            );
                          },
                        ),
                      if (controller.filterStatus != null)
                        Chip(
                          backgroundColor: _getStatusBgColor(
                            controller.filterStatus,
                          ),
                          label: Text(
                            'Status: ${controller.filterStatus!.toUpperCase()}',
                            style: TextStyle(
                              color: _getStatusColor(controller.filterStatus),
                              fontSize: 12,
                            ),
                          ),
                          onDeleted: () {
                            controller.setFilters(
                              fromDate: controller.filterFromDate,
                              toDate: controller.filterToDate,
                              status: null,
                            );
                          },
                        ),
                      TextButton(
                        onPressed: controller.clearFilters,
                        child: const Text(
                          'Clear All',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

              // List of leaves
              Expanded(
                child: controller.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                            ColorsValue.primary,
                          ),
                        ),
                      )
                    : controller.leaves.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.beach_access_outlined,
                              size: 64,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Leave Requests Found',
                              style: Styles.txtGreyColorW40014.copyWith(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: ColorsValue.primary,
                        onRefresh: () =>
                            controller.fetchLeaves(isRefresh: true),
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount:
                              controller.leaves.length +
                              (controller.isFetchingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == controller.leaves.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      ColorsValue.primary,
                                    ),
                                  ),
                                ),
                              );
                            }

                            final leave = controller.leaves[index];
                            final isPending =
                                leave.status?.toLowerCase().trim() == 'pending';

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  controller.fetchLeaveDetailsAndOpenForm(
                                    leave.id!,
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Header Row: User Name & Status Badge
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              leave.userid?.name ??
                                                  'My Request',
                                              style: Styles.txtBlackColorW70016,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getStatusBgColor(
                                                leave.status,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              (leave.status ?? 'pending')
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                color: _getStatusColor(
                                                  leave.status,
                                                ),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                      // Date Range Row
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.date_range_outlined,
                                            size: 16,
                                            color: ColorsValue.primary,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${_formatDisplayDate(leave.fromdate)}  to  ${_formatDisplayDate(leave.todate)}',
                                            style: Styles.txtBlackColorW60014,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Total Days & Leave Type Row
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '${leave.totaldays ?? 0} Days',
                                              style: Styles.txtGreyColorW40012
                                                  .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'Type: ${(leave.leavetype ?? "full").toUpperCase()}',
                                              style: Styles.txtGreyColorW40012
                                                  .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ),
                                          if (leave.totalhours != null) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                '${leave.totalhours} Hrs',
                                                style: Styles.txtGreyColorW40012
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                      // Reason section
                                      if (leave.reason != null &&
                                          leave.reason!.isNotEmpty) ...[
                                        Text(
                                          'Reason:',
                                          style: Styles.txtGreyColorW40012
                                              .copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          leave.reason!,
                                          style: Styles.txtBlackColorW60014
                                              .copyWith(
                                                fontWeight: FontWeight.w400,
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 12),
                                      ],

                                      // Action buttons (Only enable editing/deleting pending leaves for safety)
                                      if (isPending ||
                                          RoleUtils.isAdmin(
                                            controller.roleName,
                                          )) ...[
                                        Divider(
                                          height: 1,
                                          color: Colors.grey.shade100,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            if (RoleUtils.isAdmin(
                                              controller.roleName,
                                            )) ...[
                                              PopupMenuButton<String>(
                                                onSelected: (String newStatus) {
                                                  controller.changeLeaveStatus(
                                                    leave.id!,
                                                    newStatus,
                                                  );
                                                },
                                                itemBuilder: (context) => [
                                                  const PopupMenuItem(
                                                    value: 'accept',
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .check_circle_outline,
                                                          color: ColorsValue
                                                              .statusComplete,
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
                                                          color: ColorsValue
                                                              .statusCancelled,
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
                                                          color: ColorsValue
                                                              .statusPending,
                                                          size: 18,
                                                        ),
                                                        SizedBox(width: 8),
                                                        Text('Pending'),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 6,
                                                      ),
                                                  child: const Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .published_with_changes_outlined,
                                                        size: 18,
                                                        color:
                                                            ColorsValue.primary,
                                                      ),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        'Status',
                                                        style: TextStyle(
                                                          color: ColorsValue
                                                              .primary,
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                            ],
                                            TextButton.icon(
                                              onPressed: () {
                                                controller
                                                    .fetchLeaveDetailsAndOpenForm(
                                                      leave.id!,
                                                    );
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
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            TextButton.icon(
                                              onPressed: () {
                                                Utility.showDeleteDialog(
                                                  title: 'Delete Leave Request',
                                                  message:
                                                      'Are you sure you want to delete this leave request?',
                                                  onConfirm: () {
                                                    Get.back(); // Dismiss delete confirmation dialog
                                                    controller.deleteLeave(
                                                      leave.id!,
                                                    );
                                                  },
                                                );
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
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: ColorsValue.primary,
            onPressed: () {
              controller.setupForm(null);
              Get.toNamed<void>('/leaveForm');
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  void _showFilterBottomSheet(
    BuildContext context,
    LeaveController controller,
  ) {
    DateTime? tempFromDate = controller.filterFromDate;
    DateTime? tempToDate = controller.filterToDate;
    String? tempStatus = controller.filterStatus;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filter Leaves',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              tempFromDate = null;
                              tempToDate = null;
                              tempStatus = null;
                            });
                          },
                          child: const Text(
                            'Reset',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Date Selectors
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: tempFromDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setModalState(() => tempFromDate = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'From Date',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                tempFromDate == null
                                    ? 'Select'
                                    : DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(tempFromDate!),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: tempToDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setModalState(() => tempToDate = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'To Date',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                tempToDate == null
                                    ? 'Select'
                                    : DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(tempToDate!),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Status Dropdown
                    DropdownButtonFormField<String>(
                      value: tempStatus,
                      decoration: InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'pending',
                          child: Text('Pending'),
                        ),
                        DropdownMenuItem(
                          value: 'accept',
                          child: Text('Accepted'),
                        ),
                        DropdownMenuItem(
                          value: 'reject',
                          child: Text('Rejected'),
                        ),
                      ],
                      onChanged: (val) {
                        setModalState(() => tempStatus = val);
                      },
                    ),
                    const SizedBox(height: 24),

                    // Apply Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsValue.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          controller.setFilters(
                            fromDate: tempFromDate,
                            toDate: tempToDate,
                            status: tempStatus,
                          );
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Apply Filters',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
