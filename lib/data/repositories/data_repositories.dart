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

  /// Get data from secure storage
  @override
  Future<String> getSecuredValue(String key) async {
    throw UnimplementedError();
  }

  /// Save data in secure storage
  @override
  void saveValueSecurely(String key, String value) {
    throw UnimplementedError();
  }

  /// Delete data from secure storage
  @override
  void deleteSecuredValue(String key) {
    throw UnimplementedError();
  }

  /// Delete all data from secure storage
  @override
  void deleteAllSecuredValues() {
    throw UnimplementedError();
  }

  /// API to get the IP of the user
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
    bool isLoading = false,
  }) async => connectHelper.getProductListApi(
    isLoading: isLoading,
  );

  Future<ResponseModel> getCustomerListApi({
    bool isLoading = false,
  }) async => connectHelper.getCustomerListApi(
    isLoading: isLoading,
  );

  Future<ResponseModel> createCustomerApi({
    String? customerid,
    required String name,
    required String email,
    required String countrycode,
    required String mobile,
    required String feedback,
    bool isLoading = false,
  }) async => connectHelper.createCustomerApi(
    customerid: customerid,
    name: name,
    email: email,
    countrycode: countrycode,
    mobile: mobile,
    feedback: feedback,
    isLoading: isLoading,
  );

  Future<ResponseModel> getProfileApi({
    bool isLoading = false,
  }) async => connectHelper.getProfileApi(
    isLoading: isLoading,
  );

  Future<ResponseModel> getOrderListApi({
    String? customerid,
    bool isLoading = false,
  }) async => connectHelper.getOrderListApi(
    customerid: customerid,
    isLoading: isLoading,
  );

  Future<ResponseModel> createOrderApi({
    String? orderid,
    required String customerid,
    required List<Map<String, dynamic>> items,
    required num totalamount,
    String? deliverydate,
    String? feedback,
    bool isLoading = false,
  }) async => connectHelper.createOrderApi(
    orderid: orderid,
    customerid: customerid,
    items: items,
    totalamount: totalamount,
    deliverydate: deliverydate,
    feedback: feedback,
    isLoading: isLoading,
  );

  Future<ResponseModel> getOneOrderApi({
    required String orderid,
    bool isLoading = false,
  }) async => connectHelper.getOneOrderApi(
    orderid: orderid,
    isLoading: isLoading,
  );
}
