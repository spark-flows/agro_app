import 'package:agro_app/app/pages/tasks_screen/tasks_controller.dart';
import 'package:agro_app/app/theme/theme.dart';
import 'package:agro_app/app/utils/utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
                                itemCount: controller.tasks.length +
                                    (controller.isFetchingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == controller.tasks.length) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: ColorsValue.primary,
                                        ),
                                      ),
                                    );
                                  }

                                  final task = controller.tasks[index];
                                  final statusColor =
                                      _getStatusColor(task.status);
                                  final assigneeName =
                                      task.assignedto?.name ?? '';

                                  return Card(
                                    elevation: 1,
                                    margin: const EdgeInsets.only(bottom: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        controller.fetchTaskDetailsAndOpenForm(task.id ?? '');
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
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                                                      color: statusColor
                                                          .withValues(alpha: 0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        20,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          Utility.capitalizeFirst(
                                                            task.status ?? 'pending',
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
                                                style:
                                                    Styles.txtGreyColorW40012,
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow.ellipsis,
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
                                                      Icons
                                                          .calendar_today_outlined,
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
                                                        color: ColorsValue
                                                            .primary,
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
                                                        style:
                                                            Styles.txtGreyColorW40012,
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
                                                        Utility
                                                            .showDeleteDialog(
                                                          title: 'Delete Task',
                                                          message:
                                                              'Are you sure you want to delete "${task.taskname}"?',
                                                          onConfirm: () {
                                                            controller
                                                                .deleteTask(
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
}
