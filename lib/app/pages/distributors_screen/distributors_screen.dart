import 'package:agro_app/app/pages/distributors_screen/distributors_controller.dart';
import 'package:agro_app/app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DistributorsScreen extends StatefulWidget {
  const DistributorsScreen({super.key});

  @override
  State<DistributorsScreen> createState() => _DistributorsScreenState();
}

class _DistributorsScreenState extends State<DistributorsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        Get.find<DistributorsController>().fetchUsers(isRefresh: false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

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
            title: Text(
              'Distributors Management',
              style: Styles.txtBlackColorW70020,
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                /// Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: controller.searchUsers,
                  decoration: InputDecoration(
                    hintText: 'Search distributors...',
                    hintStyle: Styles.txtGreyColorW40014,
                    prefixIcon: const Icon(
                      Icons.search,
                      color: ColorsValue.primary,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              controller.searchUsers('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                /// Distributor List
                Expanded(
                  child: controller.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : controller.users.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_shipping_outlined,
                                size: 64,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No distributors found',
                                style: Styles.txtGreyColorW40014,
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () =>
                              controller.fetchUsers(isRefresh: true),
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount:
                                controller.users.length +
                                (controller.isFetchingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == controller.users.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              final user = controller.users[index];
                              final isActive = !user.isDeleted;

                              return Card(
                                elevation: 1,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    controller.setupEdit(user);
                                    Get.toNamed<void>('/distributorForm');
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    leading: CircleAvatar(
                                      backgroundColor: ColorsValue.primary
                                          .withValues(alpha: 0.1),
                                      child: const Icon(
                                        Icons.local_shipping_outlined,
                                        color: ColorsValue.primary,
                                      ),
                                    ),
                                    title: Text(
                                      '${user.name}${user.surname != null && user.surname!.isNotEmpty ? " ${user.surname}" : ""}',
                                      style: Styles.txtBlackColorW60014,
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(
                                          user.email,
                                          style: Styles.txtGreyColorW40012,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Role: ${user.roleid.rolename ?? "N/A"}',
                                          style: Styles.txtGreyColorW40012
                                              .copyWith(
                                                color: ColorsValue.primary,
                                              ),
                                        ),
                                      ],
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? Colors.green.withValues(
                                                alpha: 0.1,
                                              )
                                            : Colors.red.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        isActive ? 'Active' : 'Inactive',
                                        style: TextStyle(
                                          color: isActive
                                              ? Colors.green
                                              : Colors.red,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: ColorsValue.primary,
            onPressed: () {
              controller.clearAddForm();
              Get.toNamed<void>('/distributorForm');
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  // ─── Add / Edit Bottom Sheet ───────────────────────────────────────────────

  void _showAddDialog(BuildContext context, DistributorsController controller) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: controller.addFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Drag handle
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
                const SizedBox(height: 24),

                // ── Title
                Obx(
                  () => Text(
                    controller.editingUserId.value.isNotEmpty
                        ? 'Edit Distributor'
                        : 'Add New Distributor',
                    style: Styles.txtBlackColorW70020,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Section: Personal Info
                _sectionHeader('Personal Information'),
                const SizedBox(height: 12),

                // First Name
                _buildField(
                  controller: controller.nameCtrl,
                  label: 'First Name',
                  icon: Icons.person_outline,
                  action: TextInputAction.next,
                  validator: (v) =>
                      v!.trim().isEmpty ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 12),

                // Surname
                _buildField(
                  controller: controller.surnameCtrl,
                  label: 'Surname',
                  icon: Icons.person_outline,
                  action: TextInputAction.next,
                ),
                const SizedBox(height: 12),

                // Father Name
                _buildField(
                  controller: controller.fathernameCtrl,
                  label: 'Father Name',
                  icon: Icons.family_restroom_outlined,
                  action: TextInputAction.next,
                ),
                const SizedBox(height: 24),

                // ── Section: Contact Info
                _sectionHeader('Contact Information'),
                const SizedBox(height: 12),

                // Email
                _buildField(
                  controller: controller.emailCtrl,
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  action: TextInputAction.next,
                  validator: (v) =>
                      v!.trim().isEmpty ? 'Please enter an email' : null,
                ),
                const SizedBox(height: 12),

                // Phone
                _buildField(
                  controller: controller.phoneCtrl,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  action: TextInputAction.next,
                  validator: (v) =>
                      v!.trim().isEmpty ? 'Please enter a phone number' : null,
                ),
                const SizedBox(height: 12),

                // Password
                _buildField(
                  controller: controller.passwordCtrl,
                  label: 'Password',
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
                const SizedBox(height: 12),

                // Address
                _buildField(
                  controller: controller.addressCtrl,
                  label: 'Address',
                  icon: Icons.home_outlined,
                  action: TextInputAction.next,
                  validator: (v) =>
                      v!.trim().isEmpty ? 'Please enter an address' : null,
                ),
                const SizedBox(height: 24),

                // ── Section: Business Info
                _sectionHeader('Business Information'),
                const SizedBox(height: 12),

                // GST Number
                _buildField(
                  controller: controller.gstnumberCtrl,
                  label: 'GST Number',
                  icon: Icons.receipt_long_outlined,
                  action: TextInputAction.next,
                ),
                const SizedBox(height: 12),

                // Location
                _buildField(
                  controller: controller.locationCtrl,
                  label: 'Location',
                  icon: Icons.location_on_outlined,
                  action: TextInputAction.next,
                ),
                const SizedBox(height: 24),

                // ── Section: Bank Info
                _sectionHeader('Bank Information'),
                const SizedBox(height: 12),

                // Bank Name
                _buildField(
                  controller: controller.banknameCtrl,
                  label: 'Bank Name',
                  icon: Icons.account_balance_outlined,
                  action: TextInputAction.next,
                ),
                const SizedBox(height: 12),

                // Bank Account Number
                _buildField(
                  controller: controller.bankaccountnumberCtrl,
                  label: 'Bank Account Number',
                  icon: Icons.credit_card_outlined,
                  keyboardType: TextInputType.number,
                  action: TextInputAction.next,
                ),
                const SizedBox(height: 12),

                // IFSC Code
                _buildField(
                  controller: controller.bankifscodeCtrl,
                  label: 'IFSC Code',
                  icon: Icons.code_outlined,
                  action: TextInputAction.next,
                ),
                const SizedBox(height: 24),

                // ── Role Dropdown
                DropdownButtonFormField<String>(
                  value: controller.selectedRoleId,
                  decoration: InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.admin_panel_settings_outlined),
                  ),
                  items: controller.roles.map((role) {
                    return DropdownMenuItem(
                      value: role.id,
                      child: Text(role.rolename),
                    );
                  }).toList(),
                  onChanged: (val) {
                    controller.selectedRoleId = val;
                  },
                  validator: (v) => v == null ? 'Please select a role' : null,
                ),
                const SizedBox(height: 24),

                // ── Save Button
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
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: action,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }
}
