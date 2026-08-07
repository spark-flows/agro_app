import 'package:agro_app/app/pages/distributors_screen/distributors_controller.dart';
import 'package:agro_app/app/theme/theme.dart';
import 'package:agro_app/app/utils/utility.dart';
import 'package:agro_app/domain/models/get_all_users_model.dart';
import 'package:agro_app/domain/repositories/repository.dart';
import 'package:agro_app/domain/repositories/local_storage_keys.dart';
import 'package:agro_app/domain/services/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: ColorsValue.primary,
                          ),
                        )
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
                                    child: CircularProgressIndicator(
                                      color: ColorsValue.primary,
                                    ),
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
                                    _showUserProfileSheet(
                                      context,
                                      user,
                                      controller,
                                    );
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
                                        // const SizedBox(height: 2),
                                        // Text(
                                        //   'Role: ${user.roleid.rolename ?? "N/A"}',
                                        //   style: Styles.txtGreyColorW40012
                                        //       .copyWith(
                                        //         color: ColorsValue.primary,
                                        //       ),
                                        // ),
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

  // ─── User Profile + Clock In/Out Bottom Sheet ──────────────────────────────

  void _showUserProfileSheet(
    BuildContext context,
    Doc user,
    DistributorsController controller,
  ) {
    final bool showAttendance =
        Get.find<Repository>().getStringValue(LocalKeys.roleHiveName) !=
        "Admin";

    Get.bottomSheet<void>(
      StatefulBuilder(
        builder: (ctx, setState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Drag handle
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 20),

                  // ── Avatar + Name
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: ColorsValue.primary.withValues(
                      alpha: 0.12,
                    ),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: ColorsValue.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 0,
                    ),
                    child: Text(
                      '${user.name}${user.surname != null && user.surname!.isNotEmpty ? " ${user.surname}" : ""}',
                      style: Styles.txtBlackColorW70020,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(user.email, style: Styles.txtGreyColorW40014),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ColorsValue.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      (user.roleid.rolename ?? '').isNotEmpty
                          ? user.roleid.rolename!
                          : 'Member',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: ColorsValue.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Attendance Actions Panel ─────────────────────────────
                  if (showAttendance)
                    GetBuilder<DistributorsController>(
                      builder: (distCtrl) {
                        if (!distCtrl.loggedUserLiveTracking) {
                          return const SizedBox.shrink();
                        }

                        final currentUser = distCtrl.users.firstWhere(
                          (u) => u.id == user.id,
                          orElse: () => user,
                        );
                        final isClockedIn = currentUser.isClockedIn;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Row 1: Clock In / Clock Out
                              Row(
                                children: [
                                  // Clock In button
                                  Expanded(
                                    child: Obx(
                                      () => _attendanceButton(
                                        label: 'Clock In',
                                        icon: Icons.login_rounded,
                                        color: Colors.green,
                                        enabled: !isClockedIn,
                                        isLoading:
                                            distCtrl.isClockInLoading.value,
                                        onTap: () {
                                          distCtrl.clockInDistributor(
                                            currentUser,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Clock Out button
                                  Expanded(
                                    child: Obx(
                                      () => _attendanceButton(
                                        label: 'Clock Out',
                                        icon: Icons.logout_rounded,
                                        color: Colors.red,
                                        enabled: isClockedIn,
                                        isLoading:
                                            distCtrl.isClockOutLoading.value,
                                        onTap: () {
                                          distCtrl.clockOutDistributor(
                                            currentUser,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Divider(color: Colors.grey.shade100),
                            ],
                          ),
                        );
                      },
                    ),

                  // ── Edit / View Button ───────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Get.back();
                        await Future<void>.delayed(const Duration(milliseconds: 350));
                        await controller.setupEdit(user);
                        Get.toNamed<void>('/distributorForm');
                      },
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsValue.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // ── Attendance action button helper ────────────────────────────────────────
  Widget _attendanceButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool enabled,
    bool isLoading = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: (enabled && !isLoading) ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: enabled ? color.withValues(alpha: 0.1) : Colors.grey.shade100,
          border: Border.all(
            color: enabled
                ? color.withValues(alpha: 0.4)
                : Colors.grey.shade200,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              SizedBox(
                height: 26,
                width: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: color,
                ),
              )
            else
              Icon(
                icon,
                color: enabled ? color : Colors.grey.shade400,
                size: 26,
              ),
            const SizedBox(height: 4),
            Text(
              isLoading ? 'Loading...' : label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: enabled ? color : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Add / Edit Bottom Sheet ───────────────────────────────────────────────

  void _showAddDialog(BuildContext context, DistributorsController controller) {
    Get.bottomSheet(
      Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: controller.addFormKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
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
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Please enter a name'
                        : null,
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

                  // Phone
                  _buildField(
                    controller: controller.phoneCtrl,
                    label: 'Phone Number',
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

                  // Password
                  Obx(
                    () => _buildField(
                      controller: controller.passwordCtrl,
                      label: 'Password',
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

                  // Address
                  _buildField(
                    controller: controller.addressCtrl,
                    label: 'Address',
                    icon: Icons.home_outlined,
                    action: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Please enter an address'
                        : null,
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
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    value: controller.selectedRoleId.value,
                    decoration: InputDecoration(
                      labelText: 'Role',
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
                        Icons.admin_panel_settings_outlined,
                        color: ColorsValue.primary.withValues(alpha: 0.8),
                      ),
                    ),
                    items: controller.roles.map((role) {
                      return DropdownMenuItem(
                        value: role.id,
                        child: Text(role.rolename),
                      );
                    }).toList(),
                    onChanged: (val) {
                      controller.selectedRoleId.value = val;
                    },
                    validator: (v) => v == null ? 'Please select a role' : null,
                  ),
                  const SizedBox(height: 24),

                  // ── Assigned Users (Admin Only) ───────────────────────────
                  if (RoleUtils.isAdmin('Admin')) ...[
                    _buildUserMultiSelect(context, controller),
                    const SizedBox(height: 24),
                  ],

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
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

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
    if (controller.selectableUsers.isEmpty &&
        !controller.isUsersLoading.value) {
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
                    return const Center(child: Text('No matching users found'));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      final userId = user.id;
                      return Obx(() {
                        final isSelected = controller.selectedPermissionUserIds
                            .contains(userId);
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
                              if (!controller.selectedPermissionUserIds
                                  .contains(userId)) {
                                controller.selectedPermissionUserIds.add(
                                  userId,
                                );
                              }
                            } else {
                              controller.selectedPermissionUserIds.remove(
                                userId,
                              );
                            }
                          },
                        );
                      });
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
