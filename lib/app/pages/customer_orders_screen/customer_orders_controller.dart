import 'dart:convert';
import 'dart:io';

import 'package:agro_app/app/app.dart';
import 'package:agro_app/domain/domain.dart';
import 'package:agro_app/domain/models/get_all_users_model.dart' as users_model;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agro_app/app/pages/home_screen/home_controller.dart';
import 'package:agro_app/domain/services/enum.dart';

class CustomerOrdersController extends GetxController {
  final Repository _repository = Get.find<Repository>();

  List<CustomerOrderDoc> ordersList = [];
  bool isLoading = false;

  List<GetAllCustomerDoc> customersList = [];

  // Used ONLY for the top-bar filter dropdown
  String filterCustomerId = '';

  // ── Filter state ───────────────────────────────────────────────────────────
  DateTime? filterDateFrom;
  DateTime? filterDateTo;
  String? filterDistributorId;

  bool isAdmin = false;
  List<users_model.Doc> distributors = [];

  bool get isFilterActive =>
      filterDateFrom != null ||
      filterDateTo != null ||
      filterDistributorId != null;

  // Used ONLY for the create/edit form
  String selectedCustomerId = '';

  // Form Fields
  File? selectedImage;
  String? existingImageUrl;
  String? editingCustomerOrderId;
  final TextEditingController remark1Controller = TextEditingController();
  final TextEditingController remark2Controller = TextEditingController();
  final TextEditingController remark3Controller = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadRole();
    fetchCustomers();
    fetchAllCustomerOrders();
  }

  Future<void> _loadRole() async {
    try {
      final homeController = Get.find<HomeController>();
      isAdmin = RoleUtils.isAdmin(homeController.roleName);
      print(
        '[CustomerOrders] Resolved isAdmin=$isAdmin from HomeController roleName="${homeController.roleName}"',
      );
    } catch (e) {
      print(
        '[CustomerOrders] Error finding HomeController: $e. Falling back to local storage.',
      );
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
      isAdmin = RoleUtils.isAdmin(role);
    }
    update();

    if (isAdmin) {
      fetchDistributors();
    }
  }

  Future<void> fetchDistributors() async {
    try {
      var response = await _repository.getUsersListApi(
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
      debugPrint('[CustomerOrders] fetchDistributors error: $e');
    }
  }

  List<CustomerOrderDoc> get filteredOrders {
    List<CustomerOrderDoc> result = List.from(ordersList);

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

    // Filter by distributor
    if (filterDistributorId != null && filterDistributorId!.isNotEmpty) {
      result = result.where((o) {
        String distId = '';
        if (o.distributorid is Map) {
          distId =
              o.distributorid['_id']?.toString() ??
              o.distributorid['id']?.toString() ??
              '';
        } else if (o.distributorid != null) {
          distId = o.distributorid.toString();
        }
        print(
          '[FilterCustomerOrder] Comparing order distributor="$distId" with filter="$filterDistributorId"',
        );
        return distId == filterDistributorId;
      }).toList();
    }

    return result;
  }

  void applyFilters({
    DateTime? dateFrom,
    DateTime? dateTo,
    String? distributorId,
  }) {
    filterDateFrom = dateFrom;
    filterDateTo = dateTo;
    filterDistributorId = distributorId;
    update();
  }

  void clearFilters() {
    filterDateFrom = null;
    filterDateTo = null;
    filterDistributorId = null;
    update();
  }

  Future<void> fetchCustomers() async {
    final res = await _repository.getCustomerListApi(isLoading: false);
    if (res != null && res.data != null && res.data!.docs != null) {
      customersList = res.data!.docs!;
      update();
    }
  }

  Future<void> fetchAllCustomerOrders() async {
    isLoading = true;
    update();
    final res = await _repository.getCustomerOrderListApi(isLoading: false);
    if (res != null && res.data != null && res.data!.docs != null) {
      ordersList = res.data!.docs!;
    } else {
      ordersList = [];
    }
    isLoading = false;
    update();
  }

  Future<void> fetchCustomerOrdersByCustomer(String customerId) async {
    isLoading = true;
    update();
    final res = await _repository.getCustomerOrderListApi(
      customerid: customerId,
      isLoading: false,
    );
    if (res != null && res.data != null && res.data!.docs != null) {
      ordersList = res.data!.docs!;
    } else {
      ordersList = [];
    }
    isLoading = false;
    update();
  }

  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      selectedImage = File(image.path);
      update();
    }
  }

  void resetForm() {
    // Only reset form fields — do NOT touch filterCustomerId
    selectedCustomerId = '';
    selectedImage = null;
    existingImageUrl = null;
    editingCustomerOrderId = null;
    remark1Controller.clear();
    remark2Controller.clear();
    remark3Controller.clear();
    update();
  }

  Future<void> editOrder(CustomerOrderDoc order) async {
    editingCustomerOrderId = order.id;

    // order.customerid is a populated model object — extract .id directly
    final custId = order.customerid?.id ?? '';
    // Validate that this ID actually exists in the loaded customers list
    final exists = customersList.any((c) => c.id == custId);
    selectedCustomerId = exists ? custId : '';

    remark1Controller.text = order.remark1 ?? '';
    remark2Controller.text = order.remark2 ?? '';
    remark3Controller.text = order.remark3 ?? '';
    existingImageUrl = order.image;
    selectedImage = null;
    update();

    Utility.showLoader();
    try {
      final fetchedOrder = await _repository.getOneCustomerOrderApi(
        customerorderid: order.id ?? '',
        isLoading: false,
      );
      if (fetchedOrder != null) {
        remark1Controller.text = fetchedOrder.remark1 ?? '';
        remark2Controller.text = fetchedOrder.remark2 ?? '';
        remark3Controller.text = fetchedOrder.remark3 ?? '';
        existingImageUrl = fetchedOrder.image;
        update();
      }
    } catch (e) {
      debugPrint("Error fetching customer order: $e");
    } finally {
      Utility.closeLoader();
    }
  }

  void removeImage() {
    selectedImage = null;
    existingImageUrl = null;
    update();
  }

  Future<void> placeCustomerOrder() async {
    if (selectedCustomerId.isEmpty) {
      Utility.errorMessage('Please select a customer');
      return;
    }
    if (selectedImage == null && existingImageUrl == null) {
      Utility.errorMessage('Please upload an image for the order');
      return;
    }

    Utility.showLoader();

    // 1. Upload the image if a new one is selected
    String imageUrl = existingImageUrl ?? '';
    if (selectedImage != null) {
      final uploadRes = await _repository.uploadCustomerOrderApi(
        selectedImage!,
        isLoading: false,
      );
      if (uploadRes != null &&
          uploadRes.data != null &&
          uploadRes.data!.url != null) {
        imageUrl = uploadRes.data!.url!;
      } else {
        Utility.closeDialog();
        Utility.errorMessage('Failed to upload image. Please try again.');
        return;
      }
    }

    // 2. Create or Update the order
    final createRes = await _repository.createCustomerOrderApi(
      customerorderid: editingCustomerOrderId,
      customerid: selectedCustomerId,
      image: imageUrl,
      remark1: remark1Controller.text.trim(),
      remark2: remark2Controller.text.trim(),
      remark3: remark3Controller.text.trim(),
      isLoading: false,
    );

    Utility.closeDialog();

    if (createRes != null && createRes.isSuccess == true) {
      Get.back(); // Close bottom sheet
      Utility.snacBar(
        editingCustomerOrderId == null
            ? 'Customer order created successfully!'
            : 'Customer order updated successfully!',
        Colors.green,
      );
      resetForm();
      // Re-fetch using the current filter selection (not cleared by resetForm)
      if (filterCustomerId.isNotEmpty) {
        fetchCustomerOrdersByCustomer(filterCustomerId);
      } else {
        fetchAllCustomerOrders();
      }
    }
  }

  Future<void> deleteOrder(String id) async {
    Utility.showLoader();
    bool success = await _repository.deleteCustomerOrderApi(
      customerorderid: id,
      isLoading: false,
    );
    Utility.closeDialog();
    if (success) {
      Utility.snacBar('Customer order deleted successfully', Colors.green);
      if (filterCustomerId.isNotEmpty) {
        fetchCustomerOrdersByCustomer(filterCustomerId);
      } else {
        fetchAllCustomerOrders();
      }
    }
  }
}
