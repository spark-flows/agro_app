// To parse this JSON data, do
//
//     final addMemberGroupModel = addMemberGroupModelFromJson(jsonString);

import 'dart:convert';

AddMemberGroupModel addMemberGroupModelFromJson(String str) =>
    AddMemberGroupModel.fromJson(json.decode(str));

String addMemberGroupModelToJson(AddMemberGroupModel data) =>
    json.encode(data.toJson());

class AddMemberGroupModel {
  String? message;
  Data? data;
  int? status;
  bool? isSuccess;

  AddMemberGroupModel({this.message, this.data, this.status, this.isSuccess});

  AddMemberGroupModel copyWith({
    String? message,
    Data? data,
    int? status,
    bool? isSuccess,
  }) => AddMemberGroupModel(
    message: message ?? this.message,
    data: data ?? this.data,
    status: status ?? this.status,
    isSuccess: isSuccess ?? this.isSuccess,
  );

  factory AddMemberGroupModel.fromJson(Map<String, dynamic> json) =>
      AddMemberGroupModel(
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
  String? groupId;
  int? newMembersCount;
  int? totalMembers;

  Data({this.groupId, this.newMembersCount, this.totalMembers});

  Data copyWith({String? groupId, int? newMembersCount, int? totalMembers}) =>
      Data(
        groupId: groupId ?? this.groupId,
        newMembersCount: newMembersCount ?? this.newMembersCount,
        totalMembers: totalMembers ?? this.totalMembers,
      );

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    groupId: json["groupId"],
    newMembersCount: json["newMembersCount"],
    totalMembers: json["totalMembers"],
  );

  Map<String, dynamic> toJson() => {
    "groupId": groupId,
    "newMembersCount": newMembersCount,
    "totalMembers": totalMembers,
  };
}
