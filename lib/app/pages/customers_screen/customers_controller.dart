import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:agro_app/domain/domain.dart';
import 'package:agro_app/app/utils/utility.dart';

class CustomerItem {
  final String id;
  final String name;
  final String phone;
  final String location;
  final String gstNumber;
  final bool isActive;

  CustomerItem({
    required this.id,
    required this.name,
    required this.phone,
    required this.location,
    required this.gstNumber,
    this.isActive = true,
  });
}

class CustomersController extends GetxController {
  List<CustomerItem> customers = [];
  bool isLoading = false;
  
  int currentPage = 1;
  int limit = 100;
  String _searchQuery = '';

  final TextEditingController searchController = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController locationCtrl = TextEditingController();
  final TextEditingController gstCtrl = TextEditingController();
  final GlobalKey<FormState> addFormKey = GlobalKey<FormState>();
  
  Timer? _searchTimer;
  String editingCustomerId = '';

  @override
  void onInit() {
    super.onInit();
    fetchCustomers();
  }

  Future<void> fetchCustomers({bool isRefresh = true}) async {
    if (isRefresh) {
      currentPage = 1;
      customers.clear();
      isLoading = true;
    }
    update();

    try {
      var customerModel = await Get.find<Repository>().getCustomerListApi(
        page: currentPage,
        limit: limit,
        search: _searchQuery,
        isLoading: false,
      );
      if (customerModel != null &&
          customerModel.data != null &&
          customerModel.data!.docs != null) {
        
        final docs = customerModel.data!.docs!
            .map(
              (doc) => CustomerItem(
                id: doc.id ?? '',
                name: doc.name ?? '',
                phone: '${doc.countrycode ?? ''} ${doc.mobile ?? ''}',
                location: (doc.email?.isNotEmpty ?? false)
                    ? doc.email!
                    : 'N/A',
                gstNumber: (doc.feedback?.isNotEmpty ?? false)
                    ? doc.feedback!
                    : 'N/A',
              ),
            )
            .toList();
            
        if (isRefresh) {
          customers = docs;
        } else {
          customers.addAll(docs);
        }
      }
    } catch (e) {
      debugPrint('Error fetching customers: $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  @override
  void onClose() {
    _searchTimer?.cancel();
    searchController.dispose();
    nameCtrl.dispose();
    phoneCtrl.dispose();
    locationCtrl.dispose();
    gstCtrl.dispose();
    super.onClose();
  }

  void onSearchChanged(String query) {
    _searchQuery = query;
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      fetchCustomers(isRefresh: true);
    });
  }

  void addCustomer() async {
    if (!addFormKey.currentState!.validate()) return;

    Utility.showLoader();
    var response = await Get.find<Repository>().createCustomerApi(
      customerid: editingCustomerId.isEmpty
          ? null
          : editingCustomerId,
      name: nameCtrl.text.trim(),
      email: locationCtrl.text.trim(),
      countrycode: '+91',
      mobile: phoneCtrl.text.trim(),
      feedback: gstCtrl.text.trim(),
      isLoading: false,
    );
    Utility.closeLoader();

    if (response != null && response.isSuccess == true) {
      Get.back();
      clearAddForm();
      fetchCustomers(isRefresh: true);
    } else {
      Utility.errorMessage('Failed to save customer. Please try again.');
    }
  }

  void setupEdit(CustomerItem customer) {
    editingCustomerId = customer.id;
    nameCtrl.text = customer.name;
    phoneCtrl.text = customer.phone.replaceAll('+91 ', '');
    locationCtrl.text = customer.location == 'N/A' ? '' : customer.location;
    gstCtrl.text = customer.gstNumber == 'N/A' ? '' : customer.gstNumber;
    update();
  }

  void deleteCustomer(String id) {
    customers.removeWhere((c) => c.id == id);
    update();
  }

  void clearAddForm() {
    editingCustomerId = '';
    nameCtrl.clear();
    phoneCtrl.clear();
    locationCtrl.clear();
    gstCtrl.clear();
    update();
  }
}
