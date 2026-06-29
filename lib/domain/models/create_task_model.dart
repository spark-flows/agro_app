// To parse this JSON data, do
//
//     final createTasks = createTasksFromJson(jsonString);

import 'dart:convert';

CreateTasks createTasksFromJson(String str) => CreateTasks.fromJson(json.decode(str));

String createTasksToJson(CreateTasks data) => json.encode(data.toJson());

class CreateTasks {
    String? message;
    Data? data;
    int? status;
    bool? isSuccess;

    CreateTasks({
        this.message,
        this.data,
        this.status,
        this.isSuccess,
    });

    factory CreateTasks.fromJson(Map<String, dynamic> json) => CreateTasks(
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
    String? taskname;
    String? description;
    String? branchid;
    String? assignedto;
    String? status;
    String? date;
    bool? isDeleted;
    String? deletedBy;
    String? createdBy;
    String? updatedBy;
    String? id;
    String? createdAt;
    String? updatedAt;
    int? v;

    Data({
        this.taskname,
        this.description,
        this.branchid,
        this.assignedto,
        this.status,
        this.date,
        this.isDeleted,
        this.deletedBy,
        this.createdBy,
        this.updatedBy,
        this.id,
        this.createdAt,
        this.updatedAt,
        this.v,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        taskname: json["taskname"],
        description: json["description"],
        branchid: json["branchid"],
        assignedto: json["assignedto"],
        status: json["status"],
        date: json["date"],
        isDeleted: json["isDeleted"],
        deletedBy: json["deletedBy"],
        createdBy: json["createdBy"],
        updatedBy: json["updatedBy"],
        id: json["_id"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        v: json["__v"],
    );

    Map<String, dynamic> toJson() => {
        "taskname": taskname,
        "description": description,
        "branchid": branchid,
        "assignedto": assignedto,
        "status": status,
        "date": date,
        "isDeleted": isDeleted,
        "deletedBy": deletedBy,
        "createdBy": createdBy,
        "updatedBy": updatedBy,
        "_id": id,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "__v": v,
    };
}
