import 'package:agro_app/app/app.dart';
import 'package:agro_app/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CollectionFormPage extends StatelessWidget {
  const CollectionFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CollectionController>(
      builder: (controller) {
        final isEdit = controller.editingCollectionId.isNotEmpty;

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
              isEdit ? 'Edit Collection' : 'Create Collection',
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
                  Text('Collection Date', style: Styles.txtBlackColorW60014),
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
                        return 'Please select collection date';
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

                  // ── Party Name Field ──
                  Text('Party Name', style: Styles.txtBlackColorW60014),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: controller.partyNameCtrl,
                    decoration: InputDecoration(
                      hintText: 'Enter Party Name',
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
                        return 'Please enter party name';
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

                  // ── Payment Mode Dropdown ──
                  Text('Payment Mode', style: Styles.txtBlackColorW60014),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: controller.selectedPaymentMode,
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
                    items: CollectionController.paymentModeOptions.map((mode) {
                      String label = mode;
                      if (mode == 'cash') label = 'Cash';
                      if (mode == 'check') label = 'Check';
                      if (mode == 'rtgs/neft') label = 'RTGS / NEFT';
                      return DropdownMenuItem<String>(
                        value: mode,
                        child: Text(label, style: Styles.txtBlackColorW60014),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        controller.selectedPaymentMode = val;
                        controller.update();
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Payment Status Dropdown ──
                  Text('Payment Status', style: Styles.txtBlackColorW60014),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: controller.selectedPaymentStatus,
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
                    items: CollectionController.paymentStatusOptions.map((
                      status,
                    ) {
                      String label = status;
                      if (status == 'received') label = 'Received';
                      if (status == 'pending') label = 'Pending';
                      if (status == 'return') label = 'Return';
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(label, style: Styles.txtBlackColorW60014),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        controller.selectedPaymentStatus = val;
                        controller.update();
                      }
                    },
                  ),
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
                      onPressed: controller.submitCollection,
                      child: Text(
                        isEdit ? 'Update Collection' : 'Create Collection',
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
}
