// To parse this JSON data, do
//
//     final createProductModel = createProductModelFromJson(jsonString);

import 'dart:convert';

CreateProductModel createProductModelFromJson(String str) =>
    CreateProductModel.fromJson(json.decode(str));

String createProductModelToJson(CreateProductModel data) =>
    json.encode(data.toJson());

class CreateProductModel {
  String? message;
  CreateProductData? data;
  int? status;
  bool? isSuccess;

  CreateProductModel({this.message, this.data, this.status, this.isSuccess});

  factory CreateProductModel.fromJson(Map<String, dynamic> json) =>
      CreateProductModel(
        message: json["Message"],
        data: json["Data"] == null
            ? null
            : CreateProductData.fromJson(json["Data"]),
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

class CreateProductData {
  String? categoryid;
  String? name;
  String? unit;
  int? price;
  String? image;
  String? description;
  bool? status;
  bool? isDeleted;
  String? deletedBy;
  String? createdBy;
  String? updatedBy;
  String? id;
  String? createdAt;
  String? updatedAt;
  int? v;
  dynamic branchid;

  CreateProductData({
    this.categoryid,
    this.name,
    this.unit,
    this.price,
    this.image,
    this.description,
    this.status,
    this.isDeleted,
    this.deletedBy,
    this.createdBy,
    this.updatedBy,
    this.id,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.branchid,
  });

  factory CreateProductData.fromJson(Map<String, dynamic> json) =>
      CreateProductData(
        categoryid: json["categoryid"],
        name: json["name"],
        unit: json["unit"],
        price: json["price"],
        image: json["image"],
        description: json["description"],
        status: json["status"],
        isDeleted: json["isDeleted"],
        deletedBy: json["deletedBy"],
        createdBy: json["createdBy"],
        updatedBy: json["updatedBy"],
        id: json["_id"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        v: json["__v"],
        branchid: json["branchid"],
      );

  Map<String, dynamic> toJson() => {
    "categoryid": categoryid,
    "name": name,
    "unit": unit,
    "price": price,
    "image": image,
    "description": description,
    "status": status,
    "isDeleted": isDeleted,
    "deletedBy": deletedBy,
    "createdBy": createdBy,
    "updatedBy": updatedBy,
    "_id": id,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "__v": v,
    "branchid": branchid,
  };
}
