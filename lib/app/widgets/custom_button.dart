// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:agro_app/app/app.dart';

class CustomButton extends StatelessWidget {
  CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.leading,
    this.textStyle,
    this.heightBtn,
    this.widthBtn,
    this.radius,
    this.backgroundColor,
    this.borderColor,
    this.isBorder,
    this.isColor,
  });

  void Function()? onPressed;
  String? text;
  Widget? leading;
  TextStyle? textStyle;
  double? radius;
  double? widthBtn;
  double? heightBtn;
  Color? backgroundColor;
  Color? borderColor;
  bool? isBorder;
  bool? isColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: heightBtn ?? Dimens.fourtyFive,
        width: widthBtn ?? double.maxFinite,
        decoration: BoxDecoration(
          color: backgroundColor ?? ColorsValue.appColor,
          borderRadius: BorderRadius.circular(radius ?? Dimens.ten),
          border: isBorder ?? false
              ? Border.all(
                  width: Dimens.one,
                  color: borderColor ?? ColorsValue.appColor,
                )
              : Border.all(
                  width: Dimens.one,
                  color: borderColor ?? ColorsValue.transparent,
                ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leading != null) ...[
                Container(child: leading),
                Dimens.boxWidth8,
              ],
              Text(text ?? "", style: textStyle),
            ],
          ),
        ),
      ),
    );
  }
}
