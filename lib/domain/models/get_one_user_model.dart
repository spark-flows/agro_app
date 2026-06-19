// To parse this JSON data, do
//
//     final getOneUserModel = getOneUserModelFromJson(jsonString);

import 'dart:convert';

GetOneUserModel getOneUserModelFromJson(String str) =>
    GetOneUserModel.fromJson(json.decode(str));

String getOneUserModelToJson(GetOneUserModel data) =>
    json.encode(data.toJson());

class GetOneUserModel {
  String? message;
  Data? data;
  int? status;
  bool? isSuccess;

  GetOneUserModel({this.message, this.data, this.status, this.isSuccess});

  factory GetOneUserModel.fromJson(Map<String, dynamic> json) =>
      GetOneUserModel(
        message: json["Message"],
        data: json["Data"] == null ? null : Data.fromJson(json["Data"]),
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

class Data {
  String? id;
  String? code;
  String? name;
  String? location;
  String? email;
  String? countrycode;
  String? mobile;
  String? password;
  Roleid? roleid;
  String? rolename;
  bool? status;
  String? createdAt;
  String? updatedAt;

  Data({
    this.id,
    this.code,
    this.name,
    this.location,
    this.email,
    this.countrycode,
    this.mobile,
    this.password,
    this.roleid,
    this.rolename,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["_id"],
    code: json["code"],
    name: json["name"],
    location: json["location"],
    email: json["email"],
    countrycode: json["countrycode"],
    mobile: json["mobile"],
    password: json["password"],
    roleid: json["roleid"] == null ? null : Roleid.fromJson(json["roleid"]),
    rolename: json["rolename"],
    status: json["status"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "code": code,
    "name": name,
    "location": location,
    "email": email,
    "countrycode": countrycode,
    "mobile": mobile,
    "password": password,
    "roleid": roleid?.toJson(),
    "rolename": rolename,
    "status": status,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}

class Roleid {
  String? id;
  String? rolename;

  Roleid({this.id, this.rolename});

  factory Roleid.fromJson(Map<String, dynamic> json) =>
      Roleid(id: json["_id"], rolename: json["rolename"]);

  Map<String, dynamic> toJson() => {"_id": id, "rolename": rolename};
}
