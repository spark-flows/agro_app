// To parse this JSON data, do
//
//     final productListModel = productListModelFromJson(jsonString);

import 'dart:convert';

ProductListModel productListModelFromJson(String str) =>
    ProductListModel.fromJson(json.decode(str));

String productListModelToJson(ProductListModel data) =>
    json.encode(data.toJson());

class ProductListModel {
  String message;
  ProductListData data;
  int status;
  bool isSuccess;

  ProductListModel({
    required this.message,
    required this.data,
    required this.status,
    required this.isSuccess,
  });

  factory ProductListModel.fromJson(Map<String, dynamic> json) =>
      ProductListModel(
        message: json["Message"] ?? '',
        data: ProductListData.fromJson(json["Data"] ?? {}),
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

class ProductListData {
  List<ProductListDoc> docs;
  int totalDocs;
  int limit;
  int totalPages;
  int page;
  int pagingCounter;
  bool hasPrevPage;
  bool hasNextPage;
  dynamic prevPage;
  dynamic nextPage;

  ProductListData({
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

  factory ProductListData.fromJson(Map<String, dynamic> json) => ProductListData(
    docs: json["docs"] != null ? List<ProductListDoc>.from(json["docs"].map((x) => ProductListDoc.fromJson(x))) : [],
    totalDocs: json["totalDocs"] ?? 0,
    limit: json["limit"] ?? 0,
    totalPages: json["totalPages"] ?? 0,
    page: json["page"] ?? 0,
    pagingCounter: json["pagingCounter"] ?? 0,
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

class ProductListDoc {
  String id;
  String name;
  String unit;
  dynamic price;
  String image;
  String description;
  bool isDeleted;
  DateTime createdAt;
  dynamic categoryid;

  ProductListDoc({
    required this.id,
    required this.name,
    required this.unit,
    required this.price,
    required this.image,
    required this.description,
    required this.isDeleted,
    required this.createdAt,
    this.categoryid,
  });

  factory ProductListDoc.fromJson(Map<String, dynamic> json) => ProductListDoc(
    id: json["_id"] ?? '',
    name: json["name"] ?? '',
    unit: json["unit"] ?? '',
    price: json["price"] ?? 0,
    image: json["image"] ?? '',
    description: json["description"] ?? '',
    isDeleted: json["isDeleted"] ?? false,
    createdAt: json["createdAt"] != null ? DateTime.tryParse(json["createdAt"]) ?? DateTime.now() : DateTime.now(),
    categoryid: json["categoryid"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "unit": unit,
    "price": price,
    "image": image,
    "description": description,
    "isDeleted": isDeleted,
    "createdAt": createdAt.toIso8601String(),
    "categoryid": categoryid,
  };
}
