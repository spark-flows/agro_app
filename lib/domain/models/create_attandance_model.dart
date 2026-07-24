// To parse this JSON data, do
//
//     final createAttendanceModel = createAttendanceModelFromJson(jsonString);

import 'dart:convert';

CreateAttendanceModel createAttendanceModelFromJson(String str) => CreateAttendanceModel.fromJson(json.decode(str));

String createAttendanceModelToJson(CreateAttendanceModel data) => json.encode(data.toJson());

class CreateAttendanceModel {
    String? message;
    CreateAttendanceData? data;
    int? status;
    bool? isSuccess;

    CreateAttendanceModel({
        this.message,
        this.data,
        this.status,
        this.isSuccess,
    });

    factory CreateAttendanceModel.fromJson(Map<String, dynamic> json) => CreateAttendanceModel(
        message: json["Message"],
        data: json["Data"] == null ? null : CreateAttendanceData.fromJson(json["Data"]),
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

class CreateAttendanceData {
    CreateAttendanceCoordinates? coordinates;
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
    String? photo;
    int? odometer;

    CreateAttendanceData({
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
        this.photo,
        this.odometer,
    });

    factory CreateAttendanceData.fromJson(Map<String, dynamic> json) => CreateAttendanceData(
        coordinates: json["coordinates"] == null ? null : CreateAttendanceCoordinates.fromJson(json["coordinates"]),
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
        photo: json["photo"],
        odometer: json["odometer"],
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
        "photo": photo,
        "odometer": odometer,
    };
}

class CreateAttendanceCoordinates {
    String? latitude;
    String? longitude;

    CreateAttendanceCoordinates({
        this.latitude,
        this.longitude,
    });

    factory CreateAttendanceCoordinates.fromJson(Map<String, dynamic> json) => CreateAttendanceCoordinates(
        latitude: json["latitude"]?.toString(),
        longitude: json["longitude"]?.toString(),
    );

    Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
    };
}
