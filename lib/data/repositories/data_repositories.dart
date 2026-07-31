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

  Future<ResponseModel> getUnitListApi({bool isLoading = false}) async =>
      connectHelper.getUnitListApi(isLoading: isLoading);

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
  }) async => connectHelper.createProductApi(
    productid: productid,
    name: name,
    unit: unit,
    price: price,
    description: description,
    image: image,
    categoryid: categoryid,
    qty: qty,
    isLoading: isLoading,
  );

  Future<ResponseModel> getCustomerListApi({
    int page = 1,
    int limit = 10,
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
    String? distributorid,
    bool isLoading = false,
  }) async => connectHelper.createOrderApi(
    orderid: orderid,
    items: items,
    totalamount: totalamount,
    deliverydate: deliverydate,
    distributorid: distributorid,
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
    required List<Map<String, dynamic>> remark,
    bool isLoading = false,
  }) async {
    return await connectHelper.createCustomerOrderApi(
      customerorderid: customerorderid,
      customerid: customerid,
      image: image,
      remark: remark,
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
    bool isLoading = true,
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
  }) async => connectHelper.getOneUserApi(userid: userid, isLoading: isLoading);

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
  }) async => connectHelper.getUsersListApi(
    page: page,
    limit: limit,
    search: search,
    sortfield: sortfield,
    type: type,
    sortoption: sortoption,
    roleid: roleid,
    assigntoid: assigntoid,
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
    salary: salary,
    allowance: allowance,
    liveTracking: liveTracking,
    odometer: odometer,
    permissionbranchid: permissionbranchid,
    permissionuserid: permissionuserid,
    assigntoid: assigntoid,
    mapcolor: mapcolor,
    fcmToken: fcmToken,
    isLoading: isLoading,
  );

  Future<ResponseModel> getAllBranchesApi({bool isLoading = false}) async =>
      connectHelper.getAllBranchesApi(isLoading: isLoading);

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
  }) async => connectHelper.getTaskListApi(
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
  }) async => connectHelper.createTaskApi(
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
    tasktype: tasktype,
    remarks: remarks,
    isLoading: isLoading,
  );

  Future<ResponseModel> uploadTaskAttachmentApi(
    List<File> files, {
    bool isLoading = true,
  }) async =>
      connectHelper.uploadTaskAttachmentApi(files, isLoading: isLoading);

  Future<ResponseModel> deleteTaskApi({
    required String taskid,
    bool isLoading = false,
  }) async => connectHelper.deleteTaskApi(taskid: taskid, isLoading: isLoading);

  Future<ResponseModel> getOneTaskApi({
    required String taskid,
    bool isLoading = false,
  }) async => connectHelper.getOneTaskApi(taskid: taskid, isLoading: isLoading);

  Future<ResponseModel> changeTaskStatusApi({
    required String taskid,
    required String status,
    String? remark,
    String? updatedBy,
    bool isLoading = false,
  }) async => connectHelper.changeTaskStatusApi(
    taskid: taskid,
    status: status,
    remark: remark,
    updatedBy: updatedBy,
    isLoading: isLoading,
  );

  Future<ResponseModel> getAttendanceListApi({
    int page = 1,
    int limit = 10,
    String search = "",
    String date = "",
    String branchId = "",
    String userid = "",
    String status = "",
    bool isLoading = false,
  }) async => connectHelper.getAttendanceListApi(
    page: page,
    limit: limit,
    search: search,
    branchId: branchId,
    userid: userid,
    date: date,
    status: status,
    isLoading: isLoading,
  );

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
    String? photo,
    int? odometer,
    String? timeinphoto,
    int? timeinodometer,
    String? timeoutphoto,
    int? timeoutodometer,
    String? vehicalno,
    bool isLoading = false,
  }) async => connectHelper.createAttendanceApi(
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
    timeinphoto: timeinphoto,
    timeinodometer: timeinodometer,
    timeoutphoto: timeoutphoto,
    timeoutodometer: timeoutodometer,
    vehicalno: vehicalno,
    isLoading: isLoading,
  );

  Future<ResponseModel> deleteAttendanceApi({
    required String attendanceid,
    bool isLoading = false,
  }) async => connectHelper.deleteAttendanceApi(
    attendanceid: attendanceid,
    isLoading: isLoading,
  );

  Future<ResponseModel> getOneAttendanceApi({
    required String attendanceid,
    bool isLoading = false,
  }) async => connectHelper.getOneAttendanceApi(
    attendanceid: attendanceid,
    isLoading: isLoading,
  );

  Future<ResponseModel> changeAttendanceStatusApi({
    required String attendanceid,
    required String status,
    bool isLoading = false,
  }) async => connectHelper.changeAttendanceStatusApi(
    attendanceid: attendanceid,
    status: status,
    isLoading: isLoading,
  );

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
  }) async => connectHelper.postCreateSalaryApi(
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

  Future<ResponseModel> postSalaryListApi({
    required int page,
    required int limit,
    required String month,
    required String year,
    required String branchId,
    bool isLoading = false,
  }) async => connectHelper.postSalaryListApi(
    page: page,
    limit: limit,
    month: month,
    year: year,
    branchId: branchId,
    isLoading: isLoading,
  );

  Future<ResponseModel> getSalaryApi({
    bool isLoading = false,
    required String? userid,
    required String? month,
    required String? year,
    String? workdays,
  }) async => connectHelper.getSalaryApi(
    userid: userid,
    month: month,
    year: year,
    workdays: workdays,
    isLoading: isLoading,
  );

  Future<ResponseModel> deleteSalaryApi({
    bool isLoading = false,
    required String? salaryid,
  }) async =>
      connectHelper.deleteSalaryApi(salaryid: salaryid, isLoading: isLoading);

  Future<ResponseModel> getUserList({bool isLoading = false}) async =>
      connectHelper.getUserList(isLoading: isLoading);

  Future<ResponseModel> uploadAttendanceMediaApi(
    String filePath, {
    bool isLoading = true,
  }) async =>
      connectHelper.uploadAttendanceMediaApi(filePath, isLoading: isLoading);

  Future<ResponseModel> startTrackingApi({
    required String userId,
    required double latitude,
    required double longitude,
    required String time,
    bool isLoading = false,
  }) async => connectHelper.startTrackingApi(
    userId: userId,
    latitude: latitude,
    longitude: longitude,
    time: time,
    isLoading: isLoading,
  );

  Future<ResponseModel> stopTrackingApi({
    required String userId,
    required double latitude,
    required double longitude,
    required String time,
    bool isLoading = false,
  }) async => connectHelper.stopTrackingApi(
    userId: userId,
    latitude: latitude,
    longitude: longitude,
    time: time,
    isLoading: isLoading,
  );

  Future<ResponseModel> updateLocationApi({
    // required String trackingId,
    required String userId,
    required double latitude,
    required double longitude,
    required String timestamp,
    bool isLoading = false,
  }) async => connectHelper.updateLocationApi(
    // trackingId: trackingId,
    userId: userId,
    latitude: latitude,
    longitude: longitude,
    timestamp: timestamp,
    isLoading: isLoading,
  );

  Future<ResponseModel> pauseTrackingApi({
    required Map<String, dynamic> body,
    bool isLoading = false,
  }) async => connectHelper.pauseTrackingApi(body: body, isLoading: isLoading);

  Future<ResponseModel> createLeaveApi({
    String? leaveid,
    String? leavedate,
    required String userid,
    required String fromdate,
    required String todate,
    required num totaldays,
    required num totalhours,
    required String leavetype,
    required String reason,
    required String status,
    bool isLoading = false,
  }) async => connectHelper.createLeaveApi(
    leaveid: leaveid,
    leavedate: leavedate,
    userid: userid,
    fromdate: fromdate,
    todate: todate,
    totaldays: totaldays,
    totalhours: totalhours,
    leavetype: leavetype,
    reason: reason,
    status: status,
    isLoading: isLoading,
  );

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
  }) async => connectHelper.getLeaveListApi(
    page: page,
    limit: limit,
    search: search,
    fromDate: fromDate,
    toDate: toDate,
    status: status,
    userid: userid,
    leavetype: leavetype,
    isLoading: isLoading,
  );

  Future<ResponseModel> deleteLeaveApi({
    required String leaveid,
    bool isLoading = false,
  }) async =>
      connectHelper.deleteLeaveApi(leaveid: leaveid, isLoading: isLoading);

  Future<ResponseModel> getOneLeaveApi({
    required String leaveid,
    bool isLoading = false,
  }) async =>
      connectHelper.getOneLeaveApi(leaveid: leaveid, isLoading: isLoading);

  Future<ResponseModel> changeLeaveStatusApi({
    required String leaveid,
    required String status,
    bool isLoading = false,
  }) async => connectHelper.changeLeaveStatusApi(
    leaveid: leaveid,
    status: status,
    isLoading: isLoading,
  );
}
