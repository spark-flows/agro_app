import 'package:agro_app/app/pages/attendance_screen/attendance_controller.dart';
import 'package:agro_app/app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AttendanceFormPage extends StatefulWidget {
  const AttendanceFormPage({super.key});

  @override
  State<AttendanceFormPage> createState() => _AttendanceFormPageState();
}

class _AttendanceFormPageState extends State<AttendanceFormPage> {
  Future<void> _selectDate(
    BuildContext context,
    AttendanceController controller,
  ) async {
    DateTime initialDate;
    try {
      initialDate = DateFormat('dd-MM-yyyy').parse(controller.dateCtrl.text);
    } catch (_) {
      try {
        initialDate = DateTime.parse(controller.dateCtrl.text);
      } catch (_) {
        initialDate = DateTime.now();
      }
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

  Future<void> _selectTime(
    BuildContext context,
    TextEditingController ctrl,
  ) async {
    TimeOfDay initialTime = TimeOfDay.now();
    if (ctrl.text.isNotEmpty) {
      try {
        final parsedDate = DateFormat('hh:mm a').parse(ctrl.text);
        initialTime = TimeOfDay(
          hour: parsedDate.hour,
          minute: parsedDate.minute,
        );
      } catch (_) {
        try {
          final parsedDate = DateFormat('HH:mm').parse(ctrl.text);
          initialTime = TimeOfDay(
            hour: parsedDate.hour,
            minute: parsedDate.minute,
          );
        } catch (_) {
          try {
            final parts = ctrl.text.trim().split(':');
            if (parts.length >= 2) {
              int hour = int.parse(parts[0]);
              int minute = int.parse(parts[1].split(' ')[0]);
              if (ctrl.text.toLowerCase().contains('pm') && hour < 12)
                hour += 12;
              if (ctrl.text.toLowerCase().contains('am') && hour == 12)
                hour = 0;
              initialTime = TimeOfDay(hour: hour, minute: minute);
            }
          } catch (_) {}
        }
      }
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
      final now = DateTime.now();
      final dt = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );
      final formattedTime = DateFormat('hh:mm a').format(dt);
      setState(() {
        ctrl.text = formattedTime;
      });
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
              controller.roleName == "User"
                  ? 'Attendance Details'
                  : (controller.editingAttendanceId.isNotEmpty
                      ? 'Edit Attendance'
                      : 'Add Attendance'),
              style: Styles.txtBlackColorW70020,
            ),
          ),
          body: Form(
            key: controller.formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                AbsorbPointer(
                  absorbing: controller.roleName == "User",
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader('Time Logs'),
                      const SizedBox(height: 16),

                if (controller.isAdmin) ...[
                  Text('Select User', style: Styles.txtBlackColorW60014),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: controller.selectedUserId,
                        hint: Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: Text(
                            'Select User',
                            style: Styles.txtGreyColorW40014,
                          ),
                        ),
                        icon: const Padding(
                          padding: EdgeInsets.only(right: 12.0),
                          child: Icon(Icons.arrow_drop_down),
                        ),
                        items: controller.userList.map((user) {
                          return DropdownMenuItem<String>(
                            value: user.id,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: Text(
                                '${user.name} (${user.roleid.rolename})',
                                style: Styles.txtBlackColorW60014,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            controller.selectedUserId = val;
                            controller.update();
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

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
                const SizedBox(height: 20),

                // ── Time In & Time Out Row ────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () =>
                            _selectTime(context, controller.timeInCtrl),
                        child: IgnorePointer(
                          child: _buildField(
                            fieldController: controller.timeInCtrl,
                            label: 'Time In *',
                            icon: Icons.login,
                            validator: (v) => v!.trim().isEmpty
                                ? 'Time In is required'
                                : null,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () =>
                            _selectTime(context, controller.timeOutCtrl),
                        child: IgnorePointer(
                          child: _buildField(
                            fieldController: controller.timeOutCtrl,
                            label: 'Time Out *',
                            icon: Icons.logout,
                            validator: (v) => v!.trim().isEmpty
                                ? 'Time Out is required'
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Pause & Resume Time Row ───────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () =>
                            _selectTime(context, controller.breakStartCtrl),
                        child: IgnorePointer(
                          child: _buildField(
                            fieldController: controller.breakStartCtrl,
                            label: 'Pause Time *',
                            icon: Icons.pause_circle_outline,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () =>
                            _selectTime(context, controller.breakEndCtrl),
                        child: IgnorePointer(
                          child: _buildField(
                            fieldController: controller.breakEndCtrl,
                            label: 'Resume Time *',
                            icon: Icons.play_circle_outline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _sectionHeader('Status & Feedback'),
                const SizedBox(height: 16),

                // ── Status Dropdown Form Field ───────────────────────────────
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
                      Icons.tag_faces_outlined,
                      color: ColorsValue.primary,
                    ),
                  ),
                  items: ['present', 'absent', 'holiday', 'halfday', 'leave']
                      .map(
                        (val) => DropdownMenuItem<String>(
                          value: val,
                          child: Text(val.toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      controller.selectedStatus = newValue;
                      controller.update();
                    }
                  },
                ),
                const SizedBox(height: 20),

                // ── Remark input field ───────────────────────────────────────
                _buildField(
                  fieldController: controller.remarkCtrl,
                  label: 'Remark',
                  icon: Icons.comment_outlined,
                  keyboardType: TextInputType.multiline,
                  action: TextInputAction.newline,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),

                if (controller.timeinPhoto.value.isNotEmpty) ...[
                  _sectionHeader('Time In Photo'),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: controller.timeinPhoto.value,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 200,
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: ColorsValue.primary,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 200,
                        color: Colors.grey.shade100,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                if (controller.timeinOdometerCtrl.text.isNotEmpty) ...[
                  _sectionHeader('Time In Odometer Details'),
                  const SizedBox(height: 12),
                  _buildField(
                    fieldController: controller.timeinOdometerCtrl,
                    label: 'Time In Odometer',
                    icon: Icons.speed_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                ],

                if (controller.timeoutPhoto.value.isNotEmpty) ...[
                  _sectionHeader('Time Out Photo'),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: controller.timeoutPhoto.value,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 200,
                        color: Colors.grey.shade100,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: ColorsValue.primary,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 200,
                        color: Colors.grey.shade100,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                if (controller.timeoutOdometerCtrl.text.isNotEmpty) ...[
                  _sectionHeader('Time Out Odometer Details'),
                  const SizedBox(height: 12),
                  _buildField(
                    fieldController: controller.timeoutOdometerCtrl,
                    label: 'Time Out Odometer',
                    icon: Icons.speed_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
              ],
            ],
          ),
        ),

                const SizedBox(height: 32),

                // ── Form Action Buttons ──────────────────────────────────────
                if (controller.roleName == "User") ...[
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsValue.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: controller.saveAttendance,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorsValue.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: ColorsValue.primary,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController fieldController,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction action = TextInputAction.done,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: fieldController,
      keyboardType: keyboardType,
      textInputAction: action,
      validator: validator,
      maxLines: maxLines,
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
        prefixIcon: Icon(icon, color: ColorsValue.primary),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
