import 'package:agro_app/app/app.dart';
import 'package:agro_app/domain/services/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                padding: const EdgeInsets.all(16.0).copyWith(bottom: 10),
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
                    return const Center(
                      child: CircularProgressIndicator(
                        color: ColorsValue.primary,
                      ),
                    );
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
                              // onTap: () {
                              //   if (!RoleUtils.isAdmin(
                              //     homeController.roleName,
                              //   )) {
                              //     _showFeedbackDialog(
                              //       context,
                              //       controller,
                              //       customer,
                              //     );
                              //   }
                              // },
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
                                  if (customer.village != 'N/A' &&
                                      customer.village.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 6.0,
                                      ),
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
                            if (true)
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
              Dimens.boxHeight10,
            ],
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

  void _showAddDialog(BuildContext context, CustomersController controller) {
    Get.bottomSheet(
      GetBuilder<CustomersController>(
        builder: (controller) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Material(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            clipBehavior: Clip.antiAlias,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
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
                        Text(
                          controller.editingCustomerId.isNotEmpty
                              ? 'Edit Customer'
                              : 'Add New Customer',
                          style: Styles.txtBlackColorW70020,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // ── Distributor dropdown (admin only) ────────────────
                        if (controller.isAdminView) ...[
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            value: controller.selectedDistributorId,
                            decoration: InputDecoration(
                              labelText: 'Select Distributor',
                              labelStyle: Styles.txtGreyColorW40014,
                              floatingLabelStyle: const TextStyle(
                                color: ColorsValue.primary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: ColorsValue.primary,
                                  width: 1.5,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.store_outlined,
                                color: ColorsValue.primary.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                            hint: const Text('Select Distributor'),
                            items: controller.distributors
                                .map(
                                  (d) => DropdownMenuItem(
                                    value: d.id,
                                    child: Text(
                                      d.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              controller.selectedDistributorId = val;
                              controller.update();
                            },
                            validator: (_) =>
                                (controller.selectedDistributorId == null ||
                                    controller.selectedDistributorId!.isEmpty)
                                ? 'Please select a distributor'
                                : null,
                          ),
                          const SizedBox(height: 16),
                        ],

                        _buildField(
                          controller: controller.nameCtrl,
                          label: 'Customer Name',
                          icon: Icons.person_outline,
                          action: TextInputAction.next,
                          validator: (v) =>
                              v!.isEmpty ? 'Please enter a name' : null,
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
                        _buildField(
                          controller: controller.locationCtrl,
                          label:
                              RoleUtils.isDealer(
                                    Get.find<HomeController>().roleName,
                                  ) ||
                                  RoleUtils.isUser(
                                    Get.find<HomeController>().roleName,
                                  )
                              ? 'Email Address (Optional)'
                              : 'Email Address',
                          icon: Icons.email_outlined,
                          action: TextInputAction.next,
                          validator: (v) {
                            final bool isDealer = RoleUtils.isDealer(
                              Get.find<HomeController>().roleName,
                            );
                            final bool isUser = RoleUtils.isUser(
                              Get.find<HomeController>().roleName,
                            );
                            final bool isAdmin = RoleUtils.isAdmin(
                              Get.find<HomeController>().roleName,
                            );
                            if (isDealer || isUser || isAdmin) {
                              if (v == null || v.trim().isEmpty) {
                                return null;
                              }
                              if (!Utility.emailValidation(v.trim())) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            }

                            if (v == null || v.trim().isEmpty) {
                              return 'Please enter an email address';
                            } else if (!Utility.emailValidation(v.trim())) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: controller.villageCtrl,
                          label: 'Village',
                          icon: Icons.home_outlined,
                          action: TextInputAction.done,
                          validator: (v) =>
                              v!.isEmpty ? 'Please enter a village' : null,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            if (controller.addFormKey.currentState!
                                .validate()) {
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
        builder: (controller) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Material(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            clipBehavior: Clip.antiAlias,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
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
                      _buildField(
                        controller: controller.feedbackCtrl,
                        label: 'Feedback',
                        icon: Icons.feedback_outlined,
                        maxLines: 3,
                        alignLabelWithHint: true,
                        prefixIconPadding: const EdgeInsets.only(bottom: 32.0),
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
    int maxLines = 1,
    bool alignLabelWithHint = false,
    EdgeInsetsGeometry? prefixIconPadding,
  }) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: action,
      obscureText: obscureText,
      maxLength: maxLength,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      cursorColor: ColorsValue.primary,
      style: Styles.txtBlackColorW50014,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: alignLabelWithHint,
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
        prefixIcon: prefixIconPadding != null
            ? Padding(
                padding: prefixIconPadding,
                child: Icon(
                  icon,
                  color: ColorsValue.primary.withValues(alpha: 0.8),
                ),
              )
            : Icon(icon, color: ColorsValue.primary.withValues(alpha: 0.8)),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }
}
