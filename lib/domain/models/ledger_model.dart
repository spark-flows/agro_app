import 'dart:convert';

LedgerModel ledgerModelFromJson(String str) =>
    LedgerModel.fromJson(json.decode(str));

String ledgerModelToJson(LedgerModel data) => json.encode(data.toJson());

class LedgerModel {
  String? message;
  String? data;
  int? status;
  bool? isSuccess;

  LedgerModel({this.message, this.data, this.status, this.isSuccess});

  factory LedgerModel.fromJson(Map<String, dynamic> json) => LedgerModel(
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
