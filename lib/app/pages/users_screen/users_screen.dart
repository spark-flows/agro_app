import 'package:agro_app/app/theme/theme.dart';
import 'package:agro_app/app/utils/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'users_controller.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        Get.find<UsersController>().fetchUsers(isRefresh: false);
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
    return GetBuilder<UsersController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.bgMain,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black87),
            title: Text('Users Management', style: Styles.txtBlackColorW70020),
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
                    hintText: 'Search users...',
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

                /// Users List
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
                                Icons.group_off_outlined,
                                size: 64,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No users found',
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
                                  onTap: () async {
                                    await controller.setupEdit(user);
                                    if (context.mounted) {
                                      _showAddDialog(context, controller);
                                    }
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
                                        Icons.person_outline,
                                        color: ColorsValue.primary,
                                      ),
                                    ),
                                    title: Text(
                                      user.name ?? 'No Name',
                                      style: Styles.txtBlackColorW60014,
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(
                                          user.email ?? '-',
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
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isActive
                                                ? Colors.green.withValues(
                                                    alpha: 0.1,
                                                  )
                                                : Colors.red.withValues(
                                                    alpha: 0.1,
                                                  ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
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
                                        const SizedBox(width: 4),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            Utility.showDeleteDialog(
                                              title: 'Delete User',
                                              message:
                                                  'Are you sure you want to delete ${user.name}?',
                                              onConfirm: () {
                                                controller.deleteUser(user.id);
                                              },
                                            );
                                          },
                                        ),
                                      ],
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
              _showAddDialog(context, controller);
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showAddDialog(BuildContext context, UsersController controller) {
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
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                const SizedBox(height: 24),
                Obx(
                  () => Text(
                    controller.editingUserId.value.isNotEmpty
                        ? 'Edit User'
                        : 'Add New User',
                    style: Styles.txtBlackColorW70020,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                _buildField(
                  controller: controller.nameCtrl,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  action: TextInputAction.next,
                  validator: (v) => v!.isEmpty ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
                Obx(
                  () => _buildField(
                    controller: controller.passwordCtrl,
                    label: controller.editingUserId.value.isNotEmpty
                        ? 'Password (leave blank to keep)'
                        : 'Password',
                    icon: Icons.lock_outline,
                    obscureText: controller.isPasswordHidden.value,
                    action: TextInputAction.done,
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
                          v!.isEmpty) {
                        return 'Please enter a password';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: controller.addressCtrl,
                  label: 'Address',
                  icon: Icons.home_outlined,
                  action: TextInputAction.next,
                  // validator: (v) =>
                  //     v!.isEmpty ? 'Please enter an address' : null,
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: controller.salaryCtrl,
                  label: 'Salary',
                  icon: Icons.currency_rupee,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  action: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: controller.allowanceCtrl,
                  label: 'Allowance',
                  icon: Icons.money_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  action: TextInputAction.done,
                ),
                const SizedBox(height: 16),
                _buildBranchMultiSelect(context, controller),
                const SizedBox(height: 16),
                Obx(
                  () => SwitchListTile(
                    title: const Text('Live Tracking'),
                    secondary: const Icon(Icons.location_on_outlined, color: ColorsValue.primary),
                    value: controller.liveTracking.value,
                    activeColor: ColorsValue.primary,
                    onChanged: (bool val) {
                      controller.liveTracking.value = val;
                    },
                  ),
                ),
                _buildMapColorPicker(context, controller),
                const SizedBox(height: 8),
                Obx(
                  () => SwitchListTile(
                    title: const Text('Odometer'),
                    secondary: const Icon(Icons.speed_outlined, color: ColorsValue.primary),
                    value: controller.odometer.value,
                    activeColor: ColorsValue.primary,
                    onChanged: (bool val) {
                      controller.odometer.value = val;
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // DropdownButtonFormField<String>(
                //   autovalidateMode: AutovalidateMode.onUserInteraction,
                //   value: controller.selectedRoleId,
                //   decoration: InputDecoration(
                //     labelText: 'Role',
                //     labelStyle: Styles.txtGreyColorW40014,
                //     floatingLabelStyle: const TextStyle(
                //       color: ColorsValue.primary,
                //     ),
                //     border: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(12),
                //       borderSide: BorderSide(color: Colors.grey.shade300),
                //     ),
                //     enabledBorder: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(12),
                //       borderSide: BorderSide(color: Colors.grey.shade300),
                //     ),
                //     focusedBorder: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(12),
                //       borderSide: const BorderSide(
                //         color: ColorsValue.primary,
                //         width: 1.5,
                //       ),
                //     ),
                //     prefixIcon: Icon(
                //       Icons.admin_panel_settings_outlined,
                //       color: ColorsValue.primary.withValues(alpha: 0.8),
                //     ),
                //   ),
                //   items: controller.roles.map((role) {
                //     return DropdownMenuItem(
                //       value: role.id,
                //       child: Text(role.rolename),
                //     );
                //   }).toList(),
                //   onChanged: (val) {
                //     controller.selectedRoleId = val;
                //   },
                //   validator: (v) => v == null ? 'Please select a role' : null,
                // ),
                // const SizedBox(height: 24),
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
                    'Save User',
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

  Widget _buildBranchMultiSelect(
      BuildContext context, UsersController controller) {
    return Obx(() {
      final selectedIds = controller.selectedPermissionBranchIds;
      final selectedNames = controller.branches
          .where((b) => b.id != null && selectedIds.contains(b.id))
          .map((b) => b.name ?? '')
          .where((name) => name.isNotEmpty)
          .toList();

      String displayText;
      if (selectedIds.isEmpty) {
        displayText = 'Select Permission Branches';
      } else if (selectedNames.isNotEmpty) {
        displayText = selectedNames.join(', ');
      } else {
        displayText = '${selectedIds.length} branches selected';
      }

      return InkWell(
        onTap: () {
          _showBranchSelectionDialog(context, controller);
        },
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Permission Branches',
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
              Icons.store_outlined,
              color: ColorsValue.primary.withValues(alpha: 0.8),
            ),
            suffixIcon: const Icon(
              Icons.arrow_drop_down,
              color: Colors.grey,
            ),
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

  void _showBranchSelectionDialog(
      BuildContext context, UsersController controller) {
    if (controller.branches.isEmpty && !controller.isBranchesLoading) {
      controller.fetchBranches();
    }

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
                      'Select Permission Branches',
                      style: Styles.txtBlackColorW70020.copyWith(fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Obx(() {
                    final validBranches = controller.branches;
                    final allSelected = validBranches.isNotEmpty &&
                        validBranches.every((b) =>
                            b.id != null &&
                            controller.selectedPermissionBranchIds
                                .contains(b.id));
                    return TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        if (allSelected) {
                          controller.selectedPermissionBranchIds.clear();
                        } else {
                          controller.selectedPermissionBranchIds.assignAll(
                            validBranches
                                .map((b) => b.id)
                                .whereType<String>()
                                .toList(),
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
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Expanded(
                child: GetBuilder<UsersController>(
                  builder: (ctrl) {
                    if (ctrl.isBranchesLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: ColorsValue.primary,
                        ),
                      );
                    }
                    if (ctrl.branches.isEmpty) {
                      return const Center(
                        child: Text('No branches available'),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: ctrl.branches.length,
                      itemBuilder: (context, index) {
                        final branch = ctrl.branches[index];
                        final branchId = branch.id ?? '';
                        return Obx(() {
                          final isSelected = ctrl.selectedPermissionBranchIds
                              .contains(branchId);
                          return CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: isSelected,
                            activeColor: ColorsValue.primary,
                            title: Text(
                              branch.name ?? 'Unnamed Branch',
                              style: Styles.txtBlackColorW50014,
                            ),
                            onChanged: (bool? checked) {
                              if (checked == true) {
                                if (!ctrl.selectedPermissionBranchIds
                                    .contains(branchId)) {
                                  ctrl.selectedPermissionBranchIds.add(branchId);
                                }
                              } else {
                                ctrl.selectedPermissionBranchIds
                                    .remove(branchId);
                              }
                            },
                          );
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsValue.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildMapColorPicker(
      BuildContext context, UsersController controller) {
    final List<Map<String, dynamic>> presetColors = [
      {'hex': '#4CAF50', 'color': const Color(0xFF4CAF50)},
      {'hex': '#2196F3', 'color': const Color(0xFF2196F3)},
      {'hex': '#E91E63', 'color': const Color(0xFFE91E63)},
      {'hex': '#9C27B0', 'color': const Color(0xFF9C27B0)},
      {'hex': '#F44336', 'color': const Color(0xFFF44336)},
      {'hex': '#FF9800', 'color': const Color(0xFFFF9800)},
      {'hex': '#00BCD4', 'color': const Color(0xFF00BCD4)},
      {'hex': '#009688', 'color': const Color(0xFF009688)},
      {'hex': '#3F51B5', 'color': const Color(0xFF3F51B5)},
      {'hex': '#607D8B', 'color': const Color(0xFF607D8B)},
    ];

    return Obx(() {
      if (!controller.liveTracking.value) return const SizedBox.shrink();

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(top: 8, bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.palette_outlined,
                  size: 20,
                  color: ColorsValue.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Map Marker Color',
                  style: Styles.txtBlackColorW60014,
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    controller.mapColor.value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: presetColors.map((c) {
                final String hex = c['hex'];
                final Color color = c['color'];
                final bool isSelected =
                    controller.mapColor.value.toUpperCase() == hex.toUpperCase();

                return GestureDetector(
                  onTap: () {
                    controller.mapColor.value = hex;
                  },
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 6,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                      border: Border.all(
                        color: isSelected ? Colors.black87 : Colors.transparent,
                        width: isSelected ? 2.5 : 0,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 18,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    });
  }
}
