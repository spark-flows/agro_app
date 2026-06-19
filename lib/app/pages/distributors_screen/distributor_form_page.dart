import 'package:agro_app/app/pages/distributors_screen/distributors_controller.dart';
import 'package:agro_app/app/theme/theme.dart';
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
                      v!.trim().isEmpty ? 'Please enter a name' : null,
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
                  validator: (v) =>
                      v!.trim().isEmpty ? 'Please enter an email' : null,
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
                  validator: (v) =>
                      v!.trim().isEmpty ? 'Please enter a phone number' : null,
                ),
                const SizedBox(height: 12),
                Obx(
                  () => _buildField(
                    controller: controller.passwordCtrl,
                    label: controller.editingUserId.value.isNotEmpty
                        ? 'Password (leave blank to keep)'
                        : 'Password *',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    action: TextInputAction.next,
                    validator: (v) {
                      if (controller.editingUserId.value.isEmpty &&
                          v!.trim().isEmpty) {
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
                ),
                const SizedBox(height: 12),
                _buildField(
                  controller: controller.bankifscodeCtrl,
                  label: 'IFSC Code',
                  icon: Icons.code_outlined,
                  action: TextInputAction.next,
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: action,
      obscureText: obscureText,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        counterText: maxLength != null ? '' : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }
}
