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

  final TextEditingController titleController = TextEditingController();
  final TextEditingController deliveryDateController = TextEditingController();
  final TextEditingController feedbackController = TextEditingController();

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

  Future<void> fetchProducts() async {
    isLoading = true;
    update();
    GetAllProductModel? response = await Get.find<Repository>()
        .getProductListApi(isLoading: false);
    if (response != null && (response.data?.docs?.isNotEmpty ?? false)) {
      allProducts = response.data!.docs!
          .map(
            (doc) => ProductItem(
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
            ),
          )
          .toList();
    }
    isLoading = false;
    update();
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
    if (selectedCategory == 'All') return allProducts;
    return allProducts.where((p) => p.category == selectedCategory).toList();
  }

  void selectCategory(String cat) {
    selectedCategory = cat;
    update();
  }

  void incrementQuantity(String id) {
    final idx = allProducts.indexWhere((p) => p.id == id);
    if (idx != -1) {
      final product = allProducts[idx];
      if (product.qty == null || product.quantity < product.qty!) {
        product.quantity++;
        update();
      } else {
        Get.snackbar(
          'Limit Reached',
          'Only ${product.qty} items available in stock',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
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
    titleController.clear();
    deliveryDateController.clear();
    feedbackController.clear();
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
    feedbackController.text = details.feedback ?? '';

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
    if (selectedCustomerId.isEmpty) {
      Utility.errorMessage('Please select a customer first');
      return;
    }

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
      customerid: selectedCustomerId,
      items: itemsPayload,
      totalamount: cartTotal,
      deliverydate: deliveryDateController.text.trim(),
      feedback: feedbackController.text.trim(),
      isLoading: true,
    );
    isPlacingOrder = false;
    update();

    if (response != null && response.isSuccess == true) {
      Utility.closeDialog();
      for (var p in allProducts) {
        p.quantity = 0;
      }
      historyCustomerId = selectedCustomerId;
      fetchOrderHistory(historyCustomerId!);
      selectedCustomerId = '';
      editingOrderId = null; // Clear edit mode after success
      titleController.clear();
      deliveryDateController.clear();
      feedbackController.clear();
      update();
      Get.back();
      Get.back();
      Get.snackbar(
        'Success',
        'Order placed successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
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
      Get.back(); // Close details dialog
      if (historyCustomerId != null) {
        fetchOrderHistory(historyCustomerId!);
      }
      Get.snackbar(
        'Deleted',
        'Order deleted successfully',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } else {
      Utility.errorMessage('Failed to delete order');
    }
  }
}
