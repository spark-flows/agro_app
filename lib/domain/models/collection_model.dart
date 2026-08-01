import 'dart:convert';

GetAllCollectionsModel getAllCollectionsModelFromJson(String str) =>
    GetAllCollectionsModel.fromJson(json.decode(str));

String getAllCollectionsModelToJson(GetAllCollectionsModel data) =>
    json.encode(data.toJson());

CreateCollectionModel createCollectionModelFromJson(String str) =>
    CreateCollectionModel.fromJson(json.decode(str));

String createCollectionModelToJson(CreateCollectionModel data) =>
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
  String? collectionid;
  String? date;
  CollectionUser? userid;
  String? partyname;
  String? amount;
  String? paymentmode;
  String? paymentstatus;
  String? remark;
  String? branchid;
  bool? isDeleted;
  String? createdAt;
  String? updatedAt;

  CollectionDoc({
    this.id,
    this.collectionid,
    this.date,
    this.userid,
    this.partyname,
    this.amount,
    this.paymentmode,
    this.paymentstatus,
    this.remark,
    this.branchid,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
  });

  factory CollectionDoc.fromJson(Map<String, dynamic> json) => CollectionDoc(
        id: json["_id"],
        collectionid: json["collectionid"],
        date: json["date"],
        userid: json["userid"] == null
            ? null
            : json["userid"] is Map<String, dynamic>
                ? CollectionUser.fromJson(json["userid"])
                : CollectionUser(id: json["userid"].toString()),
        partyname: json["partyname"],
        amount: json["amount"]?.toString(),
        paymentmode: json["paymentmode"],
        paymentstatus: json["paymentstatus"],
        remark: json["remark"],
        branchid: json["branchid"]?.toString() ?? json["branchId"]?.toString(),
        isDeleted: json["isDeleted"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "collectionid": collectionid,
        "date": date,
        "userid": userid?.toJson(),
        "partyname": partyname,
        "amount": amount,
        "paymentmode": paymentmode,
        "paymentstatus": paymentstatus,
        "remark": remark,
        "branchid": branchid,
        "isDeleted": isDeleted,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
      };
}

class CollectionUser {
  String? id;
  String? name;
  String? mobile;
  String? email;
  String? role;

  CollectionUser({
    this.id,
    this.name,
    this.mobile,
    this.email,
    this.role,
  });

  factory CollectionUser.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return CollectionUser(
        id: json["_id"],
        name: json["name"],
        mobile: json["mobile"],
        email: json["email"],
        role: json["role"]?.toString() ?? json["rolename"]?.toString(),
      );
    } else if (json is String) {
      return CollectionUser(id: json);
    }
    return CollectionUser();
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "mobile": mobile,
        "email": email,
        "role": role,
      };
}

class CreateCollectionModel {
  String? message;
  CollectionDoc? data;
  int? status;
  bool? isSuccess;

  CreateCollectionModel({
    this.message,
    this.data,
    this.status,
    this.isSuccess,
  });

  factory CreateCollectionModel.fromJson(Map<String, dynamic> json) =>
      CreateCollectionModel(
        message: json["Message"],
        data: json["Data"] == null ? null : CollectionDoc.fromJson(json["Data"]),
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
