// To parse this JSON data, do
//
//     final getAttendanceModel = getAttendanceModelFromJson(jsonString);

import 'dart:convert';
import 'get_all_attandance_model.dart';

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
  List<Punching>? punching;
  List<BreakObj>? breaks;
  String? photo;
  int? odometer;
  String? timeinphoto;
  int? timeinodometer;
  String? timeoutphoto;
  int? timeoutodometer;

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
    this.punching,
    this.breaks,
    this.photo,
    this.odometer,
    this.timeinphoto,
    this.timeinodometer,
    this.timeoutphoto,
    this.timeoutodometer,
  });

  factory GetAttendanceData.fromJson(Map<String, dynamic> json) =>
      GetAttendanceData(
        id: json["_id"],
        branchid: json["branchid"] is Map<String, dynamic>
            ? GetAttendanceBranchid.fromJson(json["branchid"])
            : (json["branchid"] != null
                ? GetAttendanceBranchid(id: json["branchid"].toString())
                : null),
        date: json["date"],
        userid: json["userid"] is Map<String, dynamic>
            ? GetAttendanceUserid.fromJson(json["userid"])
            : (json["userid"] != null
                ? GetAttendanceUserid(id: json["userid"].toString())
                : null),
        timein: json["timein"],
        timeout: json["timeout"],
        coordinates: json["coordinates"] is Map<String, dynamic>
            ? GetAttendanceCoordinates.fromJson(json["coordinates"])
            : null,
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
        punching: json["punching"] == null
            ? []
            : List<Punching>.from(
                json["punching"]!.map((x) => Punching.fromJson(x)),
              ),
        breaks: json["break"] == null
            ? []
            : List<BreakObj>.from(
                json["break"]!.map((x) => BreakObj.fromJson(x)),
              ),
        photo: json["photo"]?.toString(),
        odometer: json["odometer"] != null
            ? int.tryParse(json["odometer"].toString())
            : null,
        timeinphoto: json["timeinphoto"]?.toString(),
        timeinodometer: json["timeinodometer"] != null
            ? int.tryParse(json["timeinodometer"].toString())
            : null,
        timeoutphoto: json["timeoutphoto"]?.toString(),
        timeoutodometer: json["timeoutodometer"] != null
            ? int.tryParse(json["timeoutodometer"].toString())
            : null,
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
    "punching": punching == null
        ? []
        : List<dynamic>.from(punching!.map((x) => x.toJson())),
    "break": breaks == null
        ? []
        : List<dynamic>.from(breaks!.map((x) => x.toJson())),
    "photo": photo,
    "odometer": odometer,
    "timeinphoto": timeinphoto,
    "timeinodometer": timeinodometer,
    "timeoutphoto": timeoutphoto,
    "timeoutodometer": timeoutodometer,
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
        latitude: json["latitude"]?.toString(),
        longitude: json["longitude"]?.toString(),
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
