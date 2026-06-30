// To parse this JSON data, do
//
//     final getAttendanceModel = getAttendanceModelFromJson(jsonString);

import 'dart:convert';

GetAttendanceModel getAttendanceModelFromJson(String str) =>
    GetAttendanceModel.fromJson(json.decode(str));

String getAttendanceModelToJson(GetAttendanceModel data) =>
    json.encode(data.toJson());

class GetAttendanceModel {
  String? message;
  GetAttendanceData? data;
  int? status;
  bool? isSuccess;

  GetAttendanceModel({this.message, this.data, this.status, this.isSuccess});

  factory GetAttendanceModel.fromJson(Map<String, dynamic> json) =>
      GetAttendanceModel(
        message: json["Message"],
        data: json["Data"] == null
            ? null
            : GetAttendanceData.fromJson(json["Data"]),
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

class GetAttendanceData {
  String? id;
  GetAttendanceBranchid? branchid;
  String? date;
  GetAttendanceUserid? userid;
  String? timein;
  String? timeout;
  GetAttendanceCoordinates? coordinates;
  String? breakstart;
  String? breakend;
  String? remark;
  String? status;
  GetAttendanceCreatedBy? createdBy;
  dynamic updatedBy;
  bool? isDeleted;
  String? createdAt;
  String? updatedAt;

  GetAttendanceData({
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
    this.updatedBy,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
  });

  factory GetAttendanceData.fromJson(Map<String, dynamic> json) =>
      GetAttendanceData(
        id: json["_id"],
        branchid: json["branchid"] == null
            ? null
            : GetAttendanceBranchid.fromJson(json["branchid"]),
        date: json["date"],
        userid: json["userid"] == null
            ? null
            : GetAttendanceUserid.fromJson(json["userid"]),
        timein: json["timein"],
        timeout: json["timeout"],
        coordinates: json["coordinates"] == null
            ? null
            : GetAttendanceCoordinates.fromJson(json["coordinates"]),
        breakstart: json["breakstart"],
        breakend: json["breakend"],
        remark: json["remark"],
        status: json["status"],
        createdBy: json["createdBy"] == null
            ? null
            : GetAttendanceCreatedBy.fromJson(json["createdBy"]),
        updatedBy: json["updatedBy"],
        isDeleted: json["isDeleted"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
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
    "createdBy": createdBy?.toJson(),
    "updatedBy": updatedBy,
    "isDeleted": isDeleted,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}

class GetAttendanceBranchid {
  String? id;
  String? name;
  String? shortname;

  GetAttendanceBranchid({this.id, this.name, this.shortname});

  factory GetAttendanceBranchid.fromJson(Map<String, dynamic> json) =>
      GetAttendanceBranchid(
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

class GetAttendanceCoordinates {
  String? latitude;
  String? longitude;

  GetAttendanceCoordinates({this.latitude, this.longitude});

  factory GetAttendanceCoordinates.fromJson(Map<String, dynamic> json) =>
      GetAttendanceCoordinates(
        latitude: json["latitude"],
        longitude: json["longitude"],
      );

  Map<String, dynamic> toJson() => {
    "latitude": latitude,
    "longitude": longitude,
  };
}

class GetAttendanceCreatedBy {
  String? id;
  String? name;
  String? profilepic;

  GetAttendanceCreatedBy({this.id, this.name, this.profilepic});

  factory GetAttendanceCreatedBy.fromJson(Map<String, dynamic> json) =>
      GetAttendanceCreatedBy(
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

class GetAttendanceUserid {
  String? id;
  String? name;
  String? surname;
  String? email;
  String? mobile;

  GetAttendanceUserid({
    this.id,
    this.name,
    this.surname,
    this.email,
    this.mobile,
  });

  factory GetAttendanceUserid.fromJson(Map<String, dynamic> json) =>
      GetAttendanceUserid(
        id: json["_id"],
        name: json["name"],
        surname: json["surname"],
        email: json["email"],
        mobile: json["mobile"],
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "surname": surname,
    "email": email,
    "mobile": mobile,
  };
}
