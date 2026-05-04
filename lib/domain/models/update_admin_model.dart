// To parse this JSON data, do
//
//     final updateAdminModel = updateAdminModelFromJson(jsonString);

import 'dart:convert';

UpdateAdminModel updateAdminModelFromJson(String str) =>
    UpdateAdminModel.fromJson(json.decode(str));

String updateAdminModelToJson(UpdateAdminModel data) =>
    json.encode(data.toJson());

class UpdateAdminModel {
  String? message;
  UpdateAdminData? data;
  int? status;
  bool? isSuccess;

  UpdateAdminModel({this.message, this.data, this.status, this.isSuccess});

  UpdateAdminModel copyWith({
    String? message,
    UpdateAdminData? data,
    int? status,
    bool? isSuccess,
  }) => UpdateAdminModel(
    message: message ?? this.message,
    data: data ?? this.data,
    status: status ?? this.status,
    isSuccess: isSuccess ?? this.isSuccess,
  );

  factory UpdateAdminModel.fromJson(Map<String, dynamic> json) =>
      UpdateAdminModel(
        message: json["Message"],
        data: json["Data"] == null
            ? null
            : UpdateAdminData.fromJson(json["Data"]),
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

class UpdateAdminData {
  String? groupId;
  List<String>? adminIds;
  int? totalAdmins;

  UpdateAdminData({this.groupId, this.adminIds, this.totalAdmins});

  UpdateAdminData copyWith({
    String? groupId,
    List<String>? adminIds,
    int? totalAdmins,
  }) => UpdateAdminData(
    groupId: groupId ?? this.groupId,
    adminIds: adminIds ?? this.adminIds,
    totalAdmins: totalAdmins ?? this.totalAdmins,
  );

  factory UpdateAdminData.fromJson(Map<String, dynamic> json) =>
      UpdateAdminData(
        groupId: json["groupId"],
        adminIds: json["adminIds"] == null
            ? []
            : List<String>.from(json["adminIds"]!.map((x) => x)),
        totalAdmins: json["totalAdmins"],
      );

  Map<String, dynamic> toJson() => {
    "groupId": groupId,
    "adminIds": adminIds == null
        ? []
        : List<dynamic>.from(adminIds!.map((x) => x)),
    "totalAdmins": totalAdmins,
  };
}
