// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agro_app/app/theme/colors_value.dart';

ThemeData themeData(BuildContext context) => ThemeData(
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: ColorsValue.primary,
  ),
  disabledColor: const Color(0xFFEEEEEE),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.transparent,
  ),
  timePickerTheme: const TimePickerThemeData(dayPeriodColor: ColorsValue.primary),
  shadowColor: const Color(0xFFDDE3FD),
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.all<Color>(ColorsValue.primary),
    side: BorderSide.none,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    titleTextStyle: TextStyle(color: Colors.black, fontFamily: 'Product Sans'),
    iconTheme: IconThemeData(color: Colors.black),
    actionsIconTheme: IconThemeData(color: Colors.black),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xffFFFFFF),
    type: BottomNavigationBarType.fixed,
    elevation: 0,
  ),
  primaryColor: ColorsValue.primary,
  secondaryHeaderColor: Colors.white,
  fontFamily: 'Product Sans',
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.transparent,
  colorScheme: const ColorScheme.light(
    surface: Colors.white,
    onInverseSurface: Color.fromRGBO(0, 0, 0, 0.12),
    primary: ColorsValue.primary,
  ),
  iconTheme: const IconThemeData(color: Colors.black),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: Colors.grey,
    hintStyle: TextStyle(color: Get.theme.hintColor.withOpacity(.3)),
    floatingLabelStyle: const TextStyle(color: ColorsValue.primary),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFCCCCCC), width: 1.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFCCCCCC), width: 1.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 1.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: ColorsValue.primary, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 1.5),
    ),
  ),
  textSelectionTheme: const TextSelectionThemeData(cursorColor: ColorsValue.primary),
  tabBarTheme: const TabBarThemeData(labelColor: Colors.white),
);

ThemeData darkThemeData(BuildContext context) => ThemeData(
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: ColorsValue.primary,
  ),
  textSelectionTheme: const TextSelectionThemeData(cursorColor: Colors.white),
  appBarTheme: const AppBarTheme(
    titleTextStyle: TextStyle(color: Colors.white, fontFamily: 'Product Sans'),
    backgroundColor: Colors.black,
    iconTheme: IconThemeData(color: Colors.white),
    actionsIconTheme: IconThemeData(color: Colors.white),
  ),
  secondaryHeaderColor: const Color.fromRGBO(23, 166, 221, 1),
  iconTheme: const IconThemeData(color: Colors.white),
  primaryColor: const Color(0xFFF31B82),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.transparent,
  ),
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Colors.white,
    primary: const Color.fromRGBO(23, 166, 221, 1),
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: Colors.grey,
    hintStyle: TextStyle(color: Get.theme.hintColor.withOpacity(.3)),
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(
        color: Color.fromARGB(255, 209, 209, 209),
        width: 1.5,
      ),
    ),
    enabledBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(
        color: Color.fromARGB(255, 209, 209, 209),
        width: 1.5,
      ),
    ),
    errorBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(
        color: Color.fromRGBO(240, 151, 149, 1),
        width: 1.5,
      ),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(14)),
      borderSide: BorderSide(
        color: Color.fromARGB(30, 27, 83, 244),
        width: 1.5,
      ),
    ),
  ),
  scaffoldBackgroundColor: Colors.black,
  fontFamily: 'Product Sans',
  tabBarTheme: TabBarThemeData(labelColor: Colors.white),
);
