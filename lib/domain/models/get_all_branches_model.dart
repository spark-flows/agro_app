// To parse this JSON data, do
//
//     final getAllBranchs = getAllBranchsFromJson(jsonString);

import 'dart:convert';

GetAllBranchs getAllBranchsFromJson(String str) =>
    GetAllBranchs.fromJson(json.decode(str));

String getAllBranchsToJson(GetAllBranchs data) => json.encode(data.toJson());

class GetAllBranchs {
  String? message;
  Data? data;
  int? status;
  bool? isSuccess;

  GetAllBranchs({this.message, this.data, this.status, this.isSuccess});

  factory GetAllBranchs.fromJson(Map<String, dynamic> json) => GetAllBranchs(
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
  String? name;
  bool? status;
  bool? isDeleted;
  dynamic deletedBy;
  AtedBy? createdBy;
  AtedBy? updatedBy;
  String? createdAt;
  String? updatedAt;
  String? shortname;
  String? docId;

  Doc({
    this.id,
    this.name,
    this.status,
    this.isDeleted,
    this.deletedBy,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.shortname,
    this.docId,
  });

  factory Doc.fromJson(Map<String, dynamic> json) => Doc(
    id: json["_id"],
    name: json["name"],
    status: json["status"],
    isDeleted: json["isDeleted"],
    deletedBy: json["deletedBy"],
    createdBy: json["createdBy"] == null
        ? null
        : AtedBy.fromJson(json["createdBy"]),
    updatedBy: json["updatedBy"] == null
        ? null
        : AtedBy.fromJson(json["updatedBy"]),
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    shortname: json["shortname"],
    docId: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "status": status,
    "isDeleted": isDeleted,
    "deletedBy": deletedBy,
    "createdBy": createdBy?.toJson(),
    "updatedBy": updatedBy?.toJson(),
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "shortname": shortname,
    "id": docId,
  };
}

class AtedBy {
  String? id;
  String? name;
  String? profilepic;

  AtedBy({this.id, this.name, this.profilepic});

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
