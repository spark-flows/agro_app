// To parse this JSON data, do
//
//     final getAllCustomerModel = getAllCustomerModelFromJson(jsonString);

import 'dart:convert';

GetAllCustomerModel getAllCustomerModelFromJson(String str) => GetAllCustomerModel.fromJson(json.decode(str));

String getAllCustomerModelToJson(GetAllCustomerModel data) => json.encode(data.toJson());

class GetAllCustomerModel {
    String? message;
    Data? data;
    int? status;
    bool? isSuccess;

    GetAllCustomerModel({
        this.message,
        this.data,
        this.status,
        this.isSuccess,
    });

    factory GetAllCustomerModel.fromJson(Map<String, dynamic> json) => GetAllCustomerModel(
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
    List<Doc>? docs;
    int? totalDocs;
    int? limit;
    int? totalPages;
    int? page;
    int? pagingCounter;
    bool? hasPrevPage;
    bool? hasNextPage;
    dynamic prevPage;
    dynamic nextPage;

    Data({
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

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        docs: json["docs"] == null ? [] : List<Doc>.from(json["docs"]!.map((x) => Doc.fromJson(x))),
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
        "docs": docs == null ? [] : List<dynamic>.from(docs!.map((x) => x.toJson())),
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

class Doc {
    String? id;
    String? name;
    String? email;
    String? countrycode;
    String? mobile;
    String? feedback;
    bool? isDeleted;
    String? createdAt;
    Distributorid? distributorid;

    Doc({
        this.id,
        this.name,
        this.email,
        this.countrycode,
        this.mobile,
        this.feedback,
        this.isDeleted,
        this.createdAt,
        this.distributorid,
    });

    factory Doc.fromJson(Map<String, dynamic> json) => Doc(
        id: json["_id"],
        name: json["name"],
        email: json["email"],
        countrycode: json["countrycode"],
        mobile: json["mobile"],
        feedback: json["feedback"],
        isDeleted: json["isDeleted"],
        createdAt: json["createdAt"],
        distributorid: json["distributorid"] == null ? null : Distributorid.fromJson(json["distributorid"]),
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "email": email,
        "countrycode": countrycode,
        "mobile": mobile,
        "feedback": feedback,
        "isDeleted": isDeleted,
        "createdAt": createdAt,
        "distributorid": distributorid?.toJson(),
    };
}

class Distributorid {
    Distributorid();

    factory Distributorid.fromJson(Map<String, dynamic> json) => Distributorid(
    );

    Map<String, dynamic> toJson() => {
    };
}
