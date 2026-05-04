import 'dart:convert';

CustomerListModel customerListModelFromJson(String str) =>
    CustomerListModel.fromJson(json.decode(str));

String customerListModelToJson(CustomerListModel data) =>
    json.encode(data.toJson());

class CustomerListModel {
  String message;
  CustomerData data;
  int status;
  bool isSuccess;

  CustomerListModel({
    required this.message,
    required this.data,
    required this.status,
    required this.isSuccess,
  });

  factory CustomerListModel.fromJson(Map<String, dynamic> json) =>
      CustomerListModel(
        message: json["Message"] ?? "",
        data: CustomerData.fromJson(json["Data"] ?? {}),
        status: json["Status"] ?? 0,
        isSuccess: json["IsSuccess"] ?? false,
      );

  Map<String, dynamic> toJson() => {
    "Message": message,
    "Data": data.toJson(),
    "Status": status,
    "IsSuccess": isSuccess,
  };
}

class CustomerData {
  List<CustomerDoc> docs;
  int totalDocs;
  int limit;
  int totalPages;
  int page;
  int pagingCounter;
  bool hasPrevPage;
  bool hasNextPage;

  CustomerData({
    required this.docs,
    required this.totalDocs,
    required this.limit,
    required this.totalPages,
    required this.page,
    required this.pagingCounter,
    required this.hasPrevPage,
    required this.hasNextPage,
  });

  factory CustomerData.fromJson(Map<String, dynamic> json) => CustomerData(
    docs: json["docs"] == null ? [] : List<CustomerDoc>.from(json["docs"].map((x) => CustomerDoc.fromJson(x))),
    totalDocs: json["totalDocs"] ?? 0,
    limit: json["limit"] ?? 0,
    totalPages: json["totalPages"] ?? 0,
    page: json["page"] ?? 0,
    pagingCounter: json["pagingCounter"] ?? 0,
    hasPrevPage: json["hasPrevPage"] ?? false,
    hasNextPage: json["hasNextPage"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "docs": List<dynamic>.from(docs.map((x) => x.toJson())),
    "totalDocs": totalDocs,
    "limit": limit,
    "totalPages": totalPages,
    "page": page,
    "pagingCounter": pagingCounter,
    "hasPrevPage": hasPrevPage,
    "hasNextPage": hasNextPage,
  };
}

class CustomerDoc {
  String id;
  String customerid;
  String distributorid;
  String name;
  String email;
  String countrycode;
  String mobile;
  String feedback;

  CustomerDoc({
    required this.id,
    required this.customerid,
    required this.distributorid,
    required this.name,
    required this.email,
    required this.countrycode,
    required this.mobile,
    required this.feedback,
  });

  factory CustomerDoc.fromJson(Map<String, dynamic> json) => CustomerDoc(
    id: json["_id"] ?? "",
    customerid: json["customerid"] ?? "",
    distributorid: json["distributorid"] ?? "",
    name: json["name"] ?? "",
    email: json["email"] ?? "",
    countrycode: json["countrycode"] ?? "",
    mobile: json["mobile"] ?? "",
    feedback: json["feedback"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "customerid": customerid,
    "distributorid": distributorid,
    "name": name,
    "email": email,
    "countrycode": countrycode,
    "mobile": mobile,
    "feedback": feedback,
  };
}
