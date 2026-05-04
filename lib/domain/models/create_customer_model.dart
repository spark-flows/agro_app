// To parse this JSON data, do
//
//     final createCustomerModel = createCustomerModelFromJson(jsonString);

import 'dart:convert';

CreateCustomerModel createCustomerModelFromJson(String str) =>
    CreateCustomerModel.fromJson(json.decode(str));

String createCustomerModelToJson(CreateCustomerModel data) =>
    json.encode(data.toJson());

class CreateCustomerModel {
  String? message;
  CreateCustomerModelData? data;
  int? status;
  bool? isSuccess;

  CreateCustomerModel({this.message, this.data, this.status, this.isSuccess});

  factory CreateCustomerModel.fromJson(Map<String, dynamic> json) =>
      CreateCustomerModel(
        message: json["Message"],
        data: json["Data"] == null
            ? null
            : CreateCustomerModelData.fromJson(json["Data"]),
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

class CreateCustomerModelData {
  String? distributorid;
  String? name;
  String? email;
  String? countrycode;
  String? mobile;
  bool? isVerified;
  bool? status;
  String? feedback;
  String? channelid;
  bool? isDeleted;
  String? deletedBy;
  String? createdBy;
  String? updatedBy;
  String? id;
  int? createdAtTimestamp;
  int? updatedAtTimestamp;
  String? createdAt;
  String? updatedAt;
  int? v;
  String? dataId;

  CreateCustomerModelData({
    this.distributorid,
    this.name,
    this.email,
    this.countrycode,
    this.mobile,
    this.isVerified,
    this.status,
    this.feedback,
    this.channelid,
    this.isDeleted,
    this.deletedBy,
    this.createdBy,
    this.updatedBy,
    this.id,
    this.createdAtTimestamp,
    this.updatedAtTimestamp,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.dataId,
  });

  factory CreateCustomerModelData.fromJson(Map<String, dynamic> json) =>
      CreateCustomerModelData(
        distributorid: json["distributorid"],
        name: json["name"],
        email: json["email"],
        countrycode: json["countrycode"],
        mobile: json["mobile"],
        isVerified: json["isVerified"],
        status: json["status"],
        feedback: json["feedback"],
        channelid: json["channelid"],
        isDeleted: json["isDeleted"],
        deletedBy: json["deletedBy"],
        createdBy: json["createdBy"],
        updatedBy: json["updatedBy"],
        id: json["_id"],
        createdAtTimestamp: json["createdAtTimestamp"],
        updatedAtTimestamp: json["updatedAtTimestamp"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        v: json["__v"],
        dataId: json["id"],
      );

  Map<String, dynamic> toJson() => {
    "distributorid": distributorid,
    "name": name,
    "email": email,
    "countrycode": countrycode,
    "mobile": mobile,
    "isVerified": isVerified,
    "status": status,
    "feedback": feedback,
    "channelid": channelid,
    "isDeleted": isDeleted,
    "deletedBy": deletedBy,
    "createdBy": createdBy,
    "updatedBy": updatedBy,
    "_id": id,
    "createdAtTimestamp": createdAtTimestamp,
    "updatedAtTimestamp": updatedAtTimestamp,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "__v": v,
    "id": dataId,
  };
}
