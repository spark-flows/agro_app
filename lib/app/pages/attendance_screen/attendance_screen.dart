import 'package:agro_app/app/pages/attendance_screen/attendance_controller.dart';
import 'package:agro_app/app/theme/theme.dart';
import 'package:agro_app/app/utils/utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
                                      const SizedBox(height: 12),
                                      const Divider(),
                                      const SizedBox(height: 8),

                                      // Time & Break details Grid
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildTimeInfo(
                                            'In',
                                            record.timein,
                                            Icons.login,
                                          ),
                                          _buildTimeInfo(
                                            'Out',
                                            record.timeout,
                                            Icons.logout,
                                          ),
                                          _buildTimeInfo(
                                            'Break Start',
                                            record.breakstart,
                                            Icons.free_breakfast_outlined,
                                          ),
                                          _buildTimeInfo(
                                            'Break End',
                                            record.breakend,
                                            Icons.restaurant_outlined,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                      // Location Coordinates display
                                      if (record.coordinates?.latitude !=
                                              null &&
                                          record.coordinates?.longitude != null)
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.location_on_outlined,
                                                size: 16,
                                                color: Colors.blueAccent,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  'Lat: ${record.coordinates!.latitude}   Lon: ${record.coordinates!.longitude}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade700,
                                                    fontFamily: 'monospace',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

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
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: ColorsValue.primary,
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              controller.setupForm(null);
              Get.toNamed<void>('/attendanceForm');
            },
          ),
        );
      },
    );
  }

  Widget _buildTimeInfo(String label, String? time, IconData icon) {
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
          (time == null || time.isEmpty) ? '--:--' : time,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
      ],
    );
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
}
