import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:agro_app/app/app.dart';
import 'package:agro_app/data/data.dart';
import 'package:agro_app/domain/domain.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class Utility {
  //Internet Connection Checker
  static Future<bool> isNetworkAvailable() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }

    try {
      // Try a DNS lookup to confirm internet access
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static bool isTablet() {
    final width = Get.width;
    return width >= 600; // commonly used threshold for tablets
  }

  //ApiHeader
  static Future<Map<String, String>> commonHeader({
    Map<String, String>? otherHeader,
    bool isDefaultAuthorizationKeyAdd = true,
  }) async {
    var header = <String, String>{'Content-Type': 'application/json'};
    if (isDefaultAuthorizationKeyAdd) {
      String token = await Get.find<Repository>().getSecureValue(
        LocalKeys.authToken,
      );
      header.addAll({'Authorization': 'Bearer $token'});
    }
    if (otherHeader != null) {
      header.addAll(otherHeader);
    }
    return header;
  }

  /// Read a value from secure storage
  static Future<String> getSecureValue(String key) async {
    return await Get.find<Repository>().getSecureValue(key);
  }

  //Password validation
  static String? validatePassword(String value) {
    if (value.trim().isNotEmpty) {
      if (value.contains(RegExp(r'[A-Z]'))) {
        if (value.contains(RegExp(r'[0-9]'))) {
          if (value.length < 6) {
            return 'Should Be 6 Characters'.tr;
          } else {
            return null;
          }
        } else {
          return 'Should Have OneDigit'.tr;
        }
      } else {
        return 'Should Have One Uppercase Letter'.tr;
      }
    } else {
      return 'Password Required'.tr;
    }
  }

  //Email validation
  static bool emailValidation(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    return (!regex.hasMatch(value)) ? false : true;
  }

  //Remove All Html Tag
  static String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlText.replaceAll(exp, '');
  }

  /// createDate '2018-04-10T04:00:00.000Z' To Time
  static String getFormatedTime(
    String dateTime,
    String dateTimeformat, {
    String? dateFormat,
  }) {
    var date = dateFormat != null
        ? DateFormat(dateFormat).parse(dateTime)
        : DateTime.parse(dateTime);
    var format = DateFormat(dateTimeformat);
    return format.format(date);
  }

  // String time to utc
  static String getFormatedTimeUTC(String dateTime, String dateTimeformat) {
    var dateFormat = DateFormat("yyyy-MM-dd hh:mm:ss a");
    DateTime dates = dateFormat.parse(dateTime);

    // Convert to UTC and format as ISO 8601
    String isoFormat = dates.toUtc().toIso8601String();

    return isoFormat;
  }

  // DateTime To Iso
  static String convertIsoStringToFormatted(DateTime utcString) {
    DateTime localDateTime = utcString.toLocal();
    String formattedLocalTime = DateFormat(
      "yyyy-MM-dd hh:mm:ss a",
    ).format(localDateTime);

    return formattedLocalTime;
  }

  // String datetIME TO ISO
  static String convertLocalStringToIso(String inputDate) {
    // Parse the input date string
    DateTime dateTime = DateFormat('yyyy-MM-dd hh:mm:ss a').parse(inputDate);
    // Convert to ISO 8601 string
    return dateTime.toUtc().toIso8601String();
    // Output: 2024-10-19T10:29:12.000Z
  }

  static String formatToTime(String isoDate) {
    final date = DateTime.parse(isoDate).toLocal();
    return DateFormat('hh:mm a').format(date);
  }

  //Timestemp to Time & Date
  static String parseTimeStampToTime(int value, String dateTimeformat) {
    var date = DateTime.fromMillisecondsSinceEpoch(value);
    var d12 = DateFormat(dateTimeformat).format(date);
    return d12;
  }

  /// Calculates number of weeks for a given year as per https://en.wikipedia.org/wiki/ISO_week_date#Weeks_per_year
  static int _numOfWeeks(int year) {
    var dec28 = DateTime(year, 12, 28);
    var dayOfDec28 = int.parse(DateFormat('D').format(dec28));
    return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
  }

  // Calculates week number from a date as per https://en.wikipedia.org/wiki/ISO_week_date#Calculation
  static int weekNumber(DateTime date) {
    var dayOfYear = int.parse(DateFormat('D').format(date));
    var woy = ((dayOfYear - date.weekday + 10) / 7).floor();
    if (woy < 1) {
      woy = _numOfWeeks(date.year - 1);
    } else if (woy > _numOfWeeks(date.year)) {
      woy = 1;
    }
    return woy;
  }

  /// URL Launcher
  static void launchLinkURL(String url) async {
    await launchUrl(Uri.parse(url)).onError((error, stackTrace) {
      print("Url is not valid!");
      return false;
    });
  }

  /// Show loader
  static void showLoader() async {
    if (Get.isDialogOpen == true) {
      Get.back<void>();
    }
    await Get.dialog<dynamic>(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7),
    );
  }

  static Widget loaderWidget() =>
      const Center(child: CircularProgressIndicator());

  /// Close loader
  static void closeLoader() {
    closeDialog();
  }

  /// Close any open dialog.
  static void closeDialog() {
    if (Get.isDialogOpen == true) {
      Get.back<void>();
    }
  }

  static String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Close any open snackbar
  static void closeSnackbar() {
    if (Get.isSnackbarOpen) {
      Get.back<void>();
    }
  }

  /// Returns Platform type
  static String platFormType() {
    var value = kIsWeb
        ? 3
        : GetPlatform.isAndroid
        ? 1
        : 2;
    return value.toString();
  }

  /// Random number generator
  static int getRandomNumer(int num) {
    var random = Random();
    return random.nextInt(num);
  }

  /// Return file size
  static String getFileSize(int size) {
    if (size == 0) {
      return '0 KB';
    } else {
      var val = size / pow(1024, (log(size) / log(1024)).floor());
      if (size < 1024) {
        return '$val KB';
      } else {
        return '${val.toStringAsFixed(1)} MB';
      }
    }
  }

  ////imageOptimization
  static String imageOptimization({
    required String bucket,
    required String url,
    required int width,
    required int height,
    required int quality,
    bool progressive = true,
    bool mozjpeg = true,
    required int blur,
  }) {
    var map = '';
    if (blur == 0) {
      map =
          '{"bucket": "$bucket","key": "$url","edits": {"resize": {"width": $width},"jpeg": {"quality": $quality,"progressive": $progressive,"mozjpeg": $mozjpeg}}}';
    } else {
      map =
          '{"bucket": "$bucket","key": "$url","edits": {"resize": {"width": $width},"jpeg": {"quality": $quality,"progressive": $progressive,"mozjpeg": $mozjpeg},"blur": $blur}}';
    }
    var data = base64Encode(utf8.encode(map));
    return data;
  }

  /// imageOptimizationWithoutSize
  static String imageOptimizationWithoutSize({
    required String bucket,
    required String key,
    required int quality,
    required bool progressive,
    required bool mozjpeg,
    required int blur,
  }) {
    var map = '';
    if (blur == 0) {
      map =
          '{"bucket": "$bucket","key": "$key","edits": {"jpeg": {"quality": $quality,"progressive": $progressive,"mozjpeg": $mozjpeg}}}';
    } else {
      map =
          '{"bucket": "$bucket","key": "$key","edits": {"jpeg": {"quality": $quality,"progressive": $progressive,"mozjpeg": $mozjpeg},"blur": $blur}}';
    }
    var data = base64Encode(utf8.encode(map));
    return data;
  }

  // Check Dark/Light Mode
  static bool isThemeDarkMode() {
    var repository = Get.find<Repository>();
    var themeMode = repository.getStoredValue(LocalKeys.isThemeDarkMode);
    return themeMode;
  }

  /// Compare password & confirm password.
  static bool comparePasswords(String password, String confirmPassword) {
    if (password == confirmPassword) {
      return true;
    }
    return false;
  }

  //Showmessage Type
  static void showMessage(
    String? message,
    MessageType messageType,
    Function()? onTap,
    String actionName,
  ) {
    if (message == null || message.isEmpty) return;
    closeSnackbar();
    var backgroundColor = Colors.black;
    switch (messageType) {
      case MessageType.error:
        backgroundColor = Colors.red;
        break;
      case MessageType.information:
        backgroundColor = Colors.black.withValues(alpha: 0.3);
        break;
      case MessageType.success:
        backgroundColor = Colors.green;
        break;
    }
    Future.delayed(const Duration(seconds: 0), () {
      Get.rawSnackbar(
        snackPosition: SnackPosition.TOP,
        messageText: Text(message, style: const TextStyle(color: Colors.white)),
        mainButton: TextButton(
          onPressed: onTap ?? Get.back,
          child: Text(actionName, style: const TextStyle(color: Colors.white)),
        ),
        backgroundColor: backgroundColor,
        margin: const EdgeInsets.all(15.0),
        borderRadius: 15,
        snackStyle: SnackStyle.FLOATING,
      );
    });
  }

  /// Show Error bottomsheet.
  ///
  static void showErrorBottomSheet({
    required String? message,
    Function()? onPress,
    bool isDismissible = true,
    bool autoDismiss = true,
  }) async {
    await Get.bottomSheet<void>(
      Container(
        padding: Dimens.edgeInsets30,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$message',
              style: Styles.txtBlackColorW70020.copyWith(
                color: const Color.fromRGBO(235, 87, 87, 1),
              ),
            ),
            Dimens.boxHeight10,
          ],
        ),
      ),
      backgroundColor: const Color.fromRGBO(255, 206, 206, 1),
      isScrollControlled: true,
      isDismissible: isDismissible,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
    ).timeout(
      const Duration(seconds: 4),
      onTimeout: () {
        if (autoDismiss) {
          if (Get.isBottomSheetOpen!) {
            Get.back<void>();
          }
        }
      },
    );
  }

  /// Method For Get Floated Snack Bar
  static void getRawSnackBar(String message, Color backgroundColor) async {
    Get.rawSnackbar(
      message: message,
      mainButton: TextButton(
        onPressed: Get.back,
        child: Text('okay'.tr, style: const TextStyle(color: Colors.white)),
      ),
      backgroundColor: backgroundColor,
      margin: const EdgeInsets.all(15.0),
      borderRadius: 15,
      snackStyle: SnackStyle.FLOATING,
    );
  }

  // SnackBar
  static void snacBar(String message, Color backgroundColor) async {
    Get.rawSnackbar(
      message: message,
      backgroundColor: backgroundColor,
      margin: const EdgeInsets.all(15.0),
      borderRadius: 15,
      snackStyle: SnackStyle.FLOATING,
      snackPosition: SnackPosition.TOP,
    );
  }

  // Error Message
  static errorMessage(String message) async {
    return Get.rawSnackbar(
      title: "Error",
      message: message.isNotEmpty ? message : "Internal server error",
      backgroundColor: Colors.red.shade400,
      snackPosition: SnackPosition.TOP,
      icon: const Icon(Icons.error, color: Colors.white70),
      shouldIconPulse: true,
      instantInit: true,
    );
  }

  static copyText(text) {
    Clipboard.setData(ClipboardData(text: text));
    snacBar("Copied to clipboard.", ColorsValue.appColor);
  }

  /// Document Type List For Every Platform
  static List<String> docsTypeList = [
    'zip',
    'txt',
    'rar',
    'pdf',
    'csv',
    'doc',
    'xls',
    'ppt',
    'tar',
    'tar.gz',
    'odp',
    'ods',
    'odt',
    'docx',
    'pptx',
    'xlsx',
    '7z',
  ];

  /// video Type List For Every Platform
  static List<String> videoTypeList = [
    'webm',
    'mkv',
    'flv',
    'vob',
    'ogv',
    'ogg',
    'rrc',
    'gifv',
    'mng',
    'mov',
    'avi',
    'qt',
    'wmv',
    'yuv',
    'rm',
    'asf',
    'amv',
    'mp4',
    'm4p',
    'm4v',
    'mpg',
    'mp2',
    'mpeg',
    'mpe',
    'mpv',
    'm4v',
    'svi',
    '3gp',
    '3g2',
    'mxf',
    'roq',
    'nsv',
    'flv',
    'f4v',
    'f4p',
    'f4a',
    'f4b',
    'mod',
  ];

  /// Image Type List For Every Platform
  static List<String> imageTypeList = [
    'ase',
    'art',
    'bmp',
    'blp',
    'cd5',
    'cit',
    'cpt',
    'cr2',
    'cut',
    'dds',
    'dib',
    'djvu',
    'egt',
    'exif',
    'gif',
    'gpl',
    'grf',
    'icns',
    'ico',
    'iff',
    'jng',
    'jpeg',
    'jpg',
    'jfif',
    'jp2',
    'jps',
    'lbm',
    'max',
    'miff',
    'mng',
    'msp',
    'nitf',
    'ota',
    'pbm',
    'pc1',
    'pc2',
    'pc3',
    'pcf',
    'pcx',
    'pdn',
    'pgm',
    'PI1',
    'PI2',
    'PI3',
    'pict',
    'pct',
    'pnm',
    'pns',
    'ppm',
    'psb',
    'psd',
    'pdd',
    'psp',
    'px',
    'pxm',
    'pxr',
    'qfx',
    'raw',
    'rle',
    'sct',
    'sgi',
    'rgb',
    'int',
    'bw',
    'tga',
    'tiff',
    'tif',
    'vtf',
    'xbm',
    'xcf',
    'xpm',
    '3dv',
    'amf',
    'ai',
    'awg',
    'cgm',
    'cdr',
    'cmx',
    'dxf',
    'e2d',
    'egt',
    'eps',
    'fs',
    'gbr',
    'odg',
    'svg',
    'stl',
    'vrml',
    'x3d',
    'sxd',
    'v2d',
    'vnd',
    'wmf',
    'emf',
    'art',
    'xar',
    'png',
    'webp',
    'jxr',
    'hdp',
    'wdp',
    'cur',
    'ecw',
    'iff',
    'lbm',
    'liff',
    'nrrd',
    'pam',
    'pcx',
    'pgf',
    'sgi',
    'rgb',
    'rgba',
    'bw',
    'int',
    'inta',
    'sid',
    'ras',
    'sun',
    'tga',
  ];

  /// Method For Convert URL to local path and save in local
  static Future<File> imageURLToFile({required String imageUrl}) async {
    // generate random number.
    var rng = Random();
    // get temporary directory of device.
    var tempDir = await getTemporaryDirectory();
    // get temporary path from temporary directory.
    var tempPath = tempDir.path;
    // create a new file in temporary path with random file name.
    var file = File('$tempPath${rng.nextInt(100)}.png');
    // call http.get method and pass imageUrl into it to get response.
    var response = await http.get(Uri.parse(imageUrl));
    // write bodyBytes received in response to file.
    await file.writeAsBytes(response.bodyBytes);
    // now return the file which is created with random name in
    // temporary directory and image bytes from response is written to // that file.
    return file;
  }

  /// Method For Image Get URL to Bytes
  static Future<Uint8List> urlToBytes({required String imageURL}) async {
    final data = await NetworkAssetBundle(Uri.parse(imageURL)).load(imageURL);
    final bytes = data.buffer.asUint8List();
    return bytes;
  }

  /// Method For Convert Duration To String
  static String durationToString({required Duration duration}) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    var twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    var twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    var hour = num.parse(twoDigits(duration.inHours));
    if (hour > 0) {
      return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
    } else {
      return '$twoDigitMinutes:$twoDigitSeconds';
    }
  }

  /// Age Calculator Method
  static int calculateAge(DateTime birthDate) {
    var currentDate = DateTime.now();
    var age = currentDate.year - birthDate.year;
    var month1 = currentDate.month;
    var month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      var day1 = currentDate.day;
      var day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

  // Get File Extension
  static String getFileExtension(String fileName) {
    try {
      return ".${fileName.split('.').last}";
    } catch (e) {
      return "";
    }
  }

  // Date to get today,yesterday string
  static String dateTimeTodayWithDate(timeDate) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timeDate);

    final DateTime dtToday = DateTime.now();
    final DateTime dtYesterday = DateTime.now().subtract(
      const Duration(days: 1),
    );
    final DateFormat formatter = DateFormat("dd-MM-yyyy");
    final DateFormat formatterDateTime = DateFormat("dd,MMMM yyyy hh:mm a");
    final DateFormat timeFormat = DateFormat("hh:mm a");

    return formatter.format(dateTime) == formatter.format(dtToday)
        ? "Today ${timeFormat.format(dateTime)}"
        : formatter.format(dateTime) == formatter.format(dtYesterday)
        ? "Yesterday ${timeFormat.format(dateTime)}"
        : formatterDateTime.format(dateTime);
  }

  // DateTime.now() to enter time minutes get
  static bool timeToNext(sendTime) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(sendTime);

    String timeApi = DateFormat('hh-mm').format(dateTime);
    DateTime currentTime = DateTime.now();

    DateTime targetTime = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
      int.parse(timeApi.split('-').first),
      int.parse(timeApi.split('-').last),
    );

    bool within10Minutes =
        currentTime.isAfter(targetTime.subtract(const Duration(minutes: 10))) &&
        currentTime.isBefore(targetTime.add(const Duration(minutes: 10)));

    return within10Minutes;
  }

  // Date to get today,yesterday string
  static String timestempToTime(int time) {
    var dt = DateTime.fromMillisecondsSinceEpoch(time);

    final todayDate = DateTime.now();

    final today = DateTime(todayDate.year, todayDate.month, todayDate.day);
    final yesterday = DateTime(
      todayDate.year,
      todayDate.month,
      todayDate.day - 1,
    );
    String difference = '';
    final aDate = DateTime(dt.year, dt.month, dt.day);

    if (aDate == today) {
      difference = "Today";
    } else if (aDate == yesterday) {
      difference = "Yesterday";
    } else {
      difference = DateFormat.yMMMd().format(dt).toString();
    }

    return difference;
  }

  // Enter date to time ago time
  static String timeAgo(String d) {
    var date = DateTime.fromMillisecondsSinceEpoch(int.parse(d));
    var d12 = DateFormat('yyyy-MM-ddThh:mm:ss').format(date);

    DateTime dateTime = DateTime.parse(d12);
    Duration diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 365) {
      return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "year" : "years"} ago";
    }
    if (diff.inDays > 30) {
      return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "month" : "months"} ago";
    }
    if (diff.inDays > 7) {
      return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "week" : "weeks"} ago";
    }
    if (diff.inDays > 0) {
      return "${diff.inDays} ${diff.inDays == 1 ? "day" : "days"} ago";
    }
    if (diff.inHours > 0) {
      return "${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago";
    }
    if (diff.inMinutes > 0) {
      return "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
    }
    return "just now";
  }

  static int textCharCount(String title) {
    return title.length;
  }

  /// Image And Video Permssion Cheack
  static Future<bool> imagePermissionCheack(BuildContext context) async {
    bool status = false;
    bool statusVideos = false;
    bool permanentlyDenied = false;
    bool permanentlyVideoDenied = false;
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt < 33) {
        status = await Permission.storage.request().isDenied;
        permanentlyDenied = await Permission.storage
            .request()
            .isPermanentlyDenied;
      } else {
        status = await Permission.photos.request().isDenied;
        permanentlyDenied = await Permission.photos
            .request()
            .isPermanentlyDenied;
        statusVideos = await Permission.videos.request().isDenied;
        permanentlyVideoDenied = await Permission.videos
            .request()
            .isPermanentlyDenied;
      }
    } else {
      status = await Permission.photos.request().isDenied;
      permanentlyDenied = await Permission.photos.request().isPermanentlyDenied;
    }
    if (status || permanentlyDenied || statusVideos || permanentlyVideoDenied) {
      Get.dialog(
        barrierDismissible: false,
        AlertDialog(
          title: Text("Permission Needed!", style: Styles.black50018),
          content: Text(
            "Please give the Photos Permission for uploading the image.",
            style: Styles.redColor50014,
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Allow", style: Styles.redColor50014),
              onPressed: () async {
                Get.back();
                await openAppSettings();
              },
            ),
            TextButton(
              child: Text("Deny", style: Styles.black50014),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        ),
      );
      return false;
    } else {
      return true;
    }
  }

  /// Camera Permission Check
  static Future<bool> cameraPermissionCheack(BuildContext context) async {
    // Request ONCE and inspect the single result
    final PermissionStatus status = await Permission.camera.request();

    if (status.isGranted || status.isLimited) {
      return true;
    }

    // Denied or permanently denied — show dialog
    Get.dialog(
      barrierDismissible: false,
      AlertDialog(
        title: Text("Permission Needed!", style: Styles.black50018),
        content: Text(
          "Please give the Camera Permission to capture an image.",
          style: Styles.redColor50014,
        ),
        actions: <Widget>[
          TextButton(
            child: Text("Allow", style: Styles.redColor50014),
            onPressed: () async {
              Get.back();
              await openAppSettings();
            },
          ),
          TextButton(
            child: Text("Deny", style: Styles.black50014),
            onPressed: () {
              Get.back();
            },
          ),
        ],
      ),
    );
    return false;
  }

  /// Audio Permission
  static Future<bool> audioPermissionCheack(BuildContext context) async {
    final bool status;
    bool permanentlyDenied;
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt < 33) {
        status = await Permission.storage.request().isDenied;
        permanentlyDenied = await Permission.storage
            .request()
            .isPermanentlyDenied;
      } else {
        status = await Permission.audio.request().isDenied;
        permanentlyDenied = await Permission.audio
            .request()
            .isPermanentlyDenied;
      }
    } else {
      status = await Permission.microphone.request().isDenied;
      permanentlyDenied = await Permission.microphone
          .request()
          .isPermanentlyDenied;
    }
    if (status || permanentlyDenied) {
      Get.dialog(
        barrierDismissible: false,
        AlertDialog(
          title: Text("Permission Needed!", style: Styles.black50018),
          content: Text(
            "Please give the Audio Permission for uploading the audio.",
            style: Styles.redColor50014,
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Allow", style: Styles.redColor50014),
              onPressed: () async {
                Get.back();
                await openAppSettings();
              },
            ),
            TextButton(
              child: Text("Deny", style: Styles.black50014),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        ),
      );
      return false;
    } else {
      return true;
    }
  }

  /// Microphone Permission
  static Future<bool> microphonePermissionCheack(BuildContext context) async {
    final bool status;
    bool permanentlyDenied;
    status = await Permission.microphone.request().isDenied;
    permanentlyDenied = await Permission.microphone
        .request()
        .isPermanentlyDenied;
    // }
    if (status || permanentlyDenied) {
      Get.dialog(
        barrierDismissible: false,
        AlertDialog(
          title: Text("Permission Needed!", style: Styles.black50018),
          content: Text(
            "Please give the Microphone Permission for voice call.",
            style: Styles.redColor50014,
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Allow", style: Styles.redColor50014),
              onPressed: () async {
                Get.back();
                await openAppSettings();
              },
            ),
            TextButton(
              child: Text("Deny", style: Styles.black50014),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        ),
      );
      return false;
    } else {
      return true;
    }
  }

  /// FilePicker Permission
  static Future<bool> filePickPermissionCheack() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final bool status;
    bool permanentlyDenied;
    if (Platform.isIOS) {
      status = await Permission.storage.request().isDenied;
      permanentlyDenied = await Permission.storage
          .request()
          .isPermanentlyDenied;
    } else {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      if (androidInfo.version.sdkInt < 33) {
        status = await Permission.storage.request().isDenied;
        permanentlyDenied = await Permission.storage
            .request()
            .isPermanentlyDenied;
      } else {
        status = await Permission.photos.request().isDenied;
        permanentlyDenied = await Permission.photos
            .request()
            .isPermanentlyDenied;
      }
    }
    if (status || permanentlyDenied) {
      Get.dialog(
        barrierDismissible: false,
        AlertDialog(
          title: Text("Permission Needed!", style: Styles.black50018),
          content: Text(
            "Please give the Storage Permission for uploading the File.",
            style: Styles.redColor50014,
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Allow", style: Styles.redColor50014),
              onPressed: () async {
                Get.back();
                await openAppSettings();
              },
            ),
            TextButton(
              child: Text("Deny", style: Styles.black50014),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        ),
      );
      return false;
    } else {
      return true;
    }
  }

  /// Location Permission
  static Future<bool> locationPermissionCheack() async {
    final status = await Permission.locationWhenInUse.request().isDenied;
    var permanentlyDenied = await Permission.locationWhenInUse
        .request()
        .isPermanentlyDenied;
    if (status || permanentlyDenied) {
      // ignore: use_build_context_synchronously
      Get.dialog(
        barrierDismissible: false,
        AlertDialog(
          title: Text("Permission Needed!", style: Styles.black50018),
          content: Text(
            "Please give the Location Permission for Current Location.",
            style: Styles.redColor50014,
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Allow", style: Styles.redColor50014),
              onPressed: () async {
                Get.back();
                await openAppSettings();
              },
            ),
            TextButton(
              child: Text("Deny", style: Styles.black50014),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        ),
      );
      return false;
    } else {
      return true;
    }
  }

  /// Contact Permission
  static Future<bool> contactPermissionCheack() async {
    final status = await Permission.contacts.request().isDenied;
    var permanentlyDenied = await Permission.contacts
        .request()
        .isPermanentlyDenied;
    if (status || permanentlyDenied) {
      // ignore: use_build_context_synchronously
      Get.dialog(
        barrierDismissible: false,
        AlertDialog(
          title: Text("Permission Needed!", style: Styles.black50018),
          content: Text(
            "Please give the Contacts Permission for get contact.",
            style: Styles.redColor50014,
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Allow", style: Styles.redColor50014),
              onPressed: () async {
                Get.back();
                await openAppSettings();
              },
            ),
            TextButton(
              child: Text("Deny", style: Styles.black50014),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        ),
      );
      return false;
    } else {
      return true;
    }
  }

  /// Notification Permission
  static Future<bool> notificationPermissionCheack() async {
    final status = await Permission.notification.request().isDenied;
    var permanentlyDenied = await Permission.notification
        .request()
        .isPermanentlyDenied;
    if (status || permanentlyDenied) {
      // ignore: use_build_context_synchronously
      Get.dialog(
        barrierDismissible: false,
        AlertDialog(
          title: Text("Permission Needed!", style: Styles.black50018),
          content: Text(
            "Please give the Notification Permission for notification.",
            style: Styles.redColor50014,
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Allow", style: Styles.redColor50014),
              onPressed: () async {
                Get.back();
                await openAppSettings();
              },
            ),
            TextButton(
              child: Text("Deny", style: Styles.black50014),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        ),
      );
      return false;
    } else {
      return true;
    }
  }

  // Image Fix Size Upload
  static double getImageSizeMB(String filePath) {
    var file = File(filePath);
    final bytes = file.readAsBytesSync().lengthInBytes;
    final kb = bytes / 1024;
    final mb = kb / 1024;
    return mb;
  }

  static Timer? timer;

  static showTimer() {
    timer?.cancel();
    timer = Timer(const Duration(seconds: 3), () {
      timer?.cancel();
    });
  }

  static showTimerCancle() {
    timer?.cancel();
  }

  /// main function
  static Future<String?> download({
    required String sourcePath,
    String folderName = "Downloads",
    String? customFileName,
  }) async {
    try {
      Uint8List bytes;

      /// STEP 1 → GET FILE BYTES
      if (_isNetworkFile(sourcePath)) {
        final uri = Uri.tryParse(sourcePath);
        if (uri == null || uri.host.isEmpty) {
          print("Invalid URL");
          return null;
        }

        final response = await http.get(uri);

        if (response.statusCode != 200) {
          print("Download failed → ${response.statusCode}");
          return null;
        }

        bytes = response.bodyBytes;
      } else {
        final file = File(sourcePath);

        if (!await file.exists()) {
          print("Local file not found");
          return null;
        }

        bytes = await file.readAsBytes();
      }

      /// STEP 2 → PERMISSION (ANDROID 13 SAFE)
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();

        if (!status.isGranted) {
          print("Storage permission denied");
          return null;
        }
      }

      /// STEP 3 → DIRECTORY (PLAY STORE SAFE PATH)
      final Directory baseDir = await _getSafeDirectory();

      final folder = Directory("${baseDir.path}/$folderName");
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      /// STEP 4 → FILE NAME
      String fileName =
          customFileName ?? sourcePath.split('/').last.split("?").first;

      if (fileName.isEmpty) {
        fileName = "file_${DateTime.now().millisecondsSinceEpoch}";
      }

      /// prevent overwrite
      String filePath = "${folder.path}/$fileName";
      int counter = 1;

      while (await File(filePath).exists()) {
        final name = fileName.split('.').first;
        final ext = fileName.contains(".")
            ? ".${fileName.split('.').last}"
            : "";

        filePath = "${folder.path}/${name}_$counter$ext";
        counter++;
      }

      /// STEP 5 → SAVE FILE
      final savedFile = File(filePath);
      await savedFile.writeAsBytes(bytes);

      print("Saved at → $filePath");

      return filePath;
    } catch (e) {
      print("Download Error → $e");
      return null;
    }
  }

  static Future<void> downloadPdf(String url) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath =
          '${dir.path}/invoice_${DateTime.now().millisecondsSinceEpoch}.pdf';

      await Dio().download(url, filePath);

      print('Downloaded to: $filePath');
      await OpenFilex.open(filePath);
    } catch (e) {
      print('Error downloading DOC: $e');
    }
  }

  static Future<Directory> _getSafeDirectory() async {
    if (Platform.isAndroid) {
      final dir = await getExternalStorageDirectory();
      return dir ?? await getApplicationDocumentsDirectory();
    } else {
      return await getApplicationDocumentsDirectory();
    }
  }

  /// check if URL or local file
  static bool _isNetworkFile(String path) {
    return path.startsWith("http") || path.startsWith("https");
  }

  /// get storage folder
  static Future<Directory> _getBaseDirectory() async {
    if (Platform.isAndroid) {
      return Directory("/storage/emulated/0/Download");
    } else {
      return await getApplicationDocumentsDirectory();
    }
  }

  //DownloadPdfFile and Save (legacy wrapper)
  static Future<void> downloadAndSavePDF(
    String url,
    String folderName,
    int invoiceNo,
  ) async {
    await downloadAndOpenFile(fileUrl: url, folderName: folderName);
  }

  /// Download any file from URL, save to device, show feedback, and open it.
  static Future<void> downloadAndOpenFile({
    required String fileUrl,
    String folderName = 'NPJ Whatsapp',
    bool openAfterDownload = true,
  }) async {
    try {
      if (fileUrl.isEmpty) {
        errorMessage("File URL is empty");
        return;
      }

      // Show loading
      showLoader();

      // Build full URL — handle relative paths properly
      String fullUrl;
      if (fileUrl.startsWith('http')) {
        fullUrl = fileUrl;
      } else {
        String base = ApiWrapper.api.endsWith('/')
            ? ApiWrapper.api.substring(0, ApiWrapper.api.length - 1)
            : ApiWrapper.api;
        String path = fileUrl.startsWith('/') ? fileUrl : '/$fileUrl';
        fullUrl = base + path;
      }

      final String fileName = fileUrl.split('/').last.split('?').first;
      final String safeFileName = fileName.isEmpty
          ? 'file_${DateTime.now().millisecondsSinceEpoch}'
          : fileName;

      debugPrint('Download URL: $fullUrl');

      // ── Permission check (Android only) ──────────────────────────────────
      if (Platform.isAndroid) {
        final info = await DeviceInfoPlugin().androidInfo;
        if (info.version.sdkInt <= 29) {
          // Android 9 and below need WRITE_EXTERNAL_STORAGE
          final status = await Permission.storage.request();
          if (!status.isGranted) {
            closeLoader();
            errorMessage("Storage permission is required to download files.");
            return;
          }
        }
        // Android 10–12: READ_EXTERNAL_STORAGE
        // Android 13+  : App-scoped external dir needs no extra permission
      }

      // ── Determine save directory ──────────────────────────────────────────
      Directory? saveDir;
      if (Platform.isAndroid) {
        // getExternalStorageDirectory() returns app-scoped external dir,
        // works on all Android versions without MANAGE_EXTERNAL_STORAGE.
        saveDir = await getExternalStorageDirectory();
        saveDir ??= await getApplicationDocumentsDirectory();
      } else {
        saveDir = await getApplicationDocumentsDirectory();
      }

      // Create subfolder
      final String folderPath = '${saveDir.path}/$folderName';
      await Directory(folderPath).create(recursive: true);

      // Unique file path (prevent overwrite)
      String filePath = '$folderPath/$safeFileName';
      int counter = 1;
      while (await File(filePath).exists()) {
        final name = safeFileName.contains('.')
            ? safeFileName.substring(0, safeFileName.lastIndexOf('.'))
            : safeFileName;
        final ext = safeFileName.contains('.')
            ? safeFileName.substring(safeFileName.lastIndexOf('.'))
            : '';
        filePath = '$folderPath/${name}_$counter$ext';
        counter++;
      }

      // ── Download using Dio ───────────────────────────────────────────────
      final dio = Dio();
      await dio.download(
        fullUrl,
        filePath,
        options: Options(
          receiveTimeout: const Duration(minutes: 5),
          sendTimeout: const Duration(minutes: 2),
        ),
      );

      // Close loader
      closeLoader();

      // Success feedback
      snacBar("$safeFileName downloaded successfully", Colors.green);

      // Open file
      if (openAfterDownload) {
        await OpenFilex.open(filePath);
      }
    } catch (e) {
      closeLoader();
      debugPrint('Download error: $e');
      errorMessage("Download failed: ${e.toString()}");
    }
  }

  static String formatTime(String apiTime) {
    DateTime dateTime = DateTime.parse(apiTime);
    return DateFormat('hh:mm a').format(dateTime);
  }

  static String convertUtcToIst(String utcTime) {
    try {
      // Parse UTC time
      DateTime utcDateTime = DateTime.parse(utcTime);

      // Convert to IST (UTC +5:30)
      DateTime istDateTime = utcDateTime.add(
        const Duration(hours: 5, minutes: 30),
      );

      // Format output (optional)
      return DateFormat('hh:mm a').format(istDateTime);
    } catch (e) {
      return "Invalid date";
    }
  }

  static String? validation({
    String? value,
    String? message,
    bool isEmailValidator = false,
    bool isPhone = false,
    bool isPasswordValidator = false,
  }) {
    if (value!.isEmpty) {
      return "Enter $message";
    }
    if (isEmailValidator == true) {
      if (value.isEmpty) {
        return "Enter $message";
      } else if (!RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{3,}))$',
      )
      // r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(value)) {
        return 'Enter Valid $message';
      }
    } else if (isPhone == true) {
      if (value.isEmpty) {
        return "Enter $message";
      } else if (value.length < 10) {
        return 'Enter Valid $message';
      }
    } else if (isPasswordValidator == true) {
      RegExp regex = RegExp(
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
      );
      if (value.isEmpty) {
        return "Enter $message";
      } else {
        if (!regex.hasMatch(value)) {
          return 'Must Contains 8+ chars, A-Z, a-z, 0-9, !@#\$&*~';
        } else {
          return null;
        }
      }
    }
    return null;
  }

  static void showDeleteDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
