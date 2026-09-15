// To parse this JSON data, do
//
//     final getAllCustomerModel = getAllCustomerModelFromJson(jsonString);

import 'dart:convert';

GetAllCustomerModel getAllCustomerModelFromJson(String str) {
  final decoded = json.decode(str);
  if (decoded is List) {
    return GetAllCustomerModel(
      isSuccess: true,
      status: 200,
      data: GetAllCustomerData(
        docs: List<GetAllCustomerDoc>.from(
          decoded.map((x) => GetAllCustomerDoc.fromJson(x)),
        ),
      ),
    );
  }
  return GetAllCustomerModel.fromJson(decoded as Map<String, dynamic>);
}

String getAllCustomerModelToJson(GetAllCustomerModel data) =>
    json.encode(data.toJson());

class GetAllCustomerModel {
  String? message;
  GetAllCustomerData? data;
  int? status;
  bool? isSuccess;

  GetAllCustomerModel({this.message, this.data, this.status, this.isSuccess});

  factory GetAllCustomerModel.fromJson(Map<String, dynamic> json) =>
      GetAllCustomerModel(
        message: json["Message"] ?? json["message"],
        data: json["Data"] == null && json["data"] == null
            ? null
            : GetAllCustomerData.fromJson(json["Data"] ?? json["data"]),
        status: json["Status"] ?? json["status"],
        isSuccess: json["IsSuccess"] ?? json["isSuccess"],
      );

  Map<String, dynamic> toJson() => {
    "Message": message,
    "Data": data?.toJson(),
    "Status": status,
    "IsSuccess": isSuccess,
  };
}

class GetAllCustomerData {
  List<GetAllCustomerDoc>? docs;
  int? totalDocs;
  int? limit;
  int? totalPages;
  int? page;
  int? pagingCounter;
  bool? hasPrevPage;
  bool? hasNextPage;
  dynamic prevPage;
  dynamic nextPage;

  GetAllCustomerData({
    this.docs,
    this.totalDocs,
    this.limit,
    this.totalPages,
    this.page,
    this.pagingCounter,
    this.hasPrevPage,
    this.hasNextPage,
    this.prevPage,
    this.nextPage,
  });

  factory GetAllCustomerData.fromJson(dynamic json) {
    if (json is List) {
      return GetAllCustomerData(
        docs: List<GetAllCustomerDoc>.from(
          json.map((x) => GetAllCustomerDoc.fromJson(x)),
        ),
      );
    }
    if (json is Map<String, dynamic>) {
      final dynamic rawDocs = json["docs"] ?? json["data"];
      return GetAllCustomerData(
        docs: rawDocs == null
            ? []
            : (rawDocs is List
                ? List<GetAllCustomerDoc>.from(
                    rawDocs.map((x) => GetAllCustomerDoc.fromJson(x)),
                  )
                : []),
        totalDocs: json["totalDocs"],
        limit: json["limit"],
        totalPages: json["totalPages"],
        page: json["page"],
        pagingCounter: json["pagingCounter"],
        hasPrevPage: json["hasPrevPage"],
        hasNextPage: json["hasNextPage"],
        prevPage: json["prevPage"],
        nextPage: json["nextPage"],
      );
    }
    return GetAllCustomerData();
  }

  Map<String, dynamic> toJson() => {
    "docs": docs == null
        ? []
        : List<dynamic>.from(docs!.map((x) => x.toJson())),
    "totalDocs": totalDocs,
    "limit": limit,
    "totalPages": totalPages,
    "page": page,
    "pagingCounter": pagingCounter,
    "hasPrevPage": hasPrevPage,
    "hasNextPage": hasNextPage,
    "prevPage": prevPage,
    "nextPage": nextPage,
  };
}

class GetAllCustomerDoc {
  String? id;
  String? name;
  String? email;
  String? countrycode;
  String? mobile;
  String? feedback;
  String? village;
  bool? isDeleted;
  String? createdAt;
  dynamic distributorid;

  GetAllCustomerDoc({
    this.id,
    this.name,
    this.email,
    this.countrycode,
    this.mobile,
    this.feedback,
    this.village,
    this.isDeleted,
    this.createdAt,
    this.distributorid,
  });

  factory GetAllCustomerDoc.fromJson(Map<String, dynamic> json) =>
      GetAllCustomerDoc(
        id: json["_id"],
        name: json["name"],
        email: json["email"],
        countrycode: json["countrycode"],
        mobile: json["mobile"],
        feedback: json["feedback"],
        village: json["village"],
        isDeleted: json["isDeleted"],
        createdAt: json["createdAt"],
        distributorid: json["distributorid"],
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "email": email,
    "countrycode": countrycode,
    "mobile": mobile,
    "feedback": feedback,
    "village": village,
    "isDeleted": isDeleted,
    "createdAt": createdAt,
    "distributorid": distributorid,
  };
}

class GetAllCustomerDistributorid {
  GetAllCustomerDistributorid();

  factory GetAllCustomerDistributorid.fromJson(Map<String, dynamic> json) =>
      GetAllCustomerDistributorid();

  Map<String, dynamic> toJson() => {};
}
