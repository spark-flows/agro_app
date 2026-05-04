// To parse this JSON data, do
//
//     final leaveGroupModel = leaveGroupModelFromJson(jsonString);

import 'dart:convert';

LeaveGroupModel leaveGroupModelFromJson(String str) =>
    LeaveGroupModel.fromJson(json.decode(str));

String leaveGroupModelToJson(LeaveGroupModel data) =>
    json.encode(data.toJson());

class LeaveGroupModel {
  String? message;
  LeaveGroupData? data;
  int? status;
  bool? isSuccess;

  LeaveGroupModel({this.message, this.data, this.status, this.isSuccess});

  LeaveGroupModel copyWith({
    String? message,
    LeaveGroupData? data,
    int? status,
    bool? isSuccess,
  }) => LeaveGroupModel(
    message: message ?? this.message,
    data: data ?? this.data,
    status: status ?? this.status,
    isSuccess: isSuccess ?? this.isSuccess,
  );

  factory LeaveGroupModel.fromJson(Map<String, dynamic> json) =>
      LeaveGroupModel(
        message: json["Message"],
        data: json["Data"] == null
            ? null
            : LeaveGroupData.fromJson(json["Data"]),
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

class LeaveGroupData {
  String? groupId;
  int? remainingMembers;

  LeaveGroupData({this.groupId, this.remainingMembers});

  LeaveGroupData copyWith({String? groupId, int? remainingMembers}) =>
      LeaveGroupData(
        groupId: groupId ?? this.groupId,
        remainingMembers: remainingMembers ?? this.remainingMembers,
      );

  factory LeaveGroupData.fromJson(Map<String, dynamic> json) => LeaveGroupData(
    groupId: json["groupId"],
    remainingMembers: json["remainingMembers"],
  );

  Map<String, dynamic> toJson() => {
    "groupId": groupId,
    "remainingMembers": remainingMembers,
  };
}
