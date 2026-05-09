import 'package:agro_app/app/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.bgMain,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black87),
            title: Text('Profile', style: Styles.txtBlackColorW70020),
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final user = controller.userData;
            if (user == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Failed to load profile.'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: controller.fetchProfile,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: ColorsValue.primary.withValues(
                        alpha: 0.1,
                      ),
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: ColorsValue.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    textAlign: TextAlign.center,
                    style: Styles.txtBlackColorW70020,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    textAlign: TextAlign.center,
                    style: Styles.txtGreyColorW40014,
                  ),
                  const SizedBox(height: 32),

                  _buildInfoTile(Icons.phone, 'Phone', user.mobile),
                  // _buildInfoTile(Icons.info_outline, 'Address', user.data?. ? user.address : 'N/A'),
                  // _buildInfoTile(
                  //   Icons.badge_outlined,
                  //   'Distributor ID',
                  //   user.id,
                  // ),
                  _buildInfoTile(
                    Icons.verified_user_outlined,
                    'Status',
                    user.isActive ? 'Active' : 'Inactive',
                  ),

                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.dialog(
                        Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.logout_rounded,
                                    color: Colors.red,
                                    size: 36,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Logout Account',
                                  style: Styles.txtBlackColorW70020,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Are you sure you want to log out of your account?',
                                  textAlign: TextAlign.center,
                                  style: Styles.txtGreyColorW40014,
                                ),
                                const SizedBox(height: 28),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => Get.back(),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          side: BorderSide(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Get.back();
                                          controller.logout();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: const Text(
                                          'Logout',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(icon, color: ColorsValue.primary),
        title: Text(title, style: Styles.txtGreyColorW40012),
        subtitle: Text(subtitle, style: Styles.txtBlackColorW60014),
      ),
    );
  }
}
