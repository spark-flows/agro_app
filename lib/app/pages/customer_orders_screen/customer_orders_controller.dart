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
  List<TextEditingController> remarkControllers = [];
  List<RemarkItem> loadedRemarks = [];
  String currentUserId = '';
  String currentUserName = '';

  String getRemarkUserName(RemarkItem remark) {
    if (remark.userId?.name != null && remark.userId!.name!.isNotEmpty) {
      return remark.userId!.name!;
    }
    final uid = remark.userId?.id ?? '';
    if (uid.isEmpty) return '-';

    if (uid == currentUserId) {
      return currentUserName.isNotEmpty ? currentUserName : 'Me';
    }

    final dist = distributors.firstWhereOrNull((d) => d.id == uid);
    if (dist != null) {
      return dist.name;
    }

    return uid;
  }

  String formatRemarkDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      return Utility.getFormatedTime(dateStr, 'dd MMM yyyy hh:mm a');
    } catch (_) {
      return dateStr;
    }
  }

  @override
  void onInit() {
    super.onInit();
    remarkControllers = [TextEditingController()];
    _loadRole();
    fetchCustomers();
    fetchAllCustomerOrders();
  }

  @override
  void onClose() {
    for (var c in remarkControllers) {
      c.dispose();
    }
    remark1Controller.dispose();
    remark2Controller.dispose();
    remark3Controller.dispose();
    super.onClose();
  }

  void addRemarkField() {
    remarkControllers.add(TextEditingController());
    update();
  }

  void removeRemarkFieldAt(int index) {
    if (remarkControllers.length > 1) {
      remarkControllers[index].dispose();
      remarkControllers.removeAt(index);
      if (index < loadedRemarks.length) {
        loadedRemarks.removeAt(index);
      }
      update();
    }
  }

  void populateRemarks(CustomerOrderDoc order) {
    for (var c in remarkControllers) {
      c.dispose();
    }
    remarkControllers.clear();
    loadedRemarks.clear();

    if (order.remark != null && order.remark!.isNotEmpty) {
      for (var r in order.remark!) {
        remarkControllers.add(TextEditingController(text: r.remark ?? ''));
        loadedRemarks.add(r);
      }
    } else {
      final list = <String>[];
      if (order.remark1 != null && order.remark1!.trim().isNotEmpty) {
        list.add(order.remark1!);
      }
      if (order.remark2 != null && order.remark2!.trim().isNotEmpty) {
        list.add(order.remark2!);
      }
      if (order.remark3 != null && order.remark3!.trim().isNotEmpty) {
        list.add(order.remark3!);
      }

      if (list.isNotEmpty) {
        for (var text in list) {
          remarkControllers.add(TextEditingController(text: text));
          loadedRemarks.add(
            RemarkItem(
              remark: text,
              date: order.createdAt ?? DateTime.now().toUtc().toIso8601String(),
              userId: UseridItem(id: order.createdBy ?? ''),
            ),
          );
        }
      }
    }

    if (remarkControllers.isEmpty) {
      remarkControllers.add(TextEditingController());
    }
  }

  Future<void> _loadRole() async {
    final profileJson = await Utility.getSecureValue(LocalKeys.profileData);
    if (profileJson.isNotEmpty) {
      try {
        final Map<String, dynamic>? decoded =
            json.decode(profileJson) as Map<String, dynamic>?;
        if (decoded != null) {
          final Map<String, dynamic> userData =
              (decoded['userData'] is Map<String, dynamic>)
              ? decoded['userData'] as Map<String, dynamic>
              : decoded;
          currentUserId =
              userData['id']?.toString() ?? userData['_id']?.toString() ?? '';
          currentUserName = userData['name']?.toString() ?? '';
        }
      } catch (_) {}
    }
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
        limit: 10,
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
    for (var c in remarkControllers) {
      c.dispose();
    }
    remarkControllers = [TextEditingController()];
    loadedRemarks.clear();
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

    populateRemarks(order);
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
        populateRemarks(fetchedOrder);
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

    final String distributorId = await Utility.getSecureValue(
      LocalKeys.distributorId,
    );
    final String currentDate = DateTime.now().toUtc().toIso8601String();

    List<Map<String, dynamic>> remarkPayload = [];
    for (int i = 0; i < remarkControllers.length; i++) {
      final text = remarkControllers[i].text.trim();
      if (text.isEmpty && remarkControllers.length > 1) {
        continue;
      }

      String rDate = currentDate;
      String rUserId = distributorId;

      if (i < loadedRemarks.length) {
        rDate = loadedRemarks[i].date ?? currentDate;
        rUserId = loadedRemarks[i].userId?.id ?? distributorId;
      }

      remarkPayload.add({"date": rDate, "userid": rUserId, "remark": text});
    }

    if (remarkPayload.isEmpty) {
      remarkPayload.add({
        "date": currentDate,
        "userid": distributorId,
        "remark": "",
      });
    }

    // 2. Create or Update the order
    final createRes = await _repository.createCustomerOrderApi(
      customerorderid: editingCustomerOrderId,
      customerid: selectedCustomerId,
      image: imageUrl,
      remark: remarkPayload,
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
