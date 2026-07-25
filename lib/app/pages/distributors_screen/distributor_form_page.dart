import 'package:agro_app/app/pages/distributors_screen/distributors_controller.dart';
import 'package:agro_app/app/theme/theme.dart';
import 'package:agro_app/app/utils/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Standalone Add/Edit page for a Distributor (opened as a full route).
class DistributorFormPage extends StatelessWidget {
  const DistributorFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DistributorsController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.bgMain,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black87),
            title: Obx(
              () => Text(
                controller.editingUserId.value.isNotEmpty
                    ? 'Edit Distributor'
                    : 'Add Distributor',
                style: Styles.txtBlackColorW70020,
              ),
            ),
          ),
          body: Form(
            key: controller.addFormKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // ── Personal Information ───────────────────────────────────
                _sectionHeader('Personal Information'),
                const SizedBox(height: 12),
                _buildField(
                  controller: controller.nameCtrl,
                  label: 'First Name *',
                  icon: Icons.person_outline,
                  action: TextInputAction.next,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 12),
                _buildField(
                  controller: controller.surnameCtrl,
                  label: 'Surname',
                  icon: Icons.person_outline,
                  action: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                _buildField(
                  controller: controller.fathernameCtrl,
                  label: 'Father Name',
                  icon: Icons.family_restroom_outlined,
                  action: TextInputAction.next,
                ),
                const SizedBox(height: 24),

                // ── Contact Information ────────────────────────────────────
                _sectionHeader('Contact Information'),
                const SizedBox(height: 12),
                _buildField(
                  controller: controller.emailCtrl,
                  label: 'Email Address *',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  action: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter an email';
                    } else if (!Utility.emailValidation(v.trim())) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildField(
                  controller: controller.phoneCtrl,
                  label: 'Phone Number *',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  action: TextInputAction.next,
                  maxLength: 10,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter a phone number';
                    }
                    if (v.trim().length != 10) {
                      return 'Phone number must be exactly 10 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Obx(
                  () => _buildField(
                    controller: controller.passwordCtrl,
                    label: controller.editingUserId.value.isNotEmpty
                        ? 'Password (leave blank to keep)'
                        : 'Password *',
                    icon: Icons.lock_outline,
                    obscureText: controller.isPasswordHidden.value,
                    action: TextInputAction.next,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordHidden.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        controller.isPasswordHidden.value =
                            !controller.isPasswordHidden.value;
                      },
                    ),
                    validator: (v) {
                      if (controller.editingUserId.value.isEmpty &&
                          (v == null || v.trim().isEmpty)) {
                        return 'Please enter a password';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 12),
                // _buildField(
                //   controller: controller.addressCtrl,
                //   label: 'Address *',
                //   icon: Icons.home_outlined,
                //   action: TextInputAction.next,
                //   // validator: (v) =>
                //   //     v!.trim().isEmpty ? 'Please enter an address' : null,
                // ),
                // const SizedBox(height: 24),

                // ── Business Information ───────────────────────────────────
                _sectionHeader('Business Information'),
                const SizedBox(height: 12),
                _buildField(
                  controller: controller.gstnumberCtrl,
                  label: 'GST Number',
                  icon: Icons.receipt_long_outlined,
                  action: TextInputAction.next,
                  maxLength: 15,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(15),
                    TextInputFormatter.withFunction(
                      (oldValue, newValue) =>
                          newValue.copyWith(text: newValue.text.toUpperCase()),
                    ),
                  ],
                  validator: (v) {
                    if (v != null && v.trim().isNotEmpty) {
                      final regExp = RegExp(
                        r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[0-9A-Z]{1}Z[0-9A-Z]{1}$',
                      );
                      if (!regExp.hasMatch(v.trim())) {
                        return 'Enter a valid 15-digit GSTIN (e.g. 24ABCDE1234F1Z5)';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildField(
                  controller: controller.locationCtrl,
                  label: 'Location',
                  icon: Icons.location_on_outlined,
                  action: TextInputAction.next,
                ),
                const SizedBox(height: 24),

                // ── Bank Information ───────────────────────────────────────
                _sectionHeader('Bank Information'),
                const SizedBox(height: 12),
                _buildField(
                  controller: controller.banknameCtrl,
                  label: 'Bank Name',
                  icon: Icons.account_balance_outlined,
                  action: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                _buildField(
                  controller: controller.bankaccountnumberCtrl,
                  label: 'Bank Account Number',
                  icon: Icons.credit_card_outlined,
                  keyboardType: TextInputType.number,
                  action: TextInputAction.next,
                  maxLength: 18,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(18),
                  ],
                  validator: (v) {
                    if (v != null && v.trim().isNotEmpty) {
                      final regExp = RegExp(r'^[0-9]{9,18}$');
                      if (!regExp.hasMatch(v.trim())) {
                        return 'Enter a valid bank account number (9 to 18 digits)';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildField(
                  controller: controller.bankifscodeCtrl,
                  label: 'IFSC Code',
                  icon: Icons.code_outlined,
                  action: TextInputAction.next,
                  maxLength: 11,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(11),
                    TextInputFormatter.withFunction(
                      (oldValue, newValue) =>
                          newValue.copyWith(text: newValue.text.toUpperCase()),
                    ),
                  ],
                  validator: (v) {
                    if (v != null && v.trim().isNotEmpty) {
                      final regExp = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
                      if (!regExp.hasMatch(v.trim())) {
                        return 'Enter a valid 11-character IFSC (e.g. SBIN0001234)';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // ── Role ──────────────────────────────────────────────────
                // _sectionHeader('Role'),
                // const SizedBox(height: 12),
                // DropdownButtonFormField<String>(
                //   value: controller.roles.any(
                //     (r) => r.id == controller.selectedRoleId,
                //   )
                //       ? controller.selectedRoleId
                //       : null,
                //   decoration: InputDecoration(
                //     labelText: 'Role *',
                //     border: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //     prefixIcon: const Icon(Icons.admin_panel_settings_outlined),
                //   ),
                //   items: controller.roles.map((role) {
                //     return DropdownMenuItem(
                //       value: role.id,
                //       child: Text(role.rolename),
                //     );
                //   }).toList(),
                //   onChanged: (val) => controller.selectedRoleId = val,
                //   validator: (v) => v == null ? 'Please select a role' : null,
                // ),
                // const SizedBox(height: 32),

                // ── Attendance Settings (User role only) ──────────────────
                Obx(() {
                  final selectedRole = controller.roles.firstWhereOrNull(
                    (r) => r.id == controller.selectedRoleId.value,
                  );
                  final isUserRole =
                      selectedRole?.rolename.toLowerCase() == 'user';
                  if (!isUserRole) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader('Attendance Settings'),
                      const SizedBox(height: 4),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Obx(
                              () => SwitchListTile(
                                secondary: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: ColorsValue.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.punch_clock_outlined,
                                    color: ColorsValue.primary,
                                    size: 20,
                                  ),
                                ),
                                title: const Text(
                                  'Clock In / Clock Out',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: const Text(
                                  'Enable live location tracking during shifts',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                                value: controller.liveTracking.value,
                                activeColor: ColorsValue.primary,
                                onChanged: (val) {
                                  controller.liveTracking.value = val;
                                },
                              ),
                            ),
                            Divider(height: 1, color: Colors.grey.shade100),
                            Obx(
                              () => SwitchListTile(
                                secondary: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: ColorsValue.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.speed_outlined,
                                    color: ColorsValue.primary,
                                    size: 20,
                                  ),
                                ),
                                title: const Text(
                                  'Odometer',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: const Text(
                                  'Require selfie & odometer reading on punch',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                                value: controller.odometer.value,
                                activeColor: ColorsValue.primary,
                                onChanged: (val) {
                                  controller.odometer.value = val;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                }),

                // ── Assigned Users (Admin Only) ───────────────────────────
                _buildUserMultiSelect(context, controller),
                const SizedBox(height: 24),

                // ── Save Button ────────────────────────────────────────────
                ElevatedButton(
                  onPressed: () {
                    if (controller.addFormKey.currentState!.validate()) {
                      controller.saveUser();
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
                    'Save Distributor',
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

  Widget _buildUserMultiSelect(
    BuildContext context,
    DistributorsController controller,
  ) {
    return Obx(() {
      if (!controller.isAdminView.value) return const SizedBox.shrink();

      final selectedIds = controller.selectedPermissionUserIds;
      final selectedNames = controller.selectableUsers
          .where((u) => u.id.isNotEmpty && selectedIds.contains(u.id))
          .map((u) => u.name)
          .where((name) => name.isNotEmpty)
          .toList();

      String displayText;
      if (selectedIds.isEmpty) {
        displayText = 'Select Assigned Users';
      } else if (selectedNames.isNotEmpty) {
        displayText = selectedNames.join(', ');
      } else {
        displayText = '${selectedIds.length} users selected';
      }

      return InkWell(
        onTap: () {
          _showUserSelectionDialog(context, controller);
        },
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Assigned Users',
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
              borderSide: const BorderSide(
                color: ColorsValue.primary,
                width: 1.5,
              ),
            ),
            prefixIcon: Icon(
              Icons.people_outline,
              color: ColorsValue.primary.withValues(alpha: 0.8),
            ),
            suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ),
          child: Text(
            displayText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: selectedIds.isEmpty
                ? Styles.txtGreyColorW40014
                : Styles.txtBlackColorW50014,
          ),
        ),
      );
    });
  }

  void _showUserSelectionDialog(
    BuildContext context,
    DistributorsController controller,
  ) {
    if (controller.selectableUsers.isEmpty && !controller.isUsersLoading.value) {
      controller.fetchSelectableUsers();
    }

    final searchCtrl = TextEditingController();
    final RxString searchRx = ''.obs;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Select Assigned Users',
                      style: Styles.txtBlackColorW70020.copyWith(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Obx(() {
                    final validUsers = controller.selectableUsers;
                    final selectedIds = controller.selectedPermissionUserIds;
                    final allSelected =
                        validUsers.isNotEmpty &&
                        validUsers.every(
                          (u) => u.id.isNotEmpty && selectedIds.contains(u.id),
                        );
                    return TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        if (allSelected) {
                          controller.selectedPermissionUserIds.clear();
                        } else {
                          controller.selectedPermissionUserIds.assignAll(
                            validUsers.map((u) => u.id).toList(),
                          );
                        }
                      },
                      child: Text(
                        allSelected ? 'Deselect All' : 'Select All',
                        style: const TextStyle(
                          color: ColorsValue.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: searchCtrl,
                onChanged: (val) => searchRx.value = val,
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Expanded(
                child: Obx(() {
                  if (controller.isUsersLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: ColorsValue.primary,
                      ),
                    );
                  }
                  if (controller.selectableUsers.isEmpty) {
                    return const Center(child: Text('No users available'));
                  }

                  final query = searchRx.value.toLowerCase().trim();
                  final filteredUsers = controller.selectableUsers.where((u) {
                    if (query.isEmpty) return true;
                    return u.name.toLowerCase().contains(query) ||
                        u.mobile.toLowerCase().contains(query);
                  }).toList();

                  if (filteredUsers.isEmpty) {
                    return const Center(
                      child: Text('No matching users found'),
                    );
                  }

                  final selectedIds = controller.selectedPermissionUserIds;

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      final userId = user.id;
                      final isSelected = selectedIds.contains(userId);
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: isSelected,
                        activeColor: ColorsValue.primary,
                        title: Text(
                          user.name,
                          style: Styles.txtBlackColorW50014,
                        ),
                        subtitle: user.mobile.isNotEmpty
                            ? Text(
                                user.mobile,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              )
                            : null,
                        onChanged: (bool? checked) {
                          if (checked == true) {
                            if (!controller.selectedPermissionUserIds.contains(userId)) {
                              controller.selectedPermissionUserIds.add(userId);
                            }
                          } else {
                            controller.selectedPermissionUserIds.remove(userId);
                          }
                        },
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsValue.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction action = TextInputAction.done,
    bool obscureText = false,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: action,
      obscureText: obscureText,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      cursorColor: ColorsValue.primary,
      style: Styles.txtBlackColorW50014,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Styles.txtGreyColorW40014,
        floatingLabelStyle: const TextStyle(color: ColorsValue.primary),
        counterText: maxLength != null ? '' : null,
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
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }
}
