import 'package:agro_app/app/pages/attendance_screen/attendance_controller.dart';
import 'package:agro_app/app/theme/theme.dart';
import 'package:agro_app/app/utils/utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:agro_app/domain/models/get_all_attandance_model.dart'
    as get_all_model;

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        Get.find<AttendanceController>().fetchAttendance(isRefresh: false);
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
    if (status == null) return Colors.grey;
    switch (status.toLowerCase().trim()) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'holiday':
        return Colors.blue;
      case 'halfday':
        return Colors.orange;
      case 'leave':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AttendanceController>(
      initState: (state) {
        var controller = Get.find<AttendanceController>();
        controller.loadRoleName();
      },
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.bgMain,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black87),
            title: Text(
              'Attendance Management',
              style: Styles.txtBlackColorW70020,
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ── Search Bar ─────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: controller.searchAttendance,
                        decoration: InputDecoration(
                          hintText: 'Search by remark...',
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
                                    controller.searchAttendance('');
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
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.filter_alt_outlined,
                          color:
                              (controller.filterStatus != null ||
                                  controller.filterDate != null)
                              ? ColorsValue.primary
                              : Colors.grey,
                        ),
                        onPressed: () =>
                            _showFilterBottomSheet(context, controller),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Records List ───────────────────────────────────────────
                Expanded(
                  child: controller.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: ColorsValue.primary,
                          ),
                        )
                      : controller.attendanceRecords.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.fingerprint,
                                size: 64,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No attendance records found',
                                style: Styles.txtGreyColorW40014,
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () =>
                              controller.fetchAttendance(isRefresh: true),
                          color: ColorsValue.primary,
                          child: ListView.separated(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount:
                                controller.attendanceRecords.length +
                                (controller.isFetchingMore ? 1 : 0),
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              if (index >=
                                  controller.attendanceRecords.length) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: CircularProgressIndicator(
                                      color: ColorsValue.primary,
                                    ),
                                  ),
                                );
                              }

                              final record =
                                  controller.attendanceRecords[index];
                              final statusColor = _getStatusColor(
                                record.status,
                              );

                              return Card(
                                elevation: 0.5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(color: Colors.grey.shade200),
                                ),
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _formatDisplayDate(record.date),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: statusColor.withOpacity(
                                                0.12,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: statusColor,
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              (record.status ?? 'present')
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                color: statusColor,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      if (record.userid?.name != null)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.person_outline,
                                                  size: 16,
                                                  color: Colors.black54,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  record.userid?.name ?? '',
                                                  style: const TextStyle(
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (controller.isAdmin) ...[
                                              IconButton(
                                                onPressed: () {
                                                  final lat = record
                                                      .coordinates
                                                      ?.latitude;
                                                  final lng = record
                                                      .coordinates
                                                      ?.longitude;
                                                  if (lat != null &&
                                                      lat.trim().isNotEmpty &&
                                                      lng != null &&
                                                      lng.trim().isNotEmpty) {
                                                    final url =
                                                        "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
                                                    Utility.launchLinkURL(url);
                                                  } else {
                                                    Utility.snacBar(
                                                      'Location coordinates not available.',
                                                      Colors.red,
                                                    );
                                                  }
                                                },
                                                icon: Icon(
                                                  Icons.location_on,
                                                  color:
                                                      (record
                                                                  .coordinates
                                                                  ?.latitude !=
                                                              null &&
                                                          record
                                                              .coordinates!
                                                              .latitude!
                                                              .trim()
                                                              .isNotEmpty &&
                                                          record
                                                                  .coordinates
                                                                  ?.longitude !=
                                                              null &&
                                                          record
                                                              .coordinates!
                                                              .longitude!
                                                              .trim()
                                                              .isNotEmpty)
                                                      ? Colors.redAccent
                                                      : Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      const SizedBox(height: 12),
                                      const Divider(),
                                      const SizedBox(height: 8),

                                      // Time & Break details Grid
                                      _buildPunchingAndBreaksLogs(record),
                                      const SizedBox(height: 12),

                                      // Location Coordinates display
                                      // if (record.coordinates?.latitude !=
                                      //         null &&
                                      //     record.coordinates?.longitude != null)
                                      //   Container(
                                      //     padding: const EdgeInsets.all(8),
                                      //     decoration: BoxDecoration(
                                      //       color: Colors.grey.shade50,
                                      //       borderRadius: BorderRadius.circular(
                                      //         8,
                                      //       ),
                                      //     ),
                                      //     child: Row(
                                      //       children: [
                                      //         const Icon(
                                      //           Icons.location_on_outlined,
                                      //           size: 16,
                                      //           color: Colors.blueAccent,
                                      //         ),
                                      //         const SizedBox(width: 6),
                                      //         Expanded(
                                      //           child: Text(
                                      //             'Lat: ${record.coordinates!.latitude}   Lon: ${record.coordinates!.longitude}',
                                      //             style: TextStyle(
                                      //               fontSize: 12,
                                      //               color: Colors.grey.shade700,
                                      //               fontFamily: 'monospace',
                                      //             ),
                                      //           ),
                                      //         ),
                                      //       ],
                                      //     ),
                                      //   ),
                                      if (record.remark != null &&
                                          record.remark!.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          'Remark: ${record.remark}',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],

                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          // Quick change status button
                                          PopupMenuButton<String>(
                                            icon: const Icon(
                                              Icons.change_circle_outlined,
                                              color: ColorsValue.primary,
                                            ),
                                            tooltip: 'Change Status',
                                            onSelected: (newStatus) {
                                              controller.changeAttendanceStatus(
                                                record.id ?? '',
                                                newStatus,
                                              );
                                            },
                                            itemBuilder: (context) =>
                                                [
                                                      'present',
                                                      'absent',
                                                      'holiday',
                                                      'halfday',
                                                      'leave',
                                                    ]
                                                    .map(
                                                      (st) => PopupMenuItem(
                                                        value: st,
                                                        child: Text(
                                                          st.toUpperCase(),
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                          ),
                                          if (controller.roleName !=
                                              "User") ...[
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                                color: Colors.blue,
                                              ),
                                              onPressed: () => controller
                                                  .fetchAttendanceDetailsAndOpenForm(
                                                    record.id ?? '',
                                                  ),
                                            ),
                                          ],
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                            ),
                                            onPressed: () =>
                                                _showDeleteConfirmation(
                                                  context,
                                                  controller,
                                                  record.id ?? '',
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
                        ),
                ),
                if (!controller.isAdmin)
                  _buildQuickActionsPanel(context, controller),
              ],
            ),
          ),
          floatingActionButton: controller.isAdmin
              ? FloatingActionButton(
                  backgroundColor: ColorsValue.primary,
                  child: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    controller.setupForm(null);
                    Get.toNamed<void>('/attendanceForm');
                  },
                )
              : null,
        );
      },
    );
  }

  Widget _buildTimeInfo(String label, String? time, IconData icon) {
    final displayTime = _formatTo12Hour(time);
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          displayTime,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  String _formatTo12Hour(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty || timeStr == "00:00")
      return '--:--';
    try {
      if (timeStr.toLowerCase().contains('am') ||
          timeStr.toLowerCase().contains('pm')) {
        return timeStr;
      }
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1].split(' ')[0]);
        final dt = DateTime(2026, 1, 1, hour, minute);
        return DateFormat('hh:mm a').format(dt);
      }
    } catch (_) {}
    return timeStr;
  }

  void _showDeleteConfirmation(
    BuildContext context,
    AttendanceController controller,
    String id,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Attendance'),
        content: const Text(
          'Are you sure you want to delete this attendance record?',
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(context);
              controller.deleteAttendance(id);
            },
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(
    BuildContext context,
    AttendanceController controller,
  ) {
    DateTime? tempDate = controller.filterDate;
    String? tempStatus = controller.filterStatus;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter Attendance',
                          style: Styles.txtBlackColorW70020.copyWith(
                            fontSize: 18,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            controller.clearFilters();
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Clear All',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Select Date
                    const Text(
                      'Select Date',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: tempDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setModalState(() => tempDate = picked);
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              color: ColorsValue.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                tempDate == null
                                    ? 'Choose Date'
                                    : DateFormat(
                                        'dd-MM-yyyy',
                                      ).format(tempDate!),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: tempDate != null
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                  color: tempDate != null
                                      ? Colors.black87
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ),
                            if (tempDate != null)
                              GestureDetector(
                                onTap: () {
                                  setModalState(() => tempDate = null);
                                },
                                child: Icon(
                                  Icons.cancel,
                                  color: Colors.grey.shade400,
                                  size: 18,
                                ),
                              )
                            else
                              Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey.shade400,
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Status Dropdown
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: tempStatus != null && tempStatus!.isNotEmpty
                          ? tempStatus
                          : null,
                      hint: const Text('Select Status'),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'present',
                          child: Text('Present'),
                        ),
                        DropdownMenuItem(
                          value: 'absent',
                          child: Text('Absent'),
                        ),
                        DropdownMenuItem(
                          value: 'holiday',
                          child: Text('Holiday'),
                        ),
                        DropdownMenuItem(
                          value: 'halfday',
                          child: Text('Halfday'),
                        ),
                        DropdownMenuItem(value: 'leave', child: Text('Leave')),
                      ],
                      onChanged: (val) {
                        setModalState(() => tempStatus = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    const SizedBox(height: 24),

                    // Apply Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsValue.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          controller.setFilters(
                            date: tempDate,
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
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickActionsPanel(
    BuildContext context,
    AttendanceController controller,
  ) {
    final record = controller.getTodayRecord();
    final isClockedIn = controller.isClockedInToday(record);
    final isClockedOut = controller.isClockedOutToday(record);
    final isOnBreak = controller.isOnBreakToday(record);

    final String displayTimeIn = (() {
      if (record == null) return '';
      if (record.timein != null && record.timein!.isNotEmpty)
        return record.timein!;
      if (record.punching != null && record.punching!.isNotEmpty) {
        for (var p in record.punching!.reversed) {
          if (p.timein != null && p.timein != "00:00" && p.timein!.isNotEmpty) {
            return p.timein!;
          }
        }
      }
      return '';
    })();

    final String displayTimeOut = (() {
      if (record == null) return '';
      if (record.timeout != null && record.timeout!.isNotEmpty)
        return record.timeout!;
      if (record.punching != null && record.punching!.isNotEmpty) {
        for (var p in record.punching!.reversed) {
          if (p.timeout != null &&
              p.timeout != "00:00" &&
              p.timeout!.isNotEmpty) {
            return p.timeout!;
          }
        }
      }
      return '';
    })();

    final String displayBreakStart = (() {
      if (record == null) return '';
      if (record.breakstart != null && record.breakstart!.isNotEmpty)
        return record.breakstart!;
      if (record.breaks != null && record.breaks!.isNotEmpty) {
        for (var b in record.breaks!.reversed) {
          if (b.breakstart != null &&
              b.breakstart != "00:00" &&
              b.breakstart!.isNotEmpty) {
            return b.breakstart!;
          }
        }
      }
      return '';
    })();

    // State 1: Not clocked in or already fully clocked out for today
    final bool showClockInOnly = !isClockedIn || isClockedOut;

    String title = "Daily Shift Actions";
    String subtitle = "Start your work day by Clocking In.";
    IconData headerIcon = Icons.punch_clock_outlined;
    Color statusColor = Colors.grey.shade600;

    if (isClockedIn && !isClockedOut) {
      if (isOnBreak) {
        title = "Paused";
        subtitle =
            "Shift paused at $displayBreakStart. Click Resume to resume work.";
        headerIcon = Icons.pause_circle_outline;
        statusColor = Colors.orange;
      } else {
        title = "Clocked In";
        subtitle = "Clocked in at $displayTimeIn. Have a productive day!";
        headerIcon = Icons.work_history_outlined;
        statusColor = ColorsValue.primary;
      }
    } else if (isClockedOut) {
      title = "Shift Completed";
      subtitle = "Clocked out at $displayTimeOut. See you tomorrow!";
      headerIcon = Icons.task_alt;
      statusColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(headerIcon, color: statusColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (showClockInOnly)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsValue.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.login, size: 18),
                label: const Text(
                  "Clock In",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                onPressed: () => controller.quickClockIn(),
              ),
            )
          else ...[
            if (isOnBreak)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(
                    Icons.play_arrow_outlined,
                    size: 18,
                  ),
                  label: const Text(
                    "Resume",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    controller.quickBreakOut(record);
                  },
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: ColorsValue.primary,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          foregroundColor: ColorsValue.primary,
                        ),
                        icon: const Icon(
                          Icons.pause_circle_outline,
                          size: 18,
                        ),
                        label: const Text(
                          "Pause",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          controller.quickBreakIn(record);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.logout, size: 18),
                        label: const Text(
                          "Clock Out",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () => controller.quickClockOut(record),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildPunchingAndBreaksLogs(get_all_model.GetAllAttendanceDoc record) {
    final String? timeInVal = (() {
      if (record.timein != null && record.timein!.isNotEmpty) {
        return record.timein;
      }
      if (record.punching != null && record.punching!.isNotEmpty) {
        for (var p in record.punching!) {
          if (p.timein != null && p.timein != "00:00" && p.timein!.isNotEmpty) {
            return p.timein;
          }
        }
      }
      return null;
    })();

    final String? timeOutVal = (() {
      if (record.timeout != null && record.timeout!.isNotEmpty) {
        return record.timeout;
      }
      if (record.punching != null && record.punching!.isNotEmpty) {
        for (var p in record.punching!.reversed) {
          if (p.timeout != null &&
              p.timeout != "00:00" &&
              p.timeout!.isNotEmpty) {
            return p.timeout;
          }
        }
      }
      return null;
    })();

    final String? breakStartVal = (() {
      if (record.breakstart != null && record.breakstart!.isNotEmpty) {
        return record.breakstart;
      }
      if (record.breaks != null && record.breaks!.isNotEmpty) {
        for (var b in record.breaks!) {
          if (b.breakstart != null &&
              b.breakstart != "00:00" &&
              b.breakstart!.isNotEmpty) {
            return b.breakstart;
          }
        }
      }
      return null;
    })();

    final String? breakEndVal = (() {
      if (record.breakend != null && record.breakend!.isNotEmpty) {
        return record.breakend;
      }
      if (record.breaks != null && record.breaks!.isNotEmpty) {
        for (var b in record.breaks!.reversed) {
          if (b.breakend != null &&
              b.breakend != "00:00" &&
              b.breakend!.isNotEmpty) {
            return b.breakend;
          }
        }
      }
      return null;
    })();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTimeInfo('In', timeInVal, Icons.login),
        _buildTimeInfo('Out', timeOutVal, Icons.logout),
        _buildTimeInfo(
          'Pause',
          breakStartVal,
          Icons.pause_circle_outline,
        ),
        _buildTimeInfo('Resume', breakEndVal, Icons.play_circle_outline),
      ],
    );
  }
}
