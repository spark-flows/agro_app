// To parse this JSON data, do
//
//     final loginModel = loginModelFromJson(jsonString);

import 'dart:convert';

LoginModel loginModelFromJson(String str) =>
    LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  String? message;
  Data? data;
  int? status;
  bool? isSuccess;

  LoginModel({this.message, this.data, this.status, this.isSuccess});

  LoginModel copyWith({
    String? message,
    Data? data,
    int? status,
    bool? isSuccess,
  }) => LoginModel(
    message: message ?? this.message,
    data: data ?? this.data,
    status: status ?? this.status,
    isSuccess: isSuccess ?? this.isSuccess,
  );

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
    message: json["Message"] ?? json["message"],
    data:
        ((json["Data"] ?? json["data"]) == null ||
            (json["Data"] ?? json["data"]) is! Map)
        ? null
        : Data.fromJson(json["Data"] ?? json["data"]),
    status: json["Status"] ?? json["status"],
    isSuccess: json["IsSuccess"] ?? json["isSuccess"],
  );

  Map<String, dynamic> toJson() => {
    "Message": message,
    "Data": data?.toJson(),
    "Status": status,
    "IsSuccess": isSuccess,
  };
}

class Data {
  String? accessToken;
  UserProfile? userProfile;

  Data({this.accessToken, this.userProfile});

  Data copyWith({String? accessToken, UserProfile? userProfile}) => Data(
    accessToken: accessToken ?? this.accessToken,
    userProfile: userProfile ?? this.userProfile,
  );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    accessToken: json["accessToken"],
    userProfile: json["userProfile"] == null
        ? null
        : UserProfile.fromJson(json["userProfile"]),
  );

  Map<String, dynamic> toJson() => {
    "accessToken": accessToken,
    "userProfile": userProfile?.toJson(),
  };
}

class UserProfile {
  String? id;
  String? name;
  String? email;
  String? phonenumber;
  String? password;
  String? profile;
  List<dynamic>? blockedusers;
  String? fcmToken;
  bool? isActive;
  String? channelid;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? updatedBy;

  UserProfile({
    this.id,
    this.name,
    this.email,
    this.phonenumber,
    this.password,
    this.profile,
    this.blockedusers,
    this.fcmToken,
    this.isActive,
    this.channelid,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.updatedBy,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phonenumber,
    String? password,
    String? profile,
    List<dynamic>? blockedusers,
    String? fcmToken,
    bool? isActive,
    String? channelid,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
    String? updatedBy,
  }) => UserProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    phonenumber: phonenumber ?? this.phonenumber,
    password: password ?? this.password,
    profile: profile ?? this.profile,
    blockedusers: blockedusers ?? this.blockedusers,
    fcmToken: fcmToken ?? this.fcmToken,
    isActive: isActive ?? this.isActive,
    channelid: channelid ?? this.channelid,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    v: v ?? this.v,
    updatedBy: updatedBy ?? this.updatedBy,
  );

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json["_id"],
    name: json["name"],
    email: json["email"],
    phonenumber: json["phonenumber"],
    password: json["password"],
    profile: json["profile"],
    blockedusers: json["blockedusers"] == null
        ? []
        : List<dynamic>.from(json["blockedusers"]!.map((x) => x)),
    fcmToken: json["fcm_token"],
    isActive: json["isActive"],
    channelid: json["channelid"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
    updatedBy: json["updatedBy"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "email": email,
    "phonenumber": phonenumber,
    "password": password,
    "profile": profile,
    "blockedusers": blockedusers == null
        ? []
        : List<dynamic>.from(blockedusers!.map((x) => x)),
    "fcm_token": fcmToken,
    "isActive": isActive,
    "channelid": channelid,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "updatedBy": updatedBy,
  };
}
