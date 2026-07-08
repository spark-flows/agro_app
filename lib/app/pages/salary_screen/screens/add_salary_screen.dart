import 'package:agro_app/app/app.dart';
import 'package:agro_app/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddSalaryScreen extends StatefulWidget {
  const AddSalaryScreen({super.key});

  @override
  State<AddSalaryScreen> createState() => _AddSalaryScreenState();
}

class _AddSalaryScreenState extends State<AddSalaryScreen> {
  Future<void> _selectDate(
    BuildContext context,
    SalaryController controller,
  ) async {
    DateTime initialDate;
    try {
      initialDate = DateFormat(
        'dd/MM/yyyy',
      ).parse(controller.dateController.text);
    } catch (_) {
      initialDate = DateTime.now();
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
        controller.dateController.text = DateFormat(
          'dd/MM/yyyy',
        ).format(picked);
      });
      controller.update();
    }
  }

  Future<void> _selectMonthYear(
    BuildContext context,
    SalaryController controller,
  ) async {
    DateTime initialDate;
    try {
      initialDate = DateFormat(
        'MMMM, yyyy',
      ).parse(controller.salaryMonthController.text);
    } catch (_) {
      initialDate = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
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
        controller.salaryMonthController.text = DateFormat(
          'MMMM, yyyy',
        ).format(picked);
      });
      controller.update();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SalaryController>(
      initState: (_) {
        final controller = Get.find<SalaryController>();
        controller.getUserList();
        // Set default date
        if (controller.dateController.text.isEmpty) {
          controller.dateController.text = DateFormat(
            'dd/MM/yyyy',
          ).format(DateTime.now());
        }
        if (controller.salaryMonthController.text.isEmpty) {
          controller.salaryMonthController.text = DateFormat(
            'MMMM, yyyy',
          ).format(DateTime.now());
        }
      },
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.bgMain,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black87),
            title: Text(
              controller.editingSalaryId.isNotEmpty
                  ? 'Edit Salary'
                  : 'Add Salary',
              style: Styles.txtBlackColorW70020,
            ),
          ),
          body: Form(
            key: controller.salaryKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // ── Date ────────────────────────────────────────────
                InkWell(
                  onTap: () => _selectDate(context, controller),
                  child: IgnorePointer(
                    child: _buildField(
                      fieldController: controller.dateController,
                      label: 'Date',
                      icon: Icons.calendar_today_outlined,
                      validator: (v) =>
                          v!.trim().isEmpty ? 'Please select a date' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Salary Month & Year ────────────────────────────────
                InkWell(
                  onTap: () => _selectMonthYear(context, controller),
                  child: IgnorePointer(
                    child: _buildField(
                      fieldController: controller.salaryMonthController,
                      label: 'Salary Month & Year',
                      icon: Icons.date_range_outlined,
                      validator: (v) =>
                          v!.trim().isEmpty ? 'Please select month' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── User ───────────────────────────────────────────────
                _buildDropdownField<UserData>(
                  label: 'User',
                  icon: Icons.person_outline,
                  value:
                      controller.userDataList.any(
                        (u) => u.id == controller.selectUser,
                      )
                      ? controller.userDataList.firstWhere(
                          (u) => u.id == controller.selectUser,
                        )
                      : null,
                  items: controller.userDataList
                      .map(
                        (user) => DropdownMenuItem<UserData>(
                          value: user,
                          child: Text(
                            user.name ?? '',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  hint: 'Select User',
                  onChanged: (user) {
                    controller.selectUser = user?.id;
                    if (user?.id != null) {
                      controller.getSalaryApi(0);
                    }
                    controller.update();
                  },
                ),
                const SizedBox(height: 20),

                // ── Work Days ──────────────────────────────────────────
                _buildField(
                  fieldController: controller.workDayController,
                  label: 'Work Days',
                  icon: Icons.work_outline,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) =>
                      v!.trim().isEmpty ? 'Enter work days' : null,
                  onChanged: (_) => controller.calculateNetSalary(),
                ),
                const SizedBox(height: 20),

                // ── Basic Salary ───────────────────────────────────────
                _buildField(
                  fieldController: controller.basicSalaryController,
                  label: 'Basic Salary',
                  icon: Icons.currency_rupee,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) =>
                      v!.trim().isEmpty ? 'Enter basic salary' : null,
                  readOnly: true,
                  onChanged: (_) => controller.calculateNetSalary(),
                ),
                const SizedBox(height: 20),

                // ── Bonus ──────────────────────────────────────────────
                _buildField(
                  fieldController: controller.bounsController,
                  label: 'Bonus',
                  icon: Icons.card_giftcard_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => controller.calculateNetSalary(),
                ),
                const SizedBox(height: 20),

                // ── Deduction ──────────────────────────────────────────
                _buildField(
                  fieldController: controller.deductionController,
                  label: 'Deduction',
                  icon: Icons.remove_circle_outline,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => controller.calculateNetSalary(),
                ),
                const SizedBox(height: 20),

                // ── Net Salary ─────────────────────────────────────────
                _buildField(
                  fieldController: controller.netSalaryController,
                  label: 'Net Salary',
                  icon: Icons.account_balance_wallet_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  readOnly: true,
                ),
                const SizedBox(height: 20),

                // ── Payment Mode ───────────────────────────────────────
                _buildDropdownField<String>(
                  label: 'Payment Mode',
                  icon: Icons.payment_outlined,
                  value: controller.selectPaymentMode,
                  items: controller.paymentMode
                      .map(
                        (mode) => DropdownMenuItem<String>(
                          value: mode,
                          child: Text(mode),
                        ),
                      )
                      .toList(),
                  hint: 'Select Mode',
                  onChanged: (mode) {
                    controller.selectPaymentMode = mode;
                    controller.update();
                  },
                ),
                const SizedBox(height: 20),

                // ── Payment Status ─────────────────────────────────────
                _buildDropdownField<String>(
                  label: 'Payment Status',
                  icon: Icons.check_circle_outline,
                  value: controller.selectPaymentStatus,
                  items: controller.paymentStatus
                      .map(
                        (status) => DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
                        ),
                      )
                      .toList(),
                  hint: 'Select Status',
                  onChanged: (status) {
                    controller.selectPaymentStatus = status;
                    controller.update();
                  },
                ),
                const SizedBox(height: 20),

                // ── Remark ─────────────────────────────────────────────
                _buildField(
                  fieldController: controller.remarkController,
                  label: 'Remark',
                  icon: Icons.notes_outlined,
                  maxLines: 3,
                  hintText: 'Enter remark here...',
                ),
                const SizedBox(height: 32),

                // ── Divider ────────────────────────────────────────────
                const Divider(),
                const SizedBox(height: 16),

                // ── Action Buttons: Cancel | Create ────────────────────
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (controller.salaryKey.currentState?.validate() ??
                              false) {
                            controller.postCreateSalaryApi();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsValue.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        icon: const Icon(
                          Icons.save_outlined,
                          color: Colors.white,
                        ),
                        label: Text(
                          controller.editingSalaryId.isNotEmpty
                              ? 'Save'
                              : 'Create',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Text Field Builder ──────────────────────────────────────────────────
  Widget _buildField({
    required TextEditingController fieldController,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction action = TextInputAction.done,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool readOnly = false,
    String? hintText,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: fieldController,
      keyboardType: keyboardType,
      textInputAction: action,
      validator: validator,
      maxLines: maxLines,
      readOnly: readOnly,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: Styles.txtGreyColorW40014,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
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

  // ── Dropdown Field Builder ──────────────────────────────────────────────
  Widget _buildDropdownField<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required String hint,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      isExpanded: true,
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
      hint: Text(
        hint,
        style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
      ),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
    );
  }
}
