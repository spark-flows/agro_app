import 'dart:convert';

GetOneOrderModel getOneOrderModelFromJson(String str) =>
    GetOneOrderModel.fromJson(json.decode(str));

String getOneOrderModelToJson(GetOneOrderModel data) =>
    json.encode(data.toJson());

class GetOneOrderModel {
  String? message;
  GetOneOrderData? data;
  int? status;
  bool? isSuccess;

  GetOneOrderModel({this.message, this.data, this.status, this.isSuccess});

  factory GetOneOrderModel.fromJson(Map<String, dynamic> json) =>
      GetOneOrderModel(
        message: json["Message"],
        data: json["Data"] == null ? null : GetOneOrderData.fromJson(json["Data"]),
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

class GetOneOrderData {
  String? id;
  String? orderno;
  dynamic distributorid;
  dynamic customerid;
  List<GetOneOrderItem>? items;
  dynamic deliverydate;
  dynamic totalamount;
  String? status;
  String? feedback;
  bool? isDeleted;
  String? deletedBy;
  String? createdBy;
  String? updatedBy;
  String? createdAt;
  String? updatedAt;

  GetOneOrderData({
    this.id,
    this.orderno,
    this.distributorid,
    this.customerid,
    this.items,
    this.deliverydate,
    this.totalamount,
    this.status,
    this.feedback,
    this.isDeleted,
    this.deletedBy,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory GetOneOrderData.fromJson(Map<String, dynamic> json) => GetOneOrderData(
    id: json["_id"],
    orderno: json["orderno"],
    distributorid: json["distributorid"],
    customerid: json["customerid"],
    items: json["items"] == null
        ? []
        : List<GetOneOrderItem>.from(json["items"]!.map((x) => GetOneOrderItem.fromJson(x))),
    deliverydate: json["deliverydate"],
    totalamount: json["totalamount"],
    status: json["status"],
    feedback: json["feedback"],
    isDeleted: json["isDeleted"],
    deletedBy: json["deletedBy"],
    createdBy: json["createdBy"],
    updatedBy: json["updatedBy"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "orderno": orderno,
    "distributorid": distributorid,
    "customerid": customerid,
    "items": items == null
        ? []
        : List<dynamic>.from(items!.map((x) => x.toJson())),
    "deliverydate": deliverydate,
    "totalamount": totalamount,
    "status": status,
    "feedback": feedback,
    "isDeleted": isDeleted,
    "deletedBy": deletedBy,
    "createdBy": createdBy,
    "updatedBy": updatedBy,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}

class GetOneOrderItem {
  dynamic productid;
  dynamic quantity;
  dynamic price;
  String? id;

  GetOneOrderItem({this.productid, this.quantity, this.price, this.id});

  factory GetOneOrderItem.fromJson(Map<String, dynamic> json) => GetOneOrderItem(
    productid: json["productid"],
    quantity: json["quantity"],
    price: json["price"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "productid": productid,
    "quantity": quantity,
    "price": price,
    "_id": id,
  };
}
