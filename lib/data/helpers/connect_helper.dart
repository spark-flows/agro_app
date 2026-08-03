// coverage:ignore-file
import 'dart:convert';
import 'dart:io';

import 'package:agro_app/app/app.dart';
import 'package:agro_app/data/data.dart';
import 'package:agro_app/domain/domain.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as media_type;
import 'package:image_picker/image_picker.dart';

/// The helper class which will connect to the world to get the data.
class ConnectHelper {
  ConnectHelper() {
    _init();
  }

  late Dio dio = Dio();

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
    if (kIsWeb) return;
    if (GetPlatform.isAndroid) {
      androidDeviceInfo = await deviceinfo.androidInfo;
    } else if (GetPlatform.isIOS) {
      iosDeviceInfo = await deviceinfo.iosInfo;
    }
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

    final bool isAdmin = RoleUtils.isAdmin(role);

    final String branchId = await _resolveBranchId();

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
      'branchid': branchId,
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
    final String branchId = await _resolveBranchId();
    var data = {
      'productid': productid ?? '',
      'name': name,
      'unitid': unit,
      'price': price,
      'description': description,
      'image': image,
      'quantity': qty,
      'categoryid': categoryid,
      'branchid': branchId,
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
    int limit = 10,
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

    final isAdmin = RoleUtils.isAdmin(role);

    print(
      '[CustomerList] Final - role="$role", isAdmin=$isAdmin, distributorId="$distributorId"',
    );

    final String branchId = await _resolveBranchId();

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
      "branchid": branchId,
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
    String? distributorid, // optional override for admin flow
    bool isLoading = false,
  }) async {
    // Use provided distributorid (admin) or fall back to logged-in dealer's ID
    final resolvedDistributorId =
        distributorid ?? await Utility.getSecureValue(LocalKeys.distributorId);
    final String branchId = await _resolveBranchId();
    var data = {
      "customerid": customerid ?? "",
      "distributorid": resolvedDistributorId,
      "name": name,
      "email": email,
      "countrycode": countrycode,
      "mobile": mobile,
      "feedback": feedback,
      "village": village,
      "branchid": branchId,
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

    final String normalizedRole = role.toLowerCase().trim();
    final bool isDealer =
        normalizedRole == 'dealer' || normalizedRole == 'distributor';
    var distributorId = await Utility.getSecureValue(LocalKeys.distributorId);

    dynamic distributorVal = [];
    if (isDealer && distributorId.isNotEmpty) {
      distributorVal = [distributorId];
    }

    final String branchId = await _resolveBranchId();

    var data = {
      "page": 1,
      "limit": 10,
      "search": {},
      "distributorid": distributorVal,
      "customerid": customerid != null && customerid.isNotEmpty
          ? [customerid]
          : [],
      "orderno": [],
      "deliverydate": [],
      "totalamount": [],
      "sortoption": -1,
      "branchid": branchId,
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
    required List<Map<String, dynamic>> items,
    required num totalamount,
    String? deliverydate,
    String? distributorid,
    bool isLoading = false,
  }) async {
    var loggedInDistributorId = await Utility.getSecureValue(
      LocalKeys.distributorId,
    );
    final String branchId = await _resolveBranchId();
    final String finalDistributorId =
        (distributorid != null && distributorid.isNotEmpty)
        ? distributorid
        : loggedInDistributorId;
    var data = {
      "orderid": orderid ?? "",
      "distributorid": finalDistributorId,
      "items": items,
      "deliverydate": deliverydate ?? "",
      "totalamount": totalamount.toString(),
      "branchid": branchId,
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

  Future<ResponseModel> getCustomerOrderListApi({
    String? customerid,
    bool isLoading = false,
  }) async {
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

    final String normalizedRole = role.toLowerCase().trim();
    final bool isDealer =
        normalizedRole == 'dealer' || normalizedRole == 'distributor';
    var distributorId = await Utility.getSecureValue(LocalKeys.distributorId);

    dynamic distributorVal = [];
    if (isDealer && distributorId.isNotEmpty) {
      distributorVal = [distributorId];
    }

    final String branchId = await _resolveBranchId();

    var data = {
      "page": 1,
      "limit": 10,
      "search": {},
      "distributorid": distributorVal,
      "customerid": customerid != null && customerid.isNotEmpty
          ? [customerid]
          : [],
      "orderno": [],
      "sortfield": "orderno",
      "sortoption": -1,
      "branchid": branchId,
    };
    var response = await apiWrapper.makeRequest(
      EndPoints.customerOrderListApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> createCustomerOrderApi({
    String? customerorderid,
    required String customerid,
    required String image,
    required List<Map<String, dynamic>> remark,
    bool isLoading = false,
  }) async {
    var distributorId = await Utility.getSecureValue(LocalKeys.distributorId);
    final String branchId = await _resolveBranchId();
    var data = {
      "customerorderid": customerorderid ?? "",
      "distributorid": distributorId,
      "customerid": customerid,
      "image": image,
      "remark": remark,
      "branchid": branchId,
    };
    var response = await apiWrapper.makeRequest(
      EndPoints.createCustomerOrderApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> getOneCustomerOrderApi({
    required String customerorderid,
    bool isLoading = false,
  }) async {
    var data = {"customerorderid": customerorderid};
    var response = await apiWrapper.makeRequest(
      EndPoints.getOneCustomerOrderApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> deleteCustomerOrderApi({
    required String customerorderid,
    bool isLoading = false,
  }) async {
    var data = {"customerorderid": customerorderid};
    var response = await apiWrapper.makeRequest(
      EndPoints.deleteCustomerOrderApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> uploadCustomerOrderApi(
    File image, {
    bool isLoading = true,
  }) async {
    try {
      if (isLoading) {
        if (Get.isSnackbarOpen) {
          await Get.closeCurrentSnackbar();
        }
        Utility.showLoader();
      }

      var uri = ApiWrapper.baseUrl + EndPoints.uploadCustomerOrderApi;
      var request = http.MultipartRequest('POST', Uri.parse(uri));

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          image.path,
          contentType: _getMediaType(image.path),
        ),
      );

      final headers = await Utility.commonHeader();
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      var response = await request.send().timeout(const Duration(seconds: 120));

      if (isLoading) Utility.closeDialog();

      var bytesToString = await response.stream.bytesToString();
      var hasError = response.statusCode < 200 || response.statusCode >= 300;
      if (hasError) {
        print(
          '[UploadCustomerOrder] Failed with status: ${response.statusCode}, body: $bytesToString',
        );
      }
      return ResponseModel(
        data: bytesToString,
        hasError: hasError,
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (isLoading) Utility.closeDialog();
      return ResponseModel(
        data: '{"message":"Request failed"}',
        hasError: true,
      );
    }
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

  Future<ResponseModel> getOneUserApi({
    required String userid,
    bool isLoading = false,
  }) async {
    var data = {"userid": userid};
    var response = await apiWrapper.makeRequest(
      EndPoints.getOneUserApi,
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
    String type = "",
    String? assigntoid,
    bool isLoading = false,
  }) async {
    final String branchId = await _resolveBranchId();
    final String role = await _resolveUserRole();
    final String currentUserId = await _resolveUserId();

    String? assignToIdToUse;
    final bool isAdmin = RoleUtils.isAdmin(role);
    final bool isUser = RoleUtils.isUser(role);
    // When logged in as User role (non-admin), send assigntoid in the API payload
    if (!isAdmin && !isUser) {
      assignToIdToUse = currentUserId;
    }

    var data = {
      "page": page,
      "type": type,
      "limit": 2000,
      "search": search.isNotEmpty ? {"name": search} : {},
      "sortfield": sortfield,
      "sortoption": sortoption,
      "roleid": roleid,
      "branchid": branchId,
      if (assignToIdToUse != null && assignToIdToUse.isNotEmpty)
        "assigntoid": assignToIdToUse,
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
    int? salary,
    int? allowance,
    bool? liveTracking,
    bool? odometer,
    List<String>? permissionbranchid,
    List<String>? permissionuserid,
    List<String>? assigntoid,
    String? mapcolor,
    String? fcmToken,
    bool isLoading = false,
  }) async {
    final String branchId = await _resolveBranchId();
    String tokenToUse = fcmToken ?? "";
    if (tokenToUse.isEmpty) {
      try {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) tokenToUse = token;
      } catch (_) {}
    }
    var data = {
      "userid": userid ?? "",
      "name": name,
      "email": email,
      "countrycode": countrycode,
      "mobile": mobile,
      "password": password ?? "",
      "location": address,
      "roleid": roleid,
      "branchid": branchId,
      if (surname != null && surname.isNotEmpty) "surname": surname,
      if (fathername != null && fathername.isNotEmpty) "fathername": fathername,
      if (gstnumber != null && gstnumber.isNotEmpty) "gstnumber": gstnumber,
      // if (location != null && location.isNotEmpty) "location": location,
      if (bankname != null && bankname.isNotEmpty) "bankname": bankname,
      if (bankaccountnumber != null && bankaccountnumber.isNotEmpty)
        "bankaccountnumber": bankaccountnumber,
      if (bankifsscode != null && bankifsscode.isNotEmpty)
        "bankifsscode": bankifsscode,
      "salary": salary ?? 0,
      "allowance": allowance ?? 0,
      "liveTracking": liveTracking ?? false,
      "odometer": odometer ?? false,
      if (permissionbranchid != null) "permissionbranchid": permissionbranchid,
      if (permissionuserid != null) "permissionuserid": permissionuserid,
      if (assigntoid != null) "assigntoid": assigntoid,
      if (mapcolor != null && mapcolor.isNotEmpty) "mapcolor": mapcolor,
      if (tokenToUse.isNotEmpty) "fcm_token": tokenToUse,
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

  Future<ResponseModel> getAllBranchesApi({bool isLoading = false}) async {
    var response = await apiWrapper.makeRequest(
      EndPoints.branchApi,
      Request.get,
      null,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<String> _resolveUserId() async {
    String userId = await Utility.getSecureValue(LocalKeys.userIds);
    if (userId.isEmpty) {
      userId = await Utility.getSecureValue(LocalKeys.distributorId);
    }
    if (userId.isEmpty) {
      final profileJson = await Utility.getSecureValue(LocalKeys.profileData);
      if (profileJson.isNotEmpty) {
        try {
          final decoded = json.decode(profileJson);
          userId =
              decoded['_id']?.toString() ??
              decoded['id']?.toString() ??
              decoded['userData']?['_id']?.toString() ??
              decoded['userData']?['id']?.toString() ??
              '';
        } catch (_) {}
      }
    }
    return userId;
  }

  Future<String> _resolveUserRole() async {
    String role = await Utility.getSecureValue(LocalKeys.roleName);
    if (role.isEmpty) {
      final profileJson = await Utility.getSecureValue(LocalKeys.profileData);
      if (profileJson.isNotEmpty) {
        try {
          final decoded = json.decode(profileJson);
          role = decoded['rolename']?.toString() ?? '';
        } catch (_) {}
      }
    }
    return role;
  }

  Future<String> _resolveBranchId() async {
    final String role = await Utility.getSecureValue(LocalKeys.roleName);
    final bool isAdmin = RoleUtils.isAdmin(role);

    print('[BranchResolution] role="$role", isAdmin=$isAdmin');

    // For admin users, try the selected branch first
    if (isAdmin) {
      final String selectedBranch = await Utility.getSecureValue(
        LocalKeys.selectedBranchId,
      );
      print('[BranchResolution] Admin selectedBranchId="$selectedBranch"');
      if (selectedBranch.isNotEmpty) {
        return selectedBranch;
      }
      // If selectedBranchId is not yet set (e.g. first launch before
      // fetchBranches completes), fall through to profile/API fallback below.
    }

    // Non-admin: also check selectedBranchId first (saved during login/splash)
    final String savedBranch = await Utility.getSecureValue(
      LocalKeys.selectedBranchId,
    );
    if (savedBranch.isNotEmpty) {
      print('[BranchResolution] Using saved selectedBranchId="$savedBranch"');
      return savedBranch;
    }

    // Fallback to profile data cache
    String profileJson = await Utility.getSecureValue(LocalKeys.profileData);
    String branchId = '';

    if (profileJson.isNotEmpty) {
      try {
        final Map<String, dynamic> decoded = json.decode(profileJson);
        if (decoded['branchid'] != null) {
          if (decoded['branchid'] is Map) {
            branchId = decoded['branchid']['_id']?.toString() ?? '';
          } else {
            branchId = decoded['branchid'].toString();
          }
        }
        print('[BranchResolution] From profileData cache branchId="$branchId"');
      } catch (_) {}
    }

    // Fallback: If resolved branchId is empty, try fetching fresh profile from API
    if (branchId.isEmpty) {
      print(
        '[BranchResolution] Branch ID not found in local cache. Fetching from API...',
      );
      try {
        final profileRes = await getProfileApi(isLoading: false);
        if (!profileRes.hasError && profileRes.data.isNotEmpty) {
          final decodedProfile = json.decode(profileRes.data);
          final userData = decodedProfile['Data']?['userData'];
          if (userData != null) {
            // Save fresh profile cache
            Get.find<Repository>().saveSecureValue(
              LocalKeys.profileData,
              json.encode(userData),
            );

            // Save other keys
            final freshRole =
                userData['roleid']?['rolename']?.toString() ??
                userData['rolename']?.toString() ??
                '';
            if (freshRole.isNotEmpty) {
              Get.find<Repository>().saveSecureValue(
                LocalKeys.roleName,
                freshRole,
              );
            }
            final freshDistId = userData['_id']?.toString() ?? '';
            if (freshDistId.isNotEmpty) {
              Get.find<Repository>().saveSecureValue(
                LocalKeys.distributorId,
                freshDistId,
              );
            }

            // Extract branch ID
            final rawBranch = userData['branchid'];
            if (rawBranch != null) {
              if (rawBranch is Map) {
                branchId = rawBranch['_id']?.toString() ?? '';
              } else {
                branchId = rawBranch.toString();
              }
            }

            // Save as selectedBranchId so future calls are fast
            if (branchId.isNotEmpty) {
              Get.find<Repository>().saveSecureValue(
                LocalKeys.selectedBranchId,
                branchId,
              );
            }
            print('[BranchResolution] From API fallback branchId="$branchId"');
          }
        }
      } catch (e) {
        print('[BranchResolution] Error during API branch fallback: $e');
      }
    }

    // Final fallback: if branchId is still empty, fetch branches and select the first one
    if (branchId.isEmpty) {
      print(
        '[BranchResolution] branchId is still empty. Fetching branches list as fallback...',
      );
      try {
        final response = await getAllBranchesApi(isLoading: false);
        if (!response.hasError && response.data.isNotEmpty) {
          final decoded = json.decode(response.data);
          final rawData = decoded is Map
              ? (decoded['Data'] ?? decoded['data'])
              : decoded;
          List<dynamic>? docs;
          if (rawData is List) {
            docs = rawData;
          } else if (rawData is Map) {
            docs = rawData['docs'];
          }
          if (docs != null && docs.isNotEmpty) {
            dynamic activeBranch;
            for (var b in docs) {
              if (b is Map && b['isDeleted'] != true) {
                activeBranch = b;
                break;
              }
            }
            if (activeBranch == null && docs.isNotEmpty) {
              activeBranch = docs.first;
            }
            if (activeBranch != null && activeBranch is Map) {
              final firstBranchId = activeBranch['_id']?.toString() ?? '';
              if (firstBranchId.isNotEmpty) {
                branchId = firstBranchId;
                Get.find<Repository>().saveSecureValue(
                  LocalKeys.selectedBranchId,
                  branchId,
                );
                print(
                  '[BranchResolution] Final fallback resolved branch: "$branchId"',
                );
              }
            }
          }
        }
      } catch (e) {
        print('[BranchResolution] Error during final branch fallback: $e');
      }
    }

    return branchId;
  }

  Future<ResponseModel> getTaskListApi({
    int page = 1,
    int limit = 10,
    String search = "",
    String sortfield = "date",
    int sortoption = -1,
    String fromDate = "",
    String toDate = "",
    String status = "",
    String assignedBy = "",
    String assignedto = "",
    bool isLoading = false,
  }) async {
    final String branchId = await _resolveBranchId();
    var data = {
      "page": page,
      "limit": limit,
      "serch": search.isNotEmpty ? {"taskname": search} : {},
      "branchid": branchId.isNotEmpty ? [branchId] : [],
      // "assignedto":
      //     Get.find<Repository>().getStringValue(LocalKeys.roleHiveName) ==
      //         "Admin"
      //     ? []
      //     : [assignedto],
      "date": (fromDate.isNotEmpty && toDate.isNotEmpty)
          ? [fromDate, toDate]
          : [],
      "taskname": [],
      "description": [],
      "sortfield": sortfield,
      "sortoption": sortoption,
      if (status.isNotEmpty) "status": [status],
      if (status.isNotEmpty) "status_str": status,
      if (assignedBy.isNotEmpty) "createdby": [assignedBy],
      if (assignedBy.isNotEmpty) "assignedby": [assignedBy],
      if (fromDate.isNotEmpty) "fromdate": fromDate,
      if (toDate.isNotEmpty) "todate": toDate,
    };
    var response = await apiWrapper.makeRequest(
      EndPoints.taskListApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> createTaskApi({
    String? taskid,
    required String date,
    required String taskname,
    required String description,
    required List<String> assignedto,
    required String status,
    required String duedate,
    required String time,
    required String priority,
    required List<Map<String, String>> attachment,
    String? tasktype,
    List<Map<String, dynamic>>? remarks,
    bool isLoading = false,
  }) async {
    final String branchId = await _resolveBranchId();
    var data = {
      "taskid": taskid ?? "",
      "date": date,
      "branchid": branchId,
      "taskname": taskname,
      "description": description,
      "assignedto": assignedto,
      "status": status,
      "duedate": duedate,
      "time": time,
      "priority": priority,
      "attachment": attachment,
      if (tasktype != null && tasktype.isNotEmpty) "tasktype": tasktype,
      if (remarks != null) "remarks": remarks,
    };
    var response = await apiWrapper.makeRequest(
      EndPoints.createTaskApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> uploadTaskAttachmentApi(
    List<File> files, {
    bool isLoading = true,
  }) async {
    try {
      if (isLoading) {
        if (Get.isSnackbarOpen) {
          await Get.closeCurrentSnackbar();
        }
        Utility.showLoader();
      }

      var uri = ApiWrapper.baseUrl + EndPoints.uploadTaskAttachmentApi;
      var request = http.MultipartRequest('POST', Uri.parse(uri));

      for (var file in files) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'attachment',
            file.path,
            contentType: _getMediaType(file.path),
          ),
        );
      }

      final headers = await Utility.commonHeader();
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      var response = await request.send().timeout(const Duration(seconds: 120));

      if (isLoading) Utility.closeDialog();

      var bytesToString = await response.stream.bytesToString();
      var hasError = response.statusCode < 200 || response.statusCode >= 300;
      if (hasError) {
        print(
          '[UploadTaskAttachment] Failed with status: ${response.statusCode}, body: $bytesToString',
        );
      }
      return ResponseModel(
        data: bytesToString,
        hasError: hasError,
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (isLoading) Utility.closeDialog();
      return ResponseModel(
        data: '{"message":"Upload failed: $e"}',
        hasError: true,
      );
    }
  }

  Future<ResponseModel> deleteTaskApi({
    required String taskid,
    bool isLoading = false,
  }) async {
    var data = {"taskid": taskid};
    var response = await apiWrapper.makeRequest(
      EndPoints.deleteTaskApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> getOneTaskApi({
    required String taskid,
    bool isLoading = false,
  }) async {
    var data = {"taskid": taskid};
    var response = await apiWrapper.makeRequest(
      EndPoints.getOneTaskApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> changeTaskStatusApi({
    required String taskid,
    required String status,
    String? remark,
    String? updatedBy,
    bool isLoading = false,
  }) async {
    String userId = updatedBy ?? "";
    if (userId.isEmpty) {
      userId = await Utility.getSecureValue(LocalKeys.distributorId);
      if (userId.isEmpty) {
        userId = await Utility.getSecureValue(LocalKeys.userIds);
      }
    }
    var data = {
      "taskid": taskid,
      "status": status,
      "remark": remark ?? "",
      "updatedBy": userId,
    };
    var response = await apiWrapper.makeRequest(
      EndPoints.changeTaskStatusApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> getAttendanceListApi({
    int page = 1,
    int limit = 10,
    String search = "",
    String date = "",
    String branchId = "",
    String userid = "",
    String status = "",
    bool isLoading = false,
  }) async {
    String resolvedBranchId = branchId;
    if (resolvedBranchId.isEmpty) {
      resolvedBranchId = await _resolveBranchId();
    }

    var data = {
      "page": page,
      "limit": limit,
      "search": search.isNotEmpty ? {"remark": search} : {},
      "date": date,
      "branchid": [resolvedBranchId],
      "userid": userid.isNotEmpty ? [userid] : [],
      "sortfield": "date",
      "status": status.isNotEmpty ? [status] : [],
      "sortoption": -1,
    };
    var response = await apiWrapper.makeRequest(
      EndPoints.attendanceListApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> createAttendanceApi({
    String? attendanceid,
    required String date,
    required String timein,
    required String timeout,
    required Map<String, String> coordinates,
    required String breakstart,
    required String breakend,
    required String remark,
    required String status,
    String? userid,
    List<Map<String, String>>? punching,
    List<Map<String, String>>? breaks,
    String? photo,
    int? odometer,
    String? timeinphoto,
    int? timeinodometer,
    String? timeoutphoto,
    int? timeoutodometer,
    String? vehicalno,
    bool isLoading = false,
  }) async {
    final String branchId = await _resolveBranchId();
    final String distributorId = await Utility.getSecureValue(
      LocalKeys.distributorId,
    );
    final String role = await Utility.getSecureValue(LocalKeys.roleName);
    final bool isUser = role.toLowerCase() != 'admin';

    Map<String, dynamic> data = {
      "attendanceid": attendanceid ?? "",
      "userid": userid ?? distributorId,
      "date": date,
      "branchid": branchId,
      "timein": timein,
      "timeout": timeout,
      "coordinates": coordinates,
      "breakstart": breakstart,
      "breakend": breakend,
      "remark": remark,
      "status": status,
      "odometer": odometer ?? 0,
      if (photo != null) "photo": photo,
      if (timeinphoto != null) "timeinphoto": timeinphoto,
      if (timeinodometer != null) "timeinodometer": timeinodometer,
      if (timeoutphoto != null) "timeoutphoto": timeoutphoto,
      if (timeoutodometer != null) "timeoutodometer": timeoutodometer,
      if (vehicalno != null) "vehicalno": vehicalno.toUpperCase(),
      if (punching != null) "punching": punching,
      if (breaks != null) "breaks": breaks,
    };
    var response = await apiWrapper.makeRequest(
      EndPoints.createAttendanceApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> deleteAttendanceApi({
    required String attendanceid,
    bool isLoading = false,
  }) async {
    var data = {"attendanceid": attendanceid};
    var response = await apiWrapper.makeRequest(
      EndPoints.deleteAttendanceApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> getOneAttendanceApi({
    required String attendanceid,
    bool isLoading = false,
  }) async {
    var data = {"attendanceid": attendanceid};
    var response = await apiWrapper.makeRequest(
      EndPoints.getOneAttendanceApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> changeAttendanceStatusApi({
    required String attendanceid,
    required String status,
    bool isLoading = false,
  }) async {
    var data = {"attendanceid": attendanceid, "status": status};
    var response = await apiWrapper.makeRequest(
      EndPoints.changeAttendanceStatusApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  media_type.MediaType _getMediaType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.pdf')) {
      return media_type.MediaType('application', 'pdf');
    } else if (lower.endsWith('.xls')) {
      return media_type.MediaType('application', 'vnd.ms-excel');
    } else if (lower.endsWith('.xlsx')) {
      return media_type.MediaType(
        'application',
        'vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
    } else if (lower.endsWith('.png')) {
      return media_type.MediaType('image', 'png');
    } else if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return media_type.MediaType('image', 'jpeg');
    }
    return media_type.MediaType('application', 'octet-stream');
  }

  Future<ResponseModel> postCreateSalaryApi({
    required String? salaryid,
    required String? date,
    required String? userid,
    required String? branchid,
    required String? month,
    required String? year,
    required int? workdays,
    required int? basicsalary,
    required int? bonus,
    required int? allowance,
    required int? deduction,
    required int? netsalary,
    required String? paymentmode,
    required String? paymentstatus,
    required String? transactionid,
    required String? remark,
    bool isLoading = false,
  }) async {
    var data = {
      "salaryid": salaryid,
      "date": date,
      "userid": userid,
      "branchid": branchid,
      "month": month,
      "year": year,
      "workdays": workdays,
      "basicsalary": basicsalary,
      "bonus": bonus,
      "allowance": allowance,
      "deduction": deduction,
      "netsalary": netsalary,
      "paymentmode": paymentmode,
      "paymentstatus": paymentstatus,
      "transactionid": transactionid,
      "remark": remark,
    };
    var response = await apiWrapper.makeRequest(
      EndPoints.postCreateSalaryApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> postSalaryListApi({
    required int page,
    required int limit,
    required String month,
    required String year,
    required String branchId,
    bool isLoading = false,
  }) async {
    var data = {
      "page": page,
      "limit": limit,
      "date": [],
      "month": [month],
      "year": [year],
      "userid": [],
      "sortfield": "date",
      "branchid": [branchId],
      "basicsalary": [],
      "bonus": [],
      "allowance": [],
      "deduction": [],
      "netsalary": [],
      "remark": [],
      "paymentmode": [],
      "paymentstatus": [],
      "sortoption": -1,
    };
    var response = await apiWrapper.makeRequest(
      EndPoints.postSalaryListApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> getSalaryApi({
    bool isLoading = false,
    required String? userid,
    required String? month,
    required String? year,
    String? workdays,
  }) async {
    String url =
        "${EndPoints.getSalaryApi}?userid=$userid&month=$month&year=$year";
    if (workdays != null && workdays.isNotEmpty) {
      url += "&workdays=$workdays";
    }
    var response = await apiWrapper.makeRequest(
      url,
      Request.get,
      null,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> deleteSalaryApi({
    bool isLoading = false,
    required String? salaryid,
  }) async {
    var response = await apiWrapper.makeRequest(
      EndPoints.deleteSalaryApi,
      Request.post,
      {"salaryid": salaryid},
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> getUserList({bool isLoading = false}) async {
    var brachId = await Get.find<Repository>().getSecureValue(
      LocalKeys.selectedBranchId,
    );
    var response = await apiWrapper.makeRequest(
      "${EndPoints.usersApi}?role=${Get.find<Repository>().getStringValue(LocalKeys.roleHiveName)}&branchid=${brachId}",
      Request.get,
      null,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> uploadAttendanceMediaApi(
    String filePath, {
    bool isLoading = true,
  }) async {
    try {
      if (isLoading) {
        if (Get.isSnackbarOpen) {
          await Get.closeCurrentSnackbar();
        }
        Utility.showLoader();
      }

      final headers = await Utility.commonHeader();
      headers.remove('Content-Type');

      final FormData formData;
      if (kIsWeb) {
        final bytes = await XFile(filePath).readAsBytes();
        formData = FormData.fromMap({
          'image': MultipartFile.fromBytes(
            bytes,
            filename: filePath.split(RegExp(r'[/\\]')).last,
          ),
        });
      } else {
        formData = FormData.fromMap({
          'image': await MultipartFile.fromFile(
            filePath,
            filename: filePath.split(RegExp(r'[/\\]')).last,
          ),
        });
      }

      final response = await dio.post(
        '${ApiWrapper.api}${EndPoints.uploadAttendanceApi}',
        data: formData,
        options: Options(headers: headers),
      );

      if (isLoading) Utility.closeDialog();

      if (response.statusCode == 200) {
        return ResponseModel(
          data: json.encode(response.data),
          hasError: false,
          statusCode: response.statusCode ?? 200,
        );
      } else {
        return ResponseModel(
          data: response.statusMessage ?? 'Failed to upload image',
          hasError: true,
          statusCode: response.statusCode ?? 500,
        );
      }
    } catch (e) {
      if (isLoading) Utility.closeDialog();
      return ResponseModel(data: e.toString(), hasError: true, statusCode: 500);
    }
  }

  Future<ResponseModel> startTrackingApi({
    required String userId,
    required double latitude,
    required double longitude,
    required String time,
    bool isLoading = false,
  }) async {
    final Map<String, dynamic> data = {
      "userId": userId,
      "latitude": latitude,
      "longitude": longitude,
      "time": time,
    };
    return apiWrapper.makeRequest(
      EndPoints.startTrackingApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
  }

  Future<ResponseModel> stopTrackingApi({
    required String userId,
    required double latitude,
    required double longitude,
    required String time,
    bool isLoading = false,
  }) async {
    final Map<String, dynamic> data = {
      "userId": userId,
      "latitude": latitude,
      "longitude": longitude,
      "time": time,
    };
    return apiWrapper.makeRequest(
      EndPoints.stopTrackingApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
  }

  Future<ResponseModel> updateLocationApi({
    required String userId,
    // required String trackingId,
    required double latitude,
    required double longitude,
    required String timestamp,
    bool isLoading = false,
  }) async {
    final Map<String, dynamic> data = {
      // "trackingId": trackingId,
      "userId": userId,
      "latitude": latitude,
      "longitude": longitude,
      "time": timestamp,
    };
    return apiWrapper.makeRequest(
      EndPoints.updateLocationApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
  }

  Future<ResponseModel> pauseTrackingApi({
    required Map<String, dynamic> body,
    bool isLoading = false,
  }) async {
    return apiWrapper.makeRequest(
      EndPoints.pauseTrackingApi,
      Request.post,
      body,
      isLoading,
      await Utility.commonHeader(),
    );
  }

  Future<ResponseModel> createLeaveApi({
    String? leaveid,
    required String userid,
    required String fromdate,
    required String todate,
    required num totaldays,
    required num totalhours,
    required String leavetype,
    required String reason,
    required String status,
    bool isLoading = false,
  }) async {
    final String branchId = await _resolveBranchId();
    var data = {
      if (leaveid != null && leaveid.isNotEmpty) "leaveid": leaveid,
      "userid": userid,
      "fromdate": fromdate,
      "todate": todate,
      "totaldays": totaldays,
      "totalhours": totalhours,
      "leavetype": leavetype,
      "reason": reason,
      "status": status,
      "branchid": branchId,
    };
    var response = await apiWrapper.makeRequest(
      EndPoints.createLeaveApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> getLeaveListApi({
    int page = 1,
    int limit = 10,
    String search = "",
    String fromDate = "",
    String toDate = "",
    String status = "",
    String userid = "",
    String leavetype = "",
    bool isLoading = false,
  }) async {
    var data = <String, dynamic>{
      "page": page,
      "limit": limit,
      "search": search,
      if (leavetype.isNotEmpty) "leavetype": [leavetype],
      if (status.isNotEmpty) "status": [status],
      if (userid.isNotEmpty) "userid": [userid],
      if (fromDate.isNotEmpty && toDate.isNotEmpty)
        "leavedate": [fromDate, toDate]
      else if (fromDate.isNotEmpty)
        "leavedate": [fromDate],
    };
    var response = await apiWrapper.makeRequest(
      EndPoints.leaveListApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> deleteLeaveApi({
    required String leaveid,
    bool isLoading = false,
  }) async {
    var data = {"leaveid": leaveid};
    var response = await apiWrapper.makeRequest(
      EndPoints.deleteLeaveApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> getOneLeaveApi({
    required String leaveid,
    bool isLoading = false,
  }) async {
    var data = {"leaveid": leaveid};
    var response = await apiWrapper.makeRequest(
      EndPoints.getOneLeaveApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> changeLeaveStatusApi({
    required String leaveid,
    required String status,
    bool isLoading = false,
  }) async {
    var data = {"leaveid": leaveid, "status": status};
    var response = await apiWrapper.makeRequest(
      EndPoints.changeLeaveStatusApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> createCollectionApi({
    String? collectionid,
    required String date,
    required String userid,
    required String partyname,
    required String amount,
    required String paymentmode,
    required String paymentstatus,
    String? remark,
    bool isLoading = false,
  }) async {
    final String branchId = await _resolveBranchId();
    var data = {
      "collectionid": collectionid ?? "",
      "date": date,
      "userid": userid,
      "partyname": partyname,
      "amount": amount,
      "paymentmode": paymentmode,
      "paymentstatus": paymentstatus,
      "remark": remark ?? "",
      "branchid": branchId,
    };
    var response = await apiWrapper.makeRequest(
      EndPoints.createCollectionApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> getCollectionListApi({
    int page = 1,
    int limit = 10,
    String search = "",
    String fromDate = "",
    String toDate = "",
    String userid = "",
    String sortfield = "_id",
    int sortoption = 1,
    bool isLoading = false,
  }) async {
    final String branchId = await _resolveBranchId();
    var data = <String, dynamic>{
      "page": page,
      "limit": limit,
      "search": search,
      "fromDate": fromDate,
      "toDate": toDate,
      "userid": userid,
      "sortfield": sortfield,
      "sortoption": sortoption,
      "branchid": branchId,
    };
    var response = await apiWrapper.makeRequest(
      EndPoints.collectionListApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> getOneCollectionApi({
    required String collectionid,
    bool isLoading = false,
  }) async {
    var data = {"collectionid": collectionid};
    var response = await apiWrapper.makeRequest(
      EndPoints.getOneCollectionApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> deleteCollectionApi({
    required String collectionid,
    bool isLoading = false,
  }) async {
    var data = {"collectionid": collectionid};
    var response = await apiWrapper.makeRequest(
      EndPoints.deleteCollectionApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> changeCollectionStatusApi({
    required String collectionid,
    required String paymentstatus,
    bool isLoading = false,
  }) async {
    var data = {"collectionid": collectionid, "paymentstatus": paymentstatus};
    var response = await apiWrapper.makeRequest(
      EndPoints.changeCollectionStatusApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> createExpenseApi({
    String? expenseid,
    required String date,
    required String userid,
    required String particularid,
    required String amount,
    required String image,
    required String remark,
    bool isLoading = false,
  }) async {
    final String branchId = await _resolveBranchId();
    var data = {
      "expenseid": expenseid ?? "",
      "date": date,
      "userid": userid,
      "branchid": branchId,
      "particularid": particularid,
      "amount": amount,
      "image": image,
      "remark": remark,
    };
    var response = await apiWrapper.makeRequest(
      EndPoints.createExpenseApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> getExpenseListApi({
    int page = 1,
    int limit = 10,
    String search = "",
    String fromDate = "",
    String toDate = "",
    String userid = "",
    String sortfield = "_id",
    int sortoption = 1,
    bool isLoading = false,
  }) async {
    final String branchId = await _resolveBranchId();
    var data = <String, dynamic>{
      "page": page,
      "limit": limit,
      "search": search,
      "fromDate": fromDate,
      "toDate": toDate,
      "userid": userid,
      "branchid": branchId,
      "sortfield": sortfield,
      "sortoption": sortoption,
    };
    var response = await apiWrapper.makeRequest(
      EndPoints.expenseListApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> getOneExpenseApi({
    required String expenseid,
    bool isLoading = false,
  }) async {
    var data = {"expenseid": expenseid};
    var response = await apiWrapper.makeRequest(
      EndPoints.getOneExpenseApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> deleteExpenseApi({
    required String expenseid,
    bool isLoading = false,
  }) async {
    var data = {"expenseid": expenseid};
    var response = await apiWrapper.makeRequest(
      EndPoints.deleteExpenseApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> changeExpenseStatusApi({
    required String expenseid,
    required String status,
    bool isLoading = false,
  }) async {
    var data = {"expenseid": expenseid, "status": status};
    var response = await apiWrapper.makeRequest(
      EndPoints.changeExpenseStatusApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
  }

  Future<ResponseModel> uploadExpenseImageApi(
    String filePath, {
    bool isLoading = false,
  }) async {
    try {
      if (isLoading) {
        if (Get.isSnackbarOpen) {
          await Get.closeCurrentSnackbar();
        }
        Utility.showLoader();
      }

      final headers = await Utility.commonHeader();
      headers.remove('Content-Type');

      final FormData formData;
      if (kIsWeb) {
        final bytes = await XFile(filePath).readAsBytes();
        formData = FormData.fromMap({
          'image': MultipartFile.fromBytes(
            bytes,
            filename: filePath.split(RegExp(r'[/\\]')).last,
          ),
        });
      } else {
        formData = FormData.fromMap({
          'image': await MultipartFile.fromFile(
            filePath,
            filename: filePath.split(RegExp(r'[/\\]')).last,
          ),
        });
      }

      final response = await dio.post(
        '${ApiWrapper.api}${EndPoints.uploadExpenseApi}',
        data: formData,
        options: Options(headers: headers),
      );

      if (isLoading) Utility.closeDialog();

      if (response.statusCode == 200) {
        return ResponseModel(
          data: json.encode(response.data),
          hasError: false,
          statusCode: response.statusCode ?? 200,
        );
      } else {
        return ResponseModel(
          data: response.statusMessage ?? 'Failed to upload image',
          hasError: true,
          statusCode: response.statusCode ?? 500,
        );
      }
    } catch (e) {
      if (isLoading) Utility.closeDialog();
      return ResponseModel(data: e.toString(), hasError: true, statusCode: 500);
    }
  }

  Future<ResponseModel> getParticularListApi({
    String search = "",
    bool isLoading = false,
  }) async {
    var response = await apiWrapper.makeRequest(
      '${EndPoints.particularListApi}?search=$search',
      Request.get,
      null,
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
