import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:agro_app/app/app.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      initState: (as) {
        var controller = Get.find<AuthController>();
        controller.otpTextEditingController = TextEditingController();
        controller.otpKey = Get.arguments[1] ?? "";
        controller.otpMobile = Get.arguments[0] ?? "";
        controller.counter = 30;
        controller.startTimer();
      },
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              Form(
                child: ListView(
                  physics: ClampingScrollPhysics(),
                  children: [
                    Image.asset(
                      AssetConstants.otp_image,
                      height: Get.height / 2.2,
                    ),
                    Center(
                      child: Text(
                        'OTP Verification',
                        style: Styles.txtBlackColorW70022,
                      ),
                    ),
                    Dimens.boxHeight6,
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: 'Please Enter Code Sent To ',
                          style: Styles.txtGreyColorW50012,
                          children: <TextSpan>[
                            TextSpan(
                              text: controller.otpMobile,
                              style: Styles.txtBlackColorW70012,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Dimens.boxHeight30,
                    Padding(
                      padding: Dimens.edgeInsets20_00_20_00,
                      child: PinCodeTextField(
                        controller: controller.otpTextEditingController,
                        appContext: context,
                        length: 6,
                        autoFocus: true,
                        hintCharacter: "0",
                        hintStyle: Styles.txtGreyColorW50014,
                        pastedTextStyle: const TextStyle(
                          color: ColorsValue.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        animationType: AnimationType.fade,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          activeColor: ColorsValue.primary,
                          selectedColor: ColorsValue.primary,
                          inactiveColor: ColorsValue.textFieldBg,
                          selectedFillColor: ColorsValue.whiteColor,
                          inactiveFillColor: ColorsValue.textFieldBg,
                          activeFillColor: ColorsValue.whiteColor,
                          borderWidth: 1,
                          borderRadius: BorderRadius.circular(Dimens.five),
                          fieldHeight: Get.width / Dimens.eight,
                          fieldWidth: Get.width / Dimens.eight,
                        ),
                        cursorColor: ColorsValue.primary,
                        enableActiveFill: true,
                        keyboardType: TextInputType.number,
                        errorTextMargin: Dimens.edgeInsetsTop20,
                        errorTextSpace: Dimens.twentyFive,
                        boxShadows: const [
                          BoxShadow(
                            offset: Offset(0, 1),
                            color: Colors.black12,
                            blurRadius: 2,
                          ),
                        ],
                        validator: (value) {
                          return controller.validotp(value!);
                        },
                        beforeTextPaste: (text) {
                          debugPrint("Allowing to paste $text");
                          return true;
                        },
                      ),
                    ),
                    Dimens.boxHeight30,
                    if (controller.counter == 0) ...[
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: 'didn\'t Recevie Code '.tr,
                            style: Styles.txtGreyColorW50014,
                            children: [
                              TextSpan(
                                text: 'Resend Code'.tr,
                                style: Styles.txtBlackColorW70014,
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    controller.counter = 30;
                                    controller.startTimer();
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      Center(
                        child: Text(
                          '00:${controller.counter <= 9 ? '0${controller.counter}' : controller.counter}',
                          style: Styles.txtBlackColorW50014,
                        ),
                      ),
                    ],
                    Dimens.boxHeight30,
                    Padding(
                      padding: Dimens.edgeInsets20_00_20_00,
                      child: CustomButton(
                        heightBtn: Dimens.fifty,
                        text: "Log In",
                        onPressed: () {
                          if (controller.otpFormKey.currentState!.validate()) {}
                        },
                        textStyle: Styles.whiteColorW60016,
                      ),
                    ),
                    Dimens.boxHeight25,
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Padding(
                  padding: Dimens.edgeInsets20_40_00_00,
                  child: SvgPicture.asset(AssetConstants.back_arrow),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
