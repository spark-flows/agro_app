// To parse this JSON data, do
//
//     final removedMemberGroupModel = removedMemberGroupModelFromJson(jsonString);

import 'dart:convert';

RemovedMemberGroupModel removedMemberGroupModelFromJson(String str) =>
    RemovedMemberGroupModel.fromJson(json.decode(str));

String removedMemberGroupModelToJson(RemovedMemberGroupModel data) =>
    json.encode(data.toJson());

class RemovedMemberGroupModel {
  String? message;
  RemovedMemberGroupData? data;
  int? status;
  bool? isSuccess;

  RemovedMemberGroupModel({
    this.message,
    this.data,
    this.status,
    this.isSuccess,
  });

  RemovedMemberGroupModel copyWith({
    String? message,
    RemovedMemberGroupData? data,
    int? status,
    bool? isSuccess,
  }) => RemovedMemberGroupModel(
    message: message ?? this.message,
    data: data ?? this.data,
    status: status ?? this.status,
    isSuccess: isSuccess ?? this.isSuccess,
  );

  factory RemovedMemberGroupModel.fromJson(Map<String, dynamic> json) =>
      RemovedMemberGroupModel(
        message: json["Message"],
        data: json["Data"] == null
            ? null
            : RemovedMemberGroupData.fromJson(json["Data"]),
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

class RemovedMemberGroupData {
  String? groupId;
  int? removedMembersCount;
  int? totalMembers;

  RemovedMemberGroupData({
    this.groupId,
    this.removedMembersCount,
    this.totalMembers,
  });

  RemovedMemberGroupData copyWith({
    String? groupId,
    int? removedMembersCount,
    int? totalMembers,
  }) => RemovedMemberGroupData(
    groupId: groupId ?? this.groupId,
    removedMembersCount: removedMembersCount ?? this.removedMembersCount,
    totalMembers: totalMembers ?? this.totalMembers,
  );

  factory RemovedMemberGroupData.fromJson(Map<String, dynamic> json) =>
      RemovedMemberGroupData(
        groupId: json["groupId"],
        removedMembersCount: json["removedMembersCount"],
        totalMembers: json["totalMembers"],
      );

  Map<String, dynamic> toJson() => {
    "groupId": groupId,
    "removedMembersCount": removedMembersCount,
    "totalMembers": totalMembers,
  };
}
