import 'package:agro_app/app/app.dart';
import 'package:agro_app/domain/services/enum.dart';
import 'package:agro_app/domain/models/get_all_branches_model.dart'
    as branch_model;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.bgMain,
          // appBar: AppBar(
          //   backgroundColor: Colors.white,
          //   elevation: 0,
          //   iconTheme: const IconThemeData(color: Colors.black87),
          //   title: Text(
          //     'Agro ERP Dashboard',
          //     style: Styles.txtBlackColorW70020,
          //   ),
          // ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${controller.roleName.isNotEmpty ? Utility.capitalizeFirst(controller.roleName) : ' - - '}',
                            style: Styles.txtBlackColorW70020,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'What would you like to manage today?',
                            style: Styles.txtGreyColorW40014,
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.perm_identity_sharp,
                          color: Colors.black87,
                        ),
                        onPressed: controller.goToProfile,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Branch dropdown selection (Admin only)
                  if (RoleUtils.isAdmin(controller.roleName)) ...[
                    if (controller.isBranchesLoading)
                      const Center(
                        child: CircularProgressIndicator(
                          color: ColorsValue.primary,
                        ),
                      )
                    else if (controller.branches.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<branch_model.Doc>(
                            value: controller.selectedBranch,
                            isExpanded: true,
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: ColorsValue.primary,
                            ),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            hint: Text(
                              'Select Branch',
                              style: Styles.txtGreyColorW40014,
                            ),
                            items: controller.branches.map((
                              branch_model.Doc branch,
                            ) {
                              return DropdownMenuItem<branch_model.Doc>(
                                value: branch,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.storefront_outlined,
                                      color: ColorsValue.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      child: Text(
                                        branch.name ?? '',
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: Styles.txtBlackColorW60014,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: controller.selectBranch,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                    children: [
                      if (RoleUtils.isAdmin(controller.roleName) &&
                          controller.roleName.toLowerCase().trim() != 'user')
                        _buildMenuCard(
                          title: 'Users',
                          icon: Icons.manage_accounts,
                          color: Colors.purple,
                          onTap: controller.goToUsers,
                        ),
                      if (RoleUtils.isAdmin(controller.roleName) ||
                          RoleUtils.isUser(controller.roleName))
                        _buildMenuCard(
                          title: 'Distributors',
                          icon: Icons.local_shipping_outlined,
                          color: Colors.teal,
                          onTap: controller.goToDistributors,
                        ),
                      _buildMenuCard(
                        title: 'Customers',
                        icon: Icons.people_alt,
                        color: Colors.blue,
                        onTap: controller.goToCustomers,
                      ),
                      if (RoleUtils.isAdmin(controller.roleName) ||
                          RoleUtils.isUser(controller.roleName))
                        _buildMenuCard(
                          title: 'Products',
                          icon: Icons.inventory_2_outlined,
                          color: Colors.indigo,
                          onTap: controller.goToProducts,
                        ),
                      _buildMenuCard(
                        title: 'Orders',
                        icon: Icons.shopping_cart,
                        color: Colors.orange,
                        onTap: controller.goToOrders,
                      ),
                      _buildMenuCard(
                        title: 'Customer Orders',
                        icon: Icons.list_alt,
                        color: Colors.deepOrange,
                        onTap: controller.goToCustomerOrders,
                      ),

                      if (!RoleUtils.isDealer(controller.roleName)) ...[
                        _buildMenuCard(
                          title: 'Attendance',
                          icon: Icons.fingerprint,
                          color: Colors.blueAccent,
                          onTap: controller.goToAttendance,
                        ),
                      ],
                      if (!RoleUtils.isDealer(controller.roleName))
                        _buildMenuCard(
                          title: 'Tasks',
                          icon: Icons.assignment_outlined,
                          color: Colors.teal,
                          onTap: controller.goToTasks,
                        ),
                      if (controller.roleName == "Admin") ...[
                        _buildMenuCard(
                          title: 'Salary',
                          icon: Icons.account_balance_wallet_outlined,
                          color: Colors.green,
                          onTap: controller.goToSalary,
                        ),
                      ],
                      if (!RoleUtils.isDealer(controller.roleName)) ...[
                        _buildMenuCard(
                          title: 'Leaves',
                          icon: Icons.beach_access,
                          color: Colors.green,
                          onTap: controller.goToLeaves,
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.2),
              radius: 30,
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Text(title, style: Styles.txtBlackColorW60014),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: Styles.txtGreyColorW40014),
        trailing: Text(
          value,
          style: Styles.txtBlackColorW70016.copyWith(color: color),
        ),
      ),
    );
  }
}
