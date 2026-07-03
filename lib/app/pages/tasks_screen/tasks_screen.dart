import 'package:agro_app/app/pages/tasks_screen/tasks_controller.dart';
import 'package:agro_app/app/theme/theme.dart';
import 'package:agro_app/app/utils/utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:agro_app/data/helpers/api_wrapper.dart';
import 'package:agro_app/app/widgets/show_full_scareen_image.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        Get.find<TasksController>().fetchTasks(isRefresh: false);
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
    if (status == null) return Colors.amber.shade800;
    switch (status.toLowerCase().trim()) {
      case 'processing':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
      default:
        return Colors.amber.shade800;
    }
  }

  bool _isImage(String path) {
    final cleanPath = path.toLowerCase().split('?').first;
    return cleanPath.endsWith('.jpg') ||
        cleanPath.endsWith('.jpeg') ||
        cleanPath.endsWith('.png') ||
        cleanPath.endsWith('.gif') ||
        cleanPath.endsWith('.webp') ||
        cleanPath.endsWith('.heic');
  }

  bool _isVideo(String path) {
    final cleanPath = path.toLowerCase().split('?').first;
    return cleanPath.endsWith('.mp4') ||
        cleanPath.endsWith('.mov') ||
        cleanPath.endsWith('.avi') ||
        cleanPath.endsWith('.mkv') ||
        cleanPath.endsWith('.3gp') ||
        cleanPath.endsWith('.webm');
  }

  String? _resolveMediaUrl(String mediaPath) {
    final trimmedPath = mediaPath.trim();
    if (trimmedPath.isEmpty) return null;
    final directUri = Uri.tryParse(trimmedPath);
    if (directUri != null &&
        (directUri.scheme == 'http' || directUri.scheme == 'https') &&
        directUri.host.isNotEmpty) {
      return trimmedPath;
    }
    final normalizedBase = ApiWrapper.imageUrl.endsWith('/')
        ? ApiWrapper.imageUrl
        : '${ApiWrapper.imageUrl}/';
    final normalizedPath = trimmedPath.startsWith('/')
        ? trimmedPath.substring(1)
        : trimmedPath;
    return '$normalizedBase$normalizedPath';
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TasksController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.bgMain,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black87),
            title: Text('Task Management', style: Styles.txtBlackColorW70020),
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
                        onChanged: controller.searchTasks,
                        decoration: InputDecoration(
                          hintText: 'Search tasks...',
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
                                    controller.searchTasks('');
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
                                  controller.filterFromDate != null ||
                                  controller.filterToDate != null ||
                                  controller.filterAssignedBy != null)
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

                // ── Tasks List ──────────────────────────────────────────────
                Expanded(
                  child: controller.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: ColorsValue.primary,
                          ),
                        )
                      : controller.tasks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.assignment_outlined,
                                size: 64,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No tasks found',
                                style: Styles.txtGreyColorW40014,
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () =>
                              controller.fetchTasks(isRefresh: true),
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount:
                                controller.tasks.length +
                                (controller.isFetchingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == controller.tasks.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: ColorsValue.primary,
                                    ),
                                  ),
                                );
                              }

                              final task = controller.tasks[index];
                              final statusColor = _getStatusColor(task.status);
                              final assigneeName =
                                  (task.assignedto != null &&
                                      task.assignedto!.isNotEmpty)
                                  ? task.assignedto!
                                        .map((e) => e.name ?? '')
                                        .where((n) => n.isNotEmpty)
                                        .join(', ')
                                  : '';

                              return Card(
                                elevation: 1,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    controller.fetchTaskDetailsAndOpenForm(
                                      task.id ?? '',
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12),
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
                                            Expanded(
                                              child: Text(
                                                task.taskname ?? 'Unnamed',
                                                style:
                                                    Styles.txtBlackColorW60014,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            PopupMenuButton<String>(
                                              padding: EdgeInsets.zero,
                                              onSelected: (newStatus) {
                                                controller.changeTaskStatus(
                                                  task.id ?? '',
                                                  newStatus,
                                                );
                                              },
                                              itemBuilder: (context) => const [
                                                PopupMenuItem(
                                                  value: 'pending',
                                                  child: Text('Pending'),
                                                ),
                                                PopupMenuItem(
                                                  value: 'processing',
                                                  child: Text('Processing'),
                                                ),
                                                PopupMenuItem(
                                                  value: 'completed',
                                                  child: Text('Completed'),
                                                ),
                                                PopupMenuItem(
                                                  value: 'cancelled',
                                                  child: Text('Cancelled'),
                                                ),
                                              ],
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: statusColor.withValues(
                                                    alpha: 0.1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      Utility.capitalizeFirst(
                                                        task.status ??
                                                            'pending',
                                                      ),
                                                      style: TextStyle(
                                                        color: statusColor,
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 2),
                                                    Icon(
                                                      Icons.arrow_drop_down,
                                                      size: 14,
                                                      color: statusColor,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        if (task.description != null &&
                                            task.description!.isNotEmpty) ...[
                                          Text(
                                            task.description!,
                                            style: Styles.txtGreyColorW40012,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 12),
                                        ],
                                        if (task.attachment != null &&
                                            task.attachment!.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          SizedBox(
                                            height: 60,
                                            child: ListView.separated(
                                              scrollDirection: Axis.horizontal,
                                              itemCount:
                                                  task.attachment!.length,
                                              separatorBuilder: (_, __) =>
                                                  const SizedBox(width: 8),
                                              itemBuilder: (context, index) {
                                                final attach =
                                                    task.attachment![index];
                                                final path = attach.path ?? '';
                                                if (path.isEmpty) {
                                                  return const SizedBox
                                                      .shrink();
                                                }

                                                final isImg = _isImage(path);
                                                final isVid = _isVideo(path);
                                                final resolvedUrl =
                                                    _resolveMediaUrl(path);

                                                return GestureDetector(
                                                  onTap: () {
                                                    Get.to(
                                                      () =>
                                                          const ShowFullScareenImage(),
                                                      arguments: [
                                                        path,
                                                        isVid
                                                            ? 'video'
                                                            : 'image',
                                                      ],
                                                    );
                                                  },
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      8,
                                                    ),
                                                    child: Container(
                                                      width: 60,
                                                      height: 60,
                                                      color:
                                                          Colors.grey.shade100,
                                                      child: isImg &&
                                                              resolvedUrl !=
                                                                  null
                                                          ? CachedNetworkImage(
                                                              imageUrl:
                                                                  resolvedUrl,
                                                              fit: BoxFit
                                                                  .cover,
                                                              placeholder: (
                                                                context,
                                                                url,
                                                              ) =>
                                                                  const Center(
                                                                child:
                                                                    SizedBox(
                                                                  width: 16,
                                                                  height: 16,
                                                                  child:
                                                                      CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        2,
                                                                    valueColor:
                                                                        AlwaysStoppedAnimation(
                                                                      ColorsValue
                                                                          .primary,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              errorWidget: (
                                                                context,
                                                                url,
                                                                error,
                                                              ) =>
                                                                  const Icon(
                                                                Icons
                                                                    .broken_image_outlined,
                                                                size: 20,
                                                                color: Colors
                                                                    .grey,
                                                              ),
                                                            )
                                                          : isVid
                                                              ? Stack(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  children: [
                                                                    Container(
                                                                      color: Colors
                                                                          .black12,
                                                                    ),
                                                                    const Icon(
                                                                      Icons
                                                                          .play_circle_outline,
                                                                      size: 24,
                                                                      color: Colors
                                                                          .black87,
                                                                    ),
                                                                  ],
                                                                )
                                                              : const Icon(
                                                                  Icons
                                                                      .insert_drive_file_outlined,
                                                                  size: 24,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                        ],
                                        Divider(
                                          height: 1,
                                          color: Colors.grey.shade100,
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.calendar_today_outlined,
                                                  size: 14,
                                                  color: ColorsValue.primary,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  _formatDisplayDate(task.date),
                                                  style:
                                                      Styles.txtGreyColorW40012,
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                if (assigneeName
                                                    .isNotEmpty) ...[
                                                  const Icon(
                                                    Icons.person_outline,
                                                    size: 14,
                                                    color: ColorsValue.primary,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    assigneeName,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ] else ...[
                                                  Text(
                                                    'Unassigned',
                                                    style: Styles
                                                        .txtGreyColorW40012,
                                                  ),
                                                ],
                                                const SizedBox(width: 8),
                                                IconButton(
                                                  constraints:
                                                      const BoxConstraints(),
                                                  padding: EdgeInsets.zero,
                                                  icon: const Icon(
                                                    Icons.delete_outline,
                                                    color: Colors.red,
                                                    size: 20,
                                                  ),
                                                  onPressed: () {
                                                    Utility.showDeleteDialog(
                                                      title: 'Delete Task',
                                                      message:
                                                          'Are you sure you want to delete "${task.taskname}"?',
                                                      onConfirm: () {
                                                        controller.deleteTask(
                                                          task.id ?? '',
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
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
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: ColorsValue.primary,
            onPressed: () {
              controller.setupForm(null);
              Get.toNamed<void>('/taskForm');
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  void _showFilterBottomSheet(
    BuildContext context,
    TasksController controller,
  ) {
    DateTime? tempFromDate = controller.filterFromDate;
    DateTime? tempToDate = controller.filterToDate;
    String? tempStatus = controller.filterStatus;
    String? tempAssignedBy = controller.filterAssignedBy;

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
                          'Filter Tasks',
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

                    // Date Range
                    const Text(
                      'Date Range',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
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
                            child: Text(
                              tempFromDate == null
                                  ? 'From Date'
                                  : DateFormat(
                                      'dd-MM-yyyy',
                                    ).format(tempFromDate!),
                              style: TextStyle(
                                color: tempFromDate != null
                                    ? Colors.black87
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
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
                            child: Text(
                              tempToDate == null
                                  ? 'To Date'
                                  : DateFormat(
                                      'dd-MM-yyyy',
                                    ).format(tempToDate!),
                              style: TextStyle(
                                color: tempToDate != null
                                    ? Colors.black87
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                      ],
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
                          value: 'pending',
                          child: Text('Pending'),
                        ),
                        DropdownMenuItem(
                          value: 'processing',
                          child: Text('Processing'),
                        ),
                        DropdownMenuItem(
                          value: 'completed',
                          child: Text('Completed'),
                        ),
                        DropdownMenuItem(
                          value: 'cancelled',
                          child: Text('Cancelled'),
                        ),
                      ],
                      onChanged: (val) {
                        setModalState(() => tempStatus = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Assigned By Dropdown
                    const Text(
                      'Assigned By',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value:
                          tempAssignedBy != null && tempAssignedBy!.isNotEmpty
                          ? tempAssignedBy
                          : null,
                      hint: const Text('Select User'),
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
                      items: controller.usersList.map((user) {
                        return DropdownMenuItem(
                          value: user.id,
                          child: Text(user.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setModalState(() => tempAssignedBy = val);
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
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          controller.setFilters(
                            fromDate: tempFromDate,
                            toDate: tempToDate,
                            status: tempStatus,
                            assignedBy: tempAssignedBy,
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
}
