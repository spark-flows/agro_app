import 'dart:convert';

UserRegisterModel userRegisterModelFromJson(String str) =>
    UserRegisterModel.fromJson(json.decode(str));

String userRegisterModelToJson(UserRegisterModel data) =>
    json.encode(data.toJson());

class UserRegisterModel {
  String? message;
  UserRegisterData? data;
  int? status;
  bool? isSuccess;

  UserRegisterModel({this.message, this.data, this.status, this.isSuccess});

  UserRegisterModel copyWith({
    String? message,
    UserRegisterData? data,
    int? status,
    bool? isSuccess,
  }) => UserRegisterModel(
    message: message ?? this.message,
    data: data ?? this.data,
    status: status ?? this.status,
    isSuccess: isSuccess ?? this.isSuccess,
  );

  factory UserRegisterModel.fromJson(Map<String, dynamic> json) =>
      UserRegisterModel(
        message: json["Message"] ?? json["message"],
        data:
            ((json["Data"] ?? json["data"]) == null ||
                (json["Data"] ?? json["data"]) is! Map)
            ? null
            : UserRegisterData.fromJson(json["Data"] ?? json["data"]),
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

class UserRegisterData {
  String? accessToken;
  UserRegisterUserProfile? userProfile;

  UserRegisterData({this.accessToken, this.userProfile});

  UserRegisterData copyWith({
    String? accessToken,
    UserRegisterUserProfile? userProfile,
  }) => UserRegisterData(
    accessToken: accessToken ?? this.accessToken,
    userProfile: userProfile ?? this.userProfile,
  );

  factory UserRegisterData.fromJson(Map<String, dynamic> json) =>
      UserRegisterData(
        accessToken: json["accessToken"],
        userProfile: json["userProfile"] == null
            ? null
            : UserRegisterUserProfile.fromJson(json["userProfile"]),
      );

  Map<String, dynamic> toJson() => {
    "accessToken": accessToken,
    "userProfile": userProfile?.toJson(),
  };
}

class UserRegisterUserProfile {
  String? name;
  String? email;
  String? phonenumber;
  String? about;
  List<dynamic>? blockedusers;
  String? fcmToken;
  bool? isActive;
  bool? isOnline;
  dynamic lastSeen;
  dynamic pswdResetAt;
  String? id;
  String? channelid;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  UserRegisterUserProfile({
    this.name,
    this.email,
    this.phonenumber,
    this.about,
    this.blockedusers,
    this.fcmToken,
    this.isActive,
    this.isOnline,
    this.lastSeen,
    this.pswdResetAt,
    this.id,
    this.channelid,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  UserRegisterUserProfile copyWith({
    String? name,
    String? email,
    String? phonenumber,
    String? about,
    List<dynamic>? blockedusers,
    String? fcmToken,
    bool? isActive,
    bool? isOnline,
    dynamic lastSeen,
    dynamic pswdResetAt,
    String? id,
    String? channelid,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
  }) => UserRegisterUserProfile(
    name: name ?? this.name,
    email: email ?? this.email,
    phonenumber: phonenumber ?? this.phonenumber,
    about: about ?? this.about,
    blockedusers: blockedusers ?? this.blockedusers,
    fcmToken: fcmToken ?? this.fcmToken,
    isActive: isActive ?? this.isActive,
    isOnline: isOnline ?? this.isOnline,
    lastSeen: lastSeen ?? this.lastSeen,
    pswdResetAt: pswdResetAt ?? this.pswdResetAt,
    id: id ?? this.id,
    channelid: channelid ?? this.channelid,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    v: v ?? this.v,
  );

  factory UserRegisterUserProfile.fromJson(Map<String, dynamic> json) =>
      UserRegisterUserProfile(
        name: json["name"],
        email: json["email"],
        phonenumber: json["phonenumber"],
        about: json["about"],
        blockedusers: json["blockedusers"] == null
            ? []
            : List<dynamic>.from(json["blockedusers"]!.map((x) => x)),
        fcmToken: json["fcm_token"],
        isActive: json["isActive"],
        isOnline: json["isOnline"],
        lastSeen: json["lastSeen"],
        pswdResetAt: json["pswd_reset_at"],
        id: json["_id"],
        channelid: json["channelid"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
    "name": name,
    "email": email,
    "phonenumber": phonenumber,
    "about": about,
    "blockedusers": blockedusers == null
        ? []
        : List<dynamic>.from(blockedusers!.map((x) => x)),
    "fcm_token": fcmToken,
    "isActive": isActive,
    "isOnline": isOnline,
    "lastSeen": lastSeen,
    "pswd_reset_at": pswdResetAt,
    "_id": id,
    "channelid": channelid,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}
