import 'dart:async';
import 'package:agro_app/app/utils/utility.dart';
import 'package:agro_app/domain/domain.dart';
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
    this.qty,
    this.quantity = 0,
  });
}

class OrdersController extends GetxController {
  String selectedCategory = 'All';
  List<ProductItem> allProducts = [];
  bool isLoading = false;

  List<GetAllCustomerDoc> customers = [];
  String selectedCustomerId = '';
  bool isPlacingOrder = false;
  String? editingOrderId;

  List<GetAllOrderDoc> customerOrders = [];
  bool isFetchingOrders = false;

  GetOneOrderModel? selectedOrderDetails;
  bool isFetchingOrderDetails = false;

  String? historyCustomerId;

  // Search
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();
  Timer? _searchDebounce;

  // Pagination state
  int _currentPage = 1;
  bool _hasMoreProducts = true;
  bool isLoadingMore = false;
  static const int _pageSize = 10;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController deliveryDateController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
    fetchCustomers();
    fetchAllOrders();
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
      allProducts[idx].quantity++;
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
    editingOrderId = null; // Clear edit mode
    searchQuery = '';
    searchController.clear();
    titleController.clear();
    deliveryDateController.clear();
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

    titleController.text = details.orderno ?? '';
    deliveryDateController.text = details.deliverydate?.split('T').first ?? '';

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

    final itemsPayload = cartItems
        .map(
          (p) => {
            "productid": p.id,
            "quantity": p.quantity,
            "price": p.rawPrice,
          },
        )
        .toList();

    isPlacingOrder = true;
    update();
    var response = await Get.find<Repository>().createOrderApi(
      orderid: editingOrderId, // Use the database ID if editing
      items: itemsPayload,
      totalamount: cartTotal,
      deliverydate: deliveryDateController.text.trim(),
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
      editingOrderId = null; // Clear edit mode after success
      titleController.clear();
      deliveryDateController.clear();
      update();
      if (Get.isSnackbarOpen) await Get.closeCurrentSnackbar();
      Get.back();
      Get.back();
      Utility.snacBar(
        'Order placed successfully!',
        Colors.green,
      );
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
      Utility.snacBar(
        'Order deleted successfully',
        Colors.green,
      );
    } else {
      Utility.errorMessage('Failed to delete order');
    }
  }
}
