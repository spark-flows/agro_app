import 'dart:async';

import 'package:agro_app/app/pages/home_screen/home_controller.dart';
import 'package:agro_app/app/utils/utility.dart';
import 'package:agro_app/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class CustomerItem {
  final String id;
  final String name;
  final String phone;
  final String location;
  final String feedback;
  final String village;
  final bool isActive;
  final String distributorId;

  CustomerItem({
    required this.id,
    required this.name,
    required this.phone,
    required this.location,
    required this.feedback,
    required this.village,
    this.isActive = true,
    this.distributorId = '',
  });
}

class CustomersController extends GetxController {
  List<CustomerItem> customers = [];
  bool isLoading = false;

  final int limit = 10;
  String _searchQuery = '';

  late final PagingController<int, CustomerItem> customerPagingController =
      PagingController(firstPageKey: 1);

  final TextEditingController searchController = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController locationCtrl = TextEditingController();
  final TextEditingController gstCtrl = TextEditingController();
  final TextEditingController villageCtrl = TextEditingController();
  final GlobalKey<FormState> addFormKey = GlobalKey<FormState>();

  Timer? _searchTimer;
  String editingCustomerId = '';

  // ── Distributor dropdown (admin only) ──────────────────────────────────────
  List<Doc> distributors = [];
  String? selectedDistributorId;
  bool isAdminView = false;

  @override
  void onInit() {
    super.onInit();
    customerPagingController.addPageRequestListener((pageKey) {
      fetchCustomersPage(pageKey);
    });
    // Detect role and load distributors if admin
    final homeController = Get.find<HomeController>();
    isAdminView = RoleUtils.isAdmin(homeController.roleName);
    if (isAdminView) {
      fetchDistributors();
    }
  }

  Future<void> fetchCustomersPage(int pageKey) async {
    try {
      var customerModel = await Get.find<Repository>().getCustomerListApi(
        page: pageKey,
        limit: limit,
        search: _searchQuery,
        isLoading: false,
      );
      if (customerModel != null &&
          customerModel.data != null &&
          customerModel.data!.docs != null) {
        final docs = customerModel.data!.docs!.map((doc) {
          String distId = '';
          if (doc.distributorid is Map) {
            distId = doc.distributorid["_id"]?.toString() ?? '';
          } else {
            distId = doc.distributorid?.toString() ?? '';
          }
          return CustomerItem(
            id: doc.id ?? '',
            name: doc.name ?? '',
            phone: '${doc.countrycode ?? ''} ${doc.mobile ?? ''}',
            location: (doc.email?.isNotEmpty ?? false) ? doc.email! : 'N/A',
            feedback: (doc.feedback?.isNotEmpty ?? false)
                ? doc.feedback!
                : 'N/A',
            village: (doc.village?.isNotEmpty ?? false) ? doc.village! : 'N/A',
            distributorId: distId,
          );
        }).toList();

        final hasNextPage =
            customerModel.data!.hasNextPage ?? (docs.length >= limit);
        final isLastPage = !hasNextPage || docs.length < limit;

        if (pageKey == 1) {
          customers = docs;
        } else {
          customers.addAll(docs);
        }

        if (isLastPage) {
          customerPagingController.appendLastPage(docs);
        } else {
          final nextPageKey = pageKey + 1;
          customerPagingController.appendPage(docs, nextPageKey);
        }
      } else {
        if (pageKey == 1) {
          customers.clear();
        }
        customerPagingController.appendLastPage([]);
      }
    } catch (e) {
      debugPrint('Error fetching customers page $pageKey: $e');
      customerPagingController.error = e;
    }
  }

  Future<void> fetchCustomers({bool isRefresh = true}) async {
    customerPagingController.refresh();
  }

  @override
  void onClose() {
    _searchTimer?.cancel();
    customerPagingController.dispose();
    searchController.dispose();
    nameCtrl.dispose();
    phoneCtrl.dispose();
    locationCtrl.dispose();
    gstCtrl.dispose();
    villageCtrl.dispose();
    feedbackCtrl.dispose();
    super.onClose();
  }

  /// Fetches all distributors (dealers) for the admin dropdown.
  Future<void> fetchDistributors() async {
    try {
      final response = await Get.find<Repository>().getUsersListApi(
        page: 1,
        limit: 10,
        search: '',
        type: 'dealer',
        isLoading: false,
      );
      if (response != null && response.isSuccess) {
        distributors = response.data.docs;
        update();
      }
    } catch (e) {
      debugPrint('fetchDistributors error: $e');
    }
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

    // Admin must select a distributor
    if (isAdminView &&
        (selectedDistributorId == null || selectedDistributorId!.isEmpty)) {
      Utility.errorMessage('Please select a distributor.');
      return;
    }

    Utility.showLoader();

    // For admin: use selected distributor. For dealer: connect_helper
    // reads the logged-in dealer's ID from secure storage automatically.
    String? overrideDistributorId = isAdminView ? selectedDistributorId : null;

    var response = await Get.find<Repository>().createCustomerApi(
      customerid: editingCustomerId.isEmpty ? null : editingCustomerId,
      name: nameCtrl.text.trim(),
      email: locationCtrl.text.trim(),
      countrycode: '+91',
      mobile: phoneCtrl.text.trim(),
      feedback: gstCtrl.text.trim(),
      village: villageCtrl.text.trim(),
      distributorid: overrideDistributorId,
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
    gstCtrl.text = customer.feedback == 'N/A' ? '' : customer.feedback;
    villageCtrl.text = customer.village == 'N/A' ? '' : customer.village;
    if (isAdminView) {
      selectedDistributorId = customer.distributorId.isNotEmpty
          ? customer.distributorId
          : null;
    }
    update();
  }

  Future<void> deleteCustomer(String id) async {
    Utility.showLoader();
    final success = await Get.find<Repository>().deleteCustomerApi(
      customerid: id,
      isLoading: false,
    );
    Utility.closeLoader();

    if (success) {
      Utility.snacBar('Customer deleted successfully', Colors.green);
      fetchCustomers(isRefresh: true);
    } else {
      Utility.errorMessage('Failed to delete customer');
    }
  }

  final TextEditingController feedbackCtrl = TextEditingController();

  void clearAddForm() {
    editingCustomerId = '';
    selectedDistributorId = null;
    nameCtrl.clear();
    phoneCtrl.clear();
    locationCtrl.clear();
    gstCtrl.clear();
    villageCtrl.clear();
    update();
  }

  Future<void> submitFeedback(String customerId) async {
    final feedback = feedbackCtrl.text.trim();
    if (feedback.isEmpty) {
      Utility.errorMessage('Please enter feedback');
      return;
    }

    Utility.showLoader();
    final errorMsg = await Get.find<Repository>().customerFeedbackApi(
      customerid: customerId,
      feedback: feedback,
      isLoading: false,
    );
    Utility.closeLoader();

    if (errorMsg == null) {
      Get.back(); // Close the bottom sheet
      Utility.snacBar('Feedback submitted successfully', Colors.green);
      feedbackCtrl.clear();
      // Optional: you can refresh customers if feedback is shown in the list
      fetchCustomers(isRefresh: true);
    } else {
      Utility.errorMessage(errorMsg);
    }
  }
}
