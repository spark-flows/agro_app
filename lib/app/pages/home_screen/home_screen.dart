import 'package:agro_app/app/app.dart';
import 'package:agro_app/domain/services/enum.dart';
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

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                    children: [
                      _buildMenuCard(
                        title: 'Customers',
                        icon: Icons.people_alt,
                        color: Colors.blue,
                        onTap: controller.goToCustomers,
                      ),
                      if (RoleUtils.isAdmin(controller.roleName))
                        _buildMenuCard(
                          title: 'Distributors',
                          icon: Icons.local_shipping_outlined,
                          color: Colors.teal,
                          onTap: controller.goToDistributors,
                        ),
                      if (RoleUtils.isAdmin(controller.roleName))
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
                      if (RoleUtils.isAdmin(controller.roleName))
                        _buildMenuCard(
                          title: 'Users',
                          icon: Icons.manage_accounts,
                          color: Colors.purple,
                          onTap: controller.goToUsers,
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Text('Quick Overview', style: Styles.txtBlackColorW70018),
                  // const SizedBox(height: 16),
                  // _buildStatCard(
                  //   'Total Revenue',
                  //   '₹27,410',
                  //   Icons.account_balance_wallet,
                  //   Colors.green,
                  // ),
                  // const SizedBox(height: 12),
                  // _buildStatCard(
                  //   'Pending Orders',
                  //   '1',
                  //   Icons.pending_actions,
                  //   Colors.red,
                  // ),
                  // const SizedBox(height: 12),
                  // _buildStatCard(
                  //   'Completed Orders',
                  //   '3',
                  //   Icons.check_circle,
                  //   Colors.teal,
                  // ),
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
