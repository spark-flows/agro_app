// To parse this JSON data, do
//
//     final getAllTasksModel = getAllTasksModelFromJson(jsonString);

import 'dart:convert';

GetAllTasksModel getAllTasksModelFromJson(String str) =>
    GetAllTasksModel.fromJson(json.decode(str));

String getAllTasksModelToJson(GetAllTasksModel data) =>
    json.encode(data.toJson());

class GetAllTasksModel {
  String? message;
  Data? data;
  int? status;
  bool? isSuccess;

  GetAllTasksModel({this.message, this.data, this.status, this.isSuccess});

  factory GetAllTasksModel.fromJson(Map<String, dynamic> json) =>
      GetAllTasksModel(
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
    docs: json["docs"] == null
        ? []
        : List<Doc>.from(json["docs"]!.map((x) => Doc.fromJson(x))),
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

class Doc {
  String? id;
  String? taskname;
  String? description;
  List<Assignedto>? assignedto;
  String? status;
  String? date;
  AtedBy? createdBy;
  AtedBy? updatedBy;
  Branchid? branchid;
  DeletedBy? deletedBy;
  String? duedate;
  String? time;
  String? priority;
  List<Attachment>? attachment;
  String? tasktype;
  List<TaskRemark>? remarks;

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
    this.duedate,
    this.time,
    this.priority,
    this.attachment,
    this.tasktype,
    this.remarks,
  });

  factory Doc.fromJson(Map<String, dynamic> json) => Doc(
    id: json["_id"],
    taskname: json["taskname"],
    description: json["description"],
    assignedto: json["assignedto"] == null
        ? []
        : (json["assignedto"] is List
              ? List<Assignedto>.from(
                  json["assignedto"]!.map((x) => Assignedto.fromJson(x)),
                )
              : [Assignedto.fromJson(json["assignedto"])]),
    status: json["status"],
    date: json["date"],
    createdBy: json["createdBy"] == null
        ? null
        : AtedBy.fromJson(json["createdBy"]),
    updatedBy: json["updatedBy"] == null
        ? null
        : AtedBy.fromJson(json["updatedBy"]),
    branchid: json["branchid"] == null
        ? null
        : Branchid.fromJson(json["branchid"]),
    deletedBy: json["deletedBy"] == null
        ? null
        : DeletedBy.fromJson(json["deletedBy"]),
    duedate: json["duedate"],
    time: json["time"],
    priority: json["priority"],
    attachment: json["attachment"] == null
        ? []
        : List<Attachment>.from(
            json["attachment"]!.map((x) => Attachment.fromJson(x)),
          ),
    tasktype: json["tasktype"],
    remarks: json["remarks"] == null
        ? []
        : List<TaskRemark>.from(
            json["remarks"]!.map((x) => TaskRemark.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "taskname": taskname,
    "description": description,
    "assignedto": assignedto == null
        ? []
        : List<dynamic>.from(assignedto!.map((x) => x.toJson())),
    "status": status,
    "date": date,
    "createdBy": createdBy?.toJson(),
    "updatedBy": updatedBy?.toJson(),
    "branchid": branchid?.toJson(),
    "deletedBy": deletedBy?.toJson(),
    "duedate": duedate,
    "time": time,
    "priority": priority,
    "attachment": attachment == null
        ? []
        : List<dynamic>.from(attachment!.map((x) => x.toJson())),
    "tasktype": tasktype,
    "remarks": remarks == null
        ? []
        : List<dynamic>.from(remarks!.map((x) => x.toJson())),
  };
}

class TaskRemark {
  String? status;
  String? remark;
  dynamic updatedBy;
  String? date;

  TaskRemark({this.status, this.remark, this.updatedBy, this.date});

  factory TaskRemark.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return TaskRemark(
        status: json["status"],
        remark: json["remark"],
        updatedBy: json["updatedBy"],
        date: json["date"],
      );
    }
    return TaskRemark();
  }

  Map<String, dynamic> toJson() {
    String? updatedById;
    if (updatedBy is String) {
      updatedById = updatedBy;
    } else if (updatedBy is Map) {
      updatedById = (updatedBy["_id"] ?? updatedBy["id"] ?? "").toString();
    } else if (updatedBy is AtedBy) {
      updatedById = updatedBy.id;
    }
    return {
      if (status != null) "status": status,
      if (remark != null) "remark": remark,
      "updatedBy": updatedById ?? updatedBy ?? "",
      if (date != null) "date": date,
    };
  }

  String get updatedById {
    if (updatedBy is String) return updatedBy as String;
    if (updatedBy is Map)
      return (updatedBy["_id"] ?? updatedBy["id"] ?? "").toString();
    if (updatedBy is AtedBy) return updatedBy.id ?? "";
    return "";
  }

  String get updatedByName {
    if (updatedBy is Map)
      return (updatedBy["name"] ?? updatedBy["email"] ?? "").toString();
    if (updatedBy is AtedBy) return updatedBy.name ?? "";
    return "";
  }
}

class Assignedto {
  String? id;
  String? name;
  String? mobile;
  String? email;

  Assignedto({this.id, this.name, this.mobile, this.email});

  factory Assignedto.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return Assignedto(
        id: json["_id"],
        name: json["name"],
        mobile: json["mobile"],
        email: json["email"],
      );
    } else if (json is String) {
      return Assignedto(id: json);
    }
    return Assignedto();
  }

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

  Branchid({this.id, this.name, this.shortname});

  factory Branchid.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return Branchid(
        id: json["_id"],
        name: json["name"],
        shortname: json["shortname"],
      );
    } else if (json is String) {
      return Branchid(id: json);
    }
    return Branchid();
  }

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

  AtedBy({this.id, this.name, this.profilepic});

  factory AtedBy.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return AtedBy(
        id: json["_id"],
        name: json["name"],
        profilepic: json["profilepic"],
      );
    } else if (json is String) {
      return AtedBy(id: json);
    }
    return AtedBy();
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "profilepic": profilepic,
  };
}

class DeletedBy {
  DeletedBy();

  factory DeletedBy.fromJson(Map<String, dynamic> json) => DeletedBy();

  Map<String, dynamic> toJson() => {};
}

class Attachment {
  String? path;

  Attachment({this.path});

  factory Attachment.fromJson(Map<String, dynamic> json) =>
      Attachment(path: json["path"]);

  Map<String, dynamic> toJson() => {"path": path};
}
