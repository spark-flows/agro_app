import 'dart:convert';

GetAllLeavesModel getAllLeavesModelFromJson(String str) =>
    GetAllLeavesModel.fromJson(json.decode(str));

String getAllLeavesModelToJson(GetAllLeavesModel data) =>
    json.encode(data.toJson());

CreateLeaveModel createLeaveModelFromJson(String str) =>
    CreateLeaveModel.fromJson(json.decode(str));

String createLeaveModelToJson(CreateLeaveModel data) =>
    json.encode(data.toJson());

class GetAllLeavesModel {
  String? message;
  Data? data;
  int? status;
  bool? isSuccess;

  GetAllLeavesModel({
    this.message,
    this.data,
    this.status,
    this.isSuccess,
  });

  factory GetAllLeavesModel.fromJson(Map<String, dynamic> json) =>
      GetAllLeavesModel(
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
  List<LeaveDoc>? docs;
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
            : List<LeaveDoc>.from(
                json["docs"]!.map((x) => LeaveDoc.fromJson(x)),
              ),
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

class LeaveDoc {
  String? id;
  String? leavedate;
  LeaveUser? userid;
  String? fromdate;
  String? todate;
  num? totaldays;
  num? totalhours;
  String? leavetype;
  String? reason;
  String? status;
  bool? isDeleted;
  String? createdAt;
  String? updatedAt;

  LeaveDoc({
    this.id,
    this.leavedate,
    this.userid,
    this.fromdate,
    this.todate,
    this.totaldays,
    this.totalhours,
    this.leavetype,
    this.reason,
    this.status,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
  });

  factory LeaveDoc.fromJson(Map<String, dynamic> json) => LeaveDoc(
        id: json["_id"],
        leavedate: json["leavedate"],
        userid: json["userid"] == null
            ? null
            : json["userid"] is Map<String, dynamic>
                ? LeaveUser.fromJson(json["userid"])
                : LeaveUser(id: json["userid"].toString()),
        fromdate: json["fromdate"],
        todate: json["todate"],
        totaldays: json["totaldays"],
        totalhours: json["totalhours"],
        leavetype: json["leavetype"],
        reason: json["reason"],
        status: json["status"],
        isDeleted: json["isDeleted"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "leavedate": leavedate,
        "userid": userid?.toJson(),
        "fromdate": fromdate,
        "todate": todate,
        "totaldays": totaldays,
        "totalhours": totalhours,
        "leavetype": leavetype,
        "reason": reason,
        "status": status,
        "isDeleted": isDeleted,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
      };
}

class LeaveUser {
  String? id;
  String? name;
  String? mobile;
  String? email;

  LeaveUser({
    this.id,
    this.name,
    this.mobile,
    this.email,
  });

  factory LeaveUser.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return LeaveUser(
        id: json["_id"],
        name: json["name"],
        mobile: json["mobile"],
        email: json["email"],
      );
    } else if (json is String) {
      return LeaveUser(id: json);
    }
    return LeaveUser();
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "mobile": mobile,
        "email": email,
      };
}

class CreateLeaveModel {
  String? message;
  LeaveDoc? data;
  int? status;
  bool? isSuccess;

  CreateLeaveModel({
    this.message,
    this.data,
    this.status,
    this.isSuccess,
  });

  factory CreateLeaveModel.fromJson(Map<String, dynamic> json) =>
      CreateLeaveModel(
        message: json["Message"],
        data: json["Data"] == null ? null : LeaveDoc.fromJson(json["Data"]),
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
