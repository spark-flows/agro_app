import 'package:agro_app/app/pages/tasks_screen/tasks_controller.dart';
import 'package:agro_app/app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TaskFormPage extends StatefulWidget {
  const TaskFormPage({super.key});

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  Future<void> _selectDate(BuildContext context, TasksController controller) async {
    DateTime initialDate;
    try {
      initialDate = DateFormat('dd-MM-yyyy').parse(controller.dateCtrl.text);
    } catch (_) {
      initialDate = DateTime.tryParse(controller.dateCtrl.text) ?? DateTime.now();
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
                            Icons.access_time_outlined,
                            color: ColorsValue.primary.withValues(alpha: 0.8),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.timer_outlined, color: ColorsValue.primary),
                            onPressed: () => _selectDueTime(context, controller),
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

                if (controller.isLoadingUsers)
                  const SizedBox(
                    height: 56,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: ColorsValue.primary,
                      ),
                    ),
                  )
                else if (controller.usersList.isNotEmpty)
                  FormField<List<String>>(
                    initialValue: controller.selectedAssignedToIds,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Please select at least one assignee'
                        : null,
                    builder: (formFieldState) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () => _showAssigneeMultiSelectBottomSheet(
                              context,
                              controller,
                              formFieldState,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Assigned To *',
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
                                prefixIcon: const Icon(
                                  Icons.person_outline,
                                  color: ColorsValue.primary,
                                ),
                                errorText: formFieldState.errorText,
                                suffixIcon: controller.selectedAssignedToIds.isNotEmpty
                                    ? Container(
                                        margin: const EdgeInsets.only(right: 12),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: ColorsValue.primary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${controller.selectedAssignedToIds.length} Selected',
                                          style: const TextStyle(
                                            color: ColorsValue.primary,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : const Icon(Icons.arrow_drop_down, color: Colors.grey),
                                suffixIconConstraints: const BoxConstraints(
                                  minWidth: 0,
                                  minHeight: 0,
                                ),
                              ),
                              child: Text(
                                controller.selectedAssignedToIds.isEmpty
                                    ? 'Select assignees'
                                    : controller.selectedAssignedToIds
                                        .map((id) => controller.usersList.firstWhereOrNull((u) => u.id == id)?.name ?? id)
                                        .join(', '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: controller.selectedAssignedToIds.isEmpty ? Colors.grey.shade600 : Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  )
                else
                  // Text field fallback in case no system users are returned
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    initialValue: controller.selectedAssignedToIds.join(', '),
                    cursorColor: ColorsValue.primary,
                    style: Styles.txtBlackColorW50014,
                    decoration: InputDecoration(
                      labelText: 'Assigned To (User IDs, comma separated) *',
                      labelStyle: Styles.txtGreyColorW40014,
                      floatingLabelStyle:
                          const TextStyle(color: ColorsValue.primary),
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
                        Icons.person_outline,
                        color: ColorsValue.primary,
                      ),
                    ),
                    onChanged: (val) {
                      controller.selectedAssignedToIds = val
                          .split(',')
                          .map((s) => s.trim())
                          .where((s) => s.isNotEmpty)
                          .toList();
                    },
                    validator: (v) => v!.trim().isEmpty
                        ? 'Please enter assignee user ID(s)'
                        : null,
                  ),
                const SizedBox(height: 20),

                // ── Status Dropdown ──────────────────────────────────────────
                DropdownButtonFormField<String>(
                  value: controller.selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Status *',
                    labelStyle: Styles.txtGreyColorW40014,
                    floatingLabelStyle:
                        const TextStyle(color: ColorsValue.primary),
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
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        ...controller.existingAttachments.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final att = entry.value;
                          final path = att["path"] ?? "";
                          final fileName = path.split('/').last;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(_getFileIcon(path), color: ColorsValue.primary, size: 20),
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
                                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                  onPressed: () => controller.removeExistingAttachment(idx),
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
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        ...controller.selectedFiles.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final file = entry.value;
                          final fileName = file.path.split('/').last;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: ColorsValue.primary.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(_getFileIcon(file.path), color: ColorsValue.primary, size: 20),
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
                                  icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                                  onPressed: () => controller.removeSelectedFile(idx),
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
                            side: const BorderSide(color: ColorsValue.primary, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_circle_outline, color: ColorsValue.primary, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Add PDF, Excel, or Image',
                                style: TextStyle(color: ColorsValue.primary, fontWeight: FontWeight.bold, fontSize: 13),
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

  Future<void> _selectDueDate(BuildContext context, TasksController controller) async {
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

  Future<void> _selectDueTime(BuildContext context, TasksController controller) async {
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
    if (lower.endsWith('.xls') || lower.endsWith('.xlsx')) return Icons.table_chart;
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

  void _showAssigneeMultiSelectBottomSheet(
    BuildContext context,
    TasksController controller,
    FormFieldState<List<String>> formFieldState,
  ) {
    List<String> tempSelectedIds = List.from(controller.selectedAssignedToIds);
    String searchQuery = '';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredUsers = controller.usersList.where((user) {
              final name = user.name.toLowerCase();
              final email = user.email.toLowerCase();
              final mobile = user.mobile.toLowerCase();
              final q = searchQuery.toLowerCase();
              return name.contains(q) || email.contains(q) || mobile.contains(q);
            }).toList();

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
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Assignees',
                        style: Styles.txtBlackColorW70020.copyWith(fontSize: 16),
                      ),
                      Row(
                        children: [
                          if (tempSelectedIds.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                setModalState(() {
                                  tempSelectedIds.clear();
                                });
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Clear All', style: TextStyle(color: Colors.red, fontSize: 13)),
                            ),
                          const SizedBox(width: 8),
                          Text(
                            '(${tempSelectedIds.length} selected)',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search assignees...',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                      prefixIcon: const Icon(Icons.search, size: 18, color: ColorsValue.primary),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      fillColor: Colors.grey.shade50,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: ColorsValue.primary),
                      ),
                    ),
                    style: const TextStyle(fontSize: 13),
                    onChanged: (val) {
                      setModalState(() {
                        searchQuery = val;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filteredUsers.isEmpty
                        ? const Center(child: Text('No users found', style: TextStyle(fontSize: 13, color: Colors.grey)))
                        : ListView.builder(
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = filteredUsers[index];
                              final isSelected = tempSelectedIds.contains(user.id);
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSelected ? ColorsValue.primary.withValues(alpha: 0.03) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: CheckboxListTile(
                                  activeColor: ColorsValue.primary,
                                  dense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                  visualDensity: VisualDensity.compact,
                                  value: isSelected,
                                  title: Text(
                                    user.name,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    user.email.isNotEmpty ? user.email : user.mobile,
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                  ),
                                  onChanged: (checked) {
                                    setModalState(() {
                                      if (checked == true) {
                                        tempSelectedIds.add(user.id);
                                      } else {
                                        tempSelectedIds.remove(user.id);
                                      }
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel', style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorsValue.primary,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            setState(() {
                              controller.selectedAssignedToIds = tempSelectedIds;
                              formFieldState.didChange(tempSelectedIds);
                            });
                            controller.update();
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Confirm',
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
