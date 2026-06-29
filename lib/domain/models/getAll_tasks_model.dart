// To parse this JSON data, do
//
//     final getAllTasksModel = getAllTasksModelFromJson(jsonString);

import 'dart:convert';

GetAllTasksModel getAllTasksModelFromJson(String str) => GetAllTasksModel.fromJson(json.decode(str));

String getAllTasksModelToJson(GetAllTasksModel data) => json.encode(data.toJson());

class GetAllTasksModel {
    String? message;
    Data? data;
    int? status;
    bool? isSuccess;

    GetAllTasksModel({
        this.message,
        this.data,
        this.status,
        this.isSuccess,
    });

    factory GetAllTasksModel.fromJson(Map<String, dynamic> json) => GetAllTasksModel(
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
    String? taskname;
    String? description;
    Assignedto? assignedto;
    String? status;
    String? date;
    AtedBy? createdBy;
    AtedBy? updatedBy;
    Branchid? branchid;
    DeletedBy? deletedBy;

    Doc({
        this.id,
        this.taskname,
        this.description,
        this.assignedto,
        this.status,
        this.date,
        this.createdBy,
        this.updatedBy,
        this.branchid,
        this.deletedBy,
    });

    factory Doc.fromJson(Map<String, dynamic> json) => Doc(
        id: json["_id"],
        taskname: json["taskname"],
        description: json["description"],
        assignedto: json["assignedto"] == null ? null : Assignedto.fromJson(json["assignedto"]),
        status: json["status"],
        date: json["date"],
        createdBy: json["createdBy"] == null ? null : AtedBy.fromJson(json["createdBy"]),
        updatedBy: json["updatedBy"] == null ? null : AtedBy.fromJson(json["updatedBy"]),
        branchid: json["branchid"] == null ? null : Branchid.fromJson(json["branchid"]),
        deletedBy: json["deletedBy"] == null ? null : DeletedBy.fromJson(json["deletedBy"]),
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "taskname": taskname,
        "description": description,
        "assignedto": assignedto?.toJson(),
        "status": status,
        "date": date,
        "createdBy": createdBy?.toJson(),
        "updatedBy": updatedBy?.toJson(),
        "branchid": branchid?.toJson(),
        "deletedBy": deletedBy?.toJson(),
    };
}

class Assignedto {
    String? id;
    String? name;
    String? mobile;
    String? email;

    Assignedto({
        this.id,
        this.name,
        this.mobile,
        this.email,
    });

    factory Assignedto.fromJson(Map<String, dynamic> json) => Assignedto(
        id: json["_id"],
        name: json["name"],
        mobile: json["mobile"],
        email: json["email"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "mobile": mobile,
        "email": email,
    };
}

class Branchid {
    String? id;
    String? name;
    String? shortname;

    Branchid({
        this.id,
        this.name,
        this.shortname,
    });

    factory Branchid.fromJson(Map<String, dynamic> json) => Branchid(
        id: json["_id"],
        name: json["name"],
        shortname: json["shortname"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "shortname": shortname,
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
