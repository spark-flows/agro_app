import 'package:agro_app/app/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrdersController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.bgMain,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black87),
            title: Text('Products & Orders', style: Styles.txtBlackColorW70020),
            actions: [
              IconButton(
                icon: const Icon(Icons.history, color: ColorsValue.primary),
                onPressed: () =>
                    _showOrderHistoryBottomSheet(context, controller),
              ),
            ],
          ),
          body: Column(
            children: [
              /// Products
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (controller.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final products = controller.displayProducts;
                    if (products.isEmpty) {
                      return const Center(child: Text('No products found.'));
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final item = products[index];
                        return Card(
                          elevation: 1,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Icon Placeholder
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      item.emoji,
                                      style: const TextStyle(fontSize: 30),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                /// Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: Styles.txtBlackColorW60014,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.category,
                                        style: Styles.txtGreyColorW40012,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.description,
                                        style: Styles.txtGreyColorW40012,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${item.price} ${item.unit}',
                                        style: Styles.txtBlackColorW70014
                                            .copyWith(color: Colors.green),
                                      ),
                                    ],
                                  ),
                                ),

                                /// Action
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: item.quantity == 0
                                      ? IconButton(
                                          icon: Icon(
                                            Icons.add_circle_outline,
                                            color: ColorsValue.primary,
                                            size: 30,
                                          ),
                                          onPressed: () => controller
                                              .incrementQuantity(item.id),
                                        )
                                      : Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.remove_circle_outline,
                                                color: Colors.red,
                                              ),
                                              onPressed: () => controller
                                                  .decrementQuantity(item.id),
                                            ),
                                            Text(
                                              '${item.quantity}',
                                              style: Styles.txtBlackColorW70016,
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.add_circle_outline,
                                                color: ColorsValue.primary,
                                              ),
                                              onPressed: () => controller
                                                  .incrementQuantity(item.id),
                                            ),
                                          ],
                                        ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: controller.cartCount > 0
              ? SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () =>
                          _showCartBottomSheet(context, controller),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsValue.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shopping_cart, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'View Cart (${controller.cartCount}) - ₹${controller.cartTotal}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  void _showOrderHistoryBottomSheet(
    BuildContext context,
    OrdersController controller,
  ) {
    controller.customerOrders.clear();
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Order History',
              style: Styles.txtBlackColorW70020,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Customer',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: controller.customers.map((c) {
                return DropdownMenuItem<String>(
                  value: c.id,
                  child: Text('${c.name} (${c.mobile ?? ''})'),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) controller.fetchOrderHistory(val);
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GetBuilder<OrdersController>(
                builder: (controller) {
                  if (controller.isFetchingOrders) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.customerOrders.isEmpty) {
                    return const Center(
                      child: Text('No orders found for this customer.'),
                    );
                  }
                  return ListView.builder(
                    itemCount: controller.customerOrders.length,
                    itemBuilder: (context, index) {
                      final order = controller.customerOrders[index];
                      return Card(
                        elevation: 1,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          onTap: () {
                            if (order.id != null) {
                              controller.fetchOrderDetails(order.id!);
                              _showOrderDetailsDialog(context, controller);
                            }
                          },
                          title: Text(
                            'Order: ${order.orderno}',
                            style: Styles.txtBlackColorW60014,
                          ),
                          subtitle: Text(
                            'Date: ${order.createdAt?.split('T').first ?? ''}',
                            style: Styles.txtGreyColorW40012,
                          ),
                          trailing: Text(
                            '₹${order.totalamount}',
                            style: Styles.txtBlackColorW70016.copyWith(
                              color: Colors.green,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showCartBottomSheet(BuildContext context, OrdersController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: GetBuilder<OrdersController>(
          builder: (controller) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                Text(
                  'Checkout',
                  style: Styles.txtBlackColorW70020,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select Customer',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value: controller.selectedCustomerId.isEmpty
                      ? null
                      : controller.selectedCustomerId,
                  items: controller.customers.map((c) {
                    return DropdownMenuItem<String>(
                      value: c.id,
                      child: Text('${c.name} (${c.mobile ?? ''})'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) controller.setSelectedCustomerId(val);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.titleController,
                  decoration: InputDecoration(
                    labelText: 'Order Title / ID',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.deliveryDateController,
                  decoration: InputDecoration(
                    labelText: 'Delivery Date',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    DateTime? date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      controller.deliveryDateController.text = 
                        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.feedbackController,
                  decoration: InputDecoration(
                    labelText: 'Feedback / Notes',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Amount:', style: Styles.txtBlackColorW60014),
                    Text(
                      '₹${controller.cartTotal}',
                      style: Styles.txtBlackColorW70020.copyWith(
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: controller.isPlacingOrder
                      ? null
                      : () => controller.placeOrder(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsValue.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.isPlacingOrder
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : const Text(
                          'Place Order',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
            );
          },
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showOrderDetailsDialog(BuildContext context, OrdersController controller) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: GetBuilder<OrdersController>(
          builder: (controller) {
            if (controller.isFetchingOrderDetails || controller.selectedOrderDetails == null) {
              return const Center(child: CircularProgressIndicator());
            }
            
            final details = controller.selectedOrderDetails!.data;
            if (details == null) {
              return const Center(child: Text('No details available.'));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Order Details', style: Styles.txtBlackColorW70020, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Text('Order ID: ${details.orderno ?? "-"}', style: Styles.txtBlackColorW60014),
                const SizedBox(height: 4),
                Text('Status: ${details.status ?? "Pending"}', style: Styles.txtBlackColorW60014.copyWith(color: ColorsValue.primary)),
                const SizedBox(height: 4),
                Text('Delivery Date: ${details.deliverydate ?? "N/A"}', style: Styles.txtGreyColorW40012),
                const SizedBox(height: 4),
                Text('Feedback: ${details.feedback ?? "N/A"}', style: Styles.txtGreyColorW40012),
                const Divider(height: 32),
                Text('Items:', style: Styles.txtBlackColorW60014),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: details.items?.length ?? 0,
                    itemBuilder: (ctx, idx) {
                      final item = details.items![idx];
                      String pName = 'Unknown Product';
                      if (item.productid is Map) {
                        pName = item.productid['name'] ?? item.productid['_id'] ?? 'Unknown Product';
                      } else if (item.productid != null) {
                        final localMatch = controller.allProducts.firstWhereOrNull((p) => p.id == item.productid);
                        pName = localMatch?.name ?? item.productid.toString();
                      }

                      return Card(
                        elevation: 0,
                        color: Colors.grey.shade50,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: ColorsValue.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Icon(Icons.inventory_2_outlined, color: ColorsValue.primary, size: 20),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(pName, style: Styles.txtBlackColorW60014),
                                    const SizedBox(height: 4),
                                    Text('Qty: ${item.quantity}', style: Styles.txtGreyColorW40012),
                                  ],
                                ),
                              ),
                              Text(
                                '₹${item.price}',
                                style: Styles.txtBlackColorW70016.copyWith(color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Amount:', style: Styles.txtBlackColorW70016),
                    Text('₹${details.totalamount}', style: Styles.txtBlackColorW70020.copyWith(color: Colors.green)),
                  ],
                ),
              ],
            );
          },
        ),
      ),
      isScrollControlled: true,
    );
  }
}
