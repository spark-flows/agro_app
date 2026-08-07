import 'dart:convert';

import 'package:agro_app/domain/domain.dart';

GetAllCollectionsModel getAllCollectionsModelFromJson(String str) =>
    GetAllCollectionsModel.fromJson(json.decode(str));

String getAllCollectionsModelToJson(GetAllCollectionsModel data) =>
    json.encode(data.toJson());


class GetAllCollectionsModel {
  String? message;
  CollectionData? data;
  int? status;
  bool? isSuccess;

  GetAllCollectionsModel({
    this.message,
    this.data,
    this.status,
    this.isSuccess,
  });

  factory GetAllCollectionsModel.fromJson(Map<String, dynamic> json) =>
      GetAllCollectionsModel(
        message: json["Message"],
        data: json["Data"] == null
            ? null
            : CollectionData.fromJson(json["Data"]),
        status: json["Status"],
        isSuccess: json["IsSuccess"],
      );

  Map<String, dynamic> toJson() => {
        "Message": message,
        "Data": data?.toJson(),
        "Status": status,
        "IsSuccess": isSuccess,
      };
}

class CollectionData {
  List<CollectionDoc>? docs;
  int? totalDocs;
  int? limit;
  int? totalPages;
  int? page;
  int? pagingCounter;
  bool? hasPrevPage;
  bool? hasNextPage;
  dynamic prevPage;
  dynamic nextPage;

  CollectionData({
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

  factory CollectionData.fromJson(Map<String, dynamic> json) => CollectionData(
        docs: json["docs"] == null
            ? []
            : List<CollectionDoc>.from(
                json["docs"]!.map((x) => CollectionDoc.fromJson(x)),
              ),
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

class CollectionDoc {
  String? id;
  Branchid? branchid;
  String? date;
  Partyname? userid;
  Partyname? partyname;
  int? amount;
  String? remark;
  String? paymentmode;
  String? receiptno;
  String? paymentstatus;
  bool? status;
  String? createdAt;
  String? updatedAt;

  CollectionDoc({
    this.id,
    this.branchid,
    this.date,
    this.userid,
    this.partyname,
    this.amount,
    this.remark,
    this.paymentmode,
    this.receiptno,
    this.paymentstatus,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory CollectionDoc.fromJson(Map<String, dynamic> json) => CollectionDoc(
    id: json["_id"],
    branchid: json["branchid"] == null
        ? null
        : Branchid.fromJson(json["branchid"]),
    date: json["date"],
    userid: json["userid"] == null ? null : Partyname.fromJson(json["userid"]),
    partyname: json["partyname"] == null
        ? null
        : Partyname.fromJson(json["partyname"]),
    amount: json["amount"],
    remark: json["remark"],
    paymentmode: json["paymentmode"],
    receiptno: json["receiptno"],
    paymentstatus: json["paymentstatus"],
    status: json["status"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "branchid": branchid?.toJson(),
    "date": date,
    "userid": userid?.toJson(),
    "partyname": partyname?.toJson(),
    "amount": amount,
    "remark": remark,
    "paymentmode": paymentmode,
    "receiptno": receiptno,
    "paymentstatus": paymentstatus,
    "status": status,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}

class Partyname {
  String? id;
  String? name;
  String? email;
  String? mobile;

  Partyname({this.id, this.name, this.email, this.mobile});

  factory Partyname.fromJson(Map<String, dynamic> json) => Partyname(
    id: json["_id"],
    name: json["name"],
    email: json["email"],
    mobile: json["mobile"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "email": email,
    "mobile": mobile,
  };
}
