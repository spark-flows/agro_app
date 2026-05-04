// To parse this JSON data, do
//
//     final changePassModel = changePassModelFromJson(jsonString);

import 'dart:convert';

ChangePassModel changePassModelFromJson(String str) =>
    ChangePassModel.fromJson(json.decode(str));

String changePassModelToJson(ChangePassModel data) =>
    json.encode(data.toJson());

class ChangePassModel {
  String? message;
  int? data;
  int? status;
  bool? isSuccess;

  ChangePassModel({this.message, this.data, this.status, this.isSuccess});

  ChangePassModel copyWith({
    String? message,
    int? data,
    int? status,
    bool? isSuccess,
  }) => ChangePassModel(
    message: message ?? this.message,
    data: data ?? this.data,
    status: status ?? this.status,
    isSuccess: isSuccess ?? this.isSuccess,
  );

  factory ChangePassModel.fromJson(Map<String, dynamic> json) =>
      ChangePassModel(
        message: json["Message"],
        data: json["Data"],
        status: json["Status"],
        isSuccess: json["IsSuccess"],
      );

  Map<String, dynamic> toJson() => {
    "Message": message,
    "Data": data,
    "Status": status,
    "IsSuccess": isSuccess,
  };
}
