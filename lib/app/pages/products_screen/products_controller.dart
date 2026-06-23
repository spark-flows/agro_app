import 'dart:async';
import 'package:agro_app/app/utils/utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agro_app/domain/models/get_all_product_model.dart';
import 'package:agro_app/domain/models/get_all_category_model.dart';
import 'package:agro_app/domain/models/get_all_unit_model.dart';
import 'package:agro_app/domain/repositories/repository.dart';
import 'package:agro_app/domain/repositories/local_storage_keys.dart';

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

  // ── Filter state ───────────────────────────────────────────────────────────
  String? filterCategoryId;
  String? filterUnitId;

  bool get isFilterActive => filterCategoryId != null || filterUnitId != null;

  List<GetAllProductDoc> get filteredProducts {
    List<GetAllProductDoc> result = List.from(products);

    // Filter by category
    if (filterCategoryId != null && filterCategoryId!.isNotEmpty) {
      result = result.where((p) => p.categoryid?.id == filterCategoryId).toList();
    }

    // Filter by unit
    if (filterUnitId != null && filterUnitId!.isNotEmpty) {
      result = result.where((p) => p.unit?.id == filterUnitId).toList();
    }

    return result;
  }

  void applyFilters({String? categoryId, String? unitId}) {
    filterCategoryId = categoryId;
    filterUnitId = unitId;
    update();
  }

  void clearFilters() {
    filterCategoryId = null;
    filterUnitId = null;
    update();
  }

  // ── Form state ─────────────────────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final qtyCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final imageCtrl = TextEditingController();

  String editingProductId = '';
  String? selectedCategoryId;
  List<GetAllCategoryDoc> categories = <GetAllCategoryDoc>[];

  String? selectedUnitId;
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
      debugPrint(
        '[Products] fetchUnits: response=$response, data=${response?.data?.length}',
      );
      if (response != null && response.data != null && response.data!.isNotEmpty) {
        units = response.data!;
        update();
        debugPrint(
          '[Products] fetchUnits: loaded ${units.length} units',
        );
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
    priceCtrl.clear();
    qtyCtrl.clear();
    descriptionCtrl.clear();
    imageCtrl.clear();
    selectedCategoryId = null;
    selectedUnitId = null;
    update();
  }

  void setupEdit(GetAllProductDoc product) {
    editingProductId = product.id ?? '';
    nameCtrl.text = product.name ?? '';
    priceCtrl.text = product.price?.toString() ?? '';
    qtyCtrl.text = product.qty?.toString() ?? '';
    descriptionCtrl.text = product.description ?? '';
    imageCtrl.text = product.image ?? '';
    selectedCategoryId = product.categoryid?.id;
    selectedUnitId = product.unit?.id;
    update();
  }

  // ── Save (Create / Update) ─────────────────────────────────────────────────
  Future<void> saveProduct() async {
    if (selectedCategoryId == null) {
      Utility.errorMessage('Please select a category');
      return;
    }
    if (selectedUnitId == null) {
      Utility.errorMessage('Please select a unit');
      return;
    }

    final price = int.tryParse(priceCtrl.text.trim()) ?? 0;
    final qty = int.tryParse(qtyCtrl.text.trim()) ?? 0;

    final errorMsg = await Get.find<Repository>().createProductApi(
      productid: editingProductId.isNotEmpty ? editingProductId : null,
      name: nameCtrl.text.trim(),
      unit: selectedUnitId!,
      price: price,
      qty: qty,
      description: descriptionCtrl.text.trim(),
      image: imageCtrl.text.trim(),
      categoryid: selectedCategoryId!,
      isLoading: true,
    );

    if (errorMsg == null) {
      Get.back();
      Utility.snacBar(
        editingProductId.isNotEmpty ? 'Product updated' : 'Product added',
        Colors.green,
      );
      fetchProducts(isRefresh: true);
    } else {
      Utility.errorMessage(errorMsg);
    }
  }

  Future<void> deleteProduct(String id) async {
    final success = await Get.find<Repository>().deleteProductApi(
      productid: id,
      isLoading: true,
    );
    if (success) {
      Utility.snacBar(
        'Product deleted successfully',
        Colors.green,
      );
      fetchProducts(isRefresh: true);
    } else {
      Utility.errorMessage('Failed to delete product');
    }
  }
}
