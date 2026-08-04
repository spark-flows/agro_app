import 'package:agro_app/app/pages/leave_screen/leave_controller.dart';
import 'package:agro_app/app/theme/theme.dart';
import 'package:agro_app/domain/services/enum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LeaveFormPage extends StatefulWidget {
  const LeaveFormPage({super.key});

  @override
  State<LeaveFormPage> createState() => _LeaveFormPageState();
}

class _LeaveFormPageState extends State<LeaveFormPage> {
  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
    VoidCallback onSelected, {
    DateTime? minDate,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final DateTime firstDate = minDate ?? today;

    DateTime initialDate = today;
    if (controller.text.isNotEmpty) {
      try {
        initialDate = DateFormat('dd-MM-yyyy').parse(controller.text);
      } catch (_) {
        try {
          initialDate = DateTime.parse(controller.text);
        } catch (_) {}
      }
    }

    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
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
        controller.text = DateFormat('dd-MM-yyyy').format(picked);
      });
      onSelected();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LeaveController>(
      builder: (controller) {
        final bool isUserRole = RoleUtils.isUser(controller.roleName);

        return Scaffold(
          backgroundColor: ColorsValue.bgMain,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black87),
            title: Text(
              controller.editingLeaveId.isNotEmpty
                  ? 'Edit Leave Request'
                  : 'Apply for Leave',
              style: Styles.txtBlackColorW70020,
            ),
          ),
          body: Form(
            key: controller.formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _sectionHeader('Leave Details'),
                const SizedBox(height: 16),

                // User Selection for Admin
                if (!isUserRole && controller.userList.isNotEmpty)
                  Builder(
                    builder: (context) {
                      final bool userExists = controller.userList.any(
                        (u) => u.id == controller.selectedUserId,
                      );
                      final String? activeUserId = userExists
                          ? controller.selectedUserId
                          : (controller.userList.isNotEmpty
                                ? controller.userList.first.id
                                : null);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select User *',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.person_outline,
                                  color: ColorsValue.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: activeUserId,
                                      items: controller.userList.map((user) {
                                        final name =
                                            '${user.name} ${user.surname ?? ''}'
                                                .trim();
                                        return DropdownMenuItem<String>(
                                          value: user.id,
                                          child: Text(
                                            name.isNotEmpty
                                                ? name
                                                : user.mobile,
                                            style: Styles.txtBlackColorW60014,
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          controller.selectedUserId = val;
                                          controller.calculateDuration();
                                          controller.update();
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),

                // From Date & To Date row
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          final now = DateTime.now();
                          final today = DateTime(now.year, now.month, now.day);
                          final minDate = isUserRole ? today : DateTime(2020);
                          _selectDate(context, controller.fromDateCtrl, () {
                            if (controller.fromDateCtrl.text.isNotEmpty &&
                                controller.toDateCtrl.text.isNotEmpty) {
                              try {
                                final from = DateFormat(
                                  'dd-MM-yyyy',
                                ).parse(controller.fromDateCtrl.text);
                                final to = DateFormat(
                                  'dd-MM-yyyy',
                                ).parse(controller.toDateCtrl.text);
                                if (to.isBefore(from)) {
                                  controller.toDateCtrl.text =
                                      controller.fromDateCtrl.text;
                                }
                              } catch (_) {}
                            }
                            controller.calculateDuration();
                          }, minDate: minDate);
                        },
                        child: IgnorePointer(
                          child: _buildField(
                            fieldController: controller.fromDateCtrl,
                            label: 'From Date *',
                            icon: Icons.date_range,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          final now = DateTime.now();
                          final today = DateTime(now.year, now.month, now.day);
                          DateTime minDate = isUserRole
                              ? today
                              : DateTime(2020);
                          if (controller.fromDateCtrl.text.isNotEmpty) {
                            try {
                              final parsedFrom = DateFormat(
                                'dd-MM-yyyy',
                              ).parse(controller.fromDateCtrl.text);
                              minDate = parsedFrom;
                            } catch (_) {}
                          }
                          _selectDate(
                            context,
                            controller.toDateCtrl,
                            controller.calculateDuration,
                            minDate: minDate,
                          );
                        },
                        child: IgnorePointer(
                          child: _buildField(
                            fieldController: controller.toDateCtrl,
                            label: 'To Date *',
                            icon: Icons.date_range,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Leave Type Dropdown
                const Text(
                  'Leave Type *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.beach_access,
                        color: ColorsValue.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: controller.selectedLeaveType,
                            items: const [
                              DropdownMenuItem(
                                value: 'full',
                                child: Text('Full Day'),
                              ),
                              DropdownMenuItem(
                                value: 'half',
                                child: Text('Half Day'),
                              ),
                            ],
                            onChanged: (newValue) {
                              if (newValue != null) {
                                controller.selectedLeaveType = newValue;
                                controller.calculateDuration();
                                controller.update();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (controller.selectedLeaveType == 'half') ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Session *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule, color: ColorsValue.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: controller.selectedSession,
                              items: const [
                                DropdownMenuItem(
                                  value: 'session1',
                                  child: Text('Session 1'),
                                ),
                                DropdownMenuItem(
                                  value: 'session2',
                                  child: Text('Session 2'),
                                ),
                              ],
                              onChanged: (newValue) {
                                if (newValue != null) {
                                  controller.selectedSession = newValue;
                                  controller.update();
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // Total Days & Total Hours Row
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        fieldController: controller.totalDaysCtrl,
                        label: 'Total Days *',
                        icon: Icons.view_day_outlined,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildField(
                        fieldController: controller.totalHoursCtrl,
                        label: 'Total Hours *',
                        icon: Icons.hourglass_empty,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _sectionHeader('Approval Status & Details'),
                const SizedBox(height: 16),

                // Status Dropdown: disabled/read-only for User role
                const Text(
                  'Status *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                IgnorePointer(
                  ignoring: isUserRole,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isUserRole ? Colors.grey.shade100 : Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.shield_outlined,
                          color: ColorsValue.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: isUserRole
                                  ? 'pending'
                                  : controller.selectedStatus,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'pending',
                                  child: Text(
                                    'PENDING',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'accept',
                                  child: Text(
                                    'ACCEPT',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'reject',
                                  child: Text(
                                    'REJECT',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (newValue) {
                                if (!isUserRole && newValue != null) {
                                  controller.selectedStatus = newValue;
                                  controller.update();
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Reason input field
                _buildField(
                  fieldController: controller.reasonCtrl,
                  label: 'Reason for Leave *',
                  icon: Icons.comment_outlined,
                  keyboardType: TextInputType.multiline,
                  action: TextInputAction.newline,
                  maxLines: 4,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Please enter the reason'
                      : null,
                ),
                const SizedBox(height: 32),

                // Action Buttons
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsValue.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  onPressed: controller.saveLeave,
                  child: Text(
                    controller.editingLeaveId.isNotEmpty
                        ? 'Update Leave Request'
                        : 'Submit Leave Request',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Get.back(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Styles.txtBlackColorW70016.copyWith(
            color: ColorsValue.primaryDark,
          ),
        ),
        const SizedBox(height: 4),
        Container(height: 2, width: 40, color: ColorsValue.primary),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController fieldController,
    required String label,
    required IconData icon,
    bool readOnly = false,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction action = TextInputAction.next,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: fieldController,
      readOnly: readOnly,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: action,
      maxLines: maxLines,
      style: Styles.txtBlackColorW60014,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Styles.txtGreyColorW40014,
        floatingLabelStyle: const TextStyle(color: ColorsValue.primary),
        prefixIcon: Icon(icon, color: ColorsValue.primary, size: 20),
        filled: readOnly,
        fillColor: readOnly ? Colors.grey.shade100 : null,
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
          borderSide: BorderSide(
            color: readOnly ? Colors.grey.shade300 : ColorsValue.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
