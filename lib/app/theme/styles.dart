//coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agro_app/app/app.dart';

/// A chunk of styles used in the application.
/// Will be ignored for test since all are static values and would not change.
abstract class Styles {
  static TextStyle txtBlackColorW70020 = GoogleFonts.jost(
    color: ColorsValue.txtBlackColor,
    fontSize: Dimens.twenty,
    fontWeight: FontWeight.w700,
  );
  static TextStyle txtBlackColorW70018 = GoogleFonts.jost(
    color: ColorsValue.txtBlackColor,
    fontSize: Dimens.eighteen,
    fontWeight: FontWeight.w700,
  );
  static TextStyle txtBlackColorW70022 = GoogleFonts.jost(
    color: ColorsValue.txtBlackColor,
    fontSize: Dimens.twentyTwo,
    fontWeight: FontWeight.w700,
  );
  static TextStyle black50016 = GoogleFonts.roboto(
    color: ColorsValue.blackcolor,
    fontSize: Dimens.sixteen,
    fontWeight: FontWeight.w500,
  );
  static TextStyle main70014 = GoogleFonts.roboto(
    color: ColorsValue.maincolor1,
    fontWeight: FontWeight.w700,
    fontSize: Dimens.fourteen,
  );
  static TextStyle main50012 = GoogleFonts.roboto(
    color: ColorsValue.maincolor1,
    fontWeight: FontWeight.w500,
    fontSize: Dimens.twelve,
  );
  static TextStyle greyColor888840012 = GoogleFonts.roboto(
    color: ColorsValue.greyColor8888,
    fontWeight: FontWeight.w400,
    fontSize: Dimens.twelve,
  );
  static TextStyle black40014 = GoogleFonts.roboto(
    color: ColorsValue.blackColor,
    fontSize: Dimens.fourteen,
    fontWeight: FontWeight.w400,
  );
  static TextStyle white50016 = GoogleFonts.roboto(
    color: ColorsValue.whiteColor,
    fontWeight: FontWeight.w500,
    fontSize: Dimens.sixteen,
  );
  static TextStyle main50014 = GoogleFonts.roboto(
    color: ColorsValue.maincolor1,
    fontWeight: FontWeight.w500,
    fontSize: Dimens.fourteen,
  );
  static TextStyle txtGreyColorW50012 = GoogleFonts.jost(
    color: ColorsValue.txtBlackColor,
    fontSize: Dimens.twelve,
    fontWeight: FontWeight.w500,
  );
  static TextStyle textfildback40016 = GoogleFonts.roboto(
    color: ColorsValue.textfildbackcolor,
    fontWeight: FontWeight.w400,
    fontSize: Dimens.sixteen,
  );
  static TextStyle txtGreyColorW50014 = GoogleFonts.jost(
    color: ColorsValue.txtGreyColor,
    fontSize: Dimens.fourteen,
    fontWeight: FontWeight.w500,
  );
  static TextStyle txtBlackColorW70014 = GoogleFonts.jost(
    color: ColorsValue.txtBlackColor,
    fontSize: Dimens.fourteen,
    fontWeight: FontWeight.w700,
  );
  static TextStyle txtBlackColorW70016 = GoogleFonts.jost(
    color: ColorsValue.txtBlackColor,
    fontSize: Dimens.sixteen,
    fontWeight: FontWeight.w700,
  );
  static TextStyle txtBlackColorW50014 = GoogleFonts.jost(
    color: ColorsValue.txtBlackColor,
    fontSize: Dimens.fourteen,
    fontWeight: FontWeight.w500,
  );
  static TextStyle txtBlackColorW60014 = GoogleFonts.jost(
    color: ColorsValue.txtBlackColor,
    fontSize: Dimens.fourteen,
    fontWeight: FontWeight.w600,
  );
  static TextStyle txtBlackColorW70012 = GoogleFonts.jost(
    color: ColorsValue.txtBlackColor,
    fontSize: Dimens.twelve,
    fontWeight: FontWeight.w700,
  );
  static TextStyle txtGreyColorW40014 = GoogleFonts.jost(
    color: ColorsValue.txtBlackColor,
    fontSize: Dimens.fourteen,
    fontWeight: FontWeight.w400,
  );
  static TextStyle txtGreyColorW40012 = GoogleFonts.jost(
    color: ColorsValue.txtBlackColor,
    fontSize: Dimens.twelve,
    fontWeight: FontWeight.w400,
  );
  static TextStyle appColorW70016 = GoogleFonts.jost(
    color: ColorsValue.primary,
    fontSize: Dimens.sixteen,
    fontWeight: FontWeight.w700,
  );
  static TextStyle appColorW70012 = GoogleFonts.jost(
    color: ColorsValue.primary,
    fontSize: Dimens.twelve,
    fontWeight: FontWeight.w700,
  );
  static TextStyle appColorW50014 = GoogleFonts.jost(
    color: ColorsValue.primary,
    fontSize: Dimens.fourteen,
    fontWeight: FontWeight.w500,
  );
  static TextStyle whiteColorW60016 = GoogleFonts.jost(
    color: ColorsValue.whiteColor,
    fontSize: Dimens.sixteen,
    fontWeight: FontWeight.w600,
  );
  static TextStyle whiteColorW60012 = GoogleFonts.jost(
    color: ColorsValue.whiteColor,
    fontSize: Dimens.twelve,
    fontWeight: FontWeight.w600,
  );
  static TextStyle whiteColorW80018 = GoogleFonts.jost(
    color: ColorsValue.whiteColor,
    fontSize: Dimens.eighteen,
    fontWeight: FontWeight.w800,
  );
  static TextStyle whiteColorW60018 = GoogleFonts.jost(
    color: ColorsValue.whiteColor,
    fontSize: Dimens.eighteen,
    fontWeight: FontWeight.w600,
  );
  static TextStyle blackColorW50016 = GoogleFonts.jost(
    color: ColorsValue.blackColor,
    fontSize: Dimens.sixteen,
    fontWeight: FontWeight.w500,
  );
  static TextStyle black50018 = GoogleFonts.jost(
    color: ColorsValue.blackColor,
    fontSize: Dimens.eighteen,
    fontWeight: FontWeight.w500,
  );
  static TextStyle redColor50014 = GoogleFonts.jost(
    color: ColorsValue.redColor,
    fontWeight: FontWeight.w500,
    fontSize: Dimens.fourteen,
  );
  static TextStyle black50014 = GoogleFonts.jost(
    color: ColorsValue.blackColor,
    fontSize: Dimens.fourteen,
    fontWeight: FontWeight.w500,
  );

  // ─── Dark ERP Theme (legacy) ──────────────────────────────────────────────
  static TextStyle greenColorW50010 = GoogleFonts.jost(
    color: ColorsValue.appGreen,
    fontSize: Dimens.ten,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.2,
  );
  static TextStyle darkTextSecondary40014 = GoogleFonts.jost(
    color: ColorsValue.darkTextSecondary,
    fontSize: Dimens.fourteen,
    fontWeight: FontWeight.w400,
  );

  // ─── Beautiful Agro Theme (Poppins) ──────────────────────────────────────
  static TextStyle h1White = GoogleFonts.poppins(
    color: Colors.white,
    fontSize: Dimens.twentyFour,
    fontWeight: FontWeight.w700,
  );
  static TextStyle h2White = GoogleFonts.poppins(
    color: Colors.white,
    fontSize: Dimens.twenty,
    fontWeight: FontWeight.w600,
  );
  static TextStyle h3White = GoogleFonts.poppins(
    color: Colors.white,
    fontSize: Dimens.sixteen,
    fontWeight: FontWeight.w600,
  );
  static TextStyle subWhite = GoogleFonts.poppins(
    color: Colors.white.withValues(alpha: 0.82),
    fontSize: Dimens.fourteen,
    fontWeight: FontWeight.w400,
  );
  static TextStyle h1Dark = GoogleFonts.poppins(
    color: ColorsValue.textH1,
    fontSize: Dimens.twentyTwo,
    fontWeight: FontWeight.w700,
  );
  static TextStyle h2Dark = GoogleFonts.poppins(
    color: ColorsValue.textH2,
    fontSize: Dimens.eighteen,
    fontWeight: FontWeight.w600,
  );
  static TextStyle h3Dark = GoogleFonts.poppins(
    color: ColorsValue.textH2,
    fontSize: Dimens.sixteen,
    fontWeight: FontWeight.w600,
  );
  static TextStyle bodyDark = GoogleFonts.poppins(
    color: ColorsValue.textBody,
    fontSize: Dimens.fourteen,
    fontWeight: FontWeight.w400,
  );
  static TextStyle bodyMuted = GoogleFonts.poppins(
    color: ColorsValue.textMuted,
    fontSize: Dimens.twelve,
    fontWeight: FontWeight.w400,
  );
  static TextStyle labelGreen = GoogleFonts.poppins(
    color: ColorsValue.primary,
    fontSize: Dimens.fourteen,
    fontWeight: FontWeight.w600,
  );
  static TextStyle labelAmber = GoogleFonts.poppins(
    color: ColorsValue.accent,
    fontSize: Dimens.fourteen,
    fontWeight: FontWeight.w600,
  );
  static TextStyle priceAmber = GoogleFonts.poppins(
    color: ColorsValue.accentDark,
    fontSize: Dimens.sixteen,
    fontWeight: FontWeight.w700,
  );
  static TextStyle btnWhite = GoogleFonts.poppins(
    color: Colors.white,
    fontSize: Dimens.sixteen,
    fontWeight: FontWeight.w600,
  );
  static TextStyle chipText = GoogleFonts.poppins(
    fontSize: Dimens.twelve,
    fontWeight: FontWeight.w500,
  );
}
