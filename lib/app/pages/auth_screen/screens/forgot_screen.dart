import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:agro_app/app/pages/auth_screen/auth_controller.dart';
import 'package:agro_app/app/theme/colors_value.dart';
import 'package:agro_app/app/theme/dimens.dart';
import 'package:agro_app/app/theme/styles.dart';
import 'package:agro_app/app/utils/asset_constants.dart';
import 'package:agro_app/app/utils/utility.dart';
import 'package:agro_app/app/widgets/custom_button.dart';
import 'package:agro_app/app/widgets/custom_text_form_field.dart';

class ForgotScreen extends StatelessWidget {
  const ForgotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.whiteColor,
          // bottomNavigationBar: Padding(
          //   padding: !Utility.isTablet()
          //       ? Dimens.edgeInsets20_00_20_50
          //       : Dimens.edgeInsets30_00_30_50,
          //   child: CustomButton(
          //     onPressed: () {
          //       if (controller.forgotKey.currentState!.validate()) {
          //         Utility.showLoader();
          //         // controller.postForgotApi();
          //       }
          //     },
          //     text: 'Forgot Password'.tr,
          //     textStyle: Styles.whiteColorW80018.copyWith(
          //       fontSize: Utility.isTablet() ? Dimens.twenty : Dimens.eighteen,
          //     ),
          //     backgroundColor: ColorsValue.appColor,
          //     heightBtn: Utility.isTablet() ? Dimens.sixty : Dimens.fifty,
          //   ),
          // ),
          body: SafeArea(
            child: Form(
              key: controller.forgotKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: ListView(
                physics: ClampingScrollPhysics(),
                children: [
                  SvgPicture.asset(
                    AssetConstants.ic_forgot,
                    height: Get.width / 1,
                  ),
                  Dimens.boxHeight30,
                  Center(
                    child: Text(
                      'Forgot Password',
                      style: Styles.txtBlackColorW70022.copyWith(
                        fontSize: Utility.isTablet()
                            ? Dimens.thirty
                            : Dimens.twentyTwo,
                      ),
                    ),
                  ),
                  Dimens.boxHeight10,
                  Center(
                    child: Text(
                      'Enter Your Email And We Will Send You A Link To\nReset Your Password'
                          .tr,
                      style: Styles.txtGreyColorW50012.copyWith(
                        fontSize: Utility.isTablet()
                            ? Dimens.twenty
                            : Dimens.twelve,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Dimens.boxHeight40,
                  Padding(
                    padding: !Utility.isTablet()
                        ? Dimens.edgeInsets20_00_20_00
                        : Dimens.edgeInsets30_00_30_00,
                    child: CustomTextFormField(
                      controller: controller.emailForgotController,
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
