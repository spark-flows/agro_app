// To parse this JSON data, do
//
//     final createorderModel = createorderModelFromJson(jsonString);

import 'dart:convert';

CreateorderModel createorderModelFromJson(String str) => CreateorderModel.fromJson(json.decode(str));

String createorderModelToJson(CreateorderModel data) => json.encode(data.toJson());

class CreateorderModel {
    String? message;
    CreateorderData? data;
    int? status;
    bool? isSuccess;

    CreateorderModel({
        this.message,
        this.data,
        this.status,
        this.isSuccess,
    });

    factory CreateorderModel.fromJson(Map<String, dynamic> json) => CreateorderModel(
        message: json["Message"],
        data: json["Data"] == null ? null : CreateorderData.fromJson(json["Data"]),
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

class CreateorderData {
    String? orderno;
    String? distributorid;
    String? customerid;
    List<CreateorderItem>? items;
    dynamic deliverydate;
    dynamic totalamount;
    String? status;
    String? feedback;
    bool? isDeleted;
    String? deletedBy;
    String? createdBy;
    String? updatedBy;
    String? id;
    String? createdAt;
    String? updatedAt;
    int? v;

    CreateorderData({
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
        this.id,
        this.createdAt,
        this.updatedAt,
        this.v,
    });

    factory CreateorderData.fromJson(Map<String, dynamic> json) => CreateorderData(
        orderno: json["orderno"],
        distributorid: json["distributorid"],
        customerid: json["customerid"],
        items: json["items"] == null ? [] : List<CreateorderItem>.from(json["items"]!.map((x) => CreateorderItem.fromJson(x))),
        deliverydate: json["deliverydate"],
        totalamount: json["totalamount"],
        status: json["status"],
        feedback: json["feedback"],
        isDeleted: json["isDeleted"],
        deletedBy: json["deletedBy"],
        createdBy: json["createdBy"],
        updatedBy: json["updatedBy"],
        id: json["_id"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        v: json["__v"],
    );

    Map<String, dynamic> toJson() => {
        "orderno": orderno,
        "distributorid": distributorid,
        "customerid": customerid,
        "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
        "deliverydate": deliverydate,
        "totalamount": totalamount,
        "status": status,
        "feedback": feedback,
        "isDeleted": isDeleted,
        "deletedBy": deletedBy,
        "createdBy": createdBy,
        "updatedBy": updatedBy,
        "_id": id,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "__v": v,
    };
}

class CreateorderItem {
    String? productid;
    dynamic quantity;
    dynamic price;
    String? id;

    CreateorderItem({
        this.productid,
        this.quantity,
        this.price,
        this.id,
    });

    factory CreateorderItem.fromJson(Map<String, dynamic> json) => CreateorderItem(
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
