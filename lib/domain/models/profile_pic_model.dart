import 'dart:convert';

ProfilePicUpload profilePicUploadFromJson(String str) =>
    ProfilePicUpload.fromJson(json.decode(str));

String profilePicUploadToJson(ProfilePicUpload data) =>
    json.encode(data.toJson());

class ProfilePicUpload {
  String message;
  Data data;
  int status;
  bool isSuccess;

  ProfilePicUpload({
    required this.message,
    required this.data,
    required this.status,
    required this.isSuccess,
  });

  factory ProfilePicUpload.fromJson(Map<String, dynamic> json) =>
      ProfilePicUpload(
        message: json["Message"],
        data: Data.fromJson(json["Data"]),
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

class Data {
  String about;
  String id;
  String name;
  String email;
  String phonenumber;
  String profile;
  List<dynamic> blockedusers;
  String fcmToken;
  bool isActive;
  bool isOnline;
  DateTime lastSeen;
  dynamic pswdResetAt;
  String channelid;
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  Data({
    required this.about,
    required this.id,
    required this.name,
    required this.email,
    required this.phonenumber,
    required this.profile,
    required this.blockedusers,
    required this.fcmToken,
    required this.isActive,
    required this.isOnline,
    required this.lastSeen,
    required this.pswdResetAt,
    required this.channelid,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    about: json["about"],
    id: json["_id"],
    name: json["name"],
    email: json["email"],
    phonenumber: json["phonenumber"],
    profile: json["profile"],
    blockedusers: List<dynamic>.from(json["blockedusers"].map((x) => x)),
    fcmToken: json["fcm_token"],
    isActive: json["isActive"],
    isOnline: json["isOnline"],
    lastSeen: DateTime.parse(json["lastSeen"]),
    pswdResetAt: json["pswd_reset_at"],
    channelid: json["channelid"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "about": about,
    "_id": id,
    "name": name,
    "email": email,
    "phonenumber": phonenumber,
    "profile": profile,
    "blockedusers": List<dynamic>.from(blockedusers.map((x) => x)),
    "fcm_token": fcmToken,
    "isActive": isActive,
    "isOnline": isOnline,
    "lastSeen": lastSeen.toIso8601String(),
    "pswd_reset_at": pswdResetAt,
    "channelid": channelid,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "__v": v,
  };
}
