import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:agro_app/app/navigators/routes_management.dart';
import 'package:agro_app/app/pages/auth_screen/auth_controller.dart';
import 'package:agro_app/app/theme/colors_value.dart';
import 'package:agro_app/app/theme/dimens.dart';
import 'package:agro_app/app/theme/styles.dart';
import 'package:agro_app/app/utils/utility.dart';
import 'package:agro_app/app/widgets/custom_button.dart';
import 'package:agro_app/app/widgets/custom_country_picker_field.dart';
import 'package:agro_app/app/widgets/custom_text_form_field.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.whiteColor,
          bottomNavigationBar: Padding(
            padding: Dimens.edgeInsetsBottom50,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: !Utility.isTablet()
                      ? Dimens.edgeInsets20_00_20_00
                      : Dimens.edgeInsets30_00_30_00,
                  child: CustomButton(
                    onPressed: () {
                      if (controller.registerKey.currentState!.validate()) {
                        Utility.showLoader();
                        // controller.postRegisterApi();
                      }
                    },
                    text: 'Sign Up'.tr,
                    textStyle: Styles.whiteColorW80018.copyWith(
                      fontSize: Utility.isTablet()
                          ? Dimens.twenty
                          : Dimens.eighteen,
                    ),
                    backgroundColor: ColorsValue.appColor,
                    heightBtn: Utility.isTablet() ? Dimens.sixty : Dimens.fifty,
                  ),
                ),
                Dimens.boxHeight5,
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Already Have An Account? ',
                      style: Styles.txtGreyColorW40014,
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Sign In',
                          style: Styles.appColorW70016,
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              RouteManagement.goToAuthScreen();
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: Form(
              autovalidateMode: AutovalidateMode.disabled,
              key: controller.registerKey,
              child: ListView(
                padding: Dimens.edgeInsets20_30_20_30,
                physics: ClampingScrollPhysics(),
                children: [
                  Center(
                    child: Text(
                      'Sign Up',
                      style: Styles.txtBlackColorW70022.copyWith(
                        fontSize: Utility.isTablet()
                            ? Dimens.thirty
                            : Dimens.twentyTwo,
                      ),
                    ),
                  ),
                  Dimens.boxHeight6,
                  Center(
                    child: Text(
                      'Welcome please Create your account'.tr,
                      style: Styles.txtGreyColorW50012.copyWith(
                        fontSize: Utility.isTablet()
                            ? Dimens.twenty
                            : Dimens.twelve,
                      ),
                    ),
                  ),
                  Dimens.boxHeight30,
                  CustomTextFormField(
                    controller: controller.nameRegisterController,
                    isTitle: true,
                    titleStyle: Styles.txtBlackColorW70014.copyWith(
                      fontSize: Utility.isTablet()
                          ? Dimens.twenty
                          : Dimens.fourteen,
                    ),
                    hintStyle: Styles.txtGreyColorW50012.copyWith(
                      fontSize: Utility.isTablet()
                          ? Dimens.eighteen
                          : Dimens.fourteen,
                    ),
                    hintText: 'Enter Name '.tr,
                    title: 'User Name '.tr,
                    fillColor: ColorsValue.textFieldBg,
                    filled: true,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.text,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return 'Enter User Name '.tr;
                      }
                      return null;
                    },
                  ),
                  Dimens.boxHeight20,
                  CustomCountryPickerField(
                    textEditingController: controller.mobileRegisterController,
                    isTitle: true,
                    text: 'Mobile Number '.tr,
                    hintText: 'Enter Mobile Number '.tr,
                    maxLength: 10,
                    titleStyle: Styles.txtBlackColorW70014.copyWith(
                      fontSize: Utility.isTablet()
                          ? Dimens.twenty
                          : Dimens.fourteen,
                    ),
                    hintStyle: Styles.txtGreyColorW50012.copyWith(
                      fontSize: Utility.isTablet()
                          ? Dimens.eighteen
                          : Dimens.fourteen,
                    ),
                    fillColor: ColorsValue.textFieldBg,
                    radius: Dimens.ten,
                    initialvalue: PhoneNumber(
                      isoCode: PhoneNumber.getISO2CodeByPrefix(
                        controller.dailReCode,
                      ),
                    ),
                    onInputChanged: (PhoneNumber number) {
                      controller.dailReCode = number.dialCode ?? '';
                      controller.update();
                    },
                    oninitialValidation: (bool value) {
                      controller.isReValid = value;
                      controller.update();
                    },
                    validation: (val) {
                      if (val!.isEmpty) {
                        return "Enter Mobile Number";
                      } else if (!controller.isReValid) {
                        return "Enter Valid Mobile Number";
                      }
                      return null;
                    },
                  ),
                  Dimens.boxHeight20,
                  CustomTextFormField(
                    controller: controller.emailRegisterController,
                    isTitle: true,
                    titleStyle: Styles.txtBlackColorW70014.copyWith(
                      fontSize: Utility.isTablet()
                          ? Dimens.twenty
                          : Dimens.fourteen,
                    ),
                    hintStyle: Styles.txtGreyColorW50012.copyWith(
                      fontSize: Utility.isTablet()
                          ? Dimens.eighteen
                          : Dimens.fourteen,
                    ),
                    hintText: 'Enter Email'.tr,
                    title: 'Email'.tr,
                    fillColor: ColorsValue.textFieldBg,
                    filled: true,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return 'Enter Email'.tr;
                      } else if (!Utility.emailValidation(val)) {
                        return 'Enter Valid Email';
                      }
                      return null;
                    },
                  ),
                  Dimens.boxHeight20,
                  CustomTextFormField(
                    controller: controller.passwordRegisterController,
                    isTitle: true,
                    titleStyle: Styles.txtBlackColorW70014.copyWith(
                      fontSize: Utility.isTablet()
                          ? Dimens.twenty
                          : Dimens.fourteen,
                    ),
                    hintStyle: Styles.txtGreyColorW50012.copyWith(
                      fontSize: Utility.isTablet()
                          ? Dimens.eighteen
                          : Dimens.fourteen,
                    ),
                    hintText: 'Enter Create Password'.tr,
                    title: 'Create Password'.tr,
                    fillColor: ColorsValue.textFieldBg,
                    filled: true,
                    obscureText: controller.isCreatePasswordHidden,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.text,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isCreatePasswordHidden
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        controller.isCreatePasswordHidden =
                            !controller.isCreatePasswordHidden;
                        controller.update();
                      },
                    ),
                    validator: (val) {
                      if (val!.isEmpty) {
                        return 'Enter Create Password'.tr;
                      }
                      return null;
                    },
                  ),
                  Dimens.boxHeight20,
                  CustomTextFormField(
                    controller: controller.confirmPasswordRegisterController,
                    isTitle: true,
                    titleStyle: Styles.txtBlackColorW70014.copyWith(
                      fontSize: Utility.isTablet()
                          ? Dimens.twenty
                          : Dimens.fourteen,
                    ),
                    hintStyle: Styles.txtGreyColorW50012.copyWith(
                      fontSize: Utility.isTablet()
                          ? Dimens.eighteen
                          : Dimens.fourteen,
                    ),
                    hintText: 'Enter Confirm Password'.tr,
                    title: 'Confirm Password'.tr,
                    fillColor: ColorsValue.textFieldBg,
                    filled: true,
                    obscureText: controller.isConfirmPasswordHidden,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.text,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isConfirmPasswordHidden
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        controller.isConfirmPasswordHidden =
                            !controller.isConfirmPasswordHidden;
                        controller.update();
                      },
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Enter Confirm Password'.tr;
                      }
                      if (val != controller.passwordRegisterController.text) {
                        return 'Passwords do not match'.tr;
                      }
                      return null;
                    },
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
