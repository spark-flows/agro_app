import 'dart:async';
import 'dart:convert';
import 'package:agro_app/app/utils/utility.dart';
import 'package:agro_app/domain/domain.dart';
import 'package:agro_app/domain/models/get_all_users_model.dart' as users_model;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductItem {
  final String id;
  final String name;
  final String description;
  final String price;
  final num rawPrice;
  final String unit;
  final String category;
  final String emoji;
  final Color gradStart;
  final Color gradEnd;
  final int? qty;
  int quantity;
  String? selectedUnit;
  Alternateunitid? alternateunitid;
  num? purchaseprice;
  num? saleprice;

  ProductItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.rawPrice,
    required this.unit,
    required this.category,
    required this.emoji,
    required this.gradStart,
    required this.gradEnd,
    this.alternateunitid,
    this.purchaseprice,
    this.saleprice,
    this.qty,
    this.quantity = 0,
    this.selectedUnit,
  });
}

class OrdersController extends GetxController {
  String selectedCategory = 'All';
  List<ProductItem> allProducts = [];
  bool isLoading = false;

  List<GetAllCustomerDoc> customers = [];
  String selectedCustomerId = '';
  String selectedDistributorId = '';
  String userRole = '';
  bool isPlacingOrder = false;
  String? editingOrderId;

  bool get isDealerRole =>
      userRole.toLowerCase().trim() == 'dealer' ||
      userRole.toLowerCase().trim() == 'distributor';

  List<GetAllOrderDoc> customerOrders = [];
  bool isFetchingOrders = false;

  GetOneOrderModel? selectedOrderDetails;
  bool isFetchingOrderDetails = false;

  String? historyCustomerId;

  // Search
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();
  Timer? _searchDebounce;

  String orderSearchQuery = '';

  void searchOrders(String query) {
    orderSearchQuery = query;
    update();
  }

  // Pagination state
  int _currentPage = 1;
  bool _hasMoreProducts = true;
  bool isLoadingMore = false;
  static const int _pageSize = 10;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController deliveryDateController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();

  // ── Filter state ───────────────────────────────────────────────────────────
  DateTime? filterDateFrom;
  DateTime? filterDateTo;
  DateTime? filterDeliveryDateFrom;
  DateTime? filterDeliveryDateTo;
  String? filterStatus;
  String? filterDistributorId;

  bool isAdmin = false;
  List<users_model.Doc> distributors = [];

  bool get isFilterActive =>
      filterDateFrom != null ||
      filterDateTo != null ||
      filterDeliveryDateFrom != null ||
      filterDeliveryDateTo != null ||
      filterStatus != null ||
      filterDistributorId != null;

  List<GetAllOrderDoc> get filteredOrders {
    List<GetAllOrderDoc> result = List.from(customerOrders);

    // Filter by created date range
    if (filterDateFrom != null) {
      result = result.where((o) {
        if (o.createdAt == null) return false;
        final date = DateTime.tryParse(o.createdAt!);
        if (date == null) return false;
        return !date.isBefore(
          DateTime(
            filterDateFrom!.year,
            filterDateFrom!.month,
            filterDateFrom!.day,
          ),
        );
      }).toList();
    }
    if (filterDateTo != null) {
      result = result.where((o) {
        if (o.createdAt == null) return false;
        final date = DateTime.tryParse(o.createdAt!);
        if (date == null) return false;
        return !date.isAfter(
          DateTime(
            filterDateTo!.year,
            filterDateTo!.month,
            filterDateTo!.day,
            23,
            59,
            59,
          ),
        );
      }).toList();
    }

    // Filter by delivery date range
    if (filterDeliveryDateFrom != null) {
      result = result.where((o) {
        if (o.deliverydate == null) return false;
        final date = DateTime.tryParse(o.deliverydate.toString());
        if (date == null) return false;
        return !date.isBefore(
          DateTime(
            filterDeliveryDateFrom!.year,
            filterDeliveryDateFrom!.month,
            filterDeliveryDateFrom!.day,
          ),
        );
      }).toList();
    }
    if (filterDeliveryDateTo != null) {
      result = result.where((o) {
        if (o.deliverydate == null) return false;
        final date = DateTime.tryParse(o.deliverydate.toString());
        if (date == null) return false;
        return !date.isAfter(
          DateTime(
            filterDeliveryDateTo!.year,
            filterDeliveryDateTo!.month,
            filterDeliveryDateTo!.day,
            23,
            59,
            59,
          ),
        );
      }).toList();
    }

    // Filter by status
    if (filterStatus != null && filterStatus!.isNotEmpty) {
      result = result
          .where((o) => o.status?.toLowerCase() == filterStatus!.toLowerCase())
          .toList();
    }

    // Filter by distributor
    if (filterDistributorId != null && filterDistributorId!.isNotEmpty) {
      result = result
          .where((o) => o.distributorid?.id == filterDistributorId)
          .toList();
    }

    // Filter by search query (order number, customer name, distributor name, product name)
    if (orderSearchQuery.isNotEmpty) {
      final q = orderSearchQuery.toLowerCase();
      result = result.where((o) {
        if (o.orderno != null && o.orderno!.toLowerCase().contains(q)) {
          return true;
        }
        if (o.customerid?.name != null &&
            o.customerid!.name!.toLowerCase().contains(q)) {
          return true;
        }
        if (o.distributorid?.name != null &&
            o.distributorid!.name!.toLowerCase().contains(q)) {
          return true;
        }
        if (o.items != null) {
          for (var item in o.items!) {
            String pName = '';
            if (item.productid is Map) {
              final prodMap = item.productid as Map;
              pName = prodMap['name']?.toString() ?? '';
            } else if (item.productid != null) {
              final localMatch = allProducts.firstWhereOrNull(
                (p) => p.id == item.productid,
              );
              pName = localMatch?.name ?? '';
            }
            if (pName.toLowerCase().contains(q)) {
              return true;
            }
          }
        }
        return false;
      }).toList();
    }

    return result;
  }

  void applyFilters({
    DateTime? dateFrom,
    DateTime? dateTo,
    DateTime? deliveryDateFrom,
    DateTime? deliveryDateTo,
    String? status,
    String? distributorId,
  }) {
    filterDateFrom = dateFrom;
    filterDateTo = dateTo;
    filterDeliveryDateFrom = deliveryDateFrom;
    filterDeliveryDateTo = deliveryDateTo;
    filterStatus = status;
    filterDistributorId = distributorId;
    update();
  }

  void clearFilters() {
    filterDateFrom = null;
    filterDateTo = null;
    filterDeliveryDateFrom = null;
    filterDeliveryDateTo = null;
    filterStatus = null;
    filterDistributorId = null;
    orderSearchQuery = '';
    update();
  }

  /// Unique statuses from current orders for filter dropdown
  List<String> get availableStatuses {
    final statuses = customerOrders
        .where((o) => o.status != null && o.status!.isNotEmpty)
        .map((o) => o.status!)
        .toSet()
        .toList();
    statuses.sort();
    return statuses;
  }

  List<GetAllUnitDatum> units = [];
  bool isLoadingUnits = false;

  Future<void> fetchUnits() async {
    try {
      isLoadingUnits = true;
      update();
      final response = await Get.find<Repository>().getUnitListApi();
      if (response != null && response.data != null) {
        units = response.data!;
      }
    } catch (e) {
      debugPrint('[OrdersController] fetchUnits error: $e');
    } finally {
      isLoadingUnits = false;
      update();
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadRole();
    fetchProducts();
    fetchCustomers();
    fetchAllOrders();
    fetchUnits();
  }

  Future<void> _loadRole() async {
    String role = await Utility.getSecureValue(LocalKeys.roleName);
    if (role.isEmpty) {
      final profileJson = await Utility.getSecureValue(LocalKeys.profileData);
      if (profileJson.isNotEmpty) {
        try {
          final decoded = json.decode(profileJson);
          role =
              decoded['roleid']?['rolename']?.toString() ??
              decoded['rolename']?.toString() ??
              '';
        } catch (_) {}
      }
    }
    userRole = role;
    isAdmin = RoleUtils.isAdmin(role);
    update();

    if (!isDealerRole || isAdmin) {
      fetchDistributors();
    }
  }

  Future<void> fetchDistributors() async {
    try {
      var response = await Get.find<Repository>().getUsersListApi(
        page: 1,
        limit: 100,
        type: 'dealer',
        isLoading: false,
      );
      if (response != null && response.isSuccess) {
        distributors = response.data.docs;
        update();
      }
    } catch (e) {
      debugPrint('[Orders] fetchDistributors error: $e');
    }
  }

  Future<void> fetchAllOrders() async {
    isFetchingOrders = true;
    update();
    var response = await Get.find<Repository>().getOrderListApi(
      isLoading: false,
    );
    if (response != null && response.data?.docs != null) {
      customerOrders = response.data!.docs!;
    } else {
      customerOrders.clear();
    }
    isFetchingOrders = false;
    update();
  }

  Future<void> fetchCustomers() async {
    var response = await Get.find<Repository>().getCustomerListApi(
      isLoading: false,
    );
    if (response != null && response.data?.docs != null) {
      customers = response.data!.docs!;
      update();
    }
  }

  Future<void> fetchOrderHistory(String customerId) async {
    if (customerId.isEmpty) return;
    isFetchingOrders = true;
    update();
    var response = await Get.find<Repository>().getOrderListApi(
      customerid: customerId,
      isLoading: false,
    );
    if (response != null && response.data?.docs != null) {
      customerOrders = response.data!.docs!;
    } else {
      customerOrders.clear();
    }
    isFetchingOrders = false;
    update();
  }

  Future<void> fetchOrderDetails(String orderId) async {
    isFetchingOrderDetails = true;
    selectedOrderDetails = null;
    update();
    var response = await Get.find<Repository>().getOneOrderApi(
      orderid: orderId,
      isLoading: true,
    );
    if (response != null) {
      selectedOrderDetails = response;
    }
    isFetchingOrderDetails = false;
    update();
  }

  /// Loads the first page (10 items). Call on screen open.
  Future<void> fetchProducts() async {
    isLoading = true;
    allProducts = [];
    _currentPage = 1;
    _hasMoreProducts = true;
    update();
    await _loadPage();
    isLoading = false;
    update();
  }

  /// Loads the next page. Called when the user scrolls to the bottom.
  Future<void> loadMoreProducts() async {
    if (isLoadingMore || !_hasMoreProducts) return;
    isLoadingMore = true;
    update();
    await _loadPage();
    isLoadingMore = false;
    update();
  }

  Future<void> _loadPage() async {
    final response = await Get.find<Repository>().getProductListApi(
      page: _currentPage,
      limit: _pageSize,
      search: searchQuery,
      isLoading: false,
    );
    if (response == null || response.data == null) {
      _hasMoreProducts = false;
      return;
    }
    final docs = response.data!.docs ?? [];
    for (var doc in docs) {
      allProducts.add(_buildProductItem(doc));
    }
    _hasMoreProducts = response.data!.hasNextPage == true;
    _currentPage++;
  }

  ProductItem _buildProductItem(GetAllProductDoc doc) {
    final defaultUnitName = doc.unit?.name ?? doc.unit?.id;
    return ProductItem(
      id: doc.id ?? '',
      name: doc.name ?? '',
      description: doc.description ?? '',
      price: '₹${doc.price ?? 0}',
      rawPrice: (doc.price ?? 0).toDouble(),
      unit: 'per ${doc.unit?.name ?? "-"}',
      category: doc.categoryid?.name ?? 'Others',
      emoji: '📦',
      gradStart: const Color(0xFF16A34A),
      gradEnd: const Color(0xFF4ADE80),
      qty: doc.qty,
      selectedUnit: defaultUnitName,
      alternateunitid: doc.alternateunitid,
      saleprice: doc.saleprice ?? 0,
      purchaseprice: doc.purchaseprice ?? 0,
    );
  }

  final List<String> categories = [
    'All',
    'Fertilizers',
    'Seeds',
    'Pesticides',
    'Equipment',
    'Others',
  ];

  List<ProductItem> get displayProducts {
    // Search is server-side; only apply category filter client-side
    if (selectedCategory == 'All') return allProducts;
    return allProducts.where((p) => p.category == selectedCategory).toList();
  }

  /// Debounced search: waits 400ms after typing stops, then re-fetches from page 1.
  void onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      searchQuery = query;
      fetchProducts(); // re-fetch from page 1 with new search term
    });
  }

  void selectCategory(String cat) {
    selectedCategory = cat;
    update();
  }

  void incrementQuantity(String id) {
    final idx = allProducts.indexWhere((p) => p.id == id);
    if (idx != -1) {
      final product = allProducts[idx];
      product.quantity++;
      update();
    }
  }

  void decrementQuantity(String id) {
    final idx = allProducts.indexWhere((p) => p.id == id);
    if (idx != -1 && allProducts[idx].quantity > 0) {
      allProducts[idx].quantity--;
      update();
    }
  }

  void updateQuantity(String id, int quantity) {
    final idx = allProducts.indexWhere((p) => p.id == id);
    if (idx != -1) {
      allProducts[idx].quantity = quantity >= 0 ? quantity : 0;
      update();
    }
  }

  int get cartCount => allProducts.where((p) => p.quantity > 0).length;
  num get cartTotal => allProducts
      .where((p) => p.quantity > 0)
      .fold(0, (sum, p) => sum + (p.quantity * p.rawPrice));

  void setSelectedCustomerId(String val) {
    selectedCustomerId = val;
    update();
  }

  void resetOrderFlow() {
    for (var p in allProducts) {
      p.quantity = 0;
    }
    selectedCustomerId = historyCustomerId ?? '';
    selectedDistributorId = '';
    editingOrderId = null; // Clear edit mode
    searchQuery = '';
    searchController.clear();
    titleController.clear();
    deliveryDateController.clear();
    remarkController.clear();
    if (!isDealerRole && distributors.isEmpty) {
      fetchDistributors();
    }
    update();
  }

  void populateOrderForEdit(GetOneOrderData details) {
    for (var p in allProducts) {
      p.quantity = 0;
    }

    editingOrderId = details.id; // Store the database ID for updating
    if (details.customerid is Map) {
      historyCustomerId = details.customerid["_id"];
    } else {
      historyCustomerId = details.customerid?.toString();
    }
    selectedCustomerId = historyCustomerId ?? '';

    if (details.distributorid != null) {
      if (details.distributorid is GetOneOrderDistributor) {
        selectedDistributorId = details.distributorid?.id ?? '';
      } else if (details.distributorid is Map) {
        selectedDistributorId =
            (details.distributorid as Map)["_id"]?.toString() ?? '';
      } else {
        selectedDistributorId = details.distributorid.toString();
      }
    }

    titleController.text = details.orderno ?? '';
    deliveryDateController.text = details.deliverydate?.split('T').first ?? '';
    remarkController.text = details.remark ?? '';

    if (details.items != null) {
      for (var item in details.items!) {
        String pId = '';
        if (item.productid is Map) {
          pId = item.productid["_id"];
        } else {
          pId = item.productid.toString();
        }
        final idx = allProducts.indexWhere((p) => p.id == pId);
        if (idx != -1) {
          allProducts[idx].quantity = (item.quantity is num)
              ? item.quantity.toInt()
              : int.tryParse(item.quantity.toString()) ?? 0;
          if (item.unit != null && item.unit.toString().isNotEmpty) {
            allProducts[idx].selectedUnit = item.unit.toString();
          }
        }
      }
    }
    update();
  }

  Future<void> placeOrder() async {
    final cartItems = allProducts.where((p) => p.quantity > 0).toList();
    if (cartItems.isEmpty) {
      Utility.errorMessage('Your cart is empty');
      return;
    }

    if (!isDealerRole && selectedDistributorId.isEmpty) {
      Utility.errorMessage('Please select a dealer');
      return;
    }

    if (deliveryDateController.text.trim().isEmpty) {
      Utility.errorMessage('Please select a delivery date');
      return;
    }

    final itemsPayload = cartItems.map((p) {
      String u = p.selectedUnit ?? p.unit.replaceAll("per ", "").trim();
      if (u == "-") u = "";
      return {
        "productid": p.id,
        "quantity": p.quantity,
        "price": p.rawPrice,
        "unit": u,
      };
    }).toList();

    isPlacingOrder = true;
    update();
    var response = await Get.find<Repository>().createOrderApi(
      orderid: editingOrderId, // Use the database ID if editing
      distributorid: !isDealerRole ? selectedDistributorId : null,
      items: itemsPayload,
      totalamount: cartTotal,
      deliverydate: deliveryDateController.text.trim(),
      remark: remarkController.text.trim(),
      isLoading: true,
    );
    isPlacingOrder = false;
    update();

    if (response != null && response.isSuccess == true) {
      Utility.closeDialog();
      for (var p in allProducts) {
        p.quantity = 0;
      }
      historyCustomerId = selectedCustomerId.isNotEmpty
          ? selectedCustomerId
          : null;
      if (historyCustomerId != null) {
        fetchOrderHistory(historyCustomerId!);
      } else {
        fetchAllOrders();
      }
      selectedCustomerId = '';
      selectedDistributorId = '';
      editingOrderId = null; // Clear edit mode after success
      titleController.clear();
      deliveryDateController.clear();
      remarkController.clear();
      update();
      if (Get.isSnackbarOpen) await Get.closeCurrentSnackbar();
      Get.back();
      Get.back();
      Utility.snacBar('Order placed successfully!', Colors.green);
    } else {
      Utility.errorMessage(response?.message ?? 'Failed to place order');
    }
  }

  Future<void> deleteOrder(String orderId) async {
    bool success = await Get.find<Repository>().deleteOrderApi(
      orderid: orderId,
      isLoading: true,
    );

    if (success) {
      if (Get.isSnackbarOpen) await Get.closeCurrentSnackbar();
      Get.back(); // Close details dialog
      if (historyCustomerId != null && historyCustomerId!.isNotEmpty) {
        fetchOrderHistory(historyCustomerId!);
      } else {
        fetchAllOrders();
      }
      Utility.snacBar('Order deleted successfully', Colors.green);
    } else {
      Utility.errorMessage('Failed to delete order');
    }
  }

  Future<void> changeOrderStatus(
    String orderId,
    String status, {
    bool closeDialog = true,
  }) async {
    Utility.showLoader();
    final success = await Get.find<Repository>().changeOrderStatusApi(
      orderid: orderId,
      status: status,
      isLoading: false,
    );
    Utility.closeLoader();

    if (success) {
      Utility.snacBar('Order status changed successfully', Colors.green);
      if (Get.isSnackbarOpen) await Get.closeCurrentSnackbar();
      if (closeDialog) {
        Get.back(); // Close details dialog
      }
      if (historyCustomerId != null && historyCustomerId!.isNotEmpty) {
        fetchOrderHistory(historyCustomerId!);
      } else {
        fetchAllOrders();
      }
    }
  }
}
