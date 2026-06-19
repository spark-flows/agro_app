import 'dart:io';

import 'package:agro_app/app/app.dart';
import 'package:agro_app/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CustomerOrdersController extends GetxController {
  final Repository _repository = Get.find<Repository>();

  List<CustomerOrderDoc> ordersList = [];
  bool isLoading = false;

  List<GetAllCustomerDoc> customersList = [];
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
    fetchCustomers();
    fetchAllCustomerOrders();
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

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage = File(image.path);
      update();
    }
  }

  void resetForm() {
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
      Get.snackbar(
        'Success',
        editingCustomerOrderId == null
            ? 'Customer order created successfully!'
            : 'Customer order updated successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      resetForm();
      fetchAllCustomerOrders();
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
      Get.snackbar(
        'Deleted',
        'Customer order deleted successfully',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      fetchAllCustomerOrders();
    }
  }
}
