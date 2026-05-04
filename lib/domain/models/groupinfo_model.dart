import 'dart:convert';

GroupInfoModel groupInfoModelFromJson(String str) =>
    GroupInfoModel.fromJson(json.decode(str));

String groupInfoModelToJson(GroupInfoModel data) => json.encode(data.toJson());

class GroupInfoModel {
  String? message;
  GroupInfoData? data;
  int? status;
  bool? isSuccess;

  GroupInfoModel({this.message, this.data, this.status, this.isSuccess});

  GroupInfoModel copyWith({
    String? message,
    GroupInfoData? data,
    int? status,
    bool? isSuccess,
  }) => GroupInfoModel(
    message: message ?? this.message,
    data: data ?? this.data,
    status: status ?? this.status,
    isSuccess: isSuccess ?? this.isSuccess,
  );

  factory GroupInfoModel.fromJson(Map<String, dynamic> json) => GroupInfoModel(
    message: json["Message"],
    data: json["Data"] == null ? null : GroupInfoData.fromJson(json["Data"]),
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

class GroupInfoData {
  String? groupId;
  String? groupName;
  dynamic groupImage;
  dynamic groupDescription;
  List<GroupInfoDoc>? docs;
  int? totalMembers;
  int? totalAdmins;
  int? totalMessages;
  DateTime? createdAt;
  DateTime? updatedAt;

  GroupInfoData({
    this.groupId,
    this.groupName,
    this.groupImage,
    this.groupDescription,
    this.docs,
    this.totalMembers,
    this.totalAdmins,
    this.totalMessages,
    this.createdAt,
    this.updatedAt,
  });

  GroupInfoData copyWith({
    String? groupId,
    String? groupName,
    dynamic groupImage,
    dynamic groupDescription,
    List<GroupInfoDoc>? docs,
    int? totalMembers,
    int? totalAdmins,
    int? totalMessages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => GroupInfoData(
    groupId: groupId ?? this.groupId,
    groupName: groupName ?? this.groupName,
    groupImage: groupImage ?? this.groupImage,
    groupDescription: groupDescription ?? this.groupDescription,
    docs: docs ?? this.docs,
    totalMembers: totalMembers ?? this.totalMembers,
    totalAdmins: totalAdmins ?? this.totalAdmins,
    totalMessages: totalMessages ?? this.totalMessages,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  factory GroupInfoData.fromJson(Map<String, dynamic> json) => GroupInfoData(
    groupId: json["groupId"],
    groupName: json["groupName"],
    groupImage: json["groupImage"],
    groupDescription: json["groupDescription"],
    docs: json["docs"] == null
        ? []
        : List<GroupInfoDoc>.from(
            json["docs"]!.map((x) => GroupInfoDoc.fromJson(x)),
          ),
    totalMembers: json["totalMembers"],
    totalAdmins: json["totalAdmins"],
    totalMessages: json["totalMessages"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "groupId": groupId,
    "groupName": groupName,
    "groupImage": groupImage,
    "groupDescription": groupDescription,
    "docs": docs == null
        ? []
        : List<dynamic>.from(docs!.map((x) => x.toJson())),
    "totalMembers": totalMembers,
    "totalAdmins": totalAdmins,
    "totalMessages": totalMessages,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

class GroupInfoDoc {
  String? id;
  String? name;
  String? email;
  String? profile;
  bool? isOnline;
  DateTime? lastSeen;
  bool? isAdmin;
  String? status;

  GroupInfoDoc({
    this.id,
    this.name,
    this.email,
    this.profile,
    this.isOnline,
    this.lastSeen,
    this.isAdmin,
    this.status,
  });

  GroupInfoDoc copyWith({
    String? id,
    String? name,
    String? email,
    String? profile,
    bool? isOnline,
    DateTime? lastSeen,
    bool? isAdmin,
    String? status,
  }) => GroupInfoDoc(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    profile: profile ?? this.profile,
    isOnline: isOnline ?? this.isOnline,
    lastSeen: lastSeen ?? this.lastSeen,
    isAdmin: isAdmin ?? this.isAdmin,
    status: status ?? this.status,
  );

  factory GroupInfoDoc.fromJson(Map<String, dynamic> json) => GroupInfoDoc(
    id: json["_id"],
    name: json["name"],
    email: json["email"],
    profile: json["profile"],
    isOnline: json["isOnline"],
    lastSeen: json["lastSeen"] == null
        ? null
        : DateTime.parse(json["lastSeen"]),
    isAdmin: json["isAdmin"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "email": email,
    "profile": profile,
    "isOnline": isOnline,
    "lastSeen": lastSeen?.toIso8601String(),
    "isAdmin": isAdmin,
    "status": status,
  };
}
