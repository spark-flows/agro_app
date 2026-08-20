import 'package:agro_app/app/app.dart';
import 'package:agro_app/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

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
            title: Text('Customer Orders', style: Styles.txtBlackColorW70020),
          ),
          body: Column(
            children: [
              _buildTopBar(context, controller),
              Expanded(
                child: controller.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: ColorsValue.primary,
                        ),
                      )
                    : controller.filteredOrders.isEmpty
                    ? _buildEmptyState()
                    : _buildOrdersList(controller),
              ),
            ],
          ),
          floatingActionButton: !RoleUtils.isAdmin(homeController.roleName)
              ? FloatingActionButton.extended(
                  onPressed: () => _showCreateOrderBottomSheet(
                    context,
                    controller,
                    isEdit: false,
                  ),
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

  Widget _buildTopBar(
    BuildContext context,
    CustomerOrdersController controller,
  ) {
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
                      value: controller.filterCustomerId.isNotEmpty
                          ? controller.filterCustomerId
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
                          controller.filterCustomerId = val;
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
              const SizedBox(width: 8),
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: controller.isFilterActive
                            ? ColorsValue.primary
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.filter_list_rounded,
                        color: controller.isFilterActive
                            ? ColorsValue.primary
                            : Colors.grey.shade600,
                      ),
                      onPressed: () =>
                          _showFilterBottomSheet(context, controller),
                    ),
                  ),
                  if (controller.isFilterActive)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: ColorsValue.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
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
          Text('No Customer Orders Found', style: Styles.txtBlackColorW70020),
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
          await controller.fetchCustomerOrdersByCustomer(
            controller.selectedCustomerId,
          );
        } else {
          await controller.fetchAllCustomerOrders();
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.filteredOrders.length,
        itemBuilder: (context, index) {
          final order = controller.filteredOrders[index];
          String customerName = 'Unknown Customer';
          if (order.customerid != null) {
            customerName = order.customerid?.name ?? ' 0--0 ';
          }

          String distributorName = '';
          if (order.distributorid != null) {
            if (order.distributorid is Map) {
              distributorName = order.distributorid['name']?.toString() ?? '';
            } else {
              distributorName = order.distributorid.toString();
            }
          }

          String dateStr = '';
          if (order.createdAt != null) {
            try {
              dateStr = DateFormat(
                'dd MMM yyyy',
              ).format(DateTime.parse(order.createdAt!));
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
              onTap: () async {
                final fetchedOrder = await controller.getOneCustomerOrder(
                  order.id ?? '',
                );
                if (!context.mounted) return;
                if (fetchedOrder != null) {
                  _showOrderDetails(context, fetchedOrder, controller);
                } else {
                  _showOrderDetails(context, order, controller);
                }
              },
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
                          'Order # ${order.orderno ?? '---'}',
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Distributor',
                                    style: Styles.txtGreyColorW40012,
                                  ),
                                  Text(
                                    distributorName,
                                    style: Styles.txtBlackColorW60014,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    (() {
                      String? latestNextDate;
                      if (order.remark != null && order.remark!.isNotEmpty) {
                        for (int i = order.remark!.length - 1; i >= 0; i--) {
                          final nd = order.remark![i].nextdate;
                          if (nd != null && nd.isNotEmpty) {
                            latestNextDate = nd;
                            break;
                          }
                        }
                      }
                      if (latestNextDate != null && latestNextDate.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Next Date: ',
                                style: Styles.txtGreyColorW40012,
                              ),
                              Text(
                                (() {
                                  try {
                                    final parsedDate = DateTime.parse(
                                      latestNextDate!,
                                    );
                                    return DateFormat(
                                      'dd MMM yyyy',
                                    ).format(parsedDate);
                                  } catch (_) {
                                    return latestNextDate!;
                                  }
                                })(),
                                style: Styles.txtBlackColorW50014.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    })(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showOrderDetails(
    BuildContext context,
    CustomerOrderDoc order,
    CustomerOrdersController controller,
  ) {
    final homeController = Get.find<HomeController>();
    final isAdmin = RoleUtils.isAdmin(homeController.roleName);
    final isUser = RoleUtils.isUser(homeController.roleName);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Fixed header (not scrollable)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
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
                    // Drag handle + title row
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          Text(
                            'Order Details',
                            style: Styles.txtBlackColorW70020,
                          ),
                          Text(
                            'Name: ${order.customerid?.name ?? '---'}',
                            style: Styles.txtGreyColorW40014,
                          ),
                          Text(
                            'Email: ${order.customerid?.email ?? '---'}',
                            style: Styles.txtGreyColorW40014,
                          ),
                          Text(
                            'Mobile No: ${order.customerid?.mobile ?? '---'}',
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

              // Scrollable body
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
                            order.image ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (isAdmin || isUser) ...[
                      if (order.remark != null) ...[
                        for (int i = 0; i < order.remark!.length; i++) ...[
                          _buildRemarkCard(
                            'Remark ${i + 1}',
                            order.remark![i].remark ?? '-',
                            controller.getRemarkUserName(order.remark![i]),
                            controller.formatRemarkDate(order.remark![i].date),
                            order.remark![i].nextdate,
                          ),
                          const SizedBox(height: 12),
                        ],
                      ] else ...[
                        _buildDetailRow('Remark 1', order.remark1 ?? '-'),
                        const SizedBox(height: 12),
                        _buildDetailRow('Remark 2', order.remark2 ?? '-'),
                        const SizedBox(height: 12),
                        _buildDetailRow('Remark 3', order.remark3 ?? '-'),
                      ],
                    ],
                    const SizedBox(height: 100), // space for bottom buttons
                  ],
                ),
              ),

              // Fixed bottom action buttons
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
                        onPressed: () async {
                          Get.back(); // close details modal
                          await controller.editOrder(order);
                          // Use Get.context to avoid stale context after modal closes
                          final ctx = Get.context;
                          if (ctx != null) {
                            _showCreateOrderBottomSheet(
                              ctx,
                              controller,
                              isEdit: true,
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text(
                          'Edit',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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
                            message:
                                'Are you sure you want to delete this customer order?',
                            onConfirm: () {
                              Get.back(); // close modal sheet
                              if (order.id != null) {
                                controller.deleteOrder(order.id!);
                              }
                            },
                          );
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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

  Widget _buildRemarkCard(
    String label,
    String value,
    String author,
    String date,
    String? nextDate,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Styles.txtGreyColorW40012),
              if (date.isNotEmpty && date != '-')
                Text(
                  date,
                  style: Styles.txtGreyColorW40012.copyWith(fontSize: 11),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: Styles.txtBlackColorW50014),
          if (nextDate != null && nextDate.isNotEmpty && nextDate != '-') ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 12,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  'Next Date: ',
                  style: Styles.txtGreyColorW40012.copyWith(fontSize: 11),
                ),
                Text(
                  (() {
                    try {
                      final parsedDate = DateTime.parse(nextDate);
                      return DateFormat('dd MMM yyyy').format(parsedDate);
                    } catch (_) {
                      return nextDate;
                    }
                  })(),
                  style: Styles.txtBlackColorW50014.copyWith(fontSize: 11),
                ),
              ],
            ),
          ],
          if (author.isNotEmpty && author != '-') ...[
            const SizedBox(height: 8),
            Divider(color: Colors.grey.shade200, height: 1),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'By $author',
                style: Styles.txtGreyColorW40012.copyWith(
                  fontStyle: FontStyle.italic,
                  fontSize: 11,
                  color: ColorsValue.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showCreateOrderBottomSheet(
    BuildContext context,
    CustomerOrdersController controller, {
    bool isEdit = false,
  }) {
    final homeController = Get.find<HomeController>();
    final isAdmin = RoleUtils.isAdmin(homeController.roleName);
    final isUser = RoleUtils.isUser(homeController.roleName);
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
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
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
                      ctrl.editingCustomerOrderId != null
                          ? 'Edit Customer Order'
                          : 'Create Customer Order',
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
                    Text(
                      'Select Customer *',
                      style: Styles.txtBlackColorW60014,
                    ),
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
                          hint: Text(
                            ctrl.customersList.isEmpty
                                ? 'Select or create customer'
                                : 'Choose a customer',
                          ),
                          value:
                              ctrl.selectedCustomerId.isNotEmpty &&
                                  ctrl.customersList.any(
                                    (c) => c.id == ctrl.selectedCustomerId,
                                  )
                              ? ctrl.selectedCustomerId
                              : null,
                          items: [
                            ...ctrl.customersList.map(
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Text('${c.name} (${c.mobile ?? ''})'),
                              ),
                            ),
                            if (RoleUtils.isDealer(homeController.roleName) ||
                                RoleUtils.isUser(homeController.roleName))
                              const DropdownMenuItem<String>(
                                value: 'create_new_customer',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.person_add_alt_1_outlined,
                                      color: ColorsValue.primary,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Create New Customer',
                                      style: TextStyle(
                                        color: ColorsValue.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                          onChanged: (val) {
                            if (val == 'create_new_customer') {
                              _showQuickCreateCustomerBottomSheet(
                                context,
                                ctrl,
                              );
                            } else if (val != null) {
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
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () =>
                              _showImageSourceBottomSheet(context, ctrl),
                          child: Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              border: Border.all(
                                color:
                                    ctrl.selectedImage != null ||
                                        ctrl.existingImageUrl != null
                                    ? ColorsValue.primary
                                    : Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ctrl.selectedImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.file(
                                          ctrl.selectedImage!,
                                          fit: BoxFit.cover,
                                        ),
                                        // "Tap to change" label at bottom
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 6,
                                            ),
                                            color: Colors.black54,
                                            child: const Text(
                                              'Tap to change',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ctrl.existingImageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.network(
                                          ctrl.existingImageUrl ?? '',
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Center(
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  size: 40,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                        ),
                                        // "Tap to change" label at bottom
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 6,
                                            ),
                                            color: Colors.black54,
                                            child: const Text(
                                              'Tap to change',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo,
                                        size: 40,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tap to upload image',
                                        style: Styles.txtGreyColorW40014,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        // ✕ Remove button — shown only when an image is present
                        if (ctrl.selectedImage != null ||
                            ctrl.existingImageUrl != null)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: ctrl.removeImage,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    if (isAdmin || isUser) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Remarks & Next Date',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ColorsValue.txtBlackColor,
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ctrl.isLocalPunchedIn
                                  ? Colors.red
                                  : ColorsValue.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            onPressed: ctrl.togglePunchIn,
                            icon: Icon(
                              ctrl.isLocalPunchedIn
                                  ? Icons.exit_to_app
                                  : Icons.login,
                              size: 16,
                              color: Colors.white,
                            ),
                            label: Text(
                              ctrl.isLocalPunchedIn ? 'Punch Out' : 'Punch In',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      for (
                        int i = 0;
                        i < ctrl.customerRemarkLIst.length;
                        i++
                      ) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Remark & Next Date ${i + 1}',
                                    style: Styles.txtBlackColorW60014,
                                  ),
                                  if (i >= ctrl.loadedRemarks.length &&
                                      ctrl.customerRemarkLIst.length > 1)
                                    IconButton(
                                      onPressed: () {
                                        ctrl.removeRemarkFieldAt(i);
                                      },
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                'Remark',
                                ctrl.customerRemarkLIst[i].remark ??
                                    TextEditingController(),
                                readOnly:
                                    (i < ctrl.loadedRemarks.length) ||
                                    !ctrl.isUserPunchedIn(),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Next Date',
                                style: Styles.txtBlackColorW60014,
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap:
                                    (i < ctrl.loadedRemarks.length ||
                                        !ctrl.isUserPunchedIn())
                                    ? null
                                    : () async {
                                        final initialDate =
                                            ctrl
                                                    .customerRemarkLIst[i]
                                                    .nextDate
                                                    ?.text
                                                    .isNotEmpty ==
                                                true
                                            ? DateTime.tryParse(
                                                    ctrl
                                                        .customerRemarkLIst[i]
                                                        .nextDate!
                                                        .text,
                                                  ) ??
                                                  DateTime.now()
                                            : DateTime.now();
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate: initialDate,
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime(3000),
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                colorScheme:
                                                    const ColorScheme.light(
                                                      primary:
                                                          ColorsValue.primary,
                                                    ),
                                              ),
                                              child: child!,
                                            );
                                          },
                                        );
                                        if (picked != null) {
                                          ctrl
                                                  .customerRemarkLIst[i]
                                                  .nextDate
                                                  ?.text =
                                              '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                                          ctrl.update();
                                        }
                                      },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        (i < ctrl.loadedRemarks.length ||
                                            !ctrl.isUserPunchedIn())
                                        ? Colors.grey.shade100
                                        : Colors.white,
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        ctrl
                                                    .customerRemarkLIst[i]
                                                    .nextDate
                                                    ?.text
                                                    .isNotEmpty ==
                                                true
                                            ? (() {
                                                try {
                                                  final parsed = DateTime.parse(
                                                    ctrl
                                                        .customerRemarkLIst[i]
                                                        .nextDate!
                                                        .text,
                                                  );
                                                  return DateFormat(
                                                    'dd/MM/yyyy',
                                                  ).format(parsed);
                                                } catch (_) {
                                                  return ctrl
                                                      .customerRemarkLIst[i]
                                                      .nextDate!
                                                      .text;
                                                }
                                              })()
                                            : 'Select Next Date',
                                        style:
                                            ctrl
                                                    .customerRemarkLIst[i]
                                                    .nextDate
                                                    ?.text
                                                    .isNotEmpty ==
                                                true
                                            ? Styles.txtBlackColorW50014
                                            : Styles.txtGreyColorW40014,
                                      ),
                                      Icon(
                                        Icons.calendar_today,
                                        color: Colors.grey.shade600,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: ctrl.addRemarkField,
                          style: TextButton.styleFrom(
                            foregroundColor: ColorsValue.primary,
                          ),
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text(
                            'Add Remark',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
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
                    ctrl.editingCustomerOrderId != null
                        ? 'Update Order'
                        : 'Create Order',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Styles.txtBlackColorW60014),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            hintStyle: Styles.txtGreyColorW40014,
            filled: readOnly,
            fillColor: readOnly ? Colors.grey.shade100 : null,
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
              borderSide: BorderSide(
                color: readOnly ? Colors.grey.shade300 : ColorsValue.primary,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  void _showQuickCreateCustomerBottomSheet(
    BuildContext context,
    CustomerOrdersController ctrl,
  ) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final villageCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Get.bottomSheet(
      Padding(
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
                  key: formKey,
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
                        'Create New Customer',
                        style: Styles.txtBlackColorW70020,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Customer Name
                      TextFormField(
                        controller: nameCtrl,
                        decoration: InputDecoration(
                          labelText: 'Customer Name *',
                          labelStyle: Styles.txtGreyColorW40014,
                          prefixIcon: const Icon(
                            Icons.person_outline,
                            color: ColorsValue.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter a name'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Phone Number
                      TextFormField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Phone Number *',
                          labelStyle: Styles.txtGreyColorW40014,
                          prefixIcon: const Icon(
                            Icons.phone_outlined,
                            color: ColorsValue.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          counterText: '',
                        ),
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

                      // Email Address
                      TextFormField(
                        controller: emailCtrl,
                        decoration: InputDecoration(
                          labelText: 'Email Address (Optional)',
                          labelStyle: Styles.txtGreyColorW40014,
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: ColorsValue.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) {
                          if (v != null && v.trim().isNotEmpty) {
                            if (!Utility.emailValidation(v.trim())) {
                              return 'Please enter a valid email';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Village
                      TextFormField(
                        controller: villageCtrl,
                        decoration: InputDecoration(
                          labelText: 'Village *',
                          labelStyle: Styles.txtGreyColorW40014,
                          prefixIcon: const Icon(
                            Icons.home_outlined,
                            color: ColorsValue.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter a village'
                            : null,
                      ),
                      const SizedBox(height: 24),

                      // Save Button
                      ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            Utility.showLoader();
                            try {
                              var response = await Get.find<Repository>()
                                  .createCustomerApi(
                                    name: nameCtrl.text.trim(),
                                    email: emailCtrl.text.trim(),
                                    countrycode: '+91',
                                    mobile: phoneCtrl.text.trim(),
                                    feedback: '',
                                    village: villageCtrl.text.trim(),
                                    isLoading: false,
                                  );
                              Utility.closeLoader();

                              if (response != null &&
                                  response.isSuccess == true) {
                                Get.back(); // close sheet
                                Utility.snacBar(
                                  'Customer created successfully',
                                  Colors.green,
                                );

                                // Refresh customers list
                                await ctrl.fetchCustomers();

                                // Try to find the newly created customer by mobile and select it!
                                final newCust = ctrl.customersList
                                    .firstWhereOrNull(
                                      (c) =>
                                          c.mobile == phoneCtrl.text.trim() ||
                                          c.mobile ==
                                              '+91 ${phoneCtrl.text.trim()}',
                                    );
                                if (newCust != null) {
                                  ctrl.selectedCustomerId = newCust.id ?? '';
                                  ctrl.update();
                                }
                              } else {
                                Utility.errorMessage(
                                  'Failed to save customer. Please try again.',
                                );
                              }
                            } catch (e) {
                              Utility.closeLoader();
                              Utility.errorMessage(
                                'An error occurred. Please try again.',
                              );
                            }
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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showImageSourceBottomSheet(
    BuildContext context,
    CustomerOrdersController controller,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            Text('Select Image Source', style: Styles.txtBlackColorW70020),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: Icons.camera_alt_outlined,
                  label: 'Camera',
                  onTap: () {
                    Get.back();
                    controller.pickImage(ImageSource.camera);
                  },
                ),
                _buildSourceOption(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  onTap: () {
                    Get.back();
                    controller.pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: ColorsValue.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: ColorsValue.primary, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: Styles.txtBlackColorW60014),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(
    BuildContext context,
    CustomerOrdersController controller,
  ) {
    DateTime? tempDateFrom = controller.filterDateFrom;
    DateTime? tempDateTo = controller.filterDateTo;
    String? tempDistributorId = controller.filterDistributorId;

    String formatDate(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          Future<void> pickDate({
            required DateTime? initialDate,
            required ValueChanged<DateTime?> onPicked,
          }) async {
            final picked = await showDatePicker(
              context: context,
              initialDate: initialDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: ColorsValue.primary,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setSheetState(() => onPicked(picked));
            }
          }

          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 20),

                  Text('Filter Orders', style: Styles.txtBlackColorW70020),
                  const SizedBox(height: 20),

                  // ── Date Range ──────────────────────────────────────────
                  Text('Order Date', style: Styles.txtBlackColorW60014),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => pickDate(
                            initialDate: tempDateFrom,
                            onPicked: (d) => tempDateFrom = d,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  tempDateFrom != null
                                      ? formatDate(tempDateFrom!)
                                      : 'From',
                                  style: TextStyle(
                                    color: tempDateFrom != null
                                        ? Colors.black87
                                        : Colors.grey.shade500,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () => pickDate(
                            initialDate: tempDateTo,
                            onPicked: (d) => tempDateTo = d,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  tempDateTo != null
                                      ? formatDate(tempDateTo!)
                                      : 'To',
                                  style: TextStyle(
                                    color: tempDateTo != null
                                        ? Colors.black87
                                        : Colors.grey.shade500,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Distributor Dropdown (Admin only) ───────────────────
                  if (controller.isAdmin) ...[
                    DropdownButtonFormField<String>(
                      value: tempDistributorId,
                      decoration: InputDecoration(
                        labelText: 'Distributor',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('All Distributors'),
                        ),
                        ...controller.distributors.map(
                          (dist) => DropdownMenuItem<String>(
                            value: dist.id,
                            child: Text(dist.name),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        setSheetState(() => tempDistributorId = val);
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  const SizedBox(height: 8),

                  // ── Action Buttons ──────────────────────────────────────
                  Row(
                    children: [
                      if (controller.isFilterActive) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              controller.clearFilters();
                              Get.back();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Clear Filter',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            controller.applyFilters(
                              dateFrom: tempDateFrom,
                              dateTo: tempDateTo,
                              distributorId: tempDistributorId,
                            );
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorsValue.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Apply Filters',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }
}
