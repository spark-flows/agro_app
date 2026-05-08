import 'dart:async';
import 'dart:convert';
import 'package:agro_app/app/utils/utility.dart';
import 'package:agro_app/data/data.dart';
import 'package:agro_app/device/device.dart';
import 'package:agro_app/domain/models/auth_model.dart';
import 'package:agro_app/domain/models/get_all_customers_model.dart';
import 'package:agro_app/domain/models/create_customer_model.dart';
import 'package:agro_app/domain/models/get_profille_model.dart';
import 'package:agro_app/domain/models/get_all_order_model.dart';
import 'package:agro_app/domain/models/create_order_model.dart';
import 'package:agro_app/domain/models/get_one_order_model.dart';
import 'package:agro_app/domain/models/get_all_product_model.dart';
import 'package:agro_app/domain/models/get_all_category_model.dart';
import 'package:agro_app/domain/models/get_all_users_model.dart';
import 'package:agro_app/domain/models/get_all_roll_model.dart';

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
      if (response.data.isNotEmpty) {
        return getAllProductModelFromJson(response.data);
      } else {
        return null;
      }
    } catch (e) {
      print('getProductListApi error: $e');
      Utility.closeDialog();
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
      print('[Repo] getCategoryListApi raw data length: ${response.data.length}');
      if (response.data.isNotEmpty) {
        final model = getAllCategoryModelFromJson(response.data);
        print('[Repo] getCategoryListApi parsed ${model.data.docs.length} docs, isSuccess=${model.isSuccess}');
        return model;
      } else {
        print('[Repo] getCategoryListApi: empty response');
        return null;
      }
    } catch (e, st) {
      print('[Repo] getCategoryListApi error: $e\n$st');
      Utility.closeDialog();
      return null;
    }
  }

  Future<bool> createProductApi({
    String? productid,
    required String name,
    required String unit,
    required int price,
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
        description: description,
        image: image,
        categoryid: categoryid,
        isLoading: isLoading,
      );
      return !response.hasError;
    } catch (e) {
      print('createProductApi error: $e');
      Utility.closeDialog();
      return false;
    }
  }

  Future<GetAllCustomerModel?> getCustomerListApi({
    int page = 1,
    int limit = 100,
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
      if (response.data.isNotEmpty) {
        return getAllCustomerModelFromJson(response.data);
      } else {
        return null;
      }
    } catch (e) {
      print('getCustomerListApi error: $e');
      Utility.closeDialog();
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
        isLoading: isLoading,
      );
      if (response.data.isNotEmpty) {
        return createCustomerModelFromJson(response.data);
      }
      return null;
    } catch (e) {
      Utility.closeDialog();
      return null;
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
      if (response.data.isNotEmpty) {
        return getAllOrderModelFromJson(response.data);
      } else {
        return null;
      }
    } catch (e) {
      print('getOrderListApi error: $e');
      Utility.closeDialog();
      return null;
    }
  }

  Future<CreateorderModel?> createOrderApi({
    String? orderid,
    required String customerid,
    required List<Map<String, dynamic>> items,
    required num totalamount,
    String? deliverydate,
    String? feedback,
    bool isLoading = false,
  }) async {
    try {
      var response = await _dataRepository.createOrderApi(
        orderid: orderid,
        customerid: customerid,
        items: items,
        totalamount: totalamount,
        deliverydate: deliverydate,
        feedback: feedback,
        isLoading: isLoading,
      );
      if (response.data.isNotEmpty) {
        return createorderModelFromJson(response.data);
      } else {
        return null;
      }
    } catch (e) {
      print('createOrderApi error: $e');
      Utility.closeDialog();
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
      if (response.data.isNotEmpty) {
        return getOneOrderModelFromJson(response.data);
      } else {
        return null;
      }
    } catch (e) {
      print('getOneOrderApi error: $e');
      Utility.closeDialog();
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
      return response.data.isNotEmpty == true;
    } catch (e) {
      print('deleteOrderApi error: $e');
      Utility.closeDialog();
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
      return !response.hasError;
    } catch (e) {
      print('deleteProductApi error: $e');
      Utility.closeDialog();
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
      return !response.hasError;
    } catch (e) {
      print('deleteUsersApi error: $e');
      Utility.closeDialog();
      return false;
    }
  }

  Future<GetAllUsersModel?> getUsersListApi({
    int page = 1,
    int limit = 10,
    String search = "",
    String sortfield = "_id",
    int sortoption = -1,
    String roleid = "",
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
        isLoading: isLoading,
      );
      if (response.data.isNotEmpty) {
        return getAllUsersModelFromJson(response.data);
      } else {
        return null;
      }
    } catch (e) {
      print('getUsersListApi error: $e');
      Utility.closeDialog();
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
        isLoading: isLoading,
      );
      if (!response.hasError) {
        return null; // success
      }
      // Try to parse the error message from the response body JSON
      try {
        final decoded = json.decode(response.data);
        return decoded['message']?.toString() ?? 'Failed to save user';
      } catch (_) {
        return 'Failed to save user';
      }
    } catch (e) {
      print('createUserApi error: $e');
      Utility.closeDialog();
      return 'An unexpected error occurred';
    }
  }
}
