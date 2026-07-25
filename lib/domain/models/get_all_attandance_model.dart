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
        data: json["Data"] == null
            ? null
            : GetAllAttendanceData.fromJson(json["Data"]),
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
            : List<GetAllAttendanceDoc>.from(
                json["docs"]!.map((x) => GetAllAttendanceDoc.fromJson(x)),
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
  List<Punching>? punching;
  List<BreakObj>? breaks;

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
    this.punching,
    this.breaks,
  });

  factory GetAllAttendanceDoc.fromJson(Map<String, dynamic> json) =>
      GetAllAttendanceDoc(
        id: json["_id"],
        branchid: json["branchid"] is Map<String, dynamic>
            ? GetAllAttendanceBranchid.fromJson(json["branchid"])
            : (json["branchid"] != null
                ? GetAllAttendanceBranchid(id: json["branchid"].toString())
                : null),
        date: json["date"],
        userid: json["userid"] is Map<String, dynamic>
            ? GetAllAttendanceUserid.fromJson(json["userid"])
            : (json["userid"] != null
                ? GetAllAttendanceUserid(id: json["userid"].toString())
                : null),
        timein: json["timein"],
        timeout: json["timeout"],
        coordinates: json["coordinates"] is Map<String, dynamic>
            ? GetAllAttendanceCoordinates.fromJson(json["coordinates"])
            : null,
        breakstart: (json["breakstart"] ?? json["breakStart"] ?? json["break_start"])?.toString(),
        breakend: (json["breakend"] ?? json["breakEnd"] ?? json["break_end"])?.toString(),
        remark: json["remark"]?.toString(),
        status: json["status"]?.toString(),
        createdBy: json["createdBy"]?.toString(),
        punching: json["punching"] == null
            ? []
            : List<Punching>.from(
                json["punching"]!.map((x) => Punching.fromJson(x)),
              ),
        breaks: (json["break"] ?? json["breaks"] ?? json["break_obj"]) == null
            ? []
            : List<BreakObj>.from(
                (json["break"] ?? json["breaks"] ?? json["break_obj"])!
                    .map((x) => BreakObj.fromJson(x)),
              ),
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
    "punching": punching == null
        ? []
        : List<dynamic>.from(punching!.map((x) => x.toJson())),
    "break": breaks == null
        ? []
        : List<dynamic>.from(breaks!.map((x) => x.toJson())),
  };
}

class Punching {
  String? timein;
  String? timeout;
  String? timeinphoto;
  int? timeinodometer;
  String? timeoutphoto;
  int? timeoutodometer;
  GetAllAttendanceCoordinates? timeincoordinates;
  GetAllAttendanceCoordinates? timeoutcoordinates;

  Punching({
    this.timein,
    this.timeout,
    this.timeinphoto,
    this.timeinodometer,
    this.timeoutphoto,
    this.timeoutodometer,
    this.timeincoordinates,
    this.timeoutcoordinates,
  });

  factory Punching.fromJson(Map<String, dynamic> json) => Punching(
    timein: json["timein"]?.toString(),
    timeout: json["timeout"]?.toString(),
    timeinphoto: json["timeinphoto"]?.toString(),
    timeinodometer: json["timeinodometer"] != null
        ? int.tryParse(json["timeinodometer"].toString())
        : null,
    timeoutphoto: json["timeoutphoto"]?.toString(),
    timeoutodometer: json["timeoutodometer"] != null
        ? int.tryParse(json["timeoutodometer"].toString())
        : null,
    timeincoordinates: json["timeincoordinates"] is Map<String, dynamic>
        ? GetAllAttendanceCoordinates.fromJson(json["timeincoordinates"])
        : null,
    timeoutcoordinates: json["timeoutcoordinates"] is Map<String, dynamic>
        ? GetAllAttendanceCoordinates.fromJson(json["timeoutcoordinates"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "timein": timein,
    "timeout": timeout,
    "timeinphoto": timeinphoto,
    "timeinodometer": timeinodometer,
    "timeoutphoto": timeoutphoto,
    "timeoutodometer": timeoutodometer,
    "timeincoordinates": timeincoordinates?.toJson(),
    "timeoutcoordinates": timeoutcoordinates?.toJson(),
  };
}

class BreakObj {
  String? breakstart;
  String? breakend;

  BreakObj({this.breakstart, this.breakend});

  factory BreakObj.fromJson(Map<String, dynamic> json) => BreakObj(
    breakstart: json["breakstart"]?.toString(),
    breakend: json["breakend"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "breakstart": breakstart,
    "breakend": breakend,
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
        latitude: json["latitude"]?.toString(),
        longitude: json["longitude"]?.toString(),
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
