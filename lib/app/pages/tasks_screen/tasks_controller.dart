import 'dart:async';
import 'package:agro_app/app/utils/utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:agro_app/domain/models/get_all_users_model.dart' as user_model;
import 'package:agro_app/domain/models/getAll_tasks_model.dart' as task_list_model;
import 'package:agro_app/domain/repositories/repository.dart';

class TasksController extends GetxController {
  // ── Task list & pagination state ──────────────────────────────────────────
  List<task_list_model.Doc> tasks = [];
  bool isLoading = false;
  bool isFetchingMore = false;

  int currentPage = 1;
  int totalPages = 1;
  int limit = 10; // Page limit is 10 as requested

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // ── System users list ──────────────────────────────────────────────────────
  List<user_model.Doc> usersList = [];
  bool isLoadingUsers = false;

  // ── Form Controllers & State ───────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();
  final taskNameCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  String? selectedAssignedToId; // Store User ID string
  String selectedStatus = 'pending'; // Default: pending

  String editingTaskId = '';
  Timer? _searchTimer;

  @override
  void onInit() {
    super.onInit();
    fetchTasks(isRefresh: true);
    fetchUsers();
  }

  @override
  void onClose() {
    _searchTimer?.cancel();
    taskNameCtrl.dispose();
    descriptionCtrl.dispose();
    dateCtrl.dispose();
    super.onClose();
  }

  // ── Fetch Tasks from API with Pagination ──────────────────────────────────
  Future<void> fetchTasks({bool isRefresh = true}) async {
    if (isRefresh) {
      currentPage = 1;
      tasks.clear();
      isLoading = true;
    } else {
      if (currentPage >= totalPages) return;
      currentPage++;
      isFetchingMore = true;
    }
    update();

    try {
      final response = await Get.find<Repository>().getTaskListApi(
        page: currentPage,
        limit: limit,
        search: searchQuery,
        isLoading: isRefresh,
      );

      if (response != null && response.isSuccess == true && response.data != null) {
        final docs = response.data!.docs ?? [];
        if (isRefresh) {
          tasks = docs;
        } else {
          tasks.addAll(docs);
        }
        totalPages = response.data!.totalPages ?? 1;
      }
    } catch (e) {
      debugPrint('[TasksController] fetchTasks error: $e');
    }

    isLoading = false;
    isFetchingMore = false;
    update();
  }

  // ── Fetch System Users via API ─────────────────────────────────────────────
  Future<void> fetchUsers() async {
    isLoadingUsers = true;
    update();
    try {
      final response = await Get.find<Repository>().getUsersListApi(
        page: 1,
        limit: 100, // Load first 100 users for assignees
        type: 'user',
        isLoading: false,
      );
      if (response != null && response.isSuccess) {
        usersList = response.data.docs;
      }
    } catch (e) {
      debugPrint('[TasksController] fetchUsers error: $e');
    }
    isLoadingUsers = false;
    update();
  }

  // ── Search & Filter ────────────────────────────────────────────────────────
  void searchTasks(String query) {
    _searchQuery = query;
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      fetchTasks(isRefresh: true);
    });
  }

  // ── Setup Form State ───────────────────────────────────────────────────────
  void setupForm(task_list_model.Doc? task) {
    if (task == null) {
      editingTaskId = '';
      taskNameCtrl.clear();
      descriptionCtrl.clear();
      // Default date to today formatted as dd-MM-yyyy
      dateCtrl.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
      selectedAssignedToId = null;
      selectedStatus = 'pending'; // Default as requested
    } else {
      editingTaskId = task.id ?? '';
      taskNameCtrl.text = task.taskname ?? '';
      descriptionCtrl.text = task.description ?? '';
      
      // Convert API yyyy-MM-dd to display dd-MM-yyyy
      if (task.date != null && task.date!.isNotEmpty) {
        try {
          final parsed = DateTime.parse(task.date!);
          dateCtrl.text = DateFormat('dd-MM-yyyy').format(parsed);
        } catch (_) {
          try {
            final parsed = DateFormat('yyyy-MM-dd').parse(task.date!);
            dateCtrl.text = DateFormat('dd-MM-yyyy').format(parsed);
          } catch (_) {
            dateCtrl.text = task.date ?? '';
          }
        }
      } else {
        dateCtrl.text = '';
      }

      selectedAssignedToId = task.assignedto?.id;
      selectedStatus = task.status ?? 'pending';
    }
    update();
  }

  // ── Save Task (Create/Update via API) ──────────────────────────────────────
  Future<void> saveTask() async {
    try {
      // Convert display dd-MM-yyyy to API yyyy-MM-dd
      String apiDate = dateCtrl.text.trim();
      try {
        final parsed = DateFormat('dd-MM-yyyy').parse(apiDate);
        apiDate = DateFormat('yyyy-MM-dd').format(parsed);
      } catch (_) {}

      final response = await Get.find<Repository>().createTaskApi(
        taskid: editingTaskId.isNotEmpty ? editingTaskId : null,
        date: apiDate,
        taskname: taskNameCtrl.text.trim(),
        description: descriptionCtrl.text.trim(),
        assignedto: selectedAssignedToId ?? '',
        status: selectedStatus,
        isLoading: true,
      );

      if (response != null && response.isSuccess == true) {
        Get.back(); // Go back to tasks list
        fetchTasks(isRefresh: true); // Refresh list
        Utility.snacBar(
          editingTaskId.isEmpty ? 'Task added successfully' : 'Task updated successfully',
          Colors.green,
        );
      }
    } catch (e) {
      debugPrint('[TasksController] saveTask error: $e');
    }
  }

  // ── Delete Task via API ────────────────────────────────────────────────────
  Future<void> deleteTask(String id) async {
    try {
      final success = await Get.find<Repository>().deleteTaskApi(
        taskid: id,
        isLoading: true,
      );
      if (success) {
        fetchTasks(isRefresh: true);
        Utility.snacBar('Task deleted successfully', Colors.green);
      }
    } catch (e) {
      debugPrint('[TasksController] deleteTask error: $e');
    }
  }

  // ── Fetch Task Details & Open Form (via getone API) ───────────────────────
  Future<void> fetchTaskDetailsAndOpenForm(String id) async {
    try {
      final response = await Get.find<Repository>().getOneTaskApi(
        taskid: id,
        isLoading: true,
      );
      if (response != null && response.isSuccess == true && response.data != null) {
        setupForm(response.data);
        Get.toNamed<void>('/taskForm');
      }
    } catch (e) {
      debugPrint('[TasksController] fetchTaskDetailsAndOpenForm error: $e');
    }
  }

  // ── Change Task Status (via changestatus API) ──────────────────────────────
  Future<void> changeTaskStatus(String id, String status) async {
    try {
      final success = await Get.find<Repository>().changeTaskStatusApi(
        taskid: id,
        status: status,
        isLoading: true,
      );
      if (success) {
        final index = tasks.indexWhere((t) => t.id == id);
        if (index != -1) {
          tasks[index].status = status;
        }
        update();
        Utility.snacBar('Task status updated successfully', Colors.green);
      }
    } catch (e) {
      debugPrint('[TasksController] changeTaskStatus error: $e');
    }
  }
}
