import 'dart:convert';

import 'package:agro_app/domain/domain.dart';

SalaryModel salaryModelFromJson(String str) =>
    SalaryModel.fromJson(json.decode(str));

String salaryModelToJson(SalaryModel data) => json.encode(data.toJson());

class SalaryModel {
  String? message;
  SalaryData? data;
  int? status;
  bool? isSuccess;

  SalaryModel({this.message, this.data, this.status, this.isSuccess});

  factory SalaryModel.fromJson(Map<String, dynamic> json) => SalaryModel(
    message: json["Message"],
    data: json["Data"] == null ? null : SalaryData.fromJson(json["Data"]),
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

class SalaryData {
  List<SalaryDoc>? docs;
  int? totalDocs;
  int? limit;
  int? totalPages;
  int? page;
  int? pagingCounter;
  bool? hasPrevPage;
  bool? hasNextPage;
  dynamic prevPage;
  dynamic nextPage;

  SalaryData({
    this.docs,
    this.totalDocs,
    this.limit,
    this.totalPages,
    this.page,
    this.pagingCounter,
    this.hasPrevPage,
    this.hasNextPage,
    this.prevPage,
    this.nextPage,
  });

  factory SalaryData.fromJson(Map<String, dynamic> json) => SalaryData(
    docs: json["docs"] == null
        ? []
        : List<SalaryDoc>.from(json["docs"]!.map((x) => SalaryDoc.fromJson(x))),
    totalDocs: json["totalDocs"],
    limit: json["limit"],
    totalPages: json["totalPages"],
    page: json["page"],
    pagingCounter: json["pagingCounter"],
    hasPrevPage: json["hasPrevPage"],
    hasNextPage: json["hasNextPage"],
    prevPage: json["prevPage"],
    nextPage: json["nextPage"],
  );

  Map<String, dynamic> toJson() => {
    "docs": docs == null
        ? []
        : List<dynamic>.from(docs!.map((x) => x.toJson())),
    "totalDocs": totalDocs,
    "limit": limit,
    "totalPages": totalPages,
    "page": page,
    "pagingCounter": pagingCounter,
    "hasPrevPage": hasPrevPage,
    "hasNextPage": hasNextPage,
    "prevPage": prevPage,
    "nextPage": nextPage,
  };
}

class SalaryDoc {
  String? id;
  Userid? userid;
  Branchid? branchid;
  String? date;
  String? month;
  String? year;
  int? basicsalary;
  int? bonus;
  int? allowance;
  dynamic deduction;
  int? netsalary;
  int? workdays;
  String? paymentmode;
  String? paymentstatus;
  String? transactionid;
  String? remark;
  bool? isDeleted;
  String? createdAt;

  SalaryDoc({
    this.id,
    this.userid,
    this.branchid,
    this.date,
    this.month,
    this.year,
    this.basicsalary,
    this.bonus,
    this.allowance,
    this.deduction,
    this.netsalary,
    this.workdays,
    this.paymentmode,
    this.paymentstatus,
    this.transactionid,
    this.remark,
    this.isDeleted,
    this.createdAt,
  });

  factory SalaryDoc.fromJson(Map<String, dynamic> json) => SalaryDoc(
    id: json["_id"],
    userid: json["userid"] == null ? null : Userid.fromJson(json["userid"]),
    branchid: json["branchid"] == null
        ? null
        : Branchid.fromJson(json["branchid"]),
    date: json["date"],
    month: json["month"],
    year: json["year"],
    basicsalary: json["basicsalary"],
    bonus: json["bonus"],
    allowance: json["allowance"],
    deduction: json["deduction"],
    netsalary: json["netsalary"],
    workdays: json["workdays"],
    paymentmode: json["paymentmode"],
    paymentstatus: json["paymentstatus"],
    transactionid: json["transactionid"],
    remark: json["remark"],
    isDeleted: json["isDeleted"],
    createdAt: json["createdAt"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userid": userid?.toJson(),
    "branchid": branchid?.toJson(),
    "date": date,
    "month": month,
    "year": year,
    "basicsalary": basicsalary,
    "bonus": bonus,
    "allowance": allowance,
    "deduction": deduction,
    "netsalary": netsalary,
    "workdays": workdays,
    "paymentmode": paymentmode,
    "paymentstatus": paymentstatus,
    "transactionid": transactionid,
    "remark": remark,
    "isDeleted": isDeleted,
    "createdAt": createdAt,
  };
}

class Userid {
  String? id;
  String? name;
  String? email;
  String? mobile;

  Userid({this.id, this.name, this.email, this.mobile});

  factory Userid.fromJson(Map<String, dynamic> json) => Userid(
    id: json["_id"],
    name: json["name"],
    email: json["email"],
    mobile: json["mobile"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "email": email,
    "mobile": mobile,
  };
}
