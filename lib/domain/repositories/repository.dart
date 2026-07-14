import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:agro_app/app/utils/utility.dart';
import 'package:agro_app/data/data.dart';
import 'package:agro_app/device/device.dart';
import 'package:agro_app/domain/domain.dart';
import 'package:agro_app/domain/entities/enums.dart';
import 'package:agro_app/domain/models/auth_model.dart';
import 'package:agro_app/domain/models/create_attandance_model.dart';
import 'package:agro_app/domain/models/create_customer_model.dart';
import 'package:agro_app/domain/models/create_order_model.dart';
import 'package:agro_app/domain/models/customer_order_model.dart';
import 'package:agro_app/domain/models/get_all_attandance_model.dart';
import 'package:agro_app/domain/models/get_all_category_model.dart';
import 'package:agro_app/domain/models/get_all_customers_model.dart';
import 'package:agro_app/domain/models/get_all_order_model.dart';
import 'package:agro_app/domain/models/get_all_product_model.dart';
import 'package:agro_app/domain/models/get_all_unit_model.dart';
import 'package:agro_app/domain/models/get_all_roll_model.dart';
import 'package:agro_app/domain/models/get_all_users_model.dart';
import 'package:agro_app/domain/models/get_one_attandance_model.dart';
import 'package:agro_app/domain/models/get_one_order_model.dart';
import 'package:agro_app/domain/models/get_one_user_model.dart';
import 'package:agro_app/domain/models/get_profille_model.dart';
import 'package:agro_app/domain/models/get_all_branches_model.dart';
import 'package:agro_app/domain/models/getAll_tasks_model.dart';
import 'package:agro_app/domain/models/create_task_model.dart';
import 'package:agro_app/domain/models/get_one_task_model.dart';
import 'package:agro_app/domain/models/response_model.dart';
import 'package:agro_app/domain/models/get_salary_model.dart';

/// The main repository which will get the data from [DeviceRepository] or the
/// [DataRepository].
class Repository {
  /// [_deviceRepository] : the local repository.
  /// [_dataRepository] : the data repository like api and all.
  Repository(this._deviceRepository, this._dataRepository);

  final DeviceRepository _deviceRepository;
  final DataRepository _dataRepository;

  /// Clear data from local storage for [key].
  void clearData(dynamic key) {
    try {
      _deviceRepository.clearData(key);
    } catch (_) {
      _dataRepository.clearData(key);
    }
  }

  /// Get the string value for the [key].
  ///
  /// [key] : The key whose value is needed.
  String getStringValue(String key) {
    try {
      return _deviceRepository.getStringValue(key);
    } catch (_) {
      return _dataRepository.getStringValue(key);
    }
  }

  /// Save the value to the string.
  ///
  /// [key] : The key to which [value] will be saved.
  /// [value] : The value which needs to be saved.
  void saveValue(dynamic key, dynamic value) {
    try {
      _deviceRepository.saveValue(key, value);
    } catch (_) {
      _dataRepository.saveValue(key, value);
    }
  }

  /// Get the bool value for the [key].
  ///
  /// [key] : The key whose value is needed.
  bool getBoolValue(String key) {
    try {
      return _deviceRepository.getBoolValue(key);
    } catch (_) {
      return _dataRepository.getBoolValue(key);
    }
  }

  /// Get the stored value for the [key].
  ///
  /// [key] : The key whose value is needed.
  bool getStoredValue(String key) {
    try {
      return _deviceRepository.getBoolValue(key);
    } catch (_) {
      return _dataRepository.getBoolValue(key);
    }
  }

  /// Get the secure value for the [key].
  /// [key] : The key whose value is needed.
  Future<String> getSecureValue(String key) async {
    try {
      return await _deviceRepository.getSecuredValue(key);
    } catch (_) {
      return await _dataRepository.getSecuredValue(key);
    }
  }

  /// Save the value to the string.
  ///
  /// [key] : The key to which [value] will be saved.
  /// [value] : The value which needs to be saved.
  void saveSecureValue(String key, String value) {
    try {
      _deviceRepository.saveValueSecurely(key, value);
    } catch (_) {
      _dataRepository.saveValueSecurely(key, value);
    }
  }

  /// Clear data from secure storage for [key].
  void deleteSecuredValue(String key) {
    try {
      _deviceRepository.deleteSecuredValue(key);
    } catch (_) {
      _dataRepository.deleteSecuredValue(key);
    }
  }

  /// Clear all data from secure storage .
  void deleteAllSecuredValues() {
    try {
      _deviceRepository.deleteAllSecuredValues();
    } catch (_) {
      _dataRepository.deleteAllSecuredValues();
    }
  }

  Future<LoginModel?> loginApi({
    required String userName,
    required String password,
    required String fcmToken,
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.loginApi(
        userName: userName,
        password: password,
        fcmToken: fcmToken,
        isLoading: isLoading,
      );
      var loginModel = loginModelFromJson(response.data);
      if (loginModel.status == 200) {
        return loginModel;
      } else {
        return loginModel;
      }
    } catch (e) {
      Utility.closeDialog();
      UnimplementedError();
      return null;
    }
  }

  Future<CustomerOrderListResponse?> getCustomerOrderListApi({
    String? customerid,
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.getCustomerOrderListApi(
        customerid: customerid,
        isLoading: isLoading,
      );
      if (response.hasError) {
        final msg = _parseErrorMessage(
          response.data,
          'Failed to load customer orders',
        );
        Utility.showMessage(msg, MessageType.error, null, '');
        return null;
      }
      if (response.data.isNotEmpty) {
        return CustomerOrderListResponse.fromJson(json.decode(response.data));
      }
      return null;
    } catch (e) {
      print('getCustomerOrderListApi error: $e');
      Utility.closeDialog();
      Utility.showMessage(
        'Failed to load customer orders',
        MessageType.error,
        null,
        '',
      );
      return null;
    }
  }

  Future<CustomerOrderCreateResponse?> createCustomerOrderApi({
    String? customerorderid,
    required String customerid,
    required String image,
    required List<Map<String, dynamic>> remark,
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.createCustomerOrderApi(
        customerorderid: customerorderid,
        customerid: customerid,
        image: image,
        remark: remark,
        isLoading: isLoading,
      );
      if (response.hasError) {
        final msg = _parseErrorMessage(
          response.data,
          'Failed to save customer order',
        );
        Utility.showMessage(msg, MessageType.error, null, '');
        return null;
      }
      if (response.data.isNotEmpty) {
        return CustomerOrderCreateResponse.fromJson(json.decode(response.data));
      }
      return null;
    } catch (e) {
      print('createCustomerOrderApi error: $e');
      Utility.closeDialog();
      Utility.showMessage(
        'Failed to save customer order',
        MessageType.error,
        null,
        '',
      );
      return null;
    }
  }

  Future<CustomerOrderDoc?> getOneCustomerOrderApi({
    required String customerorderid,
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.getOneCustomerOrderApi(
        customerorderid: customerorderid,
        isLoading: isLoading,
      );
      if (response.hasError) {
        final msg = _parseErrorMessage(response.data, 'Failed to load details');
        Utility.showMessage(msg, MessageType.error, null, '');
        return null;
      }
      if (response.data.isNotEmpty) {
        final Map<String, dynamic> parsed = json.decode(response.data);
        final data = parsed['Data'] ?? parsed['data'];
        if (data != null) {
          return CustomerOrderDoc.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      print('getOneCustomerOrderApi error: $e');
      Utility.closeDialog();
      Utility.showMessage(
        'Failed to load details',
        MessageType.error,
        null,
        '',
      );
      return null;
    }
  }

  Future<bool> deleteCustomerOrderApi({
    required String customerorderid,
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.deleteCustomerOrderApi(
        customerorderid: customerorderid,
        isLoading: isLoading,
      );
      if (response.hasError) {
        final msg = _parseErrorMessage(response.data, 'Failed to delete order');
        Utility.showMessage(msg, MessageType.error, null, '');
        return false;
      }
      return true;
    } catch (e) {
      print('deleteCustomerOrderApi error: $e');
      Utility.closeDialog();
      Utility.showMessage(
        'Failed to delete order',
        MessageType.error,
        null,
        '',
      );
      return false;
    }
  }

  Future<UploadImageResponse?> uploadCustomerOrderApi(
    File image, {
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.uploadCustomerOrderApi(
        image,
        isLoading: isLoading,
      );
      if (response.hasError) {
        final msg = _parseErrorMessage(response.data, 'Failed to upload image');
        Utility.showMessage(msg, MessageType.error, null, '');
        return null;
      }
      if (response.data.isNotEmpty) {
        return UploadImageResponse.fromJson(json.decode(response.data));
      }
      return null;
    } catch (e) {
      print('uploadCustomerOrderApi error: $e');
      Utility.closeDialog();
      Utility.showMessage(
        'Failed to upload image',
        MessageType.error,
        null,
        '',
      );
      return null;
    }
  }

  Future<GetAllProductModel?> getProductListApi({
    int page = 1,
    int limit = 10,
    String search = '',
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.getProductListApi(
        page: page,
        limit: limit,
        search: search,
        isLoading: isLoading,
      );
      if (response.hasError) {
        final msg = _parseErrorMessage(
          response.data,
          'Failed to load products',
        );
        Utility.showMessage(msg, MessageType.error, null, '');
        return null;
      }
      if (response.data.isNotEmpty) {
        return getAllProductModelFromJson(response.data);
      }
      return null;
    } catch (e, st) {
      print('getProductListApi error: $e\n$st');
      Utility.closeDialog();
      Utility.showMessage(
        'Failed to load products',
        MessageType.error,
        null,
        '',
      );
      return null;
    }
  }

  Future<GetAllCategoryModel?> getCategoryListApi({
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.getCategoryListApi(
        isLoading: isLoading,
      );
      if (response.hasError) {
        final msg = _parseErrorMessage(
          response.data,
          'Failed to load categories',
        );
        Utility.showMessage(msg, MessageType.error, null, '');
        return null;
      }
      if (response.data.isNotEmpty) {
        return getAllCategoryModelFromJson(response.data);
      }
      return null;
    } catch (e, st) {
      print('[Repo] getCategoryListApi error: $e\n$st');
      Utility.closeDialog();
      Utility.showMessage(
        'Failed to load categories',
        MessageType.error,
        null,
        '',
      );
      return null;
    }
  }

  Future<GetAllUnitModel?> getUnitListApi({bool isLoading = false}) async {
    try {
      var response = await _dataRepository.getUnitListApi(isLoading: isLoading);
      if (response.hasError) {
        final msg = _parseErrorMessage(response.data, 'Failed to load units');
        Utility.showMessage(msg, MessageType.error, null, '');
        return null;
      }
      if (response.data.isNotEmpty) {
        return getAllUnitModelFromJson(response.data);
      }
      return null;
    } catch (e, st) {
      print('[Repo] getUnitListApi error: $e\n$st');
      Utility.closeDialog();
      Utility.showMessage('Failed to load units', MessageType.error, null, '');
      return null;
    }
  }

  /// Returns null on success, or an error message string on failure.
  Future<String?> createProductApi({
    String? productid,
    required String name,
    required String unit,
    required int price,
    required int qty,
    required String description,
    required String image,
    required String categoryid,
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.createProductApi(
        productid: productid,
        name: name,
        unit: unit,
        price: price,
        qty: qty,
        description: description,
        image: image,
        categoryid: categoryid,
        isLoading: isLoading,
      );
      if (!response.hasError) {
        return null; // success
      }
      // Parse the error message from the API response body
      return _parseErrorMessage(response.data, 'Failed to save product');
    } catch (e) {
      print('createProductApi error: $e');
      Utility.closeDialog();
      return 'An unexpected error occurred';
    }
  }

  Future<GetAllCustomerModel?> getCustomerListApi({
    int page = 1,
    int limit = 10,
    String search = "",
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.getCustomerListApi(
        page: page,
        limit: limit,
        search: search,
        isLoading: isLoading,
      );
      if (response.hasError) {
        final msg = _parseErrorMessage(
          response.data,
          'Failed to load customers',
        );
        Utility.showMessage(msg, MessageType.error, null, '');
        return null;
      }
      if (response.data.isNotEmpty) {
        return getAllCustomerModelFromJson(response.data);
      }
      return null;
    } catch (e) {
      print('getCustomerListApi error: $e');
      Utility.closeDialog();
      Utility.showMessage(
        'Failed to load customers',
        MessageType.error,
        null,
        '',
      );
      return null;
    }
  }

  Future<CreateCustomerModel?> createCustomerApi({
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
    try {
      var response = await _dataRepository.createCustomerApi(
        customerid: customerid,
        name: name,
        email: email,
        countrycode: countrycode,
        mobile: mobile,
        feedback: feedback,
        village: village,
        distributorid: distributorid,
        isLoading: isLoading,
      );
      if (response.hasError) {
        final msg = _parseErrorMessage(
          response.data,
          'Failed to save customer',
        );
        Utility.showMessage(msg, MessageType.error, null, '');
        return null;
      }
      if (response.data.isNotEmpty) {
        return createCustomerModelFromJson(response.data);
      }
      return null;
    } catch (e) {
      Utility.closeDialog();
      Utility.showMessage(
        'Failed to save customer',
        MessageType.error,
        null,
        '',
      );
      return null;
    }
  }

  Future<bool> deleteCustomerApi({
    required String customerid,
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.deleteCustomerApi(
        customerid: customerid,
        isLoading: isLoading,
      );
      if (response.hasError) {
        final msg = _parseErrorMessage(
          response.data,
          'Failed to delete customer',
        );
        Utility.showMessage(msg, MessageType.error, null, '');
        return false;
      }
      return true;
    } catch (e) {
      print('deleteCustomerApi error: $e');
      Utility.closeDialog();
      Utility.showMessage(
        'Failed to delete customer',
        MessageType.error,
        null,
        '',
      );
      return false;
    }
  }

  Future<String?> customerFeedbackApi({
    required String customerid,
    required String feedback,
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.customerFeedbackApi(
        customerid: customerid,
        feedback: feedback,
        isLoading: isLoading,
      );
      if (!response.hasError) {
        return null;
      }
      return _parseErrorMessage(response.data, 'Failed to submit feedback');
    } catch (e) {
      print('customerFeedbackApi error: $e');
      Utility.closeDialog();
      return e.toString();
    }
  }

  Future<ProfileDataModel?> getProfileApi({bool isLoading = false}) async {
    try {
      var response = await _dataRepository.getProfileApi(isLoading: isLoading);
      if (response.data.isNotEmpty) {
        return profileDataModelFromJson(response.data);
      } else {
        return null;
      }
    } catch (e) {
      Utility.closeDialog();
      return null;
    }
  }

  Future<GetAllOrderModel?> getOrderListApi({
    String? customerid,
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.getOrderListApi(
        customerid: customerid,
        isLoading: isLoading,
      );
      if (response.hasError) {
        final msg = _parseErrorMessage(response.data, 'Failed to load orders');
        Utility.showMessage(msg, MessageType.error, null, '');
        return null;
      }
      if (response.data.isNotEmpty) {
        return getAllOrderModelFromJson(response.data);
      }
      return null;
    } catch (e) {
      print('getOrderListApi error: $e');
      Utility.closeDialog();
      Utility.showMessage('Failed to load orders', MessageType.error, null, '');
      return null;
    }
  }

  Future<CreateorderModel?> createOrderApi({
    String? orderid,
    required List<Map<String, dynamic>> items,
    required num totalamount,
    String? deliverydate,
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.createOrderApi(
        orderid: orderid,
        items: items,
        totalamount: totalamount,
        deliverydate: deliverydate,
        isLoading: isLoading,
      );
      if (response.hasError) {
        final msg = _parseErrorMessage(response.data, 'Failed to save order');
        Utility.showMessage(msg, MessageType.error, null, '');
        return null;
      }
      if (response.data.isNotEmpty) {
        return createorderModelFromJson(response.data);
      }
      return null;
    } catch (e) {
      print('createOrderApi error: $e');
      Utility.closeDialog();
      Utility.showMessage('Failed to save order', MessageType.error, null, '');
      return null;
    }
  }

  Future<GetOneOrderModel?> getOneOrderApi({
    required String orderid,
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.getOneOrderApi(
        orderid: orderid,
        isLoading: isLoading,
      );
      if (response.hasError) {
        final msg = _parseErrorMessage(
          response.data,
          'Failed to load order details',
        );
        Utility.showMessage(msg, MessageType.error, null, '');
        return null;
      }
      if (response.data.isNotEmpty) {
        return getOneOrderModelFromJson(response.data);
      }
      return null;
    } catch (e) {
      print('getOneOrderApi error: $e');
      Utility.closeDialog();
      Utility.showMessage(
        'Failed to load order details',
        MessageType.error,
        null,
        '',
      );
      return null;
    }
  }

  Future<bool> deleteOrderApi({
    required String orderid,
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.deleteOrderApi(
        orderid: orderid,
        isLoading: isLoading,
      );
      if (response.hasError) {
        final msg = _parseErrorMessage(response.data, 'Failed to delete order');
        Utility.showMessage(msg, MessageType.error, null, '');
        return false;
      }
      return true;
    } catch (e) {
      print('deleteOrderApi error: $e');
      Utility.closeDialog();
      Utility.showMessage(
        'Failed to delete order',
        MessageType.error,
        null,
        '',
      );
      return false;
    }
  }

  Future<bool> deleteProductApi({
    required String productid,
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.deleteProductApi(
        productid: productid,
        isLoading: isLoading,
      );
      if (response.hasError) {
        final msg = _parseErrorMessage(
          response.data,
          'Failed to delete product',
        );
        Utility.showMessage(msg, MessageType.error, null, '');
        return false;
      }
      return true;
    } catch (e) {
      print('deleteProductApi error: $e');
      Utility.closeDialog();
      Utility.showMessage(
        'Failed to delete product',
        MessageType.error,
        null,
        '',
      );
      return false;
    }
  }

  Future<bool> deleteUsersApi({
    required String userid,
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.deleteUsersApi(
        userid: userid,
        isLoading: isLoading,
      );
      if (response.hasError) {
        final msg = _parseErrorMessage(response.data, 'Failed to delete user');
        Utility.showMessage(msg, MessageType.error, null, '');
        return false;
      }
      return true;
    } catch (e) {
      print('deleteUsersApi error: $e');
      Utility.closeDialog();
      return false;
    }
  }

  Future<GetOneUserModel?> getOneUserApi({
    required String userid,
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.getOneUserApi(
        userid: userid,
        isLoading: isLoading,
      );
      if (response.hasError) {
        final msg = _parseErrorMessage(
          response.data,
          'Failed to load user details',
        );
        Utility.showMessage(msg, MessageType.error, null, '');
        return null;
      }
      if (response.data.isNotEmpty) {
        return getOneUserModelFromJson(response.data);
      }
      return null;
    } catch (e) {
      print('getOneUserApi error: $e');
      Utility.closeDialog();
      Utility.showMessage(
        'Failed to load user details',
        MessageType.error,
        null,
        '',
      );
      return null;
    }
  }

  Future<GetAllUsersModel?> getUsersListApi({
    int page = 1,
    int limit = 10,
    String search = "",
    String sortfield = "_id",
    int sortoption = -1,
    String roleid = "",
    String type = "",
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.getUsersListApi(
        page: page,
        limit: limit,
        search: search,
        sortfield: sortfield,
        sortoption: sortoption,
        roleid: roleid,
        type: type,
        isLoading: isLoading,
      );
      if (response.hasError) {
        final msg = _parseErrorMessage(
          response.data,
          'Failed to load distributors',
        );
        Utility.showMessage(msg, MessageType.error, null, '');
        return null;
      }
      if (response.data.isNotEmpty) {
        return getAllUsersModelFromJson(response.data);
      }
      return null;
    } catch (e, st) {
      print('getUsersListApi error: $e\n$st');
      Utility.closeDialog();
      Utility.showMessage(
        'Failed to load distributors',
        MessageType.error,
        null,
        '',
      );
      return null;
    }
  }

  Future<GetAllRolesModel?> getAllRolesApi({
    String search = "",
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.getAllRolesApi(
        search: search,
        isLoading: isLoading,
      );
      if (response.data.isNotEmpty) {
        return getAllRolesModelFromJson(response.data);
      } else {
        return null;
      }
    } catch (e) {
      print('getAllRolesApi error: $e');
      Utility.closeDialog();
      return null;
    }
  }

  /// Returns null on success, or an error message string on failure.
  Future<String?> createUserApi({
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
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.createUserApi(
        userid: userid,
        name: name,
        email: email,
        countrycode: countrycode,
        mobile: mobile,
        password: password,
        roleid: roleid,
        address: address,
        surname: surname,
        fathername: fathername,
        gstnumber: gstnumber,
        location: location,
        bankname: bankname,
        bankaccountnumber: bankaccountnumber,
        bankifsscode: bankifsscode,
        salary: salary,
        allowance: allowance,
        liveTracking: liveTracking,
        odometer: odometer,
        isLoading: isLoading,
      );
      if (!response.hasError) {
        return null; // success
      }
      // Parse the actual error message from the API response (handles both 'Message' and 'message' keys)
      return _parseErrorMessage(response.data, 'Failed to save user');
    } catch (e) {
      print('createUserApi error: $e');
      Utility.closeDialog();
      return 'An unexpected error occurred';
    }
  }

  /// Helper: extracts the error message from an API JSON response body.
  String _parseErrorMessage(String? data, String fallback) {
    if (data == null || data.isEmpty) return fallback;
    try {
      final decoded = json.decode(data);
      return decoded['message']?.toString() ??
          decoded['Message']?.toString() ??
          decoded['error']?.toString() ??
          fallback;
    } catch (_) {
      return fallback;
    }
  }

  Future<GetAllBranchs?> getAllBranchesApi({
    int page = 1,
    int limit = 10,
    String search = "",
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.getAllBranchesApi(
        page: page,
        limit: limit,
        search: search,
        isLoading: isLoading,
      );
      if (response.hasError) {
        final msg = _parseErrorMessage(
          response.data,
          'Failed to load branches',
        );
        Utility.showMessage(msg, MessageType.error, null, '');
        return null;
      }
      if (response.data.isNotEmpty) {
        return getAllBranchsFromJson(response.data);
      }
      return null;
    } catch (e, st) {
      print('getAllBranchesApi error: $e\n$st');
      Utility.closeDialog();
      Utility.showMessage(
        'Failed to load branches',
        MessageType.error,
        null,
        '',
      );
      return null;
    }
  }

  Future<GetAllTasksModel?> getTaskListApi({
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
    try {
      var response = await _dataRepository.getTaskListApi(
        page: page,
        limit: limit,
        search: search,
        sortfield: sortfield,
        sortoption: sortoption,
        fromDate: fromDate,
        toDate: toDate,
        status: status,
        assignedBy: assignedBy,
        assignedto: assignedto,
        isLoading: isLoading,
      );
      if (response.hasError) {
        final msg = _parseErrorMessage(response.data, 'Failed to load tasks');
        Utility.showMessage(msg, MessageType.error, null, '');
        return null;
      }
      if (response.data.isNotEmpty) {
        return getAllTasksModelFromJson(response.data);
      }
      return null;
    } catch (e, st) {
      print('getTaskListApi error: $e\n$st');
      Utility.closeDialog();
      Utility.showMessage('Failed to load tasks', MessageType.error, null, '');
      return null;
    }
  }

  Future<CreateTasks?> createTaskApi({
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
    try {
      var response = await _dataRepository.createTaskApi(
        taskid: taskid,
        date: date,
        taskname: taskname,
        description: description,
        assignedto: assignedto,
        status: status,
        duedate: duedate,
        time: time,
        priority: priority,
        attachment: attachment,
        isLoading: isLoading,
      );
      if (response.hasError) {
        final msg = _parseErrorMessage(response.data, 'Failed to save task');
        Utility.showMessage(msg, MessageType.error, null, '');
        return null;
      }
      if (response.data.isNotEmpty) {
        return createTasksFromJson(response.data);
      }
      return null;
    } catch (e, st) {
      print('createTaskApi error: $e\n$st');
      Utility.closeDialog();
      Utility.showMessage('Failed to save task', MessageType.error, null, '');
      return null;
    }
  }

  Future<ResponseModel> uploadTaskAttachmentApi(
    List<File> files, {
    bool isLoading = false,
  }) async =>
      _dataRepository.uploadTaskAttachmentApi(files, isLoading: isLoading);

  Future<bool> deleteTaskApi({
    required String taskid,
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.deleteTaskApi(
        taskid: taskid,
        isLoading: isLoading,
      );
      if (response.hasError) {
        final msg = _parseErrorMessage(response.data, 'Failed to delete task');
        Utility.showMessage(msg, MessageType.error, null, '');
        return false;
      }
      return true;
    } catch (e) {
      print('deleteTaskApi error: $e');
      Utility.closeDialog();
      Utility.showMessage('Failed to delete task', MessageType.error, null, '');
      return false;
    }
  }

  Future<GetOneTaskModel?> getOneTaskApi({
    required String taskid,
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.getOneTaskApi(
        taskid: taskid,
        isLoading: isLoading,
      );
      if (response.hasError) {
        final msg = _parseErrorMessage(
          response.data,
          'Failed to load task details',
        );
        Utility.showMessage(msg, MessageType.error, null, '');
        return null;
      }
      if (response.data.isNotEmpty) {
        return getOneTaskModelFromJson(response.data);
      }
      return null;
    } catch (e, st) {
      print('getOneTaskApi error: $e\n$st');
      Utility.closeDialog();
      Utility.showMessage(
        'Failed to load task details',
        MessageType.error,
        null,
        '',
      );
      return null;
    }
  }

  Future<bool> changeTaskStatusApi({
    required String taskid,
    required String status,
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.changeTaskStatusApi(
        taskid: taskid,
        status: status,
        isLoading: isLoading,
      );
      if (response.hasError) {
        final msg = _parseErrorMessage(
          response.data,
          'Failed to change task status',
        );
        Utility.showMessage(msg, MessageType.error, null, '');
        return false;
      }
      return true;
    } catch (e, st) {
      print('changeTaskStatusApi error: $e\n$st');
      Utility.closeDialog();
      Utility.showMessage(
        'Failed to change task status',
        MessageType.error,
        null,
        '',
      );
      return false;
    }
  }

  Future<GetAllAttendanceModel?> getAttendanceListApi({
    int page = 1,
    int limit = 10,
    String search = "",
    String date = "",
    String branchId = "",
    String userid = "",
    String status = "",
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.getAttendanceListApi(
        page: page,
        limit: limit,
        search: search,
        branchId: branchId,
        userid: userid,
        date: date,
        status: status,
        isLoading: isLoading,
      );
      if (response.hasError) {
        final msg = _parseErrorMessage(
          response.data,
          'Failed to load attendance records',
        );
        Utility.showMessage(msg, MessageType.error, null, '');
        return null;
      }
      if (response.data.isNotEmpty) {
        return getAllAttendanceModelFromJson(response.data);
      }
      return null;
    } catch (e, st) {
      print('getAttendanceListApi error: $e\n$st');
      Utility.closeDialog();
      Utility.showMessage(
        'Failed to load attendance records',
        MessageType.error,
        null,
        '',
      );
      return null;
    }
  }

  Future<CreateAttendanceModel?> createAttendanceApi({
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
    String? photo,
    int? odometer,
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.createAttendanceApi(
        attendanceid: attendanceid,
        date: date,
        timein: timein,
        timeout: timeout,
        coordinates: coordinates,
        breakstart: breakstart,
        breakend: breakend,
        remark: remark,
        status: status,
        punching: punching,
        breaks: breaks,
        photo: photo,
        odometer: odometer,
        isLoading: isLoading,
      );
      if (response.hasError) {
        final msg = _parseErrorMessage(
          response.data,
          'Failed to save attendance',
        );
        Utility.showMessage(msg, MessageType.error, null, '');
        return null;
      }
      if (response.data.isNotEmpty) {
        return createAttendanceModelFromJson(response.data);
      }
      return null;
    } catch (e, st) {
      print('createAttendanceApi error: $e\n$st');
      Utility.closeDialog();
      Utility.showMessage(
        'Failed to save attendance',
        MessageType.error,
        null,
        '',
      );
      return null;
    }
  }

  Future<bool> deleteAttendanceApi({
    required String attendanceid,
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.deleteAttendanceApi(
        attendanceid: attendanceid,
        isLoading: isLoading,
      );
      if (response.hasError) {
        final msg = _parseErrorMessage(
          response.data,
          'Failed to delete attendance',
        );
        Utility.showMessage(msg, MessageType.error, null, '');
        return false;
      }
      return true;
    } catch (e) {
      print('deleteAttendanceApi error: $e');
      Utility.closeDialog();
      Utility.showMessage(
        'Failed to delete attendance',
        MessageType.error,
        null,
        '',
      );
      return false;
    }
  }

  Future<GetAttendanceModel?> getOneAttendanceApi({
    required String attendanceid,
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.getOneAttendanceApi(
        attendanceid: attendanceid,
        isLoading: isLoading,
      );
      if (response.hasError) {
        final msg = _parseErrorMessage(
          response.data,
          'Failed to load attendance details',
        );
        Utility.showMessage(msg, MessageType.error, null, '');
        return null;
      }
      if (response.data.isNotEmpty) {
        return getAttendanceModelFromJson(response.data);
      }
      return null;
    } catch (e, st) {
      print('getOneAttendanceApi error: $e\n$st');
      Utility.closeDialog();
      Utility.showMessage(
        'Failed to load attendance details',
        MessageType.error,
        null,
        '',
      );
      return null;
    }
  }

  Future<bool> changeAttendanceStatusApi({
    required String attendanceid,
    required String status,
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.changeAttendanceStatusApi(
        attendanceid: attendanceid,
        status: status,
        isLoading: isLoading,
      );
      if (response.hasError) {
        final msg = _parseErrorMessage(
          response.data,
          'Failed to change attendance status',
        );
        Utility.showMessage(msg, MessageType.error, null, '');
        return false;
      }
      return true;
    } catch (e, st) {
      print('changeAttendanceStatusApi error: $e\n$st');
      Utility.closeDialog();
      Utility.showMessage(
        'Failed to change attendance status',
        MessageType.error,
        null,
        '',
      );
      return false;
    }
  }

  Future<ResponseModel?> postCreateSalaryApi({
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
    try {
      var response = await _dataRepository.postCreateSalaryApi(
        salaryid: salaryid,
        date: date,
        userid: userid,
        branchid: branchid,
        month: month,
        year: year,
        workdays: workdays,
        basicsalary: basicsalary,
        bonus: bonus,
        allowance: allowance,
        deduction: deduction,
        netsalary: netsalary,
        paymentmode: paymentmode,
        paymentstatus: paymentstatus,
        transactionid: transactionid,
        remark: remark,
        isLoading: isLoading,
      );
      return response;
    } catch (_) {
      Utility.closeDialog();
      UnimplementedError();
      return null;
    }
  }

  Future<SalaryModel?> postSalaryListApi({
    required int page,
    required int limit,
    required String month,
    required String year,
    required String branchId,
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.postSalaryListApi(
        page: page,
        limit: limit,
        month: month,
        year: year,
        branchId: branchId,
        isLoading: isLoading,
      );
      var productListModel = salaryModelFromJson(response.data);
      if (productListModel.data != null) {
        return productListModel;
      } else {
        return productListModel;
      }
    } catch (_) {
      Utility.closeDialog();
      UnimplementedError();
      return null;
    }
  }

  Future<GetSalaryModel?> getSalaryApi({
    bool isLoading = false,
    required String? userid,
    required String? month,
    required String? year,
    String? workdays,
  }) async {
    try {
      var response = await _dataRepository.getSalaryApi(
        userid: userid,
        month: month,
        year: year,
        workdays: workdays,
        isLoading: isLoading,
      );
      var productListModel = getSalaryModelFromJson(response.data);
      if (productListModel.data != null) {
        return productListModel;
      } else {
        return productListModel;
      }
    } catch (_) {
      Utility.closeDialog();
      UnimplementedError();
      return null;
    }
  }

  Future<ResponseModel?> deleteSalaryApi({
    bool isLoading = false,
    required String? salaryid,
  }) async {
    try {
      var response = await _dataRepository.deleteSalaryApi(
        salaryid: salaryid,
        isLoading: isLoading,
      );
      return response;
    } catch (_) {
      Utility.closeDialog();
      UnimplementedError();
      return null;
    }
  }

  Future<UserModel?> getUserList({bool isLoading = false}) async {
    try {
      var response = await _dataRepository.getUserList(isLoading: isLoading);
      var productListModel = userModelFromJson(response.data);
      if (productListModel.data != null) {
        return productListModel;
      } else {
        return productListModel;
      }
    } catch (_) {
      Utility.closeDialog();
      UnimplementedError();
      return null;
    }
  }

  Future<String?> uploadAttendanceMediaApi(
    String filePath, {
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.uploadAttendanceMediaApi(
        filePath,
        isLoading: isLoading,
      );
      if (response.hasError) {
        Utility.errorMessage(response.data.toString());
        return null;
      }
      final decoded = json.decode(response.data);
      if (decoded == null) return null;
      final data = decoded['Data'] ?? decoded['data'];
      if (data is String) {
        return data;
      } else if (data is Map) {
        return (data['url'] ??
                data['imageUrl'] ??
                data['image'] ??
                data['path'])
            ?.toString();
      }
      return (decoded['url'] ??
              decoded['imageUrl'] ??
              decoded['image'] ??
              decoded['path'])
          ?.toString();
    } catch (e, st) {
      print('uploadAttendanceMediaApi error: $e\n$st');
      Utility.errorMessage('Upload error: $e');
      return null;
    }
  }

  Future<String?> startTrackingApi({
    required String userId,
    required double latitude,
    required double longitude,
    required String time,
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.startTrackingApi(
        userId: userId,
        latitude: latitude,
        longitude: longitude,
        time: time,
        isLoading: isLoading,
      );
      if (response.hasError) {
        return null;
      }
      final decoded = json.decode(response.data);
      final data = decoded['Data'] ?? decoded['data'];
      if (data != null) {
        if (data is String) return data;
        return (data['trackingId'] ?? data['_id'] ?? data['id'])?.toString();
      }
      return (decoded['trackingId'] ?? decoded['_id'] ?? decoded['id'])?.toString();
    } catch (e) {
      print('startTrackingApi error: $e');
      return null;
    }
  }

  Future<bool> stopTrackingApi({
    required String userId,
    required double latitude,
    required double longitude,
    required String time,
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.stopTrackingApi(
        userId: userId,
        latitude: latitude,
        longitude: longitude,
        time: time,
        isLoading: isLoading,
      );
      return !response.hasError;
    } catch (e) {
      print('stopTrackingApi error: $e');
      return false;
    }
  }

  Future<bool> updateLocationApi({
    required String trackingId,
    required double latitude,
    required double longitude,
    required String timestamp,
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.updateLocationApi(
        trackingId: trackingId,
        latitude: latitude,
        longitude: longitude,
        timestamp: timestamp,
        isLoading: isLoading,
      );
      return !response.hasError;
    } catch (e) {
      print('updateLocationApi error: $e');
      return false;
    }
  }
}
