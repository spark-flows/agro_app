// To parse this JSON data, do
//
//     final getAllOrderModel = getAllOrderModelFromJson(jsonString);

import 'dart:convert';

GetAllOrderModel getAllOrderModelFromJson(String str) =>
    GetAllOrderModel.fromJson(json.decode(str));

String getAllOrderModelToJson(GetAllOrderModel data) =>
    json.encode(data.toJson());

class GetAllOrderModel {
  String? message;
  GetAllOrderData? data;
  int? status;
  bool? isSuccess;

  GetAllOrderModel({this.message, this.data, this.status, this.isSuccess});

  factory GetAllOrderModel.fromJson(Map<String, dynamic> json) =>
      GetAllOrderModel(
        message: json["Message"] ?? json["message"],
        data: (json["Data"] ?? json["data"]) == null
            ? null
            : GetAllOrderData.fromJson(json["Data"] ?? json["data"]),
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

class GetAllOrderData {
  List<GetAllOrderDoc>? docs;
  int? totalDocs;
  int? limit;
  int? totalPages;
  int? page;
  int? pagingCounter;
  bool? hasPrevPage;
  bool? hasNextPage;
  dynamic prevPage;
  dynamic nextPage;

  GetAllOrderData({
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

  factory GetAllOrderData.fromJson(Map<String, dynamic> json) =>
      GetAllOrderData(
        docs: json["docs"] == null
            ? []
            : List<GetAllOrderDoc>.from(
                json["docs"]!.map((x) => GetAllOrderDoc.fromJson(x)),
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

class GetAllOrderDoc {
  String? id;
  String? orderno;
  dynamic deliverydate;
  dynamic totalamount;
  String? feedback;
  bool? isDeleted;
  String? createdAt;
  String? status;
  GetAllOrderRid? distributorid;
  GetAllOrderRid? customerid;
  List<GetAllOrderItem>? items;

  GetAllOrderDoc({
    this.id,
    this.orderno,
    this.deliverydate,
    this.totalamount,
    this.feedback,
    this.isDeleted,
    this.createdAt,
    this.status,
    this.distributorid,
    this.customerid,
    this.items,
  });

  factory GetAllOrderDoc.fromJson(Map<String, dynamic> json) => GetAllOrderDoc(
    id: json["_id"]?.toString(),
    orderno: json["orderno"]?.toString(),
    deliverydate: json["deliverydate"],
    totalamount: json["totalamount"],
    feedback: json["feedback"]?.toString(),
    isDeleted: json["isDeleted"],
    status: json["status"]?.toString(),
    createdAt: json["createdAt"]?.toString(),
    distributorid: json["distributorid"] == null
        ? null
        : GetAllOrderRid.fromJson(json["distributorid"]),
    customerid: json["customerid"] == null
        ? null
        : GetAllOrderRid.fromJson(json["customerid"]),
    items: json["items"] == null
        ? []
        : List<GetAllOrderItem>.from(
            json["items"]!.map((x) => GetAllOrderItem.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "orderno": orderno,
    "deliverydate": deliverydate,
    "totalamount": totalamount,
    "feedback": feedback,
    "status": status,
    "isDeleted": isDeleted,
    "createdAt": createdAt,
    "distributorid": distributorid?.toJson(),
    "customerid": customerid?.toJson(),
    "items": items == null
        ? []
        : List<dynamic>.from(items!.map((x) => x.toJson())),
  };
}

class GetAllOrderRid {
  GetAllOrderRid();

  factory GetAllOrderRid.fromJson(Map<String, dynamic> json) =>
      GetAllOrderRid();

  Map<String, dynamic> toJson() => {};
}

class GetAllOrderItem {
  String? id;
  Productid? productid;
  dynamic quantity;
  dynamic price;

  GetAllOrderItem({this.id, this.productid, this.quantity, this.price});

  factory GetAllOrderItem.fromJson(Map<String, dynamic> json) =>
      GetAllOrderItem(
        id: json["_id"],
        productid: json["productid"] == null
            ? null
            : Productid.fromJson(json["productid"]),
        quantity: json["quantity"],
        price: json["price"],
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "productid": productid?.toJson(),
    "quantity": quantity,
    "price": price,
  };
}

class Productid {
  String? id;

  Productid({this.id});

  factory Productid.fromJson(Map<String, dynamic> json) =>
      Productid(id: json["_id"]);

  Map<String, dynamic> toJson() => {"_id": id};
}
