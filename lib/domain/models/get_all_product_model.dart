// To parse this JSON data, do
//
//     final getAllProductModel = getAllProductModelFromJson(jsonString);

import 'dart:convert';

GetAllProductModel getAllProductModelFromJson(String str) =>
    GetAllProductModel.fromJson(json.decode(str));

String getAllProductModelToJson(GetAllProductModel data) =>
    json.encode(data.toJson());

class GetAllProductModel {
  String? message;
  GetAllProductData? data;
  int? status;
  bool? isSuccess;

  GetAllProductModel({this.message, this.data, this.status, this.isSuccess});

  factory GetAllProductModel.fromJson(Map<String, dynamic> json) =>
      GetAllProductModel(
        message: json["Message"] ?? json["message"],
        data: (json["Data"] ?? json["data"]) == null
            ? null
            : GetAllProductData.fromJson(json["Data"] ?? json["data"]),
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

class GetAllProductData {
  List<GetAllProductDoc>? docs;
  int? totalDocs;
  int? limit;
  int? totalPages;
  int? page;
  int? pagingCounter;
  bool? hasPrevPage;
  bool? hasNextPage;
  dynamic prevPage;
  dynamic nextPage;

  GetAllProductData({
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

  factory GetAllProductData.fromJson(Map<String, dynamic> json) =>
      GetAllProductData(
        docs: json["docs"] == null
            ? []
            : List<GetAllProductDoc>.from(
                json["docs"]!.map((x) => GetAllProductDoc.fromJson(x)),
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

class GetAllProductDoc {
  String? id;
  GetAllProductCategoryid? categoryid;
  String? name;
  GetAllProductUnit? unit;
  int? price;
  int? qty;
  String? image;
  String? description;
  bool? isDeleted;
  String? createdAt;
  dynamic branchid;

  GetAllProductDoc({
    this.id,
    this.categoryid,
    this.name,
    this.unit,
    this.price,
    this.qty,
    this.image,
    this.description,
    this.isDeleted,
    this.createdAt,
    this.branchid,
  });

  factory GetAllProductDoc.fromJson(Map<String, dynamic> json) =>
      GetAllProductDoc(
        id: json["_id"],
        categoryid: json["categoryid"] == null
            ? null
            : (json["categoryid"] is String
                  ? GetAllProductCategoryid(id: json["categoryid"], name: '')
                  : GetAllProductCategoryid.fromJson(json["categoryid"])),
        name: json["name"]?.toString(),
        unit: json["unitid"] == null
            ? null
            : (json["unitid"] is String
                  ? GetAllProductUnit(id: json["unitid"], name: '')
                  : GetAllProductUnit.fromJson(json["unitid"])),
        price: num.tryParse(json["price"]?.toString() ?? '')?.toInt(),
        qty: num.tryParse(json["quantity"]?.toString() ?? '')?.toInt(),
        image: json["image"]?.toString(),
        description: json["description"]?.toString(),
        isDeleted: json["isDeleted"],
        createdAt: json["createdAt"]?.toString(),
        branchid: json["branchid"],
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "categoryid": categoryid?.toJson(),
    "name": name,
    "unit": unit,
    "price": price,
    "qty": qty,
    "image": image,
    "description": description,
    "isDeleted": isDeleted,
    "createdAt": createdAt,
    "branchid": branchid,
  };
}

class GetAllProductCategoryid {
  String? id;
  String? name;

  GetAllProductCategoryid({this.id, this.name});

  factory GetAllProductCategoryid.fromJson(Map<String, dynamic> json) =>
      GetAllProductCategoryid(id: json["_id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name};
}

class GetAllProductUnit {
  String? id;
  String? name;

  GetAllProductUnit({this.id, this.name});

  factory GetAllProductUnit.fromJson(Map<String, dynamic> json) =>
      GetAllProductUnit(id: json["_id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name};
}
