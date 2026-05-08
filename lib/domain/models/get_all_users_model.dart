// To parse this JSON data, do
//
//     final getAllUsersModel = getAllUsersModelFromJson(jsonString);

import 'dart:convert';

GetAllUsersModel getAllUsersModelFromJson(String str) => GetAllUsersModel.fromJson(json.decode(str));

String getAllUsersModelToJson(GetAllUsersModel data) => json.encode(data.toJson());

class GetAllUsersModel {
    String message;
    Data data;
    int status;
    bool isSuccess;

    GetAllUsersModel({
        required this.message,
        required this.data,
        required this.status,
        required this.isSuccess,
    });

    factory GetAllUsersModel.fromJson(Map<String, dynamic> json) => GetAllUsersModel(
        message: json["Message"],
        data: Data.fromJson(json["Data"]),
        status: json["Status"],
        isSuccess: json["IsSuccess"],
    );

    Map<String, dynamic> toJson() => {
        "Message": message,
        "Data": data.toJson(),
        "Status": status,
        "IsSuccess": isSuccess,
    };
}

class Data {
    List<Doc> docs;
    int totalDocs;
    int limit;
    int totalPages;
    int page;
    int pagingCounter;
    bool hasPrevPage;
    bool hasNextPage;
    dynamic prevPage;
    dynamic nextPage;

    Data({
        required this.docs,
        required this.totalDocs,
        required this.limit,
        required this.totalPages,
        required this.page,
        required this.pagingCounter,
        required this.hasPrevPage,
        required this.hasNextPage,
        required this.prevPage,
        required this.nextPage,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        docs: List<Doc>.from(json["docs"].map((x) => Doc.fromJson(x))),
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
        "docs": List<dynamic>.from(docs.map((x) => x.toJson())),
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
    String id;
    String code;
    String name;
    String email;
    String mobile;
    bool status;
    bool isDeleted;
    String? address;
    DateTime createdAt;
    DateTime updatedAt;
    Roleid roleid;
    AtedBy createdBy;
    AtedBy updatedBy;
    DeletedBy deletedBy;
    String? surname;
    String? fathername;

    Doc({
        required this.id,
        required this.code,
        required this.name,
        required this.email,
        required this.mobile,
        required this.status,
        required this.isDeleted,
        this.address,
        required this.createdAt,
        required this.updatedAt,
        required this.roleid,
        required this.createdBy,
        required this.updatedBy,
        required this.deletedBy,
        this.surname,
        this.fathername,
    });

    factory Doc.fromJson(Map<String, dynamic> json) => Doc(
        id: json["_id"],
        code: json["code"],
        name: json["name"],
        email: json["email"],
        mobile: json["mobile"],
        status: json["status"],
        isDeleted: json["isDeleted"],
        address: json["address"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        roleid: Roleid.fromJson(json["roleid"]),
        createdBy: AtedBy.fromJson(json["createdBy"]),
        updatedBy: AtedBy.fromJson(json["updatedBy"]),
        deletedBy: DeletedBy.fromJson(json["deletedBy"]),
        surname: json["surname"],
        fathername: json["fathername"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "code": code,
        "name": name,
        "email": email,
        "mobile": mobile,
        "status": status,
        "isDeleted": isDeleted,
        "address": address,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "roleid": roleid.toJson(),
        "createdBy": createdBy.toJson(),
        "updatedBy": updatedBy.toJson(),
        "deletedBy": deletedBy.toJson(),
        "surname": surname,
        "fathername": fathername,
    };
}

class AtedBy {
    String? id;
    String? name;
    String? profilepic;

    AtedBy({
        this.id,
        this.name,
        this.profilepic,
    });

    factory AtedBy.fromJson(Map<String, dynamic> json) => AtedBy(
        id: json["_id"],
        name: json["name"],
        profilepic: json["profilepic"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "profilepic": profilepic,
    };
}

class DeletedBy {
    DeletedBy();

    factory DeletedBy.fromJson(Map<String, dynamic> json) => DeletedBy(
    );

    Map<String, dynamic> toJson() => {
    };
}

class Roleid {
    String? id;
    String? rolename;

    Roleid({
        this.id,
        this.rolename,
    });

    factory Roleid.fromJson(Map<String, dynamic> json) => Roleid(
        id: json["_id"],
        rolename: json["rolename"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "rolename": rolename,
    };
}
