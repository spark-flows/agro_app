import 'package:agro_app/app/app.dart';
import 'package:agro_app/domain/services/enum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CustomersController>(
      builder: (controller) {
        final homeController = Get.find<HomeController>();
        return Scaffold(
          backgroundColor: ColorsValue.bgMain,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black87),
            title: Text('Customers', style: Styles.txtBlackColorW70020),
          ),
          body: Column(
            children: [
              /// Simple Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: controller.searchController,
                  onChanged: controller.onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search customers...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),

              /// List
              Expanded(
                child: () {
                  if (controller.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.customers.isEmpty) {
                    return const Center(child: Text('No customers found.'));
                  }
                  return ListView.builder(
                    itemCount: controller.customers.length,
                    itemBuilder: (context, index) {
                      final customer = controller.customers[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        elevation: 1,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              onTap: () {
                                if (RoleUtils.isAdmin(
                                  homeController.roleName,
                                )) {
                                  _showFeedbackDialog(
                                    context,
                                    controller,
                                    customer,
                                  );
                                }
                              },
                              contentPadding: const EdgeInsets.only(
                                left: 16,
                                right: 16,
                                top: 4,
                                bottom: 0,
                              ),
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor: ColorsValue.primary.withValues(
                                  alpha: 0.1,
                                ),
                                child: Text(
                                  customer.name.isNotEmpty
                                      ? customer.name
                                            .substring(0, 1)
                                            .toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    color: ColorsValue.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              title: Text(
                                customer.name,
                                style: Styles.txtBlackColorW70020.copyWith(
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.phone_outlined,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        customer.phone,
                                        style: Styles.txtGreyColorW40014,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.email_outlined,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        customer.location,
                                        style: Styles.txtGreyColorW40014,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  if (customer.village != 'N/A' && customer.village.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 6.0),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.home_outlined,
                                            size: 14,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            customer.village,
                                            style: Styles.txtGreyColorW40014,
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (RoleUtils.isAdmin(
                                        homeController.roleName,
                                      ) &&
                                      customer.feedback != 'N/A' &&
                                      customer.feedback.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: 'Feedback: ',
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            TextSpan(
                                              text: customer.feedback,
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Divider(height: 1, color: Colors.grey.shade200),
                            if (!RoleUtils.isAdmin(homeController.roleName))
                              IntrinsicHeight(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextButton.icon(
                                        onPressed: () {
                                          controller.setupEdit(customer);
                                          _showAddDialog(context, controller);
                                        },
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          color: Colors.blue,
                                          size: 20,
                                        ),
                                        label: const Text(
                                          'Edit',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.zero,
                                          ),
                                        ),
                                      ),
                                    ),
                                    VerticalDivider(
                                      width: 1,
                                      color: Colors.grey.shade200,
                                      thickness: 1,
                                    ),
                                    Expanded(
                                      child: TextButton.icon(
                                        onPressed: () {
                                          Utility.showDeleteDialog(
                                            title: 'Delete Customer',
                                            message:
                                                'Are you sure you want to delete ${customer.name}? This action cannot be undone.',
                                            onConfirm: () {
                                              controller.deleteCustomer(
                                                customer.id,
                                              );
                                            },
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        label: const Text(
                                          'Delete',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.zero,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                }(),
              ),
            ],
          ),
          floatingActionButton: !RoleUtils.isAdmin(homeController.roleName)
              ? FloatingActionButton(
                  backgroundColor: ColorsValue.primary,
                  onPressed: () {
                    controller.clearAddForm();
                    _showAddDialog(context, controller);
                  },
                  child: const Icon(Icons.add),
                )
              : null,
        );
      },
    );
  }

  void _showAddDialog(BuildContext context, CustomersController controller) {
    Get.bottomSheet(
      GetBuilder<CustomersController>(
        builder: (controller) => Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(Get.context!).viewInsets.bottom + 24,
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
                  Text(
                    controller.editingCustomerId.isNotEmpty
                        ? 'Edit Customer'
                        : 'Add New Customer',
                    style: Styles.txtBlackColorW70020,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: controller.nameCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Customer Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    validator: (v) => v!.isEmpty ? 'Please enter a name' : null,
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
                    controller: controller.locationCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    validator: (v) =>
                        v!.isEmpty ? 'Please enter an email address' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.villageCtrl,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'Village',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.home_outlined),
                    ),
                    validator: (v) => v!.isEmpty ? 'Please enter a village' : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (controller.addFormKey.currentState!.validate()) {
                        controller.addCustomer();
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
                      'Save Customer',
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

  void _showFeedbackDialog(
    BuildContext context,
    CustomersController controller,
    CustomerItem customer,
  ) {
    controller.feedbackCtrl.text = customer.feedback != 'N/A'
        ? customer.feedback
        : '';
    Get.bottomSheet(
      GetBuilder<CustomersController>(
        builder: (controller) => Container(
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
                Text(
                  'Add Feedback for ${customer.name}',
                  style: Styles.txtBlackColorW70020,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: controller.feedbackCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Feedback',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 32.0),
                      child: Icon(Icons.feedback_outlined),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    controller.submitFeedback(customer.id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsValue.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Submit Feedback',
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
