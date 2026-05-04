import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agro_app/app/app.dart';

class ProfileWidget extends StatefulWidget {
  String? imagePath;
  final bool? isEdit;
  final bool? isSelected;
  Color? iconbackgroundcolor;
  Color? iconColor;
  final VoidCallback? onClicked;
  File? file;
  final Function(String? file)? onImageSelected;
  ProfileWidget({
    Key? key,
    this.onImageSelected,
    this.imagePath,
    this.isEdit = false,
    this.isSelected = false,
    this.onClicked,
    this.iconbackgroundcolor,
    this.iconColor,
    this.file,
  }) : super(key: key);

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          buildImage(),
          Positioned(
            right: 0,
            bottom: 0,
            child: buildEditIcon(
              widget.iconbackgroundcolor ?? ColorsValue.greyAAAAAA,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildImage() {
    return ClipOval(
      child: Material(
        color: ColorsValue.maincolor1,
        child: Padding(
          padding: Dimens.edgeInsets2,
          child: ClipOval(
            child: Material(
              color: ColorsValue.white,
              child: widget.isSelected!
                  ? Ink.image(
                      image: FileImage(widget.file!),
                      fit: BoxFit.cover,
                      width: 130,
                      height: 130,
                      child: InkWell(onTap: widget.onClicked),
                    )
                  : CachedNetworkImage(
                      imageUrl: widget.imagePath ?? '',
                      fit: BoxFit.cover,
                      maxHeightDiskCache: 300,
                      maxWidthDiskCache: 300,
                      width: 130,
                      height: 130,
                      placeholder: (context, url) => Center(
                        child: Image.asset(AssetConstants.usera, height: 130),
                      ),
                      errorWidget: (context, url, error) =>
                          Image.asset(AssetConstants.usera),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEditIcon(Color color) => buildCircle(
    color: ColorsValue.maincolor1,
    all: 0,
    child: GestureDetector(
      onTap: widget.onClicked,
      child: buildCircle(
        color: color,
        all: 10,
        child: SvgPicture.asset(
          AssetConstants.editicon,
          colorFilter: ColorFilter.mode(
            widget.iconColor ?? ColorsValue.white,
            BlendMode.srcIn,
          ),
        ),
      ),
    ),
  );

  Widget buildCircle({Widget? child, double? all, Color? color}) => ClipOval(
    child: Container(padding: EdgeInsets.all(all!), color: color, child: child),
  );

  // Future image(source) async {
  //   final imagepicker = await ImagePicker().pickImage(source: source);
  //   setState(() {
  //     if (imagepicker != null) {
  //       if (widget.onImageSelected != null) {
  //         widget.onImageSelected!(imagepicker.path);
  //         widget.imagePath = imagepicker.path;
  //       }
  //     }
  //   });
  // }
  pickImahe(source) async {
    final ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: source);
    if (file != null) {
      widget.imagePath = file.path;
      setState(() {});
    }
    print("on image selected");
  }
}
