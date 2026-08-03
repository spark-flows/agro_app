import 'dart:io';
import 'package:agro_app/app/app.dart';
import 'package:agro_app/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class ExpenseFormPage extends StatelessWidget {
  const ExpenseFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExpenseController>(
      builder: (controller) {
        final isEdit = controller.editingExpenseId.isNotEmpty;

        return Scaffold(
          backgroundColor: ColorsValue.bgMain,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Get.back(),
            ),
            title: Text(
              isEdit ? 'Edit Expense' : 'Create Expense',
              style: Styles.txtBlackColorW70020,
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (RoleUtils.isAdmin(controller.roleName)) ...[
                    Text('Select User', style: Styles.txtBlackColorW60014),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: controller.selectedUserId,
                          hint: Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Text(
                              'Select User',
                              style: Styles.txtGreyColorW40014,
                            ),
                          ),
                          icon: const Padding(
                            padding: EdgeInsets.only(right: 12.0),
                            child: Icon(Icons.arrow_drop_down),
                          ),
                          items: controller.userList.map((user) {
                            return DropdownMenuItem<String>(
                              value: user.id,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 12.0),
                                child: Text(
                                  '${user.name} (${user.roleid.rolename})',
                                  style: Styles.txtBlackColorW60014,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              controller.selectedUserId = val;
                              controller.update();
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Date Selection Field ──
                  Text('Expense Date', style: Styles.txtBlackColorW60014),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: controller.dateCtrl,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Select Date',
                      suffixIcon: const Icon(
                        Icons.calendar_today,
                        color: ColorsValue.primary,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please select expense date';
                      }
                      return null;
                    },
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            DateTime.tryParse(controller.dateCtrl.text) ??
                            DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        controller.dateCtrl.text = DateFormat(
                          'yyyy-MM-dd',
                        ).format(picked);
                        controller.update();
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Particular / Category Dropdown ──
                  Text(
                    'Particular (Expense Category)',
                    style: Styles.txtBlackColorW60014,
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: controller.selectedParticularId.isNotEmpty
                        ? controller.selectedParticularId
                        : null,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    hint: Text(
                      'Select Particular',
                      style: Styles.txtGreyColorW40014,
                    ),
                    items: controller.particulars.map((particular) {
                      return DropdownMenuItem<String>(
                        value: particular.id,
                        child: Text(
                          particular.name ?? '',
                          style: Styles.txtBlackColorW60014,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        controller.selectedParticularId = val;
                        controller.update();
                      }
                    },
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please select an expense particular';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Amount Field ──
                  Text('Amount (₹)', style: Styles.txtBlackColorW60014),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: controller.amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter Amount',
                      prefixText: '₹ ',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter amount';
                      }
                      if (double.tryParse(val.trim()) == null) {
                        return 'Please enter a valid numeric amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Image Upload Picker ──
                  Text(
                    'Expense Image / Receipt',
                    style: Styles.txtBlackColorW60014,
                  ),
                  const SizedBox(height: 6),
                  _buildImageSelectionField(context, controller),
                  const SizedBox(height: 16),

                  // ── Remark Field ──
                  Text('Remark (Optional)', style: Styles.txtBlackColorW60014),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: controller.remarkCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Enter Remark',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // ── Submit Button ──
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsValue.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: controller.submitExpense,
                      child: Text(
                        isEdit ? 'Update Expense' : 'Create Expense',
                        style: Styles.whiteColorW60016,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSelectionField(
    BuildContext context,
    ExpenseController controller,
  ) {
    final hasNewImage = controller.selectedImage != null;
    final hasExistingImage =
        controller.existingImageUrl != null &&
        controller.existingImageUrl!.trim().isNotEmpty;

    if (hasNewImage || hasExistingImage) {
      return Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: hasNewImage
                  ? Image.file(controller.selectedImage!, fit: BoxFit.cover)
                  : controller.existingImageUrl!.startsWith('http')
                  ? Image.network(
                      controller.existingImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Text('Failed to load image')),
                    )
                  : Image.file(
                      File(controller.existingImageUrl!),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: InkWell(
              onTap: controller.removeImage,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      );
    }

    return InkWell(
      onTap: () => _showImageSourceSheet(context, controller),
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_a_photo_outlined,
              color: ColorsValue.primary,
              size: 30,
            ),
            const SizedBox(height: 6),
            Text('Add Receipt Image', style: Styles.txtGreyColorW40012),
          ],
        ),
      ),
    );
  }

  void _showImageSourceSheet(
    BuildContext context,
    ExpenseController controller,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 30,
              top: 10,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Image Source',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    // Camera Option
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(ctx);
                          controller.pickImage(ImageSource.camera);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: ColorsValue.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: ColorsValue.primary.withAlpha(51),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  size: 28,
                                  color: ColorsValue.primary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Camera',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Gallery Option
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(ctx);
                          controller.pickImage(ImageSource.gallery);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: ColorsValue.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: ColorsValue.primary.withAlpha(51),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.photo_library_outlined,
                                  size: 28,
                                  color: ColorsValue.primary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Gallery',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
