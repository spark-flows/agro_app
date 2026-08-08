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
        message: json["Message"] ?? json["message"],
        data: (json["Data"] ?? json["data"]) == null ? null : CreateorderData.fromJson(json["Data"] ?? json["data"]),
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
        orderno: json["orderno"]?.toString(),
        distributorid: json["distributorid"]?.toString(),
        customerid: json["customerid"]?.toString(),
        items: json["items"] == null ? [] : List<CreateorderItem>.from(json["items"]!.map((x) => CreateorderItem.fromJson(x))),
        deliverydate: json["deliverydate"],
        totalamount: json["totalamount"],
        status: json["status"]?.toString(),
        feedback: json["feedback"]?.toString(),
        isDeleted: json["isDeleted"],
        deletedBy: json["deletedBy"]?.toString(),
        createdBy: json["createdBy"]?.toString(),
        updatedBy: json["updatedBy"]?.toString(),
        id: json["_id"]?.toString(),
        createdAt: json["createdAt"]?.toString(),
        updatedAt: json["updatedAt"]?.toString(),
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
    String? remark;

    CreateorderItem({
        this.productid,
        this.quantity,
        this.price,
        this.id,
        this.remark,
    });

    factory CreateorderItem.fromJson(Map<String, dynamic> json) => CreateorderItem(
        productid: json["productid"],
        quantity: json["quantity"],
        price: json["price"],
        id: json["_id"],
        remark: json["remark"]?.toString(),
    );

    Map<String, dynamic> toJson() => {
        "productid": productid,
        "quantity": quantity,
        "price": price,
        "_id": id,
        "remark": remark,
    };
}
