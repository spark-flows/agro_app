// coverage:ignore-file
import 'dart:convert';
import 'dart:io';

import 'package:agro_app/app/app.dart';
import 'package:agro_app/data/data.dart';
import 'package:agro_app/domain/domain.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as media_type;

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
    bool isLoading = false,
  }) async {
    var distributorId = await Utility.getSecureValue(LocalKeys.distributorId);
    final String branchId = await _resolveBranchId();
    var data = {
      "orderid": orderid ?? "",
      "distributorid": distributorId,
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
    bool isLoading = false,
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
    bool isLoading = false,
  }) async {
    final String branchId = await _resolveBranchId();
    var data = {
      "page": page,
      "type": type,
      "limit": limit,
      "search": search.isNotEmpty ? {"name": search} : {},
      "sortfield": sortfield,
      "sortoption": sortoption,
      "roleid": roleid,
      "branchid": branchId,
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
    final String branchId = await _resolveBranchId();
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

  Future<ResponseModel> getAllBranchesApi({
    int page = 1,
    int limit = 10,
    String search = "",
    bool isLoading = false,
  }) async {
    var data = {
      "page": page,
      "limit": limit,
      "search": search,
      "sortfield": "_id",
      "sortoption": 1,
    };
    var response = await apiWrapper.makeRequest(
      EndPoints.branchApi,
      Request.post,
      data,
      isLoading,
      await Utility.commonHeader(),
    );
    return response;
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
          final docs = decoded['Data']?['docs'];
          if (docs is List && docs.isNotEmpty) {
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
      "assignedto": [assignedto],
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
    bool isLoading = false,
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
    bool isLoading = false,
  }) async {
    var data = {"taskid": taskid, "status": status};
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
      "date": [date],
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
    List<Map<String, String>>? punching,
    List<Map<String, String>>? breaks,
    bool isLoading = false,
  }) async {
    final String branchId = await _resolveBranchId();
    final String distributorId = await Utility.getSecureValue(
      LocalKeys.distributorId,
    );
    final String role = await Utility.getSecureValue(LocalKeys.roleName);
    final bool isUser = role.toLowerCase() != 'admin';

    Map<String, dynamic> data;
    if (isUser) {
      data = {
        "attendanceid": attendanceid ?? "",
        "date": date,
        "branchid": branchId,
        "userid": distributorId,
        "coordinates": coordinates,
        "punching": punching ?? [],
        "break": breaks ?? [],
        "remark": remark,
        "status": "present",
      };
    } else {
      data = {
        "attendanceid": attendanceid ?? "",
        "date": date,
        "branchid": branchId,
        "userid": distributorId,
        "timein": timein,
        "timeout": timeout,
        "coordinates": coordinates,
        "breakstart": breakstart,
        "breakend": breakend,
        "remark": remark,
        "status": status,
      };
    }
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
    required String date,
    required String branchId,
    bool isLoading = false,
  }) async {
    var data = {
      "page": page,
      "limit": limit,
      // "search": {},
      "date": [date],
      "month": [],
      "year": [],
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
  }) async {
    var response = await apiWrapper.makeRequest(
      "${EndPoints.getSalaryApi}?userid=$userid&month=$month&year=$year",
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
    var response = await apiWrapper.makeRequest(
      "${EndPoints.usersApi}?role=admin&branchid=${Get.find<Repository>().getSecureValue(LocalKeys.selectedBranchId)}",
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
