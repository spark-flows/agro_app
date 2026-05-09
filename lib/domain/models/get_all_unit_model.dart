import 'dart:convert';

GetAllUnitModel getAllUnitModelFromJson(String str) =>
    GetAllUnitModel.fromJson(json.decode(str));

String getAllUnitModelToJson(GetAllUnitModel data) =>
    json.encode(data.toJson());

class GetAllUnitModel {
  String? message;
  List<GetAllUnitDatum>? data;
  int? status;
  bool? isSuccess;

  GetAllUnitModel({this.message, this.data, this.status, this.isSuccess});

  factory GetAllUnitModel.fromJson(Map<String, dynamic> json) =>
      GetAllUnitModel(
        message: json["Message"],
        data: json["Data"] == null
            ? []
            : List<GetAllUnitDatum>.from(
                json["Data"]!.map((x) => GetAllUnitDatum.fromJson(x)),
              ),
        status: json["Status"],
        isSuccess: json["IsSuccess"],
      );

  Map<String, dynamic> toJson() => {
    "Message": message,
    "Data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
    "Status": status,
    "IsSuccess": isSuccess,
  };
}

class GetAllUnitDatum {
  String? id;
  String? name;
  bool? status;
  bool? isDeleted;
  dynamic deletedBy;
  GetAllUnitCreatedBy? createdBy;
  dynamic updatedBy;
  String? createdAt;
  String? updatedAt;
  int? v;

  GetAllUnitDatum({
    this.id,
    this.name,
    this.status,
    this.isDeleted,
    this.deletedBy,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory GetAllUnitDatum.fromJson(Map<String, dynamic> json) =>
      GetAllUnitDatum(
        id: json["_id"],
        name: json["name"],
        status: json["status"],
        isDeleted: json["isDeleted"],
        deletedBy: json["deletedBy"],
        createdBy: json["createdBy"] == null
            ? null
            : GetAllUnitCreatedBy.fromJson(json["createdBy"]),
        updatedBy: json["updatedBy"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "status": status,
    "isDeleted": isDeleted,
    "deletedBy": deletedBy,
    "createdBy": createdBy?.toJson(),
    "updatedBy": updatedBy,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "__v": v,
  };
}

class GetAllUnitCreatedBy {
  String? id;
  String? name;
  String? profilepic;

  GetAllUnitCreatedBy({this.id, this.name, this.profilepic});

  factory GetAllUnitCreatedBy.fromJson(Map<String, dynamic> json) =>
      GetAllUnitCreatedBy(
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
