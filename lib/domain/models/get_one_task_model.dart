import 'dart:convert';
import 'package:agro_app/domain/models/getAll_tasks_model.dart';

GetOneTaskModel getOneTaskModelFromJson(String str) => GetOneTaskModel.fromJson(json.decode(str));

String getOneTaskModelToJson(GetOneTaskModel data) => json.encode(data.toJson());

class GetOneTaskModel {
  String? message;
  Doc? data;
  int? status;
  bool? isSuccess;

  GetOneTaskModel({
    this.message,
    this.data,
    this.status,
    this.isSuccess,
  });

  factory GetOneTaskModel.fromJson(Map<String, dynamic> json) => GetOneTaskModel(
        message: json["Message"] ?? json["message"],
        data: (json["Data"] ?? json["data"]) == null
            ? null
            : Doc.fromJson(json["Data"] ?? json["data"]),
        status: json["Status"] ?? json["status"],
        isSuccess: json["IsSuccess"] ?? json["isSuccess"] ?? json["issuccess"],
      );

  Map<String, dynamic> toJson() => {
        "Message": message,
        "Data": data?.toJson(),
        "Status": status,
        "IsSuccess": isSuccess,
      };
}
