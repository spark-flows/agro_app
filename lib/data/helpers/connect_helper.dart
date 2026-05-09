// coverage:ignore-file
import 'dart:convert';
import 'dart:io';

import 'package:agro_app/app/app.dart';
import 'package:agro_app/data/data.dart';
import 'package:agro_app/domain/domain.dart';
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

  Future<ResponseModel> getProductListApi({
    int page = 1,
    int limit = 10,
    String search = '',
    bool isLoading = false,
  }) async {
    String distributorId = await Utility.getSecureValue(
      LocalKeys.distributorId,
    );
    String role = await Utility.getSecureValue(LocalKeys.roleName);
    if (role.isEmpty) {
      final profileJson = await Utility.getSecureValue(LocalKeys.profileData);
      if (profileJson.isNotEmpty) {
        try {
          final decoded = json.decode(profileJson);
          role =
              decoded['roleid']?['rolename']?.toString() ??
              decoded['rolename']?.toString() ??
              '';
        } catch (_) {}
      }
    }

    final bool isAdmin =
        role.toLowerCase() == 'admin' ||
        role.toLowerCase() == 'is_admin' ||
        role == '1';

    var data = {
      'page': page,
      'limit': limit,
      'search': search.isNotEmpty ? {'name': search} : {},
      'distributorid': (distributorId.isNotEmpty && !isAdmin)
          ? [distributorId]
          : [],
      'categoryid': [],
      'name': [],
      'unit': [],
      'price': [],
      'description': [],
      'sortoption': -1,
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

  Future<ResponseModel> getCategoryListApi({bool isLoading = false}) async {
    var response = await apiWrapper.makeRequest(
      '${EndPoints.categoryApi}?search=',
      Request.get,
      null,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> getUnitListApi({bool isLoading = false}) async {
    var response = await apiWrapper.makeRequest(
      '${EndPoints.unitApi}?search=',
      Request.get,
      null,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> createProductApi({
    String? productid,
    required String name,
    required String unit,
    required int price,
    required String description,
    required String image,
    required String categoryid,
    required int qty,
    bool isLoading = false,
  }) async {
    var data = {
      'productid': productid ?? '',
      'name': name,
      'unit': unit,
      'price': price,
      'description': description,
      'image': image,
      'qty': qty,
      'categoryid': categoryid,
    };
    var response = await apiWrapper.makeRequest(
      EndPoints.createProductApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> getCustomerListApi({
    int page = 1,
    int limit = 100,
    String search = "",
    bool isLoading = false,
  }) async {
    String distributorId = await Utility.getSecureValue(
      LocalKeys.distributorId,
    );

    // ── Step 1: Try LocalKeys.roleName directly ──────────────────────────────
    String role = await Utility.getSecureValue(LocalKeys.roleName);
    print('[CustomerList] Step1 - LocalKeys.roleName = "$role"');

    // ── Step 2: Try parsing from cached profileData JSON ─────────────────────
    if (role.isEmpty) {
      final profileJson = await Utility.getSecureValue(LocalKeys.profileData);
      print(
        '[CustomerList] Step2 - profileData length = ${profileJson.length}',
      );
      if (profileJson.isNotEmpty) {
        try {
          final decoded = json.decode(profileJson);
          role =
              decoded['roleid']?['rolename']?.toString() ??
              decoded['rolename']?.toString() ??
              '';
          print('[CustomerList] Step2 - parsed role = "$role"');
        } catch (e) {
          print('[CustomerList] Step2 - parse error: $e');
        }
      }
    }

    // ── Step 3: Last resort — call profile API directly ───────────────────────
    if (role.isEmpty) {
      print('[CustomerList] Step3 - calling profile API directly');
      try {
        final profileRes = await getProfileApi(isLoading: false);
        if (!profileRes.hasError && profileRes.data.isNotEmpty) {
          final decodedProfile = json.decode(profileRes.data);
          final userData = decodedProfile['Data']?['userData'];
          if (userData != null) {
            role =
                userData['roleid']?['rolename']?.toString() ??
                userData['rolename']?.toString() ??
                '';
            print('[CustomerList] Step3 - profile API returned role = "$role"');
            // Save for next time
            if (role.isNotEmpty) {
              Get.find<Repository>().saveSecureValue(LocalKeys.roleName, role);
            }
            final freshDistId = userData['_id']?.toString() ?? '';
            if (freshDistId.isNotEmpty && distributorId.isEmpty) {
              distributorId = freshDistId;
              Get.find<Repository>().saveSecureValue(
                LocalKeys.distributorId,
                freshDistId,
              );
            }
          }
        }
      } catch (e) {
        print('[CustomerList] Step3 - profile API error: $e');
      }
    }

    final isAdmin =
        role.toLowerCase() == 'admin' ||
        role.toLowerCase() == 'is_admin' ||
        role == '1';

    print(
      '[CustomerList] Final - role="$role", isAdmin=$isAdmin, distributorId="$distributorId"',
    );

    var data = {
      "page": page,
      "limit": limit,
      "search": search.isNotEmpty ? {"name": search} : {},
      "distributorid": isAdmin
          ? []
          : (distributorId.isNotEmpty ? [distributorId] : []),
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
    required String village,
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
      "village": village,
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

  Future<ResponseModel> deleteCustomerApi({
    required String customerid,
    bool isLoading = false,
  }) async {
    var data = {"customerid": customerid};
    var response = await apiWrapper.makeRequest(
      EndPoints.deleteCustomerApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> customerFeedbackApi({
    required String customerid,
    required String feedback,
    bool isLoading = false,
  }) async {
    var data = {"customerid": customerid, "feedback": feedback};
    var response = await apiWrapper.makeRequest(
      EndPoints.customerFeedbackApi,
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

  Future<ResponseModel> getOrderListApi({
    String? customerid,
    bool isLoading = false,
  }) async {
    var distributorId = await Utility.getSecureValue(LocalKeys.distributorId);
    var data = {
      "page": 1,
      "limit": 100,
      "search": {},
      "distributorid": distributorId.isNotEmpty ? [distributorId] : [],
      "customerid": customerid != null && customerid.isNotEmpty
          ? [customerid]
          : [],
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
    var data = {"orderid": orderid};
    var response = await apiWrapper.makeRequest(
      EndPoints.getOneOrderApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> deleteOrderApi({
    required String orderid,
    bool isLoading = false,
  }) async {
    var data = {"orderid": orderid};
    var response = await apiWrapper.makeRequest(
      EndPoints.deleteOrderApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> deleteProductApi({
    required String productid,
    bool isLoading = false,
  }) async {
    var data = {"productid": productid};
    var response = await apiWrapper.makeRequest(
      EndPoints.deleteProductApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> deleteUsersApi({
    required String userid,
    bool isLoading = false,
  }) async {
    var data = {"userid": userid};
    var response = await apiWrapper.makeRequest(
      EndPoints.deleteUsersApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> getUsersListApi({
    int page = 1,
    int limit = 10,
    String search = "",
    String sortfield = "_id",
    int sortoption = -1,
    String roleid = "",
    bool isLoading = false,
  }) async {
    var data = {
      "page": page,
      "limit": limit,
      "search": search.isNotEmpty ? {"name": search} : {},
      "sortfield": sortfield,
      "sortoption": sortoption,
      "roleid": roleid,
      "branchid": "",
    };
    var response = await apiWrapper.makeRequest(
      EndPoints.usersApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> getAllRolesApi({
    String search = "",
    bool isLoading = false,
  }) async {
    var response = await apiWrapper.makeRequest(
      '${EndPoints.rolesApi}?search=$search',
      Request.get,
      null,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> createUserApi({
    String? userid,
    required String name,
    required String email,
    required String countrycode,
    required String mobile,
    required String address,
    String? password,
    required String roleid,
    String? surname,
    String? fathername,
    String? gstnumber,
    String? location,
    String? bankname,
    String? bankaccountnumber,
    String? bankifsscode,
    bool isLoading = false,
  }) async {
    var data = {
      "userid": userid ?? "",
      "name": name,
      "email": email,
      "countrycode": countrycode,
      "mobile": mobile,
      "password": password ?? "",
      "location": address,
      "roleid": roleid,
      if (surname != null && surname.isNotEmpty) "surname": surname,
      if (fathername != null && fathername.isNotEmpty) "fathername": fathername,
      if (gstnumber != null && gstnumber.isNotEmpty) "gstnumber": gstnumber,
      // if (location != null && location.isNotEmpty) "location": location,
      if (bankname != null && bankname.isNotEmpty) "bankname": bankname,
      if (bankaccountnumber != null && bankaccountnumber.isNotEmpty)
        "bankaccountnumber": bankaccountnumber,
      if (bankifsscode != null && bankifsscode.isNotEmpty)
        "bankifsscode": bankifsscode,
    };
    var response = await apiWrapper.makeRequest(
      EndPoints.createUsersApi,
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
