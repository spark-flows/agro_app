import 'package:agro_app/app/app.dart';
import 'package:agro_app/domain/domain.dart';
import 'package:agro_app/domain/services/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrdersController>(
      builder: (controller) {
        final homeController = Get.find<HomeController>();
        return Scaffold(
          backgroundColor: ColorsValue.bgMain,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black87),
            title: Text(
              'Distributor Orders History',
              style: Styles.txtBlackColorW70020,
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Search & Filter Row ───────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: controller.searchOrders,
                        decoration: InputDecoration(
                          hintText: 'Search orders, customers or products...',
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
                                    controller.searchOrders('');
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
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: ColorsValue.primary,
                              width: 1.5,
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
                const SizedBox(height: 10),

                /// Order List
                Expanded(
                  child: controller.isFetchingOrders
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: ColorsValue.primary,
                          ),
                        )
                      : controller.filteredOrders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 64,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No orders found.',
                                style: Styles.txtGreyColorW40014,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: controller.filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = controller.filteredOrders[index];
                            return Card(
                              elevation: 1,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                onTap: () {
                                  if (order.id != null) {
                                    controller.fetchOrderDetails(order.id!);
                                    _showOrderDetailsDialog(
                                      context,
                                      controller,
                                      homeController,
                                    );
                                  }
                                },
                                leading: CircleAvatar(
                                  backgroundColor: ColorsValue.primary
                                      .withValues(alpha: 0.1),
                                  child: const Icon(
                                    Icons.shopping_bag_outlined,
                                    color: ColorsValue.primary,
                                  ),
                                ),
                                title: Text(
                                  'Order: ${order.orderno}',
                                  style: Styles.txtBlackColorW60014,
                                ),
                                subtitle: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 4.0,
                                              ),
                                              child: Text(
                                                'Date: ${order.createdAt?.split('T').first ?? ''}',
                                                style:
                                                    Styles.txtGreyColorW40012,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Delivery Date: ${order.deliverydate?.split('T').first ?? "N/A"}',
                                              style: Styles.txtGreyColorW40012,
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 4.0,
                                              ),
                                              child: Text(
                                                'Status: ${order.status ?? ''}',
                                                style:
                                                    Styles.txtGreyColorW40012,
                                              ),
                                            ),
                                            // if (RoleUtils.isAdmin(
                                            //   homeController.roleName,
                                            // )) ...[
                                            //   const SizedBox(height: 4),
                                            //   PopupMenuButton<String>(
                                            //     padding: EdgeInsets.zero,
                                            //     icon: const Icon(
                                            //       Icons
                                            //           .published_with_changes_outlined,
                                            //       color: ColorsValue.primary,
                                            //       size: 20,
                                            //     ),
                                            //     onSelected: (String newStatus) {
                                            //       if (order.id != null) {
                                            //         controller
                                            //             .changeOrderStatus(
                                            //               order.id!,
                                            //               newStatus,
                                            //               closeDialog: false,
                                            //             );
                                            //       }
                                            //     },
                                            //     itemBuilder: (context) => [
                                            //       const PopupMenuItem(
                                            //         value: 'accept',
                                            //         child: Row(
                                            //           children: [
                                            //             Icon(
                                            //               Icons
                                            //                   .check_circle_outline,
                                            //               color: Colors.green,
                                            //               size: 18,
                                            //             ),
                                            //             SizedBox(width: 8),
                                            //             Text('Accept'),
                                            //           ],
                                            //         ),
                                            //       ),
                                            //       const PopupMenuItem(
                                            //         value: 'reject',
                                            //         child: Row(
                                            //           children: [
                                            //             Icon(
                                            //               Icons.cancel_outlined,
                                            //               color: Colors.red,
                                            //               size: 18,
                                            //             ),
                                            //             SizedBox(width: 8),
                                            //             Text('Reject'),
                                            //           ],
                                            //         ),
                                            //       ),
                                            //       const PopupMenuItem(
                                            //         value: 'delivered',
                                            //         child: Row(
                                            //           children: [
                                            //             Icon(
                                            //               Icons
                                            //                   .local_shipping_outlined,
                                            //               color: Colors.blue,
                                            //               size: 18,
                                            //             ),
                                            //             SizedBox(width: 8),
                                            //             Text('Delivered'),
                                            //           ],
                                            //         ),
                                            //       ),
                                            //       const PopupMenuItem(
                                            //         value: 'pending',
                                            //         child: Row(
                                            //           children: [
                                            //             Icon(
                                            //               Icons.hourglass_empty,
                                            //               color: Colors.orange,
                                            //               size: 18,
                                            //             ),
                                            //             SizedBox(width: 8),
                                            //             Text('Pending'),
                                            //           ],
                                            //         ),
                                            //       ),
                                            //     ],
                                            //   ),
                                            // ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              if (Get.isSnackbarOpen) await Get.closeCurrentSnackbar();
              // Reset order state (clear cart/fields) and pre-select customer
              controller.resetOrderFlow();
              Get.to(() => NewOrderScreen(controller: controller));
            },
            backgroundColor: ColorsValue.primary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Create Order',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Filter Bottom Sheet ──────────────────────────────────────────────────
  void _showFilterBottomSheet(
    BuildContext context,
    OrdersController controller,
  ) {
    DateTime? tempDateFrom = controller.filterDateFrom;
    DateTime? tempDateTo = controller.filterDateTo;
    DateTime? tempDeliveryDateFrom = controller.filterDeliveryDateFrom;
    DateTime? tempDeliveryDateTo = controller.filterDeliveryDateTo;
    String? tempStatus = controller.filterStatus;
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
                  // Handle bar
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

                  // ── Date (Created At) Range ─────────────────────────────
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

                  // ── Delivery Date Range ─────────────────────────────────
                  Text('Delivery Date', style: Styles.txtBlackColorW60014),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => pickDate(
                            initialDate: tempDeliveryDateFrom,
                            onPicked: (d) => tempDeliveryDateFrom = d,
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
                                  Icons.event,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  tempDeliveryDateFrom != null
                                      ? formatDate(tempDeliveryDateFrom!)
                                      : 'From',
                                  style: TextStyle(
                                    color: tempDeliveryDateFrom != null
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
                            initialDate: tempDeliveryDateTo,
                            onPicked: (d) => tempDeliveryDateTo = d,
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
                                  Icons.event,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  tempDeliveryDateTo != null
                                      ? formatDate(tempDeliveryDateTo!)
                                      : 'To',
                                  style: TextStyle(
                                    color: tempDeliveryDateTo != null
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

                  // ── Status Dropdown ─────────────────────────────────────
                  DropdownButtonFormField<String>(
                    initialValue: tempStatus,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.flag_outlined),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('All Statuses'),
                      ),
                      ...controller.availableStatuses.map(
                        (status) => DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      setSheetState(() => tempStatus = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Distributor Dropdown (Admin only) ───────────────────
                  if (controller.isAdmin) ...[
                    DropdownButtonFormField<String>(
                      initialValue: tempDistributorId,
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
                              _searchController.clear();
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
                              deliveryDateFrom: tempDeliveryDateFrom,
                              deliveryDateTo: tempDeliveryDateTo,
                              status: tempStatus,
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

/// --- New Order Placement Flow ---

class NewOrderScreen extends StatefulWidget {
  final OrdersController controller;
  const NewOrderScreen({super.key, required this.controller});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Trigger load when within 200px of the bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      widget.controller.loadMoreProducts();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrdersController>(
      init: widget.controller,
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.bgMain,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black87),
            title: Text(
              'Place Distributor Order',
              style: Styles.txtBlackColorW70020,
            ),
          ),
          body: Column(
            children: [
              // ── Search Bar ──────────────────────────────────────────────
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: TextField(
                  controller: controller.searchController,
                  onChanged: controller.onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search products by name, category...',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: ColorsValue.primary,
                    ),
                    suffixIcon: controller.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              controller.searchController.clear();
                              controller.onSearchChanged('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: ColorsValue.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Product List ─────────────────────────────────────────────
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (controller.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: ColorsValue.primary,
                        ),
                      );
                    }

                    final products = controller.displayProducts;
                    if (products.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 64,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              controller.searchQuery.isNotEmpty
                                  ? 'No products match "${controller.searchQuery}"'
                                  : 'No products found.',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    // +1 for bottom loader row
                    final itemCount =
                        products.length + (controller.isLoadingMore ? 1 : 0);

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: itemCount,
                      itemBuilder: (context, index) {
                        // Last item = loading spinner
                        if (index == products.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: ColorsValue.primary,
                              ),
                            ),
                          );
                        }
                        return ProductCard(
                          controller: controller,
                          item: products[index],
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
                            'View Cart (${controller.cartCount})',
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
}

class ProductCard extends StatefulWidget {
  final OrdersController controller;
  final ProductItem item;

  const ProductCard({super.key, required this.controller, required this.item});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late TextEditingController _qtyController;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(text: '${widget.item.quantity}');

    // Default unit fallback logic
    final String defaultUnit = widget.item.unit.replaceAll("per ", "").trim();
    final currentUnit =
        (widget.item.selectedUnit != null &&
            widget.item.selectedUnit!.isNotEmpty)
        ? widget.item.selectedUnit
        : (defaultUnit != "-" ? defaultUnit : "");
    widget.item.selectedUnit = currentUnit;
  }

  @override
  void didUpdateWidget(covariant ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync external updates (e.g. cart cleared)
    final targetQtyText = '${widget.item.quantity}';
    if (_qtyController.text != targetQtyText &&
        !FocusScope.of(context).hasFocus) {
      _qtyController.text = targetQtyText;
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  List<DropdownMenuItem<String>> _buildDropdownItems() {
    final List<String> uniqueNames = [];

    // Add units fetched from API
    for (var u in widget.controller.units) {
      if (u.name != null && u.name!.isNotEmpty) {
        final name = u.name!.trim();
        if (!uniqueNames.contains(name)) {
          uniqueNames.add(name);
        }
      }
    }

    // Ensure the current selected unit is in the items to avoid dropdown assertion crash
    final current = widget.item.selectedUnit?.trim() ?? "";
    if (current.isNotEmpty && !uniqueNames.contains(current)) {
      uniqueNames.add(current);
    }

    return uniqueNames.map((name) {
      return DropdownMenuItem<String>(
        value: name,
        child: Text(name, style: Styles.txtBlackColorW60014),
      );
    }).toList();
  }

  void _showCreateUnitDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('Create New Unit'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Enter unit name (e.g. LITER, BAG, BOX)',
            labelText: 'Unit Name',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                Utility.showMessage(
                  'Please enter a unit name',
                  MessageType.error,
                  null,
                  '',
                );
                return;
              }
              Get.back(); // close dialog

              Utility.showLoader();
              final success = await Get.find<Repository>().createUnitApi(
                name: name,
                isLoading: false,
              );
              Utility.closeDialog();

              if (success) {
                Utility.showMessage(
                  'Unit created successfully',
                  MessageType.success,
                  null,
                  '',
                );
                await widget.controller.fetchUnits();
                setState(() {
                  widget.item.selectedUnit = name;
                });
                widget.controller.update();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDealer = RoleUtils.isDealer(
      Get.find<HomeController>().roleName,
    );
    final bool isUser = RoleUtils.isUser(Get.find<HomeController>().roleName);
    final bool isAdmin = RoleUtils.isAdmin(Get.find<HomeController>().roleName);
    final bool isInCart = widget.item.quantity > 0;

    return Card(
      elevation: isInCart ? 3 : 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isInCart ? ColorsValue.primary : Colors.transparent,
          width: isInCart ? 1.5 : 0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Icon Placeholder
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      widget.item.emoji,
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                /// Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.item.name, style: Styles.txtBlackColorW60014),
                      const SizedBox(height: 4),
                      Text(
                        widget.item.category,
                        style: Styles.txtGreyColorW40012,
                      ),
                      const SizedBox(height: 4),
                      if (isAdmin || isDealer || isUser) ...[
                        Text(
                          widget.item.alternateunitid?.name ?? "",
                          style: Styles.txtGreyColorW40012,
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        widget.item.description,
                        style: Styles.txtGreyColorW40012,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (isAdmin || isUser) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Purchase :-  ₹${widget.item.purchaseprice ?? 0}',
                              style: Styles.txtBlackColorW70014.copyWith(
                                color: ColorsValue.primary,
                              ),
                            ),
                            Text(
                              'Sale :- ₹${widget.item.saleprice ?? 0}',
                              style: Styles.txtBlackColorW70014.copyWith(
                                color: ColorsValue.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (!widget.controller.isDealerRole) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Available Qty: ${widget.item.qty ?? 0}',
                          style: Styles.txtGreyColorW40012,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _qtyController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter Qty',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter quantity';
                      }
                      if (int.tryParse(val.trim()) == null) {
                        return 'Please enter a valid numeric quantity';
                      }
                      return null;
                    },
                    onChanged: (val) {
                      final parsed = int.tryParse(val.trim()) ?? 0;
                      widget.item.quantity = parsed;
                      widget.controller.update();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: Text(
                          'Choose a unit',
                          style: Styles.txtGreyColorW40014,
                        ),
                        value:
                            widget.item.selectedUnit?.isNotEmpty == true &&
                                _buildDropdownItems().any(
                                  (item) =>
                                      item.value == widget.item.selectedUnit,
                                )
                            ? widget.item.selectedUnit
                            : null,
                        items: [
                          ..._buildDropdownItems(),
                          const DropdownMenuItem<String>(
                            value: 'create_new_unit',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.add_circle_outline,
                                  color: ColorsValue.primary,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Create New Unit',
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
                          if (val == 'create_new_unit') {
                            _showCreateUnitDialog(context);
                          } else if (val != null) {
                            widget.item.selectedUnit = val;
                            widget.controller.update();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _showCartBottomSheet(
  BuildContext context,
  OrdersController controller,
) async {
  if (Get.isSnackbarOpen) await Get.closeCurrentSnackbar();
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
                if (!controller.isDealerRole) ...[
                  Builder(
                    builder: (context) {
                      final Map<String, dynamic> uniqueDistributors = {};
                      for (var dist in controller.distributors) {
                        if (dist.id.isNotEmpty) {
                          uniqueDistributors[dist.id] = dist;
                        }
                      }
                      final String? selectedValue =
                          uniqueDistributors.containsKey(
                            controller.selectedDistributorId,
                          )
                          ? controller.selectedDistributorId
                          : null;

                      final selectedDistText = selectedValue != null
                          ? ((uniqueDistributors[selectedValue].name != null &&
                                    uniqueDistributors[selectedValue]
                                        .name
                                        .isNotEmpty)
                                ? uniqueDistributors[selectedValue].name
                                : 'Unknown Dealer')
                          : 'Select Dealer';

                      return InkWell(
                        onTap: () {
                          Get.dialog(
                            _DealerSearchDialog(
                              controller: controller,
                              distributors: uniqueDistributors.values.toList(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Select Dealer',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.storefront_outlined),
                            suffixIcon: const Icon(Icons.arrow_drop_down),
                          ),
                          child: Text(
                            selectedDistText,
                            style: TextStyle(
                              fontSize: 16,
                              color: selectedValue != null
                                  ? ColorsValue.txtBlackColor
                                  : Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
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

Widget _buildDistributorRow(IconData icon, String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 14, color: Colors.grey.shade600),
      const SizedBox(width: 6),
      Text(
        '$label: ',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade700,
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

void _showOrderDetailsDialog(
  BuildContext context,
  OrdersController controller,
  HomeController homeController,
) async {
  if (Get.isSnackbarOpen) await Get.closeCurrentSnackbar();
  Get.bottomSheet(
    DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: GetBuilder<OrdersController>(
          builder: (controller) {
            if (controller.isFetchingOrderDetails ||
                controller.selectedOrderDetails == null) {
              return const Center(
                child: CircularProgressIndicator(color: ColorsValue.primary),
              );
            }

            final details = controller.selectedOrderDetails!.data;
            if (details == null) {
              return const Center(child: Text('No details available.'));
            }

            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Title
                Text(
                  'Order Details',
                  style: Styles.txtBlackColorW70020,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Order meta
                Text(
                  'Order ID: ${details.orderno ?? "-"}',
                  style: Styles.txtBlackColorW60014,
                ),
                const SizedBox(height: 4),
                Text(
                  'Status: ${details.status ?? "Pending"}',
                  style: Styles.txtBlackColorW60014.copyWith(
                    color: ColorsValue.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Date: ${details.createdAt?.split('T').first ?? ''}',
                  style: Styles.txtGreyColorW40012,
                ),
                const SizedBox(height: 4),
                Text(
                  'Delivery Date: ${details.deliverydate?.split('T').first ?? "N/A"}',
                  style: Styles.txtGreyColorW40012,
                ),
                const SizedBox(height: 16),

                // Distributor Info
                if (details.distributorid != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ColorsValue.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ColorsValue.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person_pin_circle_outlined,
                              size: 16,
                              color: ColorsValue.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Distributor Info',
                              style: Styles.txtBlackColorW60014.copyWith(
                                color: ColorsValue.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (details.distributorid!.name != null)
                          _buildDistributorRow(
                            Icons.badge_outlined,
                            'Name',
                            details.distributorid!.name!,
                          ),
                        if (details.distributorid!.email != null) ...[
                          const SizedBox(height: 4),
                          _buildDistributorRow(
                            Icons.email_outlined,
                            'Email',
                            details.distributorid!.email!,
                          ),
                        ],
                        if (details.distributorid!.mobile != null) ...[
                          const SizedBox(height: 4),
                          _buildDistributorRow(
                            Icons.phone_outlined,
                            'Mobile',
                            details.distributorid!.mobile!,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                const Divider(height: 24),
                Text(
                  'Items (${details.items?.length ?? 0}):',
                  style: Styles.txtBlackColorW60014,
                ),
                const SizedBox(height: 8),

                // Items — rendered inline, no nested ListView
                ...List.generate(details.items?.length ?? 0, (idx) {
                  final item = details.items![idx];
                  String pName = 'Unknown Product';
                  String? pUnit;

                  // 1. Resolve unit from the item level (unitid or unit)
                  if (item.unitid is Map) {
                    pUnit = item.unitid['name']?.toString();
                  } else if (item.unitid is String) {
                    pUnit = item.unitid;
                  } else if (item.unit != null && item.unit!.isNotEmpty) {
                    pUnit = item.unit;
                  }

                  // 2. Resolve product name and try productid level unit if not found
                  if (item.productid is Map) {
                    pName =
                        item.productid['name'] ??
                        item.productid['_id'] ??
                        'Unknown Product';
                    if (pUnit == null || pUnit.isEmpty) {
                      final unitData =
                          item.productid['unitid'] ?? item.productid['unit'];
                      if (unitData is Map) {
                        pUnit = unitData['name']?.toString();
                      } else if (unitData is String) {
                        pUnit = unitData;
                      }
                    }
                  } else if (item.productid != null) {
                    final localMatch = controller.allProducts.firstWhereOrNull(
                      (p) => p.id == item.productid,
                    );
                    pName = localMatch?.name ?? item.productid.toString();
                    if (pUnit == null || pUnit.isEmpty) {
                      pUnit = localMatch != null
                          ? localMatch.unit.replaceAll("per ", "")
                          : null;
                    }
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
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
                              child: Icon(
                                Icons.inventory_2_outlined,
                                color: ColorsValue.primary,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(pName, style: Styles.txtBlackColorW60014),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      'Qty: ${item.quantity}',
                                      style: Styles.txtGreyColorW40012,
                                    ),
                                    if (pUnit != null && pUnit.isNotEmpty) ...[
                                      const SizedBox(width: 12),
                                      Text(
                                        'Unit: $pUnit',
                                        style: Styles.txtGreyColorW40012,
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // Action buttons
                if (!RoleUtils.isAdmin(homeController.roleName))
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            controller.populateOrderForEdit(details);
                            Get.back();
                            Get.to(
                              () => NewOrderScreen(controller: controller),
                            );
                          },
                          icon: const Icon(
                            Icons.edit,
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
                            backgroundColor: ColorsValue.primary,
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
                                  'Are you sure you want to delete this order?',
                              onConfirm: () {
                                if (details.id != null) {
                                  controller.deleteOrder(details.id!);
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
                            backgroundColor: Colors.red.shade400,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                if (RoleUtils.isAdmin(homeController.roleName))
                  Row(
                    children: [
                      Expanded(
                        child: PopupMenuButton<String>(
                          onSelected: (String newStatus) {
                            if (details.id != null) {
                              controller.changeOrderStatus(
                                details.id!,
                                newStatus,
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'accept',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.green,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Accept'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'reject',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.cancel_outlined,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Reject'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delivered',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.local_shipping_outlined,
                                    color: Colors.blue,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Delivered'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'pending',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.hourglass_empty,
                                    color: Colors.orange,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Pending'),
                                ],
                              ),
                            ),
                          ],
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: ColorsValue.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.published_with_changes_outlined,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Change Status',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    ),
    isScrollControlled: true,
  );
}

class _DealerSearchDialog extends StatefulWidget {
  final OrdersController controller;
  final List<dynamic> distributors;

  const _DealerSearchDialog({
    required this.controller,
    required this.distributors,
  });

  @override
  State<_DealerSearchDialog> createState() => _DealerSearchDialogState();
}

class _DealerSearchDialogState extends State<_DealerSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.distributors.where((dist) {
      final name = (dist.name ?? '').toLowerCase();
      return name.contains(_searchQuery.toLowerCase().trim());
    }).toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Select Dealer', style: Styles.txtBlackColorW70018),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search dealer...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text('No dealers found'))
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final dist = filtered[index];
                        final name = (dist.name != null && dist.name.isNotEmpty)
                            ? dist.name
                            : 'Unknown Dealer';
                        final isSelected =
                            widget.controller.selectedDistributorId == dist.id;
                        return ListTile(
                          title: Text(
                            name,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? ColorsValue.primary
                                  : ColorsValue.txtBlackColor,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: ColorsValue.primary,
                                )
                              : null,
                          onTap: () {
                            widget.controller.selectedDistributorId = dist.id;
                            widget.controller.update();
                            Get.back();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
