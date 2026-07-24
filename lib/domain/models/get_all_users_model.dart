// To parse this JSON data, do
//
//     final getAllUsersModel = getAllUsersModelFromJson(jsonString);

import 'dart:convert';

GetAllUsersModel getAllUsersModelFromJson(String str) =>
    GetAllUsersModel.fromJson(json.decode(str));

String getAllUsersModelToJson(GetAllUsersModel data) =>
    json.encode(data.toJson());

class GetAllUsersModel {
  String message;
  Data data;
  int status;
  bool isSuccess;

  GetAllUsersModel({
    required this.message,
    required this.data,
    required this.status,
    required this.isSuccess,
  });

  factory GetAllUsersModel.fromJson(Map<String, dynamic> json) =>
      GetAllUsersModel(
        message: json["Message"],
        data: Data.fromJson(json["Data"]),
        status: json["Status"],
        isSuccess: json["IsSuccess"],
      );

  Map<String, dynamic> toJson() => {
    "Message": message,
    "Data": data.toJson(),
    "Status": status,
    "IsSuccess": isSuccess,
  };
}

class Data {
  List<Doc> docs;
  int totalDocs;
  int limit;
  int totalPages;
  int page;
  int pagingCounter;
  bool hasPrevPage;
  bool hasNextPage;
  dynamic prevPage;
  dynamic nextPage;

  Data({
    required this.docs,
    required this.totalDocs,
    required this.limit,
    required this.totalPages,
    required this.page,
    required this.pagingCounter,
    required this.hasPrevPage,
    required this.hasNextPage,
    required this.prevPage,
    required this.nextPage,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    docs: json["docs"] == null
        ? []
        : List<Doc>.from((json["docs"] as List).map((x) => Doc.fromJson(x))),
    totalDocs: json["totalDocs"] ?? 0,
    limit: json["limit"] ?? 10,
    totalPages: json["totalPages"] ?? 1,
    page: json["page"] ?? 1,
    pagingCounter: json["pagingCounter"] ?? 1,
    hasPrevPage: json["hasPrevPage"] ?? false,
    hasNextPage: json["hasNextPage"] ?? false,
    prevPage: json["prevPage"],
    nextPage: json["nextPage"],
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
    "prevPage": prevPage,
    "nextPage": nextPage,
  };
}

class Doc {
  String id;
  String code;
  String name;
  String email;
  String mobile;
  bool status;
  bool isDeleted;
  String? address;
  DateTime createdAt;
  DateTime updatedAt;
  Roleid roleid;
  AtedBy createdBy;
  AtedBy updatedBy;
  DeletedBy deletedBy;
  String? surname;
  String? fathername;

  // Distributor shift / clock states (totally separate)
  bool isClockedIn;
  bool isClockedOut;
  String? clockInTime;
  String? clockOutTime;

  Doc({
    required this.id,
    required this.code,
    required this.name,
    required this.email,
    required this.mobile,
    required this.status,
    required this.isDeleted,
    this.address,
    required this.createdAt,
    required this.updatedAt,
    required this.roleid,
    required this.createdBy,
    required this.updatedBy,
    required this.deletedBy,
    this.surname,
    this.fathername,
    this.isClockedIn = false,
    this.isClockedOut = false,
    this.clockInTime,
    this.clockOutTime,
    this.permissionbranchid,
    this.mapcolor,
  });

  List<String>? permissionbranchid;
  String? mapcolor;

  factory Doc.fromJson(Map<String, dynamic> json) => Doc(
    id: json["_id"]?.toString() ?? '',
    code: json["code"]?.toString() ?? '',
    name: json["name"]?.toString() ?? '',
    email: json["email"]?.toString() ?? '',
    mobile: json["mobile"]?.toString() ?? '',
    status: json["status"] is bool ? json["status"] : false,
    isDeleted: json["isDeleted"] is bool ? json["isDeleted"] : false,
    address: json["location"]?.toString(),
    createdAt: json["createdAt"] != null
        ? DateTime.tryParse(json["createdAt"].toString()) ?? DateTime.now()
        : DateTime.now(),
    updatedAt: json["updatedAt"] != null
        ? DateTime.tryParse(json["updatedAt"].toString()) ?? DateTime.now()
        : DateTime.now(),
    roleid: json["roleid"] is Map<String, dynamic>
        ? Roleid.fromJson(json["roleid"])
        : Roleid(id: json["roleid"]?.toString(), rolename: ''),
    createdBy: json["createdBy"] is Map<String, dynamic>
        ? AtedBy.fromJson(json["createdBy"])
        : AtedBy(id: json["createdBy"]?.toString()),
    updatedBy: json["updatedBy"] is Map<String, dynamic>
        ? AtedBy.fromJson(json["updatedBy"])
        : AtedBy(id: json["updatedBy"]?.toString()),
    deletedBy: json["deletedBy"] is Map<String, dynamic>
        ? DeletedBy.fromJson(json["deletedBy"])
        : DeletedBy(),
    surname: json["surname"]?.toString(),
    fathername: json["fathername"]?.toString(),
    isClockedIn: json["isClockedIn"] is bool ? json["isClockedIn"] : false,
    isClockedOut: json["isClockedOut"] is bool ? json["isClockedOut"] : false,
    clockInTime: json["clockInTime"]?.toString(),
    clockOutTime: json["clockOutTime"]?.toString(),
    mapcolor: (json["mapcolor"] ?? json["mapColor"])?.toString(),
    permissionbranchid: (json["permissionbranchid"] ?? json["permissionbranchId"] ?? json["permissionbranch"]) == null
        ? []
        : (json["permissionbranchid"] ?? json["permissionbranchId"] ?? json["permissionbranch"]) is List
            ? ((json["permissionbranchid"] ?? json["permissionbranchId"] ?? json["permissionbranch"]) as List)
                .map((x) => x is Map ? (x["_id"] ?? x["id"] ?? "").toString() : x.toString())
                .where((x) => x.isNotEmpty)
                .toList()
            : [],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "code": code,
    "name": name,
    "email": email,
    "mobile": mobile,
    "status": status,
    "isDeleted": isDeleted,
    "location": address,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "roleid": roleid.toJson(),
    "createdBy": createdBy.toJson(),
    "updatedBy": updatedBy.toJson(),
    "deletedBy": deletedBy.toJson(),
    "surname": surname,
    "fathername": fathername,
    "isClockedIn": isClockedIn,
    "isClockedOut": isClockedOut,
    "clockInTime": clockInTime,
    "clockOutTime": clockOutTime,
    "permissionbranchid": permissionbranchid,
    "mapcolor": mapcolor,
  };
}

class AtedBy {
  String? id;
  String? name;
  String? profilepic;

  AtedBy({this.id, this.name, this.profilepic});

  factory AtedBy.fromJson(Map<String, dynamic> json) => AtedBy(
    id: json["_id"],
    name: json["name"],
    profilepic: json["profilepic"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "profilepic": profilepic,
  };
}

class DeletedBy {
  DeletedBy();

  factory DeletedBy.fromJson(Map<String, dynamic> json) => DeletedBy();

  Map<String, dynamic> toJson() => {};
}

class Roleid {
  String? id;
  String? rolename;

  Roleid({this.id, this.rolename});

  factory Roleid.fromJson(Map<String, dynamic> json) =>
      Roleid(id: json["_id"], rolename: json["rolename"]);

  Map<String, dynamic> toJson() => {"_id": id, "rolename": rolename};
}
