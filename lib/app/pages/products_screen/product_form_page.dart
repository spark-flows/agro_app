import 'dart:io';

import 'package:agro_app/app/pages/products_screen/products_controller.dart';
import 'package:agro_app/app/theme/theme.dart';
import 'package:agro_app/app/utils/utility.dart';
import 'package:agro_app/data/helpers/api_wrapper.dart';
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

  // ── Load units via repository ────────────────────────────────────────────
  Future<void> _loadUnits() async {
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
  Future<void> _pickAndUploadImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
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
        '${ApiWrapper.api}${EndPoints.productUploadApi}',
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
        Utility.snacBar('Image uploaded successfully', Colors.green);
      } else {
        // Log full response so we can find the correct key
        debugPrint('[ProductForm] Upload response: $data');
        Utility.snacBar(
          'Image uploaded but URL not found in response',
          Colors.orange,
        );
      }
    } catch (e) {
      debugPrint('[ProductForm] Upload error: $e');
      setState(() => _pickedImage = null);
      Utility.errorMessage('Image upload failed. Please try again.');
    } finally {
      if (mounted) setState(() => _uploadingImage = false);
    }
  }

  void _showImageSourceBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            const SizedBox(height: 24),
            Text('Select Image Source', style: Styles.txtBlackColorW70020),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: Icons.camera_alt_outlined,
                  label: 'Camera',
                  onTap: () {
                    Get.back();
                    _pickAndUploadImage(ImageSource.camera);
                  },
                ),
                _buildSourceOption(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  onTap: () {
                    Get.back();
                    _pickAndUploadImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: ColorsValue.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: ColorsValue.primary, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: Styles.txtBlackColorW60014),
        ],
      ),
    );
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
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // ── Category ──────────────────────────────────────────────
                _sectionHeader('Category'),
                const SizedBox(height: 12),

                if (_loadingCategories)
                  const SizedBox(
                    height: 56,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: ColorsValue.primary,
                      ),
                    ),
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
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    value: _categories.any((cat) => cat.id == _selectedCategoryId)
                        ? _selectedCategoryId
                        : null,
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

                const SizedBox(height: 24),

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
                const SizedBox(height: 24),

                // ── Unit Dropdown ───────────────────────────────────────────
                if (_loadingUnits)
                  const SizedBox(
                    height: 56,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: ColorsValue.primary,
                      ),
                    ),
                  )
                else if (_units.isEmpty)
                  OutlinedButton.icon(
                    onPressed: _loadUnits,
                    icon: const Icon(Icons.refresh, color: ColorsValue.primary),
                    label: const Text(
                      'Tap to retry loading units',
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
                    value: _units.any((unit) => unit.id == _selectedUnitId)
                        ? _selectedUnitId
                        : null,
                    decoration: InputDecoration(
                      labelText: 'Unit *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.scale_outlined),
                    ),
                    items: _units
                        .map(
                          (unit) => DropdownMenuItem<String>(
                            value: unit.id,
                            child: Text(unit.name ?? ''),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() => _selectedUnitId = val);
                      controller.selectedUnitId = val;
                    },
                    validator: (v) => v == null ? 'Please select a unit' : null,
                  ),
                const SizedBox(height: 12),

                _buildField(
                  fieldController: controller.qtyCtrl,
                  label: 'Quantity *',
                  icon: Icons.numbers_outlined,
                  keyboardType: TextInputType.number,
                  action: TextInputAction.next,
                  validator: (v) =>
                      v!.trim().isEmpty ? 'Please enter quantity' : null,
                ),
                const SizedBox(height: 24),

                // ── Product Image ──────────────────────────────────────────
                _sectionHeader('Product Image'),
                const SizedBox(height: 12),
                _buildImagePicker(controller),

                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _uploadingImage
                      ? null
                      : () {
                          if (controller.formKey.currentState!.validate()) {
                            controller.selectedCategoryId = _selectedCategoryId;
                            controller.selectedUnitId = _selectedUnitId;
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
          onPressed: _uploadingImage
              ? null
              : () => _showImageSourceBottomSheet(context),
          icon: _uploadingImage
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: ColorsValue.primary,
                  ),
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
                : 'Pick Image',
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
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: fieldController,
      keyboardType: keyboardType,
      textInputAction: action,
      cursorColor: ColorsValue.primary,
      style: Styles.txtBlackColorW50014,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Styles.txtGreyColorW40014,
        floatingLabelStyle: const TextStyle(color: ColorsValue.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorsValue.primary, width: 1.5),
        ),
        prefixIcon: Icon(
          icon,
          color: ColorsValue.primary.withValues(alpha: 0.8),
        ),
      ),
      validator: validator,
    );
  }
}
