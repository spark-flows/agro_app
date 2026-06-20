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

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      initState: (state) {
        // controller initialisation handled by GetBuilder builder callback
      },
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.whiteColor,
          body: Form(
            key: controller.resetKey,
            child: ListView(
              physics: ClampingScrollPhysics(),
              children: [
                SvgPicture.asset(
                  AssetConstants.ic_reset_password,
                  height: Get.width,
                ),
                Padding(
                  padding: Dimens.edgeInsets20_00_20_00,
                  child: Text(
                    'Reset Password',
                    style: Styles.txtBlackColorW70022.copyWith(
                      fontSize: Utility.isTablet()
                          ? Dimens.thirty
                          : Dimens.twentyTwo,
                    ),
                  ),
                ),
                Dimens.boxHeight30,
                Padding(
                  padding: !Utility.isTablet()
                      ? Dimens.edgeInsets20_00_20_00
                      : Dimens.edgeInsets30_00_30_00,
                  child: CustomTextFormField(
                    controller: controller.newPasswordController,
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
                    hintText: 'Enter New Password'.tr,
                    title: 'New Password'.tr,
                    fillColor: ColorsValue.textFieldBg,
                    filled: true,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.name,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return 'Enter New Password'.tr;
                      }
                      return null;
                    },
                  ),
                ),
                Dimens.boxHeight20,
                Padding(
                  padding: !Utility.isTablet()
                      ? Dimens.edgeInsets20_00_20_00
                      : Dimens.edgeInsets30_00_30_00,
                  child: CustomTextFormField(
                    controller: controller.confirmPasswordController,
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
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.name,
                    validator: (val) {
                      if (val!.isEmpty) {
                        return 'Enter Confirm Password'.tr;
                      }
                      return null;
                    },
                  ),
                ),
                Dimens.boxHeight50,
                Padding(
                  padding: !Utility.isTablet()
                      ? Dimens.edgeInsets20_00_20_20
                      : Dimens.edgeInsets30_00_30_30,
                  child: CustomButton(
                    onPressed: () {
                      if (controller.resetKey.currentState!.validate()) {
                        // controller.postResetApi();
                      }
                    },
                    text: 'Reset Password'.tr,
                    textStyle: Styles.whiteColorW80018.copyWith(
                      fontSize: Utility.isTablet()
                          ? Dimens.twenty
                          : Dimens.eighteen,
                    ),
                    backgroundColor: ColorsValue.primary,
                    heightBtn: Utility.isTablet() ? Dimens.sixty : Dimens.fifty,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
