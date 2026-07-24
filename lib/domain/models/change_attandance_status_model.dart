// To parse this JSON data, do
//
//     final changeAttendanceStatusModel = changeAttendanceStatusModelFromJson(jsonString);

import 'dart:convert';

ChangeAttendanceStatusModel changeAttendanceStatusModelFromJson(String str) =>
    ChangeAttendanceStatusModel.fromJson(json.decode(str));

String changeAttendanceStatusModelToJson(ChangeAttendanceStatusModel data) =>
    json.encode(data.toJson());

class ChangeAttendanceStatusModel {
  String? message;
  ChangeAttendanceStatusData? data;
  int? status;
  bool? isSuccess;

  ChangeAttendanceStatusModel({
    this.message,
    this.data,
    this.status,
    this.isSuccess,
  });

  factory ChangeAttendanceStatusModel.fromJson(Map<String, dynamic> json) =>
      ChangeAttendanceStatusModel(
        message: json["Message"],
        data: json["Data"] == null
            ? null
            : ChangeAttendanceStatusData.fromJson(json["Data"]),
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

class ChangeAttendanceStatusData {
  ChangeAttendanceStatusCoordinates? coordinates;
  String? id;
  String? branchid;
  String? date;
  String? userid;
  String? timein;
  String? timeout;
  String? breakstart;
  String? breakend;
  String? remark;
  String? status;
  String? createdBy;
  String? updatedBy;
  bool? isDeleted;
  String? createdAt;
  String? updatedAt;
  int? v;

  ChangeAttendanceStatusData({
    this.coordinates,
    this.id,
    this.branchid,
    this.date,
    this.userid,
    this.timein,
    this.timeout,
    this.breakstart,
    this.breakend,
    this.remark,
    this.status,
    this.createdBy,
    this.updatedBy,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory ChangeAttendanceStatusData.fromJson(Map<String, dynamic> json) =>
      ChangeAttendanceStatusData(
        coordinates: json["coordinates"] == null
            ? null
            : ChangeAttendanceStatusCoordinates.fromJson(json["coordinates"]),
        id: json["_id"],
        branchid: json["branchid"],
        date: json["date"],
        userid: json["userid"],
        timein: json["timein"],
        timeout: json["timeout"],
        breakstart: json["breakstart"],
        breakend: json["breakend"],
        remark: json["remark"],
        status: json["status"],
        createdBy: json["createdBy"],
        updatedBy: json["updatedBy"],
        isDeleted: json["isDeleted"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
    "coordinates": coordinates?.toJson(),
    "_id": id,
    "branchid": branchid,
    "date": date,
    "userid": userid,
    "timein": timein,
    "timeout": timeout,
    "breakstart": breakstart,
    "breakend": breakend,
    "remark": remark,
    "status": status,
    "createdBy": createdBy,
    "updatedBy": updatedBy,
    "isDeleted": isDeleted,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "__v": v,
  };
}

class ChangeAttendanceStatusCoordinates {
  String? latitude;
  String? longitude;

  ChangeAttendanceStatusCoordinates({this.latitude, this.longitude});

  factory ChangeAttendanceStatusCoordinates.fromJson(
    Map<String, dynamic> json,
  ) => ChangeAttendanceStatusCoordinates(
    latitude: json["latitude"]?.toString(),
    longitude: json["longitude"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "latitude": latitude,
    "longitude": longitude,
  };
}
