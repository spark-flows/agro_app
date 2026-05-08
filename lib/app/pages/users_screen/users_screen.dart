import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agro_app/app/theme/theme.dart';
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
                      ? const Center(child: CircularProgressIndicator())
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
                                    _showAddDialog(context, controller);
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
                                    trailing: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                TextFormField(
                  controller: controller.nameCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  validator: (v) => v!.isEmpty ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  validator: (v) => v!.isEmpty ? 'Please enter an email' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.phoneCtrl,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                  validator: (v) =>
                      v!.isEmpty ? 'Please enter a phone number' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.passwordCtrl,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                  validator: (v) {
                    if (controller.editingUserId.value.isEmpty && v!.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.addressCtrl,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                  validator: (v) =>
                      v!.isEmpty ? 'Please enter a address' : null,
                ),
                const SizedBox(height: 16),
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
}
