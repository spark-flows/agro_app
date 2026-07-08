import 'dart:convert';

GetSalaryModel getSalaryModelFromJson(String str) =>
    GetSalaryModel.fromJson(json.decode(str));

class GetSalaryModel {
  String? message;
  GetSalaryData? data;
  int? status;
  bool? isSuccess;

  GetSalaryModel({this.message, this.data, this.status, this.isSuccess});

  factory GetSalaryModel.fromJson(Map<String, dynamic> json) => GetSalaryModel(
    message: json["Message"],
    data: json["Data"] == null ? null : GetSalaryData.fromJson(json["Data"]),
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

class GetSalaryData {
  String? userid;
  String? month;
  String? year;
  int? basicsalary;
  int? presentdays;
  int? workinghours;

  GetSalaryData({
    this.userid,
    this.month,
    this.year,
    this.basicsalary,
    this.presentdays,
    this.workinghours,
  });

  factory GetSalaryData.fromJson(Map<String, dynamic> json) => GetSalaryData(
    userid: json["userid"],
    month: json["month"],
    year: json["year"],
    basicsalary: json["basicsalary"],
    presentdays: json["presentdays"],
    workinghours: json["workinghours"],
  );

  Map<String, dynamic> toJson() => {
    "userid": userid,
    "month": month,
    "year": year,
    "basicsalary": basicsalary,
    "presentdays": presentdays,
    "workinghours": workinghours,
  };
}
