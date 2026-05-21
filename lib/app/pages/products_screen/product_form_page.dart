import 'dart:io';

import 'package:agro_app/app/pages/products_screen/products_controller.dart';
import 'package:agro_app/app/theme/theme.dart';
import 'package:agro_app/app/utils/utility.dart';
import 'package:agro_app/data/helpers/end_points.dart';
import 'package:agro_app/domain/models/get_all_category_model.dart';
import 'package:agro_app/domain/models/get_all_unit_model.dart';
import 'package:agro_app/domain/repositories/repository.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  // ── Category state ────────────────────────────────────────────────────────
  List<GetAllCategoryDoc> _categories = [];
  bool _loadingCategories = true;
  String? _selectedCategoryId;

  // ── Unit state ────────────────────────────────────────────────────────────
  List<GetAllUnitDatum> _units = [];
  bool _loadingUnits = true;
  String? _selectedUnitId;

  // ── Image state ───────────────────────────────────────────────────────────
  File? _pickedImage;
  bool _uploadingImage = false;

  @override
  void initState() {
    super.initState();
    final ctrl = Get.find<ProductsController>();
    _selectedCategoryId = ctrl.selectedCategoryId;
    _selectedUnitId = ctrl.selectedUnitId;
    // Pre-populate unit list from controller if already loaded
    _units = ctrl.units;
    if (_units.isNotEmpty) _loadingUnits = false;
    _loadCategories();
    _loadUnits();
  }

  // ── Load categories via repository ────────────────────────────────────────
  Future<void> _loadCategories() async {
    setState(() => _loadingCategories = true);
    try {
      final response = await Get.find<Repository>().getCategoryListApi();
      if (mounted) {
        setState(() {
          _categories = response?.data.docs ?? [];
          _loadingCategories = false;
        });
      }
    } catch (e) {
      debugPrint('[ProductForm] _loadCategories error: $e');
      if (mounted) setState(() => _loadingCategories = false);
    }
  }

  // ── Load units via repository ─────────────────────────────────────────────
  Future<void> _loadUnits() async {
    if (_units.isNotEmpty) {
      if (mounted) setState(() => _loadingUnits = false);
      return;
    }
    setState(() => _loadingUnits = true);
    try {
      final response = await Get.find<Repository>().getUnitListApi();
      if (mounted) {
        setState(() {
          _units = response?.data ?? [];
          _loadingUnits = false;
        });
      }
    } catch (e) {
      debugPrint('[ProductForm] _loadUnits error: $e');
      if (mounted) setState(() => _loadingUnits = false);
    }
  }

  // ── Pick image from gallery / camera ─────────────────────────────────────
  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() {
      _pickedImage = File(picked.path);
      _uploadingImage = true;
    });

    try {
      final headers = await Utility.commonHeader();
      // Remove Content-Type so Dio sets it with multipart boundary
      headers.remove('Content-Type');

      final dioClient = dio.Dio();
      final formData = dio.FormData.fromMap({
        'image': await dio.MultipartFile.fromFile(
          picked.path,
          filename: picked.name,
        ),
      });

      final response = await dioClient.post(
        'https://api.japexim.co.in/${EndPoints.productUploadApi}',
        data: formData,
        options: dio.Options(headers: headers),
      );

      // Extract the server image URL from the response
      final data = response.data;
      String? imageUrl;

      if (data is Map) {
        final dynamic dataField = data['Data'] ?? data['data'];

        if (dataField is String) {
          // If the API returns the URL directly in the Data field
          imageUrl = dataField;
        } else if (dataField is Map) {
          // If it's nested in a Map
          imageUrl =
              (dataField['url'] ?? dataField['imageUrl'] ?? dataField['image'])
                  ?.toString();
        }

        // Fallback
        imageUrl ??= (data['url'] ?? data['imageUrl'])?.toString();
      }

      if (imageUrl != null && imageUrl.isNotEmpty) {
        Get.find<ProductsController>().imageCtrl.text = imageUrl;
        Get.snackbar(
          'Success',
          'Image uploaded successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green.shade800,
        );
      } else {
        // Log full response so we can find the correct key
        debugPrint('[ProductForm] Upload response: $data');
        Get.snackbar(
          'Upload Note',
          'Image uploaded but URL not found in response. Check console.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('[ProductForm] Upload error: $e');
      setState(() => _pickedImage = null);
      Get.snackbar(
        'Error',
        'Image upload failed. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
      );
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
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
            title: Text(
              controller.editingProductId.isNotEmpty
                  ? 'Edit Product'
                  : 'Add Product',
              style: Styles.txtBlackColorW70020,
            ),
          ),
          body: Form(
            key: controller.formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _sectionHeader('Product Information'),
                const SizedBox(height: 12),

                _buildField(
                  fieldController: controller.nameCtrl,
                  label: 'Product Name *',
                  icon: Icons.inventory_2_outlined,
                  action: TextInputAction.next,
                  validator: (v) =>
                      v!.trim().isEmpty ? 'Please enter product name' : null,
                ),
                const SizedBox(height: 12),

                // // ── Unit Dropdown ───────────────────────────────────────────
                // if (_loadingUnits)
                //   const SizedBox(
                //     height: 56,
                //     child: Center(child: CircularProgressIndicator()),
                //   )
                // else if (_units.isEmpty)
                //   OutlinedButton.icon(
                //     onPressed: _loadUnits,
                //     icon: const Icon(Icons.refresh, color: ColorsValue.primary),
                //     label: const Text(
                //       'Tap to retry loading units',
                //       style: TextStyle(color: ColorsValue.primary),
                //     ),
                //     style: OutlinedButton.styleFrom(
                //       minimumSize: const Size.fromHeight(56),
                //       side: const BorderSide(color: ColorsValue.primary),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(12),
                //       ),
                //     ),
                //   )
                // else
                //   DropdownButtonFormField<String>(
                //     value: _selectedUnitId,
                //     decoration: InputDecoration(
                //       labelText: 'Unit *',
                //       border: OutlineInputBorder(
                //         borderRadius: BorderRadius.circular(12),
                //       ),
                //       prefixIcon: const Icon(Icons.scale_outlined),
                //     ),
                //     items: _units
                //         .map(
                //           (unit) => DropdownMenuItem<String>(
                //             value: unit.id,
                //             child: Text(unit.name ?? ''),
                //           ),
                //         )
                //         .toList(),
                //     onChanged: (val) {
                //       setState(() => _selectedUnitId = val);
                //       controller.selectedUnitId = val;
                //     },
                //     validator: (v) => v == null ? 'Please select a unit' : null,
                //   ),
                // const SizedBox(height: 12),

                // _buildField(
                //   fieldController: controller.priceCtrl,
                //   label: 'Price (₹) *',
                //   icon: Icons.currency_rupee_outlined,
                //   keyboardType: TextInputType.number,
                //   action: TextInputAction.next,
                //   validator: (v) =>
                //       v!.trim().isEmpty ? 'Please enter a price' : null,
                // ),
                // const SizedBox(height: 12),
                // _buildField(
                //   fieldController: controller.qtyCtrl,
                //   label: 'Quantity *',
                //   icon: Icons.numbers_outlined,
                //   keyboardType: TextInputType.number,
                //   action: TextInputAction.next,
                //   validator: (v) =>
                //       v!.trim().isEmpty ? 'Please enter quantity' : null,
                // ),
                // const SizedBox(height: 12),
                // TextFormField(
                //   controller: controller.descriptionCtrl,
                //   maxLines: 3,
                //   textInputAction: TextInputAction.next,
                //   decoration: InputDecoration(
                //     labelText: 'Description',
                //     alignLabelWithHint: true,
                //     border: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //     prefixIcon: const Padding(
                //       padding: EdgeInsets.only(bottom: 48),
                //       child: Icon(Icons.description_outlined),
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 24),

                // ── Product Image ──────────────────────────────────────────
                _sectionHeader('Product Image'),
                const SizedBox(height: 12),
                _buildImagePicker(controller),
                const SizedBox(height: 24),

                // ── Category ──────────────────────────────────────────────
                _sectionHeader('Category'),
                const SizedBox(height: 12),

                if (_loadingCategories)
                  const SizedBox(
                    height: 56,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_categories.isEmpty)
                  OutlinedButton.icon(
                    onPressed: _loadCategories,
                    icon: const Icon(Icons.refresh, color: ColorsValue.primary),
                    label: const Text(
                      'Tap to retry loading categories',
                      style: TextStyle(color: ColorsValue.primary),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      side: const BorderSide(color: ColorsValue.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    decoration: InputDecoration(
                      labelText: 'Category *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.category_outlined),
                    ),
                    items: _categories
                        .map(
                          (cat) => DropdownMenuItem<String>(
                            value: cat.id,
                            child: Text(cat.name),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() => _selectedCategoryId = val);
                      controller.selectedCategoryId = val;
                    },
                    validator: (v) =>
                        v == null ? 'Please select a category' : null,
                  ),

                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _uploadingImage
                      ? null
                      : () {
                          if (controller.formKey.currentState!.validate()) {
                            controller.selectedCategoryId = _selectedCategoryId;
                            controller.saveProduct();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsValue.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Product',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Image picker widget ───────────────────────────────────────────────────
  Widget _buildImagePicker(ProductsController controller) {
    final existingUrl = controller.imageCtrl.text;
    final hasImage = _pickedImage != null || existingUrl.isNotEmpty;

    return Column(
      children: [
        // Preview area
        if (hasImage)
          Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _pickedImage != null
                    ? Image.file(
                        _pickedImage!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        existingUrl,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (e, s, t) => Container(
                          height: 180,
                          color: Colors.grey.shade100,
                          child: const Icon(
                            Icons.broken_image,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                      ),
              ),
              if (_uploadingImage)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      color: Colors.black45,
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              // Clear button
              if (!_uploadingImage)
                GestureDetector(
                  onTap: () {
                    setState(() => _pickedImage = null);
                    controller.imageCtrl.clear();
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),

        if (hasImage) const SizedBox(height: 10),

        // Pick / Change image button
        OutlinedButton.icon(
          onPressed: _uploadingImage ? null : _pickAndUploadImage,
          icon: _uploadingImage
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(
                  Icons.add_photo_alternate_outlined,
                  color: ColorsValue.primary,
                ),
          label: Text(
            _uploadingImage
                ? 'Uploading...'
                : hasImage
                ? 'Change Image'
                : 'Pick Image from Gallery',
            style: const TextStyle(color: ColorsValue.primary),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            side: const BorderSide(color: ColorsValue.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: ColorsValue.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(title, style: Styles.txtBlackColorW60014),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController fieldController,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction action = TextInputAction.done,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: fieldController,
      keyboardType: keyboardType,
      textInputAction: action,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }
}
