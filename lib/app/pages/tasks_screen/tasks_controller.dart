import 'dart:async';
import 'dart:io';
import 'package:agro_app/app/theme/colors_value.dart';
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
  final remarkCtrl = TextEditingController();
  List<String> selectedAssignedToIds = []; // Store User ID strings
  String selectedStatus = 'pending'; // Default: pending
  String selectedPriority = 'medium'; // Default: medium
  String selectedTaskType = 'regular'; // Options: regular, advance
  List<task_list_model.TaskRemark> existingRemarks = [];
  String currentUserId = '';
  List<File> selectedFiles = []; // Picked local files
  List<Map<String, String>> existingAttachments =
      []; // Uploaded attachments when editing

  List<task_list_model.Assignedto> currentAssignees = [];
  String editingTaskId = '';
  Timer? _searchTimer;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUserId();
    fetchTasks(isRefresh: true);
    fetchUsers();
  }

  Future<void> _loadCurrentUserId() async {
    currentUserId = await Get.find<Repository>().getSecureValue(
      LocalKeys.distributorId,
    );
    if (currentUserId.isEmpty) {
      currentUserId = await Get.find<Repository>().getSecureValue(
        LocalKeys.userIds,
      );
    }
    update();
  }

  @override
  void onClose() {
    _searchTimer?.cancel();
    taskNameCtrl.dispose();
    descriptionCtrl.dispose();
    dateCtrl.dispose();
    dueCtrl.dispose();
    dueTimeCtrl.dispose();
    remarkCtrl.dispose();
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
      selectedTaskType = 'regular';
      remarkCtrl.clear();
      existingRemarks = [];
      selectedFiles = [];
      existingAttachments = [];
    } else {
      editingTaskId = task.id ?? '';
      currentAssignees = task.assignedto ?? [];
      taskNameCtrl.text = task.taskname ?? '';
      descriptionCtrl.text = task.description ?? '';
      selectedTaskType = task.tasktype ?? 'regular';

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
      existingRemarks = List<task_list_model.TaskRemark>.from(
        task.remarks ?? [],
      );
      remarkCtrl.clear();
      if (currentUserId.isNotEmpty) {
        final myRemark = existingRemarks.firstWhereOrNull(
          (r) => r.updatedById.isNotEmpty && r.updatedById == currentUserId,
        );
        if (myRemark != null) {
          remarkCtrl.text = myRemark.remark ?? '';
        }
      }
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

      final List<String> assignees = List.from(selectedAssignedToIds);
      String loggedInUserId = await Get.find<Repository>().getSecureValue(
        LocalKeys.distributorId,
      );
      if (loggedInUserId.isEmpty) {
        loggedInUserId = await Get.find<Repository>().getSecureValue(
          LocalKeys.userIds,
        );
      }
      if (loggedInUserId.isNotEmpty && !assignees.contains(loggedInUserId)) {
        assignees.add(loggedInUserId);
      }

      final String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final newRemarkText = remarkCtrl.text.trim();

      List<Map<String, dynamic>> remarksPayload = [];
      for (var r in existingRemarks) {
        remarksPayload.add(r.toJson());
      }

      if (newRemarkText.isNotEmpty && loggedInUserId.isNotEmpty) {
        final userRemarkIdx = remarksPayload.indexWhere(
          (r) =>
              r["updatedBy"] != null &&
              r["updatedBy"].toString() == loggedInUserId,
        );
        final newRemarkMap = {
          "status": selectedTaskType,
          "remark": newRemarkText,
          "updatedBy": loggedInUserId,
          "date": todayDate,
        };
        if (userRemarkIdx != -1) {
          remarksPayload[userRemarkIdx] = newRemarkMap;
        } else {
          remarksPayload.add(newRemarkMap);
        }
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
        tasktype: selectedTaskType,
        remarks: remarksPayload,
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
  Future<void> showChangeStatusDialog({
    required String taskId,
    required String newStatus,
  }) async {
    final remarkStatusCtrl = TextEditingController();
    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ColorsValue.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.published_with_changes,
                      color: ColorsValue.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Update Status",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ColorsValue.txtBlackColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "New Status: ${newStatus.toUpperCase()}",
                          style: TextStyle(
                            fontSize: 12,
                            color: ColorsValue.txtGreyColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: remarkStatusCtrl,
                maxLines: 3,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ColorsValue.txtBlackColor,
                ),
                decoration: InputDecoration(
                  labelText: "Remark *",
                  hintText: "Enter remark for status change",
                  labelStyle: TextStyle(
                    color: ColorsValue.txtGreyColor,
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.comment_outlined,
                    color: ColorsValue.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: ColorsValue.primary,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                        foregroundColor: ColorsValue.txtGreyColor,
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final remarkText = remarkStatusCtrl.text.trim();
                        if (remarkText.isEmpty) {
                          Utility.errorMessage("Please enter a remark");
                          return;
                        }
                        Get.back(); // close dialog
                        await changeTaskStatus(
                          id: taskId,
                          status: newStatus,
                          remark: remarkText,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsValue.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Submit",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> changeTaskStatus({
    required String id,
    required String status,
    required String remark,
  }) async {
    try {
      if (currentUserId.isEmpty) {
        await _loadCurrentUserId();
      }
      final success = await Get.find<Repository>().changeTaskStatusApi(
        taskid: id,
        status: status,
        remark: remark,
        updatedBy: currentUserId,
        isLoading: true,
      );
      if (success) {
        final index = tasks.indexWhere((t) => t.id == id);
        if (index != -1) {
          tasks[index].status = status;
        }
        await fetchTasks(isRefresh: true);
        Utility.snacBar('Task status updated successfully', Colors.green);
      }
    } catch (e) {
      debugPrint('[TasksController] changeTaskStatus error: $e');
    }
  }
}
