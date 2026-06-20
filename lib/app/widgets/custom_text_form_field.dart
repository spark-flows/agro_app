// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agro_app/app/theme/colors_value.dart';
import 'package:agro_app/app/theme/dimens.dart';
import 'package:agro_app/app/theme/styles.dart';

class CustomTextFormField extends StatelessWidget {
  CustomTextFormField({
    super.key,
    this.isTitle = false,
    this.isCompulsory = false,
    this.title,
    this.heightBtn,
    this.widthBtn,
    this.titleStyle,
    this.style,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.obscureText,
    this.readOnly,
    this.textAlign,
    this.filled,
    this.fillColor,
    this.prefixIcon,
    this.suffixIcon,
    this.hintText,
    this.hintStyle,
    this.errorStyle,
    this.focusNode,
    this.radius,
    this.isBorder = false,
  });

  bool isTitle;
  bool isCompulsory;
  String? title;
  double? widthBtn;
  double? heightBtn;
  TextStyle? titleStyle;
  TextStyle? style;
  TextEditingController? controller;
  TextInputType? keyboardType;
  TextInputAction? textInputAction;
  List<TextInputFormatter>? inputFormatters;
  String? Function(String?)? validator;
  void Function(String)? onChanged;
  int? maxLength;
  int? maxLines;
  int? minLines;
  bool? obscureText = false;
  bool? readOnly = false;
  TextAlign? textAlign;
  bool? filled;
  Color? fillColor;
  Widget? prefixIcon;
  Widget? suffixIcon;
  String? hintText;
  TextStyle? hintStyle;
  TextStyle? errorStyle;
  FocusNode? focusNode;
  double? radius;
  bool? isBorder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isTitle) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title ?? "", style: titleStyle),
              if (isCompulsory) ...[Text(" *", style: Styles.blackColorW50016)],
            ],
          ),
          Dimens.boxHeight5,
        ],
        SizedBox(
          height: heightBtn,
          width: widthBtn,
          child: TextFormField(
            style: style,
            focusNode: focusNode,
            controller: controller,
            cursorColor: ColorsValue.primary,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            inputFormatters: inputFormatters,
            maxLength: maxLength,
            maxLines: maxLines,
            minLines: minLines,
            onTapOutside: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            obscureText: obscureText ?? false,
            readOnly: readOnly ?? false,
            textAlign: textAlign ?? TextAlign.start,
            validator: validator,
            onChanged: onChanged,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              contentPadding: Dimens.edgeInsets20_12_20_12,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius ?? Dimens.twelve),
                borderSide: isBorder ?? false
                    ? const BorderSide(width: 1.5, color: ColorsValue.primary)
                    : BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius ?? Dimens.twelve),
                borderSide: isBorder ?? false
                    ? const BorderSide(width: 1.0, color: ColorsValue.borderCol)
                    : BorderSide.none,
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius ?? Dimens.twelve),
                borderSide: isBorder ?? false
                    ? const BorderSide(width: 1.0, color: ColorsValue.borderCol)
                    : BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius ?? Dimens.twelve),
                borderSide: isBorder ?? false
                    ? const BorderSide(width: 1.0, color: Colors.red)
                    : BorderSide.none,
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius ?? Dimens.twelve),
                borderSide: isBorder ?? false
                    ? const BorderSide(width: 1.5, color: Colors.red)
                    : BorderSide.none,
              ),
              filled: filled,
              fillColor: fillColor,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              hintText: hintText,
              hintStyle: hintStyle,
              errorStyle: errorStyle,
            ),
          ),
        ),
      ],
    );
  }
}
