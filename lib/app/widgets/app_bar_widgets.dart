import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:agro_app/app/app.dart';

// ignore: must_be_immutable
class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  AppBarWidget({
    super.key,
    required this.onTapBack,
    required this.title,
    this.isVisible = true,
    this.isCenter = false,
    this.actions,
    this.backgroundColor,
  });

  void Function()? onTapBack;
  String title;
  bool isVisible;
  bool isCenter;
  List<Widget>? actions;
  Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? ColorsValue.appBg,
      centerTitle: isCenter ? true : false,
      automaticallyImplyLeading: false,
      leadingWidth: isVisible ? Dimens.fifty : Dimens.twenty,
      leading: Visibility(
        visible: isVisible,
        child: Padding(
          padding: Dimens.edgeInsets12,
          child: InkWell(
            onTap: onTapBack,
            child: SvgPicture.asset(AssetConstants.back_arrow),
          ),
        ),
      ),
      titleSpacing: Dimens.zero,
      title: Text(title, style: Styles.txtBlackColorW70020),
      actions: actions,
    );
  }

  static final _appBar = AppBar();

  @override
  Size get preferredSize => AppBarWidget._appBar.preferredSize;
}
