import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agro_app/app/app.dart';
import 'package:agro_app/domain/domain.dart';
import 'package:intl/intl.dart';
import 'package:agro_app/data/helpers/api_wrapper.dart';
import 'package:agro_app/domain/services/enum.dart';
import 'customer_orders_controller.dart';

class CustomerOrdersScreen extends StatelessWidget {
  const CustomerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    return GetBuilder<CustomerOrdersController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.bgMain,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Get.back(),
            ),
            title: Text(
              'Customer Orders',
              style: Styles.txtBlackColorW70020,
            ),
          ),
          body: Column(
            children: [
              _buildTopBar(context, controller),
              Expanded(
                child: controller.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : controller.ordersList.isEmpty
                        ? _buildEmptyState()
                        : _buildOrdersList(controller),
              ),
            ],
          ),
          floatingActionButton: !RoleUtils.isAdmin(homeController.roleName)
              ? FloatingActionButton.extended(
                  onPressed: () => _showCreateOrderBottomSheet(context, controller, isEdit: false),
                  backgroundColor: ColorsValue.primary,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'New Order',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, CustomerOrdersController controller) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: Text(
                        'Filter by Customer (Optional)',
                        style: Styles.txtGreyColorW40014,
                      ),
                      value: controller.selectedCustomerId.isNotEmpty
                          ? controller.selectedCustomerId
                          : null,
                      items: [
                        const DropdownMenuItem<String>(
                          value: '',
                          child: Text('All Customers'),
                        ),
                        ...controller.customersList.map((c) {
                          return DropdownMenuItem<String>(
                            value: c.id,
                            child: Text(
                              '${c.name} (${c.mobile ?? ''})',
                              style: Styles.txtBlackColorW50014,
                            ),
                          );
                        }),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          controller.selectedCustomerId = val;
                          controller.update();
                          if (val.isEmpty) {
                            controller.fetchAllCustomerOrders();
                          } else {
                            controller.fetchCustomerOrdersByCustomer(val);
                          }
                        }
                      },
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.deepOrange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.list_alt,
              size: 64,
              color: Colors.deepOrange,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Customer Orders Found',
            style: Styles.txtBlackColorW70020,
          ),
          const SizedBox(height: 8),
          Text(
            'Create a new order to get started.',
            style: Styles.txtGreyColorW40014,
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(CustomerOrdersController controller) {
    return RefreshIndicator(
      onRefresh: () async {
        if (controller.selectedCustomerId.isNotEmpty) {
          await controller.fetchCustomerOrdersByCustomer(controller.selectedCustomerId);
        } else {
          await controller.fetchAllCustomerOrders();
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.ordersList.length,
        itemBuilder: (context, index) {
          final order = controller.ordersList[index];
          String customerName = 'Unknown Customer';
          if (order.customerid != null && order.customerid is Map) {
             customerName = order.customerid['firstname'] ?? order.customerid['name'] ?? 'Unknown Customer';
          }
          
          String dateStr = '';
          if (order.createdAt != null) {
            try {
               dateStr = DateFormat('dd MMM yyyy').format(DateTime.parse(order.createdAt!));
            } catch (e) {
               dateStr = order.createdAt!;
            }
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () => _showOrderDetails(context, order, controller),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order #${order.customerorderid ?? '---'}',
                          style: Styles.txtBlackColorW70016,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            dateStr,
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.deepOrange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: Colors.deepOrange,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Customer',
                                style: Styles.txtGreyColorW40012,
                              ),
                              Text(
                                customerName,
                                style: Styles.txtBlackColorW60014,
                              ),
                            ],
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
      ),
    );
  }

  void _showOrderDetails(BuildContext context, CustomerOrderDoc order, CustomerOrdersController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Details',
                          style: Styles.txtBlackColorW70020,
                        ),
                        Text(
                          '#${order.customerorderid ?? '---'}',
                          style: Styles.txtGreyColorW40014,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (order.image != null && order.image!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          ApiWrapper.imageUrl + order.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Center(
                            child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  _buildDetailRow('Remark 1', order.remark1 ?? '-'),
                  const SizedBox(height: 12),
                  _buildDetailRow('Remark 2', order.remark2 ?? '-'),
                  const SizedBox(height: 12),
                  _buildDetailRow('Remark 3', order.remark3 ?? '-'),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back(); // close modal
                        controller.editOrder(order);
                        _showCreateOrderBottomSheet(context, controller, isEdit: true);
                      },
                      icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 18),
                      label: const Text(
                        'Edit',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(double.infinity, 50),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Utility.showDeleteDialog(
                          title: 'Confirm Delete',
                          message: 'Are you sure you want to delete this customer order?',
                          onConfirm: () {
                            Get.back(); // close modal sheet
                            if (order.id != null) {
                              controller.deleteOrder(order.id!);
                            }
                          },
                        );
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.white, size: 18),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(double.infinity, 50),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Styles.txtGreyColorW40012),
          const SizedBox(height: 4),
          Text(value, style: Styles.txtBlackColorW50014),
        ],
      ),
    );
  }

  void _showCreateOrderBottomSheet(BuildContext context, CustomerOrdersController controller, {bool isEdit = false}) {
    if (!isEdit) {
      controller.resetForm();
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GetBuilder<CustomerOrdersController>(
        builder: (ctrl) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ctrl.editingCustomerOrderId != null ? 'Edit Customer Order' : 'Create Customer Order',
                      style: Styles.txtBlackColorW70020,
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Customer Dropdown
                    Text('Select Customer *', style: Styles.txtBlackColorW60014),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: const Text('Choose a customer'),
                          value: ctrl.selectedCustomerId.isNotEmpty ? ctrl.selectedCustomerId : null,
                          items: ctrl.customersList.map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text('${c.name} (${c.mobile ?? ''})'),
                          )).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              ctrl.selectedCustomerId = val;
                              ctrl.update();
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Image Picker
                    Text('Order Image *', style: Styles.txtBlackColorW60014),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: ctrl.pickImage,
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ctrl.selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(ctrl.selectedImage!, fit: BoxFit.cover),
                              )
                            : ctrl.existingImageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      ApiWrapper.imageUrl + ctrl.existingImageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Center(
                                        child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                                      ),
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo, size: 40, color: Colors.grey.shade400),
                                      const SizedBox(height: 8),
                                      Text('Tap to upload image', style: Styles.txtGreyColorW40014),
                                    ],
                                  ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Remarks
                    _buildTextField('Remark 1', ctrl.remark1Controller),
                    const SizedBox(height: 16),
                    _buildTextField('Remark 2', ctrl.remark2Controller),
                    const SizedBox(height: 16),
                    _buildTextField('Remark 3', ctrl.remark3Controller),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: ctrl.placeCustomerOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsValue.primary,
                    minimumSize: const Size(double.infinity, 50),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    ctrl.editingCustomerOrderId != null ? 'Update Order' : 'Create Order',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Styles.txtBlackColorW60014),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            hintStyle: Styles.txtGreyColorW40014,
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
              borderSide: const BorderSide(color: ColorsValue.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
