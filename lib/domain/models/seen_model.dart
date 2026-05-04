// To parse this JSON data, do
//
//     final seenModel = seenModelFromJson(jsonString);

import 'dart:convert';

SeenModel seenModelFromJson(String str) => SeenModel.fromJson(json.decode(str));

String seenModelToJson(SeenModel data) => json.encode(data.toJson());

class SeenModel {
  String? message;
  SeenData? data;
  int? status;
  bool? isSuccess;

  SeenModel({this.message, this.data, this.status, this.isSuccess});

  factory SeenModel.fromJson(Map<String, dynamic> json) => SeenModel(
    message: json["Message"],
    data: json["Data"] == null ? null : SeenData.fromJson(json["Data"]),
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

class SeenData {
  int? modifiedCount;

  SeenData({this.modifiedCount});

  factory SeenData.fromJson(Map<String, dynamic> json) =>
      SeenData(modifiedCount: json["modifiedCount"]);

  Map<String, dynamic> toJson() => {"modifiedCount": modifiedCount};
}
