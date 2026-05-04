// coverage:ignore-file
import 'dart:io';

import 'package:agro_app/app/app.dart';
import 'package:agro_app/data/data.dart';
import 'package:agro_app/domain/entities/enums.dart';
import 'package:agro_app/domain/models/response_model.dart';
import 'package:agro_app/domain/repositories/local_storage_keys.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

/// The helper class which will connect to the world to get the data.
class ConnectHelper {
  ConnectHelper() {
    _init();
  }

  late Dio dio;

  /// Api wrapper initialization
  final apiWrapper = ApiWrapper();

  /// Device info plugin initialization
  final deviceinfo = DeviceInfoPlugin();

  /// To get android device info
  AndroidDeviceInfo? androidDeviceInfo;

  /// To get iOS device info
  IosDeviceInfo? iosDeviceInfo;

  // IosDeviceInfo? iosDeviceInfo;

  // coverage:ignore-start
  /// initialize the andorid device information
  void _init() async {
    if (GetPlatform.isAndroid) {
      androidDeviceInfo = await deviceinfo.androidInfo;
    } else {
      iosDeviceInfo = await deviceinfo.iosInfo;
    }
    dio = Dio();
  }

  // coverage:ignore-end

  /// Device id
  String? get deviceId => GetPlatform.isAndroid
      ? androidDeviceInfo?.id
      : iosDeviceInfo?.identifierForVendor;

  /// Device make brand
  String? get deviceMake =>
      GetPlatform.isAndroid ? androidDeviceInfo?.brand : 'Apple';

  /// Device Model
  String? get deviceModel =>
      GetPlatform.isAndroid ? androidDeviceInfo?.model : iosDeviceInfo?.model;

  /// Device is a type of 1 for Android and 2 for iOS
  String get deviceTypeCode => GetPlatform.isAndroid ? '1' : '2';

  /// Device OS
  String get deviceOs => GetPlatform.isAndroid ? 'ANDROID' : 'IOS';

  /// API to get the IP of the user
  Future<String> getIp() async {
    var ip = '';
    if (await Utility.isNetworkAvailable()) {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          ip = addr.address;
        }
      }
      return ip.isNotEmpty ? ip : '0.0.0.0';
    }
    return '0.0.0.0';
  }

  Future<ResponseModel> loginApi({
    required String userName,
    required String password,
    required String fcmToken,
    bool isLoading = false,
  }) async {
    var data = {
      'username': userName,
      'password': password,
      'fcm_token': fcmToken,
    };
    var response = await apiWrapper.makeRequest(
      EndPoints.loginApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(isDefaultAuthorizationKeyAdd: false),
    );
    return response;
  }

  Future<ResponseModel> getProductListApi({bool isLoading = false}) async {
    var data = {
      "page": 1,
      "limit": 10,
      "search": {},
      "categoryid": [],
      "name": [],
      "unit": [],
      "price": [],
      "description": [],
      "sortoption": -1,
    };
    var response = await apiWrapper.makeRequest(
      EndPoints.productApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> getCustomerListApi({bool isLoading = false}) async {
    String distributorId = await Utility.getSecureValue(
      LocalKeys.distributorId,
    );
    var data = {
      "page": 1,
      "limit": 100,
      "search": {},
      "distributorid": distributorId.isNotEmpty ? [distributorId] : [],
      "name": [],
      "email": [],
      "countrycode": [],
      "mobile": [],
      "sortoption": -1,
    };
    var response = await apiWrapper.makeRequest(
      EndPoints.customerListApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> createCustomerApi({
    String? customerid,
    required String name,
    required String email,
    required String countrycode,
    required String mobile,
    required String feedback,
    bool isLoading = false,
  }) async {
    var distributorId = await Utility.getSecureValue(LocalKeys.distributorId);
    var data = {
      "customerid": customerid ?? "",
      "distributorid": distributorId,
      "name": name,
      "email": email,
      "countrycode": countrycode,
      "mobile": mobile,
      "feedback": feedback,
    };
    var response = await apiWrapper.makeRequest(
      EndPoints.createCustomerApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> getProfileApi({bool isLoading = false}) async {
    var response = await apiWrapper.makeRequest(
      EndPoints.profileApi,
      Request.get,
      null,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> getOrderListApi({String? customerid, bool isLoading = false}) async {
    var distributorId = await Utility.getSecureValue(LocalKeys.distributorId);
    var data = {
      "page": 1,
      "limit": 100,
      "search": {},
      "distributorid": distributorId.isNotEmpty ? [distributorId] : [],
      "customerid": customerid != null && customerid.isNotEmpty ? [customerid] : [],
      "orderno": [],
      "deliverydate": [],
      "totalamount": [],
      "sortoption": -1,
    };
    var response = await apiWrapper.makeRequest(
      EndPoints.orderListApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> createOrderApi({
    String? orderid,
    required String customerid,
    required List<Map<String, dynamic>> items,
    required num totalamount,
    String? deliverydate,
    String? feedback,
    bool isLoading = false,
  }) async {
    var distributorId = await Utility.getSecureValue(LocalKeys.distributorId);
    var data = {
      "orderid": orderid ?? "",
      "distributorid": distributorId,
      "customerid": customerid,
      "items": items,
      "deliverydate": deliverydate ?? "",
      "totalamount": totalamount.toString(),
      "feedback": feedback ?? "",
    };
    var response = await apiWrapper.makeRequest(
      EndPoints.createOrderApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> getOneOrderApi({
    required String orderid,
    bool isLoading = false,
  }) async {
    var data = {
      "orderid": orderid,
    };
    var response = await apiWrapper.makeRequest(
      EndPoints.getOneOrderApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }
}

class FileUrl {
  final String url;
  FileUrl({required this.url});

  factory FileUrl.fromJson(Map<String, dynamic> json) {
    return FileUrl(url: json['url'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {"url": url};
  }
}
