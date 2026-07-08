import 'dart:convert';

import 'package:agro_app/domain/domain.dart';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

class UserModel {
  String? message;
  List<UserData>? data;
  int? status;
  bool? isSuccess;

  UserModel({this.message, this.data, this.status, this.isSuccess});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    message: json["Message"],
    data: json["Data"] == null
        ? []
        : List<UserData>.from(json["Data"]!.map((x) => UserData.fromJson(x))),
    status: json["Status"],
    isSuccess: json["IsSuccess"],
  );

  Map<String, dynamic> toJson() => {
    "Message": message,
    "Data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
    "Status": status,
    "IsSuccess": isSuccess,
  };
}

class UserData {
  String? id;
  String? code;
  String? name;
  String? surname;
  String? fathername;
  String? gstnumber;
  String? location;
  String? bankname;
  String? bankaccountnumber;
  String? bankifsccode;
  String? email;
  String? countrycode;
  String? mobile;
  Branchid? branchid;
  String? profilepic;
  Roleid? roleid;
  String? rolename;
  int? salary;
  bool? status;
  String? createdAt;
  String? updatedAt;

  UserData({
    this.id,
    this.code,
    this.name,
    this.surname,
    this.fathername,
    this.gstnumber,
    this.location,
    this.bankname,
    this.bankaccountnumber,
    this.bankifsccode,
    this.email,
    this.countrycode,
    this.mobile,
    this.branchid,
    this.profilepic,
    this.roleid,
    this.rolename,
    this.salary,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    id: json["_id"],
    code: json["code"],
    name: json["name"],
    surname: json["surname"],
    fathername: json["fathername"],
    gstnumber: json["gstnumber"],
    location: json["location"],
    bankname: json["bankname"],
    bankaccountnumber: json["bankaccountnumber"],
    bankifsccode: json["bankifsccode"],
    email: json["email"],
    countrycode: json["countrycode"],
    mobile: json["mobile"],
    branchid: json["branchid"] == null
        ? null
        : Branchid.fromJson(json["branchid"]),
    profilepic: json["profilepic"],
    roleid: json["roleid"] == null ? null : Roleid.fromJson(json["roleid"]),
    rolename: json["rolename"],
    salary: json["salary"],
    status: json["status"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "code": code,
    "name": name,
    "surname": surname,
    "fathername": fathername,
    "gstnumber": gstnumber,
    "location": location,
    "bankname": bankname,
    "bankaccountnumber": bankaccountnumber,
    "bankifsccode": bankifsccode,
    "email": email,
    "countrycode": countrycode,
    "mobile": mobile,
    "branchid": branchid?.toJson(),
    "profilepic": profilepic,
    "roleid": roleid?.toJson(),
    "rolename": rolename,
    "salary": salary,
    "status": status,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}

class Branchid {
  String? id;
  String? name;
  String? shortname;

  Branchid({this.id, this.name, this.shortname});

  factory Branchid.fromJson(Map<String, dynamic> json) => Branchid(
    id: json["_id"],
    name: json["name"],
    shortname: json["shortname"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "shortname": shortname,
  };
}
