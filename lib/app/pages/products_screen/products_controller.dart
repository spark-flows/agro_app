import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agro_app/domain/models/get_all_product_model.dart';
import 'package:agro_app/domain/models/get_all_category_model.dart';
import 'package:agro_app/domain/models/get_all_unit_model.dart';
import 'package:agro_app/domain/repositories/repository.dart';

class ProductsController extends GetxController {
  // ── List state ─────────────────────────────────────────────────────────────
  List<GetAllProductDoc> products = [];
  bool isLoading = false;
  bool isFetchingMore = false;

  int currentPage = 1;
  int totalPages = 1;
  int limit = 10;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // ── Form state ─────────────────────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final qtyCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final imageCtrl = TextEditingController();

  String editingProductId = '';
  String? selectedCategoryId;
  String? selectedUnitId;
  List<GetAllCategoryDoc> categories = <GetAllCategoryDoc>[];
  List<GetAllUnitDatum> units = <GetAllUnitDatum>[];

  Timer? _searchTimer;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
    fetchCategories();
    fetchUnits();
  }

  @override
  void onClose() {
    _searchTimer?.cancel();
    nameCtrl.dispose();
    priceCtrl.dispose();
    qtyCtrl.dispose();
    descriptionCtrl.dispose();
    imageCtrl.dispose();
    super.onClose();
  }

  void searchProducts(String query) {
    _searchQuery = query;
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      fetchProducts(isRefresh: true);
    });
  }

  // ── Fetch Categories ───────────────────────────────────────────────────────
  Future<void> fetchCategories() async {
    try {
      debugPrint('[Products] fetchCategories: calling API...');
      final response = await Get.find<Repository>().getCategoryListApi();
      debugPrint(
        '[Products] fetchCategories: response=$response, docs=${response?.data.docs.length}',
      );
      if (response != null && response.data.docs.isNotEmpty) {
        categories = response.data.docs;
        update();
        debugPrint(
          '[Products] fetchCategories: loaded ${categories.length} categories',
        );
      } else {
        debugPrint('[Products] fetchCategories: no categories returned');
      }
    } catch (e, st) {
      debugPrint('[Products] fetchCategories error: $e\n$st');
    }
  }

  // ── Fetch Units ────────────────────────────────────────────────────────────
  Future<void> fetchUnits() async {
    try {
      debugPrint('[Products] fetchUnits: calling API...');
      final response = await Get.find<Repository>().getUnitListApi();
      if (response != null &&
          response.data != null &&
          response.data!.isNotEmpty) {
        units = response.data!;
        update();
        debugPrint('[Products] fetchUnits: loaded ${units.length} units');
      } else {
        debugPrint('[Products] fetchUnits: no units returned');
      }
    } catch (e, st) {
      debugPrint('[Products] fetchUnits error: $e\n$st');
    }
  }

  // ── Fetch Products ─────────────────────────────────────────────────────────
  Future<void> fetchProducts({bool isRefresh = true}) async {
    if (isRefresh) {
      currentPage = 1;
      products.clear();
      isLoading = true;
    } else {
      if (currentPage >= totalPages) return;
      currentPage++;
      isFetchingMore = true;
    }
    update();

    final response = await Get.find<Repository>().getProductListApi(
      page: currentPage,
      limit: limit,
      search: searchQuery,
      isLoading: isRefresh,
    );

    if (response != null && response.isSuccess == true) {
      final docs = response.data?.docs ?? [];
      if (isRefresh) {
        products = docs;
      } else {
        products.addAll(docs);
      }
      totalPages = response.data?.totalPages ?? 1;
    }

    isLoading = false;
    isFetchingMore = false;
    update();
  }

  // ── Form helpers ───────────────────────────────────────────────────────────
  void clearForm() {
    editingProductId = '';
    nameCtrl.clear();
    selectedUnitId = null;
    priceCtrl.clear();
    qtyCtrl.clear();
    descriptionCtrl.clear();
    imageCtrl.clear();
    selectedCategoryId = null;
    update();
  }

  void setupEdit(GetAllProductDoc product) {
    editingProductId = product.id ?? '';
    nameCtrl.text = product.name ?? '';
    // Match the unit name to its id from the loaded units list
    final unitName = product.unit ?? '';
    selectedUnitId = units
        .where((u) => u.name == unitName)
        .map((u) => u.id)
        .firstOrNull;
    priceCtrl.text = product.price?.toString() ?? '';
    qtyCtrl.text = product.qty?.toString() ?? '';
    descriptionCtrl.text = product.description ?? '';
    imageCtrl.text = product.image ?? '';
    selectedCategoryId = product.categoryid?.id;
    update();
  }

  // ── Save (Create / Update) ─────────────────────────────────────────────────
  Future<void> saveProduct() async {
    if (selectedCategoryId == null) {
      Get.snackbar(
        'Error',
        'Please select a category',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (selectedUnitId == null) {
      Get.snackbar(
        'Error',
        'Please select a unit',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // final price = int.tryParse(priceCtrl.text.trim()) ?? 0;
    // final qty = int.tryParse(qtyCtrl.text.trim()) ?? 0;

    final errorMsg = await Get.find<Repository>().createProductApi(
      productid: editingProductId.isNotEmpty ? editingProductId : null,
      name: nameCtrl.text.trim(),
      // unit: selectedUnitId!,
      // price: price,
      // qty: qty,
      // description: descriptionCtrl.text.trim(),
      image: imageCtrl.text.trim(),
      categoryid: selectedCategoryId!,
      isLoading: true,
    );

    if (errorMsg == null) {
      Get.back();
      Get.snackbar(
        'Success',
        editingProductId.isNotEmpty ? 'Product updated' : 'Product added',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      fetchProducts(isRefresh: true);
    } else {
      Get.snackbar(
        'Error',
        errorMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  Future<void> deleteProduct(String id) async {
    final success = await Get.find<Repository>().deleteProductApi(
      productid: id,
      isLoading: true,
    );
    if (success) {
      Get.snackbar(
        'Success',
        'Product deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      fetchProducts(isRefresh: true);
    } else {
      Get.snackbar(
        'Error',
        'Failed to delete product',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
