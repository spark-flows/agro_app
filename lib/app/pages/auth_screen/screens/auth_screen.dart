import 'package:agro_app/app/app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: ColorsValue.white,
          body: SafeArea(
            child: Form(
              key: controller.loginKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(Dimens.twenty),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Dimens.boxHeight40,
                    Image.asset(AssetConstants.logo, height: 150),
                    Dimens.boxHeight20,
                    Text(
                      'Agro ERP',
                      textAlign: TextAlign.center,
                      style: Styles.txtBlackColorW70022.copyWith(fontSize: 28),
                    ),
                    Dimens.boxHeight10,
                    Text(
                      'Welcome back! Please login to your account.',
                      textAlign: TextAlign.center,
                      style: Styles.txtGreyColorW40014,
                    ),
                    Dimens.boxHeight40,

                    /// Form Fields
                    Text('Username', style: Styles.txtBlackColorW60014),
                    Dimens.boxHeight8,
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: controller.userNameController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: 'Enter your username',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Enter username';
                        }
                        return null;
                      },
                    ),
                    Dimens.boxHeight20,

                    Text('Password', style: Styles.txtBlackColorW60014),
                    Dimens.boxHeight8,
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: controller.passController,
                      obscureText: controller.isPasswordHidden,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordHidden
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            controller.isPasswordHidden =
                                !controller.isPasswordHidden;
                            controller.update();
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Enter password';
                        }
                        if (val.length < 4) {
                          return 'Minimum 4 characters';
                        }
                        return null;
                      },
                    ),
                    Dimens.boxHeight30,

                    /// Login Button
                    ElevatedButton(
                      onPressed: () {
                        if (controller.loginKey.currentState!.validate()) {
                          controller.postLoginApi();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsValue.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: controller.isLoginLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text('Login', style: Styles.whiteColorW60016),
                    ),
                    Dimens.boxHeight20,

                    /// Register text
                    // Center(
                    //   child: RichText(
                    //     text: TextSpan(
                    //       text: "Don't have an account? ",
                    //       style: Styles.txtGreyColorW40014,
                    //       children: [
                    //         TextSpan(
                    //           text: 'Register here',
                    //           style: TextStyle(
                    //             color: ColorsValue.primary,
                    //             fontWeight: FontWeight.bold,
                    //           ),
                    //           recognizer: TapGestureRecognizer()
                    //             ..onTap = RouteManagement.goToRegisterScreen,
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
