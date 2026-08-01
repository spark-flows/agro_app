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
          ),
          body: Column(
            children: [
              // ── Search & Filter Bar ──
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
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
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () => _showFilterBottomSheet(context, controller),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Icon(
                          Icons.filter_list,
                          color: (controller.filterFromDate != null ||
                                  controller.filterStatus != null)
                              ? ColorsValue.primary
                              : Colors.grey,
                        ),
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
                          'Filter Leaves',
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
                      value: tempStatus,
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
                              controller.setFilters(
                                fromDate: tempFromDate,
                                toDate: tempToDate,
                                status: tempStatus,
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
