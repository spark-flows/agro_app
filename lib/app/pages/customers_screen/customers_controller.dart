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
  final RxList<CustomerItem> customers = <CustomerItem>[].obs;

  final RxList<CustomerItem> filtered = <CustomerItem>[].obs;
  final TextEditingController searchController = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController locationCtrl = TextEditingController();
  final TextEditingController gstCtrl = TextEditingController();
  final GlobalKey<FormState> addFormKey = GlobalKey<FormState>();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearch);
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    isLoading.value = true;
    try {
      var customerModel = await Get.find<Repository>().getCustomerListApi(isLoading: false);
      if (customerModel != null && customerModel.data != null && customerModel.data!.docs != null) {
        customers.assignAll(customerModel.data!.docs!.map((doc) => CustomerItem(
          id: doc.id ?? '',
          name: doc.name ?? '',
          phone: '${doc.countrycode ?? ''} ${doc.mobile ?? ''}',
          location: (doc.email?.isNotEmpty ?? false) ? doc.email! : 'N/A',
          gstNumber: (doc.feedback?.isNotEmpty ?? false) ? doc.feedback! : 'N/A',
        )).toList());
        _onSearch();
      }
    } catch (e) {
      debugPrint('Error fetching customers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearch);
    searchController.dispose();
    nameCtrl.dispose();
    phoneCtrl.dispose();
    locationCtrl.dispose();
    gstCtrl.dispose();
    super.onClose();
  }

  void _onSearch() {
    final q = searchController.text.toLowerCase();
    if (q.isEmpty) {
      filtered.assignAll(customers);
    } else {
      filtered.assignAll(customers.where((c) =>
          c.name.toLowerCase().contains(q) ||
          c.location.toLowerCase().contains(q) ||
          c.phone.contains(q)));
    }
  }

  RxString editingCustomerId = ''.obs;

  void addCustomer() async {
    if (!addFormKey.currentState!.validate()) return;
    
    Utility.showLoader();
    String distributorId = await Utility.getSecureValue(LocalKeys.distributorId);
    var response = await Get.find<Repository>().createCustomerApi(
      customerid: editingCustomerId.value.isEmpty ? null : editingCustomerId.value,
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
      fetchCustomers();
    } else {
      Utility.errorMessage('Failed to save customer. Please try again.');
    }
  }

  void setupEdit(CustomerItem customer) {
    editingCustomerId.value = customer.id;
    nameCtrl.text = customer.name;
    phoneCtrl.text = customer.phone.replaceAll('+91 ', '');
    locationCtrl.text = customer.location == 'N/A' ? '' : customer.location;
    gstCtrl.text = customer.gstNumber == 'N/A' ? '' : customer.gstNumber;
  }

  void deleteCustomer(String id) {
    customers.removeWhere((c) => c.id == id);
    filtered.removeWhere((c) => c.id == id);
    update();
  }

  void clearAddForm() {
    editingCustomerId.value = '';
    nameCtrl.clear();
    phoneCtrl.clear();
    locationCtrl.clear();
    gstCtrl.clear();
  }
}
