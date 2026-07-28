import 'package:agro_app/app/pages/products_screen/products_controller.dart';
import 'package:agro_app/app/theme/theme.dart';
import 'package:agro_app/app/utils/utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        Get.find<ProductsController>().fetchProducts(isRefresh: false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductsController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.bgMain,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black87),
            title: Text('Products', style: Styles.txtBlackColorW70020),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ── Search Bar + Filter ────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: controller.searchProducts,
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          hintStyle: Styles.txtGreyColorW40014,
                          prefixIcon: const Icon(
                            Icons.search,
                            color: ColorsValue.primary,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    controller.searchProducts('');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // ── Filter Button ────────────────────────────────────────
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: controller.isFilterActive
                                  ? ColorsValue.primary
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.filter_list_rounded,
                              color: controller.isFilterActive
                                  ? ColorsValue.primary
                                  : Colors.grey.shade600,
                            ),
                            onPressed: () =>
                                _showFilterBottomSheet(context, controller),
                          ),
                        ),
                        if (controller.isFilterActive)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: ColorsValue.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // ── Product List ───────────────────────────────────────────
                Expanded(
                  child: controller.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: ColorsValue.primary,
                          ),
                        )
                      : controller.filteredProducts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 64,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No products found',
                                style: Styles.txtGreyColorW40014,
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () =>
                              controller.fetchProducts(isRefresh: true),
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount:
                                controller.filteredProducts.length +
                                (controller.isFetchingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == controller.filteredProducts.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: ColorsValue.primary,
                                    ),
                                  ),
                                );
                              }
                              final product =
                                  controller.filteredProducts[index];
                              final isActive = !(product.isDeleted ?? false);

                              return Card(
                                elevation: 1,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  // onTap: () {
                                  //   controller.setupEdit(product);
                                  //   Get.toNamed<void>('/productForm');
                                  // },
                                  borderRadius: BorderRadius.circular(12),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    leading:
                                        product.image != null &&
                                            product.image!.isNotEmpty
                                        ? GestureDetector(
                                            onTap: () => _openFullScreen(
                                              context,
                                              product.image!,
                                              product.id ?? '',
                                            ),
                                            child: Hero(
                                              tag: 'product_img_${product.id}',
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.network(
                                                  product.image!,
                                                  width: 48,
                                                  height: 48,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (e, s, t) =>
                                                      _productIcon(),
                                                ),
                                              ),
                                            ),
                                          )
                                        : _productIcon(),
                                    title: Text(
                                      product.name ?? 'Unnamed',
                                      style: Styles.txtBlackColorW60014,
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        if (product.categoryid?.name != null &&
                                            product.categoryid!.name!
                                                .trim()
                                                .isNotEmpty)
                                          Text(
                                            'Category: ${product.categoryid!.name}',
                                            style: Styles.txtGreyColorW40012,
                                          ),
                                        Text(
                                          [
                                            if (product.unit?.name != null &&
                                                product.unit!.name!.isNotEmpty)
                                              'Unit: ${product.unit?.name}',
                                            'Qty: ${product.qty ?? 0}',
                                          ].join(' | '),
                                          style: Styles.txtGreyColorW40012,
                                        ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isActive
                                                ? Colors.green.withValues(
                                                    alpha: 0.1,
                                                  )
                                                : Colors.red.withValues(
                                                    alpha: 0.1,
                                                  ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            isActive ? 'Active' : 'Inactive',
                                            style: TextStyle(
                                              color: isActive
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            Utility.showDeleteDialog(
                                              title: 'Delete Product',
                                              message:
                                                  'Are you sure you want to delete ${product.name}?',
                                              onConfirm: () {
                                                controller.deleteProduct(
                                                  product.id ?? '',
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),
          // floatingActionButton: FloatingActionButton(
          //   backgroundColor: ColorsValue.primary,
          //   onPressed: () {
          //     controller.clearForm();
          //     Get.toNamed<void>('/productForm');
          //   },
          //   child: const Icon(Icons.add),
          // ),
        );
      },
    );
  }

  Widget _productIcon() {
    return CircleAvatar(
      backgroundColor: ColorsValue.primary.withValues(alpha: 0.1),
      child: const Icon(Icons.inventory_2_outlined, color: ColorsValue.primary),
    );
  }

  void _openFullScreen(BuildContext context, String imageUrl, String heroTag) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (ctx, anim, secAnim) => FullScreenImagePage(
          imageUrl: imageUrl,
          heroTag: 'product_img_$heroTag',
        ),
        transitionsBuilder: (ctx, animation, secAnim, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  // ── Filter Bottom Sheet ────────────────────────────────────────────────────
  void _showFilterBottomSheet(
    BuildContext context,
    ProductsController controller,
  ) {
    String? tempCategoryId = controller.filterCategoryId;
    String? tempUnitId = controller.filterUnitId;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text('Filter Products', style: Styles.txtBlackColorW70020),

                // Title row
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Text('Filter Products', style: Styles.txtBlackColorW70020),
                //     // if (tempCategoryId != null || tempUnitId != null)
                //     //   TextButton(
                //     //     onPressed: () {
                //     //       setSheetState(() {
                //     //         tempCategoryId = null;
                //     //         tempUnitId = null;
                //     //       });
                //     //     },
                //     //     child: const Text(
                //     //       'Clear All',
                //     //       style: TextStyle(color: Colors.red, fontSize: 13),
                //     //     ),
                //     //   ),
                //   ],
                // ),
                const SizedBox(height: 20),

                // ── Category Dropdown ──────────────────────────────────────
                DropdownButtonFormField<String>(
                  value: tempCategoryId,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.category_outlined),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Categories'),
                    ),
                    ...controller.categories.map(
                      (cat) => DropdownMenuItem<String>(
                        value: cat.id,
                        child: Text(cat.name),
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    setSheetState(() => tempCategoryId = val);
                  },
                ),
                const SizedBox(height: 16),

                // ── Unit Dropdown ──────────────────────────────────────────
                DropdownButtonFormField<String>(
                  value: tempUnitId,
                  decoration: InputDecoration(
                    labelText: 'Unit',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.scale_outlined),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Units'),
                    ),
                    ...controller.units.map(
                      (unit) => DropdownMenuItem<String>(
                        value: unit.id,
                        child: Text(unit.name ?? ''),
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    setSheetState(() => tempUnitId = val);
                  },
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    // ── Clear Filter Button (only when filters are active) ──
                    if (controller.isFilterActive) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            controller.clearFilters();
                            Get.back();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Clear Filter',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    // ── Apply Filters Button ────────────────────────────────
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          controller.applyFilters(
                            categoryId: tempCategoryId,
                            unitId: tempUnitId,
                          );
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsValue.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Apply Filters',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }
}

// ── Full Screen Image Viewer ────────────────────────────────────────────────

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const FullScreenImagePage({
    super.key,
    required this.imageUrl,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Center(
        child: Hero(
          tag: heroTag,
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 5.0,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              },
              errorBuilder: (context, error, stackTrace) => const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, color: Colors.white54, size: 64),
                  SizedBox(height: 12),
                  Text(
                    'Image could not be loaded',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
