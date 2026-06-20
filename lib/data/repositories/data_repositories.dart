import 'dart:io';

import 'package:agro_app/data/data.dart';
import 'package:agro_app/domain/domain.dart';

/// Repositories (retrieve data, heavy processing etc..)
class DataRepository extends DomainRepository {
  /// [connectHelper] : A connection helper which will connect to the
  /// remote to get the data.
  DataRepository(this.connectHelper);

  final ConnectHelper connectHelper;

  @override
  void clearData(dynamic key) {
    throw UnimplementedError();
  }

  /// Delete the box
  @override
  void deleteBox() {
    throw UnimplementedError();
  }

  /// returns stored string value
  @override
  String getStringValue(String key) {
    throw UnimplementedError();
  }

  /// store the data
  @override
  void saveValue(dynamic key, dynamic value) {
    throw UnimplementedError();
  }

  /// return bool value
  @override
  bool getBoolValue(String key) => throw UnimplementedError();

  @override
  Future<String> getSecuredValue(String key) async {
    throw UnimplementedError();
  }

  @override
  void saveValueSecurely(String key, String value) {
    throw UnimplementedError();
  }

  @override
  void deleteSecuredValue(String key) {
    throw UnimplementedError();
  }

  @override
  void deleteAllSecuredValues() {
    throw UnimplementedError();
  }

  @override
  Future<String> getIp() async => await connectHelper.getIp();

  Future<ResponseModel> loginApi({
    required String userName,
    required String password,
    required String fcmToken,
    bool isLoading = false,
  }) async => connectHelper.loginApi(
    userName: userName,
    password: password,
    fcmToken: fcmToken,
    isLoading: isLoading,
  );

  Future<ResponseModel> getProductListApi({
    int page = 1,
    int limit = 10,
    String search = '',
    bool isLoading = false,
  }) async => connectHelper.getProductListApi(
    page: page,
    limit: limit,
    search: search,
    isLoading: isLoading,
  );

  Future<ResponseModel> getCategoryListApi({bool isLoading = false}) async =>
      connectHelper.getCategoryListApi(isLoading: isLoading);

  Future<ResponseModel> createProductApi({
    String? productid,
    required String name,
    // required String unit,
    // required int price,
    // required String description,
    required String image,
    required String categoryid,
    // required int qty,
    bool isLoading = false,
  }) async => connectHelper.createProductApi(
    productid: productid,
    name: name,
    // unit: unit,
    // price: price,
    // description: description,
    image: image,
    categoryid: categoryid,
    // qty: qty,
    isLoading: isLoading,
  );

  Future<ResponseModel> getCustomerListApi({
    int page = 1,
    int limit = 100,
    String search = "",
    bool isLoading = false,
  }) async => connectHelper.getCustomerListApi(
    page: page,
    limit: limit,
    search: search,
    isLoading: isLoading,
  );

  Future<ResponseModel> createCustomerApi({
    String? customerid,
    required String name,
    required String email,
    required String countrycode,
    required String mobile,
    required String feedback,
    required String village,
    String? distributorid,
    bool isLoading = false,
  }) async => connectHelper.createCustomerApi(
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

  Future<ResponseModel> deleteCustomerApi({
    required String customerid,
    bool isLoading = false,
  }) async => connectHelper.deleteCustomerApi(
    customerid: customerid,
    isLoading: isLoading,
  );

  Future<ResponseModel> customerFeedbackApi({
    required String customerid,
    required String feedback,
    bool isLoading = false,
  }) async => connectHelper.customerFeedbackApi(
    customerid: customerid,
    feedback: feedback,
    isLoading: isLoading,
  );

  Future<ResponseModel> getProfileApi({bool isLoading = false}) async =>
      connectHelper.getProfileApi(isLoading: isLoading);

  Future<ResponseModel> getOrderListApi({
    String? customerid,
    bool isLoading = false,
  }) async => connectHelper.getOrderListApi(
    customerid: customerid,
    isLoading: isLoading,
  );

  Future<ResponseModel> createOrderApi({
    String? orderid,
    required List<Map<String, dynamic>> items,
    required num totalamount,
    String? deliverydate,
    bool isLoading = false,
  }) async => connectHelper.createOrderApi(
    orderid: orderid,
    items: items,
    totalamount: totalamount,
    deliverydate: deliverydate,
    isLoading: isLoading,
  );

  Future<ResponseModel> getOneOrderApi({
    required String orderid,
    bool isLoading = false,
  }) async =>
      connectHelper.getOneOrderApi(orderid: orderid, isLoading: isLoading);

  Future<ResponseModel> deleteOrderApi({
    required String orderid,
    bool isLoading = false,
  }) async {
    return await connectHelper.deleteOrderApi(
      orderid: orderid,
      isLoading: isLoading,
    );
  }

  Future<ResponseModel> getCustomerOrderListApi({
    String? customerid,
    bool isLoading = false,
  }) async {
    return await connectHelper.getCustomerOrderListApi(
      customerid: customerid,
      isLoading: isLoading,
    );
  }

  Future<ResponseModel> createCustomerOrderApi({
    String? customerorderid,
    required String customerid,
    required String image,
    required String remark1,
    required String remark2,
    required String remark3,
    bool isLoading = false,
  }) async {
    return await connectHelper.createCustomerOrderApi(
      customerorderid: customerorderid,
      customerid: customerid,
      image: image,
      remark1: remark1,
      remark2: remark2,
      remark3: remark3,
      isLoading: isLoading,
    );
  }

  Future<ResponseModel> getOneCustomerOrderApi({
    required String customerorderid,
    bool isLoading = false,
  }) async {
    return await connectHelper.getOneCustomerOrderApi(
      customerorderid: customerorderid,
      isLoading: isLoading,
    );
  }

  Future<ResponseModel> deleteCustomerOrderApi({
    required String customerorderid,
    bool isLoading = false,
  }) async {
    return await connectHelper.deleteCustomerOrderApi(
      customerorderid: customerorderid,
      isLoading: isLoading,
    );
  }

  Future<ResponseModel> uploadCustomerOrderApi(
    File image, {
    bool isLoading = false,
  }) async {
    return await connectHelper.uploadCustomerOrderApi(
      image,
      isLoading: isLoading,
    );
  }

  Future<ResponseModel> deleteProductApi({
    required String productid,
    bool isLoading = false,
  }) async => connectHelper.deleteProductApi(
    productid: productid,
    isLoading: isLoading,
  );

  Future<ResponseModel> deleteUsersApi({
    required String userid,
    bool isLoading = false,
  }) async =>
      connectHelper.deleteUsersApi(userid: userid, isLoading: isLoading);

  Future<ResponseModel> getOneUserApi({
    required String userid,
    bool isLoading = false,
  }) async =>
      connectHelper.getOneUserApi(userid: userid, isLoading: isLoading);

  Future<ResponseModel> getUsersListApi({
    int page = 1,
    int limit = 10,
    String search = "",
    String sortfield = "_id",
    int sortoption = -1,
    String roleid = "",
    String type = "",
    bool isLoading = false,
  }) async => connectHelper.getUsersListApi(
    page: page,
    limit: limit,
    search: search,
    sortfield: sortfield,
    type: type,
    sortoption: sortoption,
    roleid: roleid,
    isLoading: isLoading,
  );

  Future<ResponseModel> getAllRolesApi({
    String search = "",
    bool isLoading = false,
  }) async =>
      connectHelper.getAllRolesApi(search: search, isLoading: isLoading);

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
  }) async => connectHelper.createUserApi(
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

  Future<ResponseModel> getAllBranchesApi({
    int page = 1,
    int limit = 100,
    String search = "",
    bool isLoading = false,
  }) async => connectHelper.getAllBranchesApi(
    page: page,
    limit: limit,
    search: search,
    isLoading: isLoading,
  );
}
