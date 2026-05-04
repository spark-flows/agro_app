// To parse this JSON data, do
//
//     final profileDataModel = profileDataModelFromJson(jsonString);

import 'dart:convert';

ProfileDataModel profileDataModelFromJson(String str) => ProfileDataModel.fromJson(json.decode(str));

String profileDataModelToJson(ProfileDataModel data) => json.encode(data.toJson());

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

    factory ProfileDataModel.fromJson(Map<String, dynamic> json) => ProfileDataModel(
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

    ProfileDataData({
        required this.userData,
    });

    factory ProfileDataData.fromJson(Map<String, dynamic> json) => ProfileDataData(
        userData: ProfileDataUserData.fromJson(json["userData"]),
    );

    Map<String, dynamic> toJson() => {
        "userData": userData.toJson(),
    };
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
    dynamic roleid;
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
    });

    factory ProfileDataUserData.fromJson(Map<String, dynamic> json) => ProfileDataUserData(
        id: json["_id"],
        code: json["code"],
        name: json["name"],
        email: json["email"],
        mobile: json["mobile"],
        profilepic: json["profilepic"],
        isVerified: json["isVerified"],
        isActive: json["isActive"],
        roleid: json["roleid"],
        rolename: json["rolename"],
        status: json["status"],
        availability: json["availability"],
        salestarget: ProfileDataSalestarget.fromJson(json["salestarget"]),
        deletedBy: json["deletedBy"],
        createdBy: json["createdBy"],
        updatedBy: json["updatedBy"],
        address: json["address"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        channelid: json["channelid"],
        currencyCode: json["currencyCode"],
        fcmToken: json["fcm_token"],
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
        "roleid": roleid,
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
    };
}

class ProfileDataSalestarget {
    int monthlytarget;
    int currentmonthachieved;

    ProfileDataSalestarget({
        required this.monthlytarget,
        required this.currentmonthachieved,
    });

    factory ProfileDataSalestarget.fromJson(Map<String, dynamic> json) => ProfileDataSalestarget(
        monthlytarget: json["monthlytarget"],
        currentmonthachieved: json["currentmonthachieved"],
    );

    Map<String, dynamic> toJson() => {
        "monthlytarget": monthlytarget,
        "currentmonthachieved": currentmonthachieved,
    };
}
