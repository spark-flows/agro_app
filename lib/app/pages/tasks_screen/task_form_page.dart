import 'package:agro_app/app/pages/tasks_screen/tasks_controller.dart';
import 'package:agro_app/app/theme/theme.dart';
import 'package:agro_app/domain/models/getAll_tasks_model.dart'
    as task_list_model;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TaskFormPage extends StatefulWidget {
  const TaskFormPage({super.key});

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  Future<void> _selectDate(
    BuildContext context,
    TasksController controller,
  ) async {
    DateTime initialDate;
    try {
      initialDate = DateFormat('dd-MM-yyyy').parse(controller.dateCtrl.text);
    } catch (_) {
      initialDate =
          DateTime.tryParse(controller.dateCtrl.text) ?? DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ColorsValue.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.dateCtrl.text = DateFormat('dd-MM-yyyy').format(picked);
      });
      controller.update();
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
            title: Text(
              controller.editingTaskId.isNotEmpty ? 'Edit Task' : 'Add Task',
              style: Styles.txtBlackColorW70020,
            ),
          ),
          body: Form(
            key: controller.formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _sectionHeader('Task Details'),
                const SizedBox(height: 16),

                // ── Task Name ────────────────────────────────────────────────
                _buildField(
                  fieldController: controller.taskNameCtrl,
                  label: 'Task Name *',
                  icon: Icons.assignment_outlined,
                  action: TextInputAction.next,
                  validator: (v) =>
                      v!.trim().isEmpty ? 'Please enter task name' : null,
                ),
                const SizedBox(height: 20),

                // ── Description ──────────────────────────────────────────────
                _buildField(
                  fieldController: controller.descriptionCtrl,
                  label: 'Description',
                  icon: Icons.description_outlined,
                  keyboardType: TextInputType.multiline,
                  action: TextInputAction.newline,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),

                // ── Date Picker ──────────────────────────────────────────────
                InkWell(
                  onTap: () => _selectDate(context, controller),
                  child: IgnorePointer(
                    child: _buildField(
                      fieldController: controller.dateCtrl,
                      label: 'Date *',
                      icon: Icons.calendar_today_outlined,
                      validator: (v) =>
                          v!.trim().isEmpty ? 'Please select a date' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                _sectionHeader('Schedule & Priority'),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDueDate(context, controller),
                        child: IgnorePointer(
                          child: _buildField(
                            fieldController: controller.dueCtrl,
                            label: 'Due Date',
                            icon: Icons.date_range_outlined,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: controller.dueTimeCtrl,
                        cursorColor: ColorsValue.primary,
                        style: Styles.txtBlackColorW50014,
                        decoration: InputDecoration(
                          labelText: 'Due Time / Duration',
                          hintText: 'e.g. 20 minuets',
                          labelStyle: Styles.txtGreyColorW40014,
                          floatingLabelStyle: const TextStyle(
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
                          prefixIcon: Icon(
                            Icons.access_time_outlined,
                            color: ColorsValue.primary.withValues(alpha: 0.8),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.timer_outlined,
                              color: ColorsValue.primary,
                            ),
                            onPressed: () =>
                                _selectDueTime(context, controller),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  value: controller.selectedPriority,
                  decoration: InputDecoration(
                    labelText: 'Priority *',
                    labelStyle: Styles.txtGreyColorW40014,
                    floatingLabelStyle: const TextStyle(
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
                    prefixIcon: const Icon(
                      Icons.priority_high_outlined,
                      color: ColorsValue.primary,
                    ),
                  ),
                  items: ['low', 'medium', 'high']
                      .map(
                        (val) => DropdownMenuItem<String>(
                          value: val,
                          child: Text(val.toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      controller.selectedPriority = newValue;
                      controller.update();
                    }
                  },
                ),
                const SizedBox(height: 24),

                _sectionHeader('Assignment & Status'),
                const SizedBox(height: 16),

                if (controller.isLoadingUsers) ...[
                  const SizedBox(
                    height: 56,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: ColorsValue.primary,
                      ),
                    ),
                  ),
                ] else ...[
                  InkWell(
                    onTap: () =>
                        _showAssigneesSelectionSheet(context, controller),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            color: ColorsValue.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              controller.selectedAssignedToIds.isEmpty
                                  ? 'Select Assignees'
                                  : '${controller.selectedAssignedToIds.length} assignees selected',
                              style: controller.selectedAssignedToIds.isEmpty
                                  ? Styles.txtGreyColorW40014
                                  : Styles.txtBlackColorW50014,
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (controller.currentAssignees.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.currentAssignees.map((user) {
                      return Chip(
                        avatar: const CircleAvatar(
                          backgroundColor: ColorsValue.primary,
                          child: Icon(
                            Icons.person,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                        label: Text(
                          user.name ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                        backgroundColor: Colors.grey.shade100,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        onDeleted: () {
                          controller.currentAssignees.remove(user);
                          controller.selectedAssignedToIds.remove(user.id);
                          controller.update();
                        },
                        deleteIcon: Icon(Icons.close),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 15),
                ] else ...[
                  const SizedBox(height: 20),
                ],

                // ── Status Dropdown ──────────────────────────────────────────
                DropdownButtonFormField<String>(
                  value: controller.selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Status *',
                    labelStyle: Styles.txtGreyColorW40014,
                    floatingLabelStyle: const TextStyle(
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
                    prefixIcon: const Icon(
                      Icons.star_half_outlined,
                      color: ColorsValue.primary,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
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
                    if (val != null) {
                      setState(() {
                        controller.selectedStatus = val;
                      });
                      controller.update();
                    }
                  },
                ),
                const SizedBox(height: 20),

                // ── Task Type Dropdown ───────────────────────────────────────
                DropdownButtonFormField<String>(
                  value: controller.selectedTaskType,
                  decoration: InputDecoration(
                    labelText: 'Task Type *',
                    labelStyle: Styles.txtGreyColorW40014,
                    floatingLabelStyle: const TextStyle(
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
                    prefixIcon: const Icon(
                      Icons.category_outlined,
                      color: ColorsValue.primary,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'regular', child: Text('Regular')),
                    DropdownMenuItem(value: 'advance', child: Text('Advance')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        controller.selectedTaskType = val;
                      });
                      controller.update();
                    }
                  },
                ),
                const SizedBox(height: 24),

                // ── Remarks Section ──────────────────────────────────────────
                _sectionHeader('Remarks'),
                const SizedBox(height: 16),

                if (controller.existingRemarks.isNotEmpty) ...[
                  ...controller.existingRemarks.map((rem) {
                    final isMyRemark =
                        controller.currentUserId.isNotEmpty &&
                        rem.updatedById.isNotEmpty &&
                        rem.updatedById == controller.currentUserId;
                    final authorDisplay = isMyRemark
                        ? 'You'
                        : (rem.updatedByName.isNotEmpty
                              ? rem.updatedByName
                              : (rem.updatedById.isNotEmpty
                                    ? rem.updatedById
                                    : 'User'));

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMyRemark
                            ? ColorsValue.primary.withValues(alpha: 0.05)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isMyRemark
                              ? ColorsValue.primary
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isMyRemark
                                        ? Icons.edit_note
                                        : Icons.lock_outline,
                                    size: 16,
                                    color: isMyRemark
                                        ? ColorsValue.primary
                                        : Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    authorDisplay,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isMyRemark
                                          ? ColorsValue.primary
                                          : Colors.grey.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: rem.status == 'advance'
                                      ? Colors.orange.shade100
                                      : Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  (rem.status ?? 'regular').toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: rem.status == 'advance'
                                        ? Colors.orange.shade800
                                        : Colors.blue.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            rem.remark ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          if (rem.date != null && rem.date!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              rem.date!,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                ],

                _buildField(
                  fieldController: controller.remarkCtrl,
                  label: 'Add / Edit Remark',
                  icon: Icons.comment_outlined,
                  keyboardType: TextInputType.multiline,
                  action: TextInputAction.newline,
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                _sectionHeader('Attachments'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (controller.existingAttachments.isNotEmpty) ...[
                        const Text(
                          'Existing Attachments',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...controller.existingAttachments.asMap().entries.map((
                          entry,
                        ) {
                          final idx = entry.key;
                          final att = entry.value;
                          final path = att["path"] ?? "";
                          final fileName = path.split('/').last;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _getFileIcon(path),
                                  color: ColorsValue.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    fileName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      controller.removeExistingAttachment(idx),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 12),
                      ],
                      if (controller.selectedFiles.isNotEmpty) ...[
                        const Text(
                          'New Attachments',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...controller.selectedFiles.asMap().entries.map((
                          entry,
                        ) {
                          final idx = entry.key;
                          final file = entry.value;
                          final fileName = file.path
                              .split(RegExp(r'[/\\]'))
                              .last;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: ColorsValue.primary.withValues(
                                alpha: 0.03,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _getFileIcon(file.path),
                                  color: ColorsValue.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    fileName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      controller.removeSelectedFile(idx),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 12),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: controller.pickAttachments,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(
                              color: ColorsValue.primary,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                color: ColorsValue.primary,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Add PDF, Excel, or Image',
                                style: TextStyle(
                                  color: ColorsValue.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // ── Save Button ──────────────────────────────────────────────
                ElevatedButton(
                  onPressed: () {
                    if (controller.formKey.currentState!.validate()) {
                      controller.saveTask();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsValue.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Task',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectDueDate(
    BuildContext context,
    TasksController controller,
  ) async {
    DateTime initialDate;
    try {
      initialDate = DateFormat('dd-MM-yyyy').parse(controller.dueCtrl.text);
    } catch (_) {
      initialDate = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ColorsValue.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.dueCtrl.text = DateFormat('dd-MM-yyyy').format(picked);
      });
      controller.update();
    }
  }

  Future<void> _selectDueTime(
    BuildContext context,
    TasksController controller,
  ) async {
    TimeOfDay initialTime = TimeOfDay.now();
    if (controller.dueTimeCtrl.text.isNotEmpty) {
      try {
        final parts = controller.dueTimeCtrl.text.split(':');
        if (parts.length == 2) {
          initialTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      } catch (_) {}
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ColorsValue.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final hourStr = picked.hour.toString().padLeft(2, '0');
      final minuteStr = picked.minute.toString().padLeft(2, '0');
      setState(() {
        controller.dueTimeCtrl.text = "$hourStr:$minuteStr";
      });
      controller.update();
    }
  }

  IconData _getFileIcon(String fileNameOrPath) {
    final lower = fileNameOrPath.toLowerCase();
    if (lower.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (lower.endsWith('.xls') || lower.endsWith('.xlsx'))
      return Icons.table_chart;
    return Icons.insert_photo;
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: ColorsValue.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(title, style: Styles.txtBlackColorW60014),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController fieldController,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction action = TextInputAction.done,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: fieldController,
      keyboardType: keyboardType,
      textInputAction: action,
      maxLines: maxLines,
      cursorColor: ColorsValue.primary,
      style: Styles.txtBlackColorW50014,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Styles.txtGreyColorW40014,
        floatingLabelStyle: const TextStyle(color: ColorsValue.primary),
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
          borderSide: const BorderSide(color: ColorsValue.primary, width: 1.5),
        ),
        prefixIcon: Icon(
          icon,
          color: ColorsValue.primary.withValues(alpha: 0.8),
        ),
      ),
      validator: validator,
    );
  }

  void _showAssigneesSelectionSheet(
    BuildContext context,
    TasksController controller,
  ) {
    List<String> tempSelectedIds = List.from(controller.selectedAssignedToIds);
    String sheetSearchQuery = '';

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          final filteredUsers = controller.usersList
              .where((user) => user.roleid.rolename?.toLowerCase() != 'admin')
              .where((user) {
                if (sheetSearchQuery.isEmpty) return true;
                return user.name.toLowerCase().contains(
                  sheetSearchQuery.toLowerCase(),
                );
              })
              .toList();

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Select Assignees', style: Styles.txtBlackColorW70020),
                    IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
                TextField(
                  onChanged: (val) {
                    setSheetState(() {
                      sheetSearchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search assignee...',
                    hintStyle: Styles.txtGreyColorW40014,
                    prefixIcon: const Icon(
                      Icons.search,
                      color: ColorsValue.primary,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 12,
                    ),
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
                      borderSide: const BorderSide(
                        color: ColorsValue.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: filteredUsers.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Text('No assignees found'),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, idx) {
                            final user = filteredUsers[idx];
                            final isChecked = tempSelectedIds.contains(user.id);
                            return CheckboxListTile(
                              visualDensity: VisualDensity(
                                horizontal: Dimens.zero,
                                vertical: Dimens.zero,
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              dense: true,
                              activeColor: ColorsValue.primary,
                              title: Text(
                                user.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                user.roleid.rolename ?? '',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                              value: isChecked,
                              onChanged: (bool? checked) {
                                setSheetState(() {
                                  if (checked == true) {
                                    tempSelectedIds.add(user.id);
                                  } else {
                                    tempSelectedIds.remove(user.id);
                                  }
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setSheetState(() {
                            tempSelectedIds.clear();
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'Clear All',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          controller.selectedAssignedToIds = List.from(
                            tempSelectedIds,
                          );
                          controller.currentAssignees = controller.usersList
                              .where((u) => tempSelectedIds.contains(u.id))
                              .map(
                                (u) => task_list_model.Assignedto(
                                  id: u.id,
                                  name: u.name,
                                  mobile: u.mobile,
                                  email: u.email,
                                ),
                              )
                              .toList();
                          controller.update();
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsValue.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }
}
