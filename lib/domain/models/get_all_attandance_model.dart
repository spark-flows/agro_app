// To parse this JSON data, do
//
//     final getAllAttendanceModel = getAllAttendanceModelFromJson(jsonString);

import 'dart:convert';

GetAllAttendanceModel getAllAttendanceModelFromJson(String str) =>
    GetAllAttendanceModel.fromJson(json.decode(str));

String getAllAttendanceModelToJson(GetAllAttendanceModel data) =>
    json.encode(data.toJson());

class GetAllAttendanceModel {
  String? message;
  GetAllAttendanceData? data;
  int? status;
  bool? isSuccess;

  GetAllAttendanceModel({this.message, this.data, this.status, this.isSuccess});

  factory GetAllAttendanceModel.fromJson(Map<String, dynamic> json) =>
      GetAllAttendanceModel(
        message: json["Message"],
        data: json["Data"] == null ? null : GetAllAttendanceData.fromJson(json["Data"]),
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

class GetAllAttendanceData {
  List<GetAllAttendanceDoc>? docs;
  int? totalDocs;
  int? limit;
  int? totalPages;
  int? page;
  int? pagingCounter;
  bool? hasPrevPage;
  bool? hasNextPage;
  dynamic prevPage;
  dynamic nextPage;

  GetAllAttendanceData({
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

  factory GetAllAttendanceData.fromJson(Map<String, dynamic> json) =>
      GetAllAttendanceData(
        docs: json["docs"] == null
            ? []
            : List<GetAllAttendanceDoc>.from(json["docs"]!.map((x) => GetAllAttendanceDoc.fromJson(x))),
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

class GetAllAttendanceDoc {
  String? id;
  GetAllAttendanceBranchid? branchid;
  String? date;
  GetAllAttendanceUserid? userid;
  String? timein;
  String? timeout;
  GetAllAttendanceCoordinates? coordinates;
  String? breakstart;
  String? breakend;
  String? remark;
  String? status;
  String? createdBy;

  GetAllAttendanceDoc({
    this.id,
    this.branchid,
    this.date,
    this.userid,
    this.timein,
    this.timeout,
    this.coordinates,
    this.breakstart,
    this.breakend,
    this.remark,
    this.status,
    this.createdBy,
  });

  factory GetAllAttendanceDoc.fromJson(Map<String, dynamic> json) =>
      GetAllAttendanceDoc(
        id: json["_id"],
        branchid: json["branchid"] == null
            ? null
            : GetAllAttendanceBranchid.fromJson(json["branchid"]),
        date: json["date"],
        userid: json["userid"] == null ? null : GetAllAttendanceUserid.fromJson(json["userid"]),
        timein: json["timein"],
        timeout: json["timeout"],
        coordinates: json["coordinates"] == null
            ? null
            : GetAllAttendanceCoordinates.fromJson(json["coordinates"]),
        breakstart: json["breakstart"],
        breakend: json["breakend"],
        remark: json["remark"],
        status: json["status"],
        createdBy: json["createdBy"],
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "branchid": branchid?.toJson(),
    "date": date,
    "userid": userid?.toJson(),
    "timein": timein,
    "timeout": timeout,
    "coordinates": coordinates?.toJson(),
    "breakstart": breakstart,
    "breakend": breakend,
    "remark": remark,
    "status": status,
    "createdBy": createdBy,
  };
}

class GetAllAttendanceBranchid {
  String? id;
  String? shortname;

  GetAllAttendanceBranchid({this.id, this.shortname});

  factory GetAllAttendanceBranchid.fromJson(Map<String, dynamic> json) =>
      GetAllAttendanceBranchid(id: json["_id"], shortname: json["shortname"]);

  Map<String, dynamic> toJson() => {"_id": id, "shortname": shortname};
}

class GetAllAttendanceCoordinates {
  String? latitude;
  String? longitude;

  GetAllAttendanceCoordinates({this.latitude, this.longitude});

  factory GetAllAttendanceCoordinates.fromJson(Map<String, dynamic> json) =>
      GetAllAttendanceCoordinates(
        latitude: json["latitude"],
        longitude: json["longitude"],
      );

  Map<String, dynamic> toJson() => {
    "latitude": latitude,
    "longitude": longitude,
  };
}

class GetAllAttendanceUserid {
  String? id;
  String? name;
  String? email;
  String? mobile;

  GetAllAttendanceUserid({this.id, this.name, this.email, this.mobile});

  factory GetAllAttendanceUserid.fromJson(Map<String, dynamic> json) =>
      GetAllAttendanceUserid(
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
