// coverage:ignore-file
// ignore_for_file: use_full_hex_values_for_flutter_colors

import 'package:flutter/material.dart';

/// A list of custom color used in the application.
///
/// Will be ignored for test since all are static values and would not change.
abstract class ColorsValue {
  static Color transparent = Colors.transparent;
  static Color white = Colors.white;
  // static Color black = Colors.black;
  static Color grey9BA6A8 = const Color(0xff9BA6A8);
  static Color greyAAAAAA = const Color(0xFFAAAAAA);
  static Color appColor = const Color(0xFFD5A976);
  static Color lightAppColor = const Color(0xFFF5EADE);
  static Color whiteColor = const Color(0xFFFFFFFF);
  static Color blackColor = const Color(0xFF000000);
  static Color appBg = const Color(0xFFF6F6F6);
  static Color redColor = const Color(0xFFD80032);
  static Color txtBlackColor = const Color(0xFF334155);
  static Color txtGreyColor = const Color(0xFF64748B);
  static Color textFieldBg = const Color(0xFFF3F4F6);
  static Color yellow = const Color(0xFFFFB800);
  static Color orange = const Color(0xFFFF4D00);
  static Color green = const Color(0xFF00C21D);
  static const maincoloropacity1 = Color(maincoloropacity);
  static const textfildbackcolor = Color(textfildback);
  static const maincolor1 = Color(mainAppColor);
  static const blackcolor = Color(black);
  static const lightmainColor = Color(lightmaincolor);
  static Color greyColor8888 = const Color(0xff888888);

  static const int maincoloropacity = 0xffECFBFC;
  static const int maincolor = 0xff5AC8D2;
  static const int black = 0xff242427;
  static const int textfildback = 0xffF1F1F1;
  static const int mainAppColor = 0xffD5A976;
  static const int lightmaincolor = 0xffDEF4F6;

  // ─── Beautiful Agro Theme ────────────────────────────────────────────────────
  // Primary - Emerald Green
  static const Color primary        = Color(0xFF059669);
  static const Color primaryDark    = Color(0xFF047857);
  static const Color primaryDeep    = Color(0xFF064E3B);
  static const Color primaryLight   = Color(0xFFD1FAE5);
  static const Color primarySurface = Color(0xFFF0FDF4);

  // Accent - Warm Amber
  static const Color accent         = Color(0xFFF59E0B);
  static const Color accentDark     = Color(0xFFD97706);
  static const Color accentLight    = Color(0xFFFEF3C7);

  // Neutrals
  static const Color bgMain         = Color(0xFFF8FAFC);
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color textH1         = Color(0xFF0F172A);
  static const Color textH2         = Color(0xFF1E293B);
  static const Color textBody       = Color(0xFF475569);
  static const Color textMuted      = Color(0xFF94A3B8);
  static const Color borderCol      = Color(0xFFE2E8F0);
  static const Color divider        = Color(0xFFF1F5F9);

  // Status
  static const Color statusPending      = Color(0xFFEA580C);
  static const Color statusPendingBg    = Color(0xFFFFF7ED);
  static const Color statusProcessing   = Color(0xFF2563EB);
  static const Color statusProcessingBg = Color(0xFFEFF6FF);
  static const Color statusComplete     = Color(0xFF16A34A);
  static const Color statusCompleteBg   = Color(0xFFF0FDF4);
  static const Color statusCancelled    = Color(0xFFDC2626);
  static const Color statusCancelledBg  = Color(0xFFFEF2F2);

  // Legacy dark aliases (kept for backward compat)
  static Color darkBg            = const Color(0xFF0F1117);
  static Color darkSidebar       = const Color(0xFF16181F);
  static Color darkCard          = const Color(0xFF1C1E27);
  static Color darkBorder        = const Color(0xFF2A2D38);
  static Color darkTextPrimary   = const Color(0xFFE8EAF0);
  static Color darkTextSecondary = const Color(0xFF8A8FA8);
  static Color appGreen          = const Color(0xFF059669);
  static Color appGreenLight     = const Color(0xFFD1FAE5);
}
