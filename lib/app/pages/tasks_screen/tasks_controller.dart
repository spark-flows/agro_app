import 'dart:async';
import 'dart:io';
import 'package:agro_app/app/utils/utility.dart';
import 'package:agro_app/domain/repositories/local_storage_keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:agro_app/domain/models/get_all_users_model.dart' as user_model;
import 'package:agro_app/domain/models/getAll_tasks_model.dart'
    as task_list_model;
import 'package:agro_app/domain/models/upload_files_model.dart';
import 'package:agro_app/domain/repositories/repository.dart';
import 'package:file_picker/file_picker.dart';

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

  // ── Filter State ───────────────────────────────────────────────────────────
  DateTime? filterFromDate;
  DateTime? filterToDate;
  String? filterStatus;
  String? filterAssignedBy; // Store User ID string of creator

  // ── System users list ──────────────────────────────────────────────────────
  List<user_model.Doc> usersList = [];
  bool isLoadingUsers = false;

  // ── Form Controllers & State ───────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();
  final taskNameCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  final dueCtrl = TextEditingController();
  final dueTimeCtrl = TextEditingController();
  List<String> selectedAssignedToIds = []; // Store User ID strings
  String selectedStatus = 'pending'; // Default: pending
  String selectedPriority = 'medium'; // Default: medium
  List<File> selectedFiles = []; // Picked local files
  List<Map<String, String>> existingAttachments =
      []; // Uploaded attachments when editing

  List<task_list_model.Assignedto> currentAssignees = [];
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
    dueCtrl.dispose();
    dueTimeCtrl.dispose();
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

    var userId = await Get.find<Repository>().getSecureValue(LocalKeys.userIds);

    try {
      final response = await Get.find<Repository>().getTaskListApi(
        page: currentPage,
        limit: limit,
        search: searchQuery,
        fromDate: filterFromDate != null
            ? DateFormat('yyyy-MM-dd').format(filterFromDate!)
            : "",
        toDate: filterToDate != null
            ? DateFormat('yyyy-MM-dd').format(filterToDate!)
            : "",
        status: filterStatus ?? "",
        assignedBy: filterAssignedBy ?? "",
        assignedto: userId,
        isLoading: isRefresh,
      );

      if (response != null &&
          response.isSuccess == true &&
          response.data != null) {
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
    print('[TasksController] fetchUsers: Starting fetch...');
    try {
      final response = await Get.find<Repository>().getUsersListApi(
        page: 1,
        limit: 100, // Load first 100 users for assignees
        type: 'user',
        isLoading: false,
      );
      if (response != null) {
        print(
          '[TasksController] fetchUsers success: status=${response.status}, isSuccess=${response.isSuccess}, docsLen=${response.data.docs.length}',
        );
        usersList = response.data.docs;
        for (var u in usersList) {
          print('  - User: id=${u.id}, name=${u.name}');
        }
      } else {
        print('[TasksController] fetchUsers: response is null');
      }
    } catch (e, st) {
      print('[TasksController] fetchUsers error: $e\n$st');
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

  void setFilters({
    DateTime? fromDate,
    DateTime? toDate,
    String? status,
    String? assignedBy,
  }) {
    filterFromDate = fromDate;
    filterToDate = toDate;
    filterStatus = status;
    filterAssignedBy = assignedBy;
    fetchTasks(isRefresh: true);
  }

  void clearFilters() {
    filterFromDate = null;
    filterToDate = null;
    filterStatus = null;
    filterAssignedBy = null;
    fetchTasks(isRefresh: true);
  }

  // ── Setup Form State ───────────────────────────────────────────────────────
  // ── Setup Form State ───────────────────────────────────────────────────────
  void setupForm(task_list_model.Doc? task) {
    if (task == null) {
      editingTaskId = '';
      currentAssignees = [];
      taskNameCtrl.clear();
      descriptionCtrl.clear();
      // Default date to today formatted as dd-MM-yyyy
      dateCtrl.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
      selectedAssignedToIds = [];
      selectedStatus = 'pending'; // Default as requested
      dueCtrl.clear();
      dueTimeCtrl.clear();
      selectedPriority = 'medium';
      selectedFiles = [];
      existingAttachments = [];
    } else {
      editingTaskId = task.id ?? '';
      currentAssignees = task.assignedto ?? [];
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

      // Convert API yyyy-MM-dd to display dd-MM-yyyy for duedate
      if (task.duedate != null && task.duedate!.isNotEmpty) {
        try {
          final parsed = DateTime.parse(task.duedate!);
          dueCtrl.text = DateFormat('dd-MM-yyyy').format(parsed);
        } catch (_) {
          try {
            final parsed = DateFormat('yyyy-MM-dd').parse(task.duedate!);
            dueCtrl.text = DateFormat('dd-MM-yyyy').format(parsed);
          } catch (_) {
            dueCtrl.text = task.duedate ?? '';
          }
        }
      } else {
        dueCtrl.text = '';
      }

      dueTimeCtrl.text = task.time ?? '';
      selectedPriority = task.priority ?? 'medium';
      selectedAssignedToIds = [];
      if (task.assignedto != null) {
        for (var user in task.assignedto!) {
          if (user.id != null) {
            selectedAssignedToIds.add(user.id!);
          }
        }
      }
      selectedStatus = task.status ?? 'pending';
      selectedFiles = [];
      existingAttachments =
          task.attachment?.map((att) => {"path": att.path ?? ""}).toList() ??
          [];
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

      // Convert display dd-MM-yyyy to API yyyy-MM-dd for duedate
      String apiDueDate = dueCtrl.text.trim();
      if (apiDueDate.isNotEmpty) {
        try {
          final parsed = DateFormat('dd-MM-yyyy').parse(apiDueDate);
          apiDueDate = DateFormat('yyyy-MM-dd').format(parsed);
        } catch (_) {}
      }

      // Upload new selected files if any
      List<Map<String, String>> uploadedUrls = [];
      if (selectedFiles.isNotEmpty) {
        final uploadResponse = await Get.find<Repository>()
            .uploadTaskAttachmentApi(selectedFiles, isLoading: true);
        if (!uploadResponse.hasError) {
          final uploadResult = uploadFilesFromJson(uploadResponse.data);
          if (uploadResult.data != null) {
            for (var fileDatum in uploadResult.data!) {
              if (fileDatum.url != null) {
                uploadedUrls.add({"path": fileDatum.url!});
              }
            }
          }
        } else {
          Utility.snacBar('Failed to upload attachments', Colors.red);
          return;
        }
      }

      final List<Map<String, String>> finalAttachments = [
        ...existingAttachments,
        ...uploadedUrls,
      ];

      final List<String> assignees = [];
      if (selectedAssignedToIds.isNotEmpty) {
        assignees.add(selectedAssignedToIds.first);
      }
      final String loggedInUserId = await Get.find<Repository>().getSecureValue(
        LocalKeys.distributorId,
      );
      if (loggedInUserId.isNotEmpty) {
        assignees.add(loggedInUserId);
      }

      final response = await Get.find<Repository>().createTaskApi(
        taskid: editingTaskId.isNotEmpty ? editingTaskId : null,
        date: apiDate,
        taskname: taskNameCtrl.text.trim(),
        description: descriptionCtrl.text.trim(),
        assignedto: assignees,
        status: selectedStatus,
        duedate: apiDueDate,
        time: dueTimeCtrl.text.trim(),
        priority: selectedPriority,
        attachment: finalAttachments,
        isLoading: true,
      );

      if (response != null && response.isSuccess == true) {
        Get.back(); // Go back to tasks list
        fetchTasks(isRefresh: true); // Refresh list
        Utility.snacBar(
          editingTaskId.isEmpty
              ? 'Task added successfully'
              : 'Task updated successfully',
          Colors.green,
        );
      }
    } catch (e) {
      debugPrint('[TasksController] saveTask error: $e');
    }
  }

  // ── Attachment Picker Helpers ──────────────────────────────────────────────
  Future<void> pickAttachments() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'xls', 'xlsx', 'jpg', 'jpeg', 'png'],
        allowMultiple: true,
      );
      if (result != null) {
        selectedFiles.addAll(
          result.paths
              .where((path) => path != null)
              .map((path) => File(path!))
              .toList(),
        );
        update();
      }
    } catch (e) {
      debugPrint('[TasksController] pickAttachments error: $e');
    }
  }

  void removeSelectedFile(int index) {
    if (index >= 0 && index < selectedFiles.length) {
      selectedFiles.removeAt(index);
      update();
    }
  }

  void removeExistingAttachment(int index) {
    if (index >= 0 && index < existingAttachments.length) {
      existingAttachments.removeAt(index);
      update();
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
      if (response != null &&
          response.isSuccess == true &&
          response.data != null) {
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
