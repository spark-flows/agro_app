// To parse this JSON data, do
//
//     final profileDataModel = profileDataModelFromJson(jsonString);

import 'dart:convert';

ProfileDataModel profileDataModelFromJson(String str) =>
    ProfileDataModel.fromJson(json.decode(str));

String profileDataModelToJson(ProfileDataModel data) =>
    json.encode(data.toJson());

class ProfileDataModel {
  String message;
  ProfileDataData data;
  int status;
  bool isSuccess;

  ProfileDataModel({
    required this.message,
    required this.data,
    required this.status,
    required this.isSuccess,
  });

  factory ProfileDataModel.fromJson(Map<String, dynamic> json) =>
      ProfileDataModel(
        message: json["Message"],
        data: ProfileDataData.fromJson(json["Data"]),
        status: json["Status"],
        isSuccess: json["IsSuccess"],
      );

  Map<String, dynamic> toJson() => {
    "Message": message,
    "Data": data.toJson(),
    "Status": status,
    "IsSuccess": isSuccess,
  };
}

class ProfileDataData {
  ProfileDataUserData userData;

  ProfileDataData({required this.userData});

  factory ProfileDataData.fromJson(Map<String, dynamic> json) =>
      ProfileDataData(userData: ProfileDataUserData.fromJson(json["userData"]));

  Map<String, dynamic> toJson() => {"userData": userData.toJson()};
}

class ProfileDataUserData {
  String id;
  String code;
  String name;
  String email;
  String mobile;
  String profilepic;
  bool isVerified;
  bool isActive;
  Roleid roleid;
  String rolename;
  bool status;
  String availability;
  ProfileDataSalestarget salestarget;
  dynamic deletedBy;
  dynamic createdBy;
  dynamic updatedBy;
  String address;
  DateTime createdAt;
  DateTime updatedAt;
  int v;
  String channelid;
  String currencyCode;
  String fcmToken;
  ProfileBranch? branchid;
  bool? odometer;
  bool? liveTracking;
  String? starttime;
  String? endtime;
  String? breakstart;
  String? breakend;

  ProfileDataUserData({
    required this.id,
    required this.code,
    required this.name,
    required this.email,
    required this.mobile,
    required this.profilepic,
    required this.isVerified,
    required this.isActive,
    required this.roleid,
    required this.rolename,
    required this.status,
    required this.availability,
    required this.salestarget,
    required this.deletedBy,
    required this.createdBy,
    required this.updatedBy,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.channelid,
    required this.currencyCode,
    required this.fcmToken,
    this.branchid,
    this.odometer,
    this.liveTracking,
    this.starttime,
    this.endtime,
    this.breakstart,
    this.breakend,
  });

  factory ProfileDataUserData.fromJson(Map<String, dynamic> json) =>
      ProfileDataUserData(
        id: json["_id"] as String? ?? '',
        code: json["code"] as String? ?? '',
        name: json["name"] as String? ?? '',
        email: json["email"] as String? ?? '',
        mobile: json["mobile"] as String? ?? '',
        profilepic: json["profilepic"] as String? ?? '',
        isVerified: json["isVerified"] as bool? ?? false,
        isActive: json["isActive"] as bool? ?? false,
        roleid: json["roleid"] != null
            ? Roleid.fromJson(json["roleid"] as Map<String, dynamic>)
            : Roleid(id: '', rolename: ''),
        rolename: json["rolename"] as String? ?? '',
        status: json["status"] as bool? ?? false,
        availability: json["availability"] as String? ?? '',
        salestarget: json["salestarget"] != null
            ? ProfileDataSalestarget.fromJson(
                json["salestarget"] as Map<String, dynamic>,
              )
            : ProfileDataSalestarget(monthlytarget: 0, currentmonthachieved: 0),
        deletedBy: json["deletedBy"],
        createdBy: json["createdBy"],
        updatedBy: json["updatedBy"],
        address: json["address"] as String? ?? '',
        createdAt: json["createdAt"] != null
            ? DateTime.tryParse(json["createdAt"].toString()) ?? DateTime.now()
            : DateTime.now(),
        updatedAt: json["updatedAt"] != null
            ? DateTime.tryParse(json["updatedAt"].toString()) ?? DateTime.now()
            : DateTime.now(),
        v: json["__v"] as int? ?? 0,
        channelid: json["channelid"] as String? ?? '',
        currencyCode: json["currencyCode"] as String? ?? '',
        fcmToken: json["fcm_token"] as String? ?? '',
        branchid: json["branchid"] != null
            ? ProfileBranch.fromJson(json["branchid"] as Map<String, dynamic>)
            : null,
        odometer: json["odometer"] as bool? ?? false,
        liveTracking: json["liveTracking"] as bool? ?? false,
        starttime: (json["starttime"] ?? json["startTime"] ?? json["start_time"])?.toString(),
        endtime: (json["endtime"] ?? json["endTime"] ?? json["end_time"])?.toString(),
        breakstart: (json["breakstart"] ?? json["breakStart"] ?? json["break_start"])?.toString(),
        breakend: (json["breakend"] ?? json["breakEnd"] ?? json["break_end"])?.toString(),
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "code": code,
    "name": name,
    "email": email,
    "mobile": mobile,
    "profilepic": profilepic,
    "isVerified": isVerified,
    "isActive": isActive,
    "roleid": roleid.toJson(),
    "rolename": rolename,
    "status": status,
    "availability": availability,
    "salestarget": salestarget.toJson(),
    "deletedBy": deletedBy,
    "createdBy": createdBy,
    "updatedBy": updatedBy,
    "address": address,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "__v": v,
    "channelid": channelid,
    "currencyCode": currencyCode,
    "fcm_token": fcmToken,
    "branchid": branchid?.toJson(),
    "odometer": odometer,
    "liveTracking": liveTracking,
    "starttime": starttime,
    "endtime": endtime,
    "breakstart": breakstart,
    "breakend": breakend,
  };
}

class ProfileDataSalestarget {
  int monthlytarget;
  int currentmonthachieved;

  ProfileDataSalestarget({
    required this.monthlytarget,
    required this.currentmonthachieved,
  });

  factory ProfileDataSalestarget.fromJson(Map<String, dynamic> json) =>
      ProfileDataSalestarget(
        monthlytarget: json["monthlytarget"] as int? ?? 0,
        currentmonthachieved: json["currentmonthachieved"] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
    "monthlytarget": monthlytarget,
    "currentmonthachieved": currentmonthachieved,
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

class ProfileBranch {
  String id;
  String name;
  String shortname;

  ProfileBranch({
    required this.id,
    required this.name,
    required this.shortname,
  });

  factory ProfileBranch.fromJson(Map<String, dynamic> json) => ProfileBranch(
    id: json["_id"] as String? ?? '',
    name: json["name"] as String? ?? '',
    shortname: json["shortname"] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "shortname": shortname,
  };
}
