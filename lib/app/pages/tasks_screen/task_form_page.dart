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

                _sectionHeader('Assignment & Status'),
                const SizedBox(height: 16),

                // ── Assigned To Dropdown ─────────────────────────────────────
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
                  DropdownButtonFormField<String>(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    value: controller.usersList.any((user) => user.id == controller.selectedAssignedToId)
                        ? controller.selectedAssignedToId
                        : null,
                    decoration: InputDecoration(
                      labelText: 'Assigned To *',
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
                    items: controller.usersList
                        .map(
                          (user) => DropdownMenuItem<String>(
                            value: user.id,
                            child: Text(user.name),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        controller.selectedAssignedToId = val;
                      });
                      controller.update();
                    },
                    validator: (v) =>
                        v == null ? 'Please select an assignee' : null,
                  )
                else
                  // Text field fallback in case no system users are returned
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    initialValue: controller.selectedAssignedToId,
                    cursorColor: ColorsValue.primary,
                    style: Styles.txtBlackColorW50014,
                    decoration: InputDecoration(
                      labelText: 'Assigned To (User ID) *',
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
                      controller.selectedAssignedToId = val;
                    },
                    validator: (v) => v!.trim().isEmpty
                        ? 'Please enter assignee user ID'
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
}
