import 'dart:convert';

GetAllLedgersModel getAllLedgersModelFromJson(String str) =>
    GetAllLedgersModel.fromJson(json.decode(str));

String getAllLedgersModelToJson(GetAllLedgersModel data) =>
    json.encode(data.toJson());

class GetAllLedgersModel {
  String? message;
  LedgersData? data;
  int? status;
  bool? isSuccess;

  GetAllLedgersModel({this.message, this.data, this.status, this.isSuccess});

  factory GetAllLedgersModel.fromJson(Map<String, dynamic> json) =>
      GetAllLedgersModel(
        message: json["Message"] ?? json["message"],
        data: (json["Data"] ?? json["data"]) == null
            ? null
            : LedgersData.fromJson(json["Data"] ?? json["data"]),
        status: json["Status"] ?? json["status"],
        isSuccess: json["IsSuccess"] ?? json["isSuccess"] ?? json["issuccess"],
      );

  Map<String, dynamic> toJson() => {
        "Message": message,
        "Data": data?.toJson(),
        "Status": status,
        "IsSuccess": isSuccess,
      };
}

class LedgersData {
  List<LedgerDoc>? docs;
  int? totalDocs;
  int? limit;
  int? totalPages;
  int? page;
  int? pagingCounter;
  bool? hasPrevPage;
  bool? hasNextPage;

  LedgersData({
    this.docs,
    this.totalDocs,
    this.limit,
    this.totalPages,
    this.page,
    this.pagingCounter,
    this.hasPrevPage,
    this.hasNextPage,
  });

  factory LedgersData.fromJson(Map<String, dynamic> json) => LedgersData(
        docs: json["docs"] == null
            ? []
            : List<LedgerDoc>.from(
                json["docs"]!.map((x) => LedgerDoc.fromJson(x)),
              ),
        totalDocs: json["totalDocs"],
        limit: json["limit"],
        totalPages: json["totalPages"],
        page: json["page"],
        pagingCounter: json["pagingCounter"],
        hasPrevPage: json["hasPrevPage"],
        hasNextPage: json["hasNextPage"],
      );

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
      };
}

class LedgerDoc {
  String? id;
  String? name;
  dynamic parent;
  dynamic openingbalance;
  dynamic closingbalance;
  String? branchid;
  bool? isDeleted;
  String? createdAt;
  String? updatedAt;

  LedgerDoc({
    this.id,
    this.name,
    this.parent,
    this.openingbalance,
    this.closingbalance,
    this.branchid,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
  });

  factory LedgerDoc.fromJson(Map<String, dynamic> json) => LedgerDoc(
        id: json["_id"]?.toString() ?? json["id"]?.toString(),
        name: json["name"]?.toString(),
        parent: json["parent"],
        openingbalance: json["openingbalance"] ?? json["openingBalance"],
        closingbalance: json["closingbalance"] ?? json["closingBalance"],
        branchid: json["branchid"]?.toString() ?? json["branchId"]?.toString(),
        isDeleted: json["isDeleted"],
        createdAt: json["createdAt"]?.toString(),
        updatedAt: json["updatedAt"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "parent": parent,
        "openingbalance": openingbalance,
        "closingbalance": closingbalance,
        "branchid": branchid,
        "isDeleted": isDeleted,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
      };
}
