import 'dart:convert';

GetAllRolesModel getAllRolesModelFromJson(String str) =>
    GetAllRolesModel.fromJson(json.decode(str));

String getAllRolesModelToJson(GetAllRolesModel data) =>
    json.encode(data.toJson());

class GetAllRolesModel {
  String message;
  List<GetAllRolesDatum> data;
  int status;
  bool isSuccess;

  GetAllRolesModel({
    required this.message,
    required this.data,
    required this.status,
    required this.isSuccess,
  });

  factory GetAllRolesModel.fromJson(Map<String, dynamic> json) =>
      GetAllRolesModel(
        message: json["Message"],
        data: List<GetAllRolesDatum>.from(
          json["Data"].map((x) => GetAllRolesDatum.fromJson(x)),
        ),
        status: json["Status"],
        isSuccess: json["IsSuccess"],
      );

  Map<String, dynamic> toJson() => {
    "Message": message,
    "Data": List<dynamic>.from(data.map((x) => x.toJson())),
    "Status": status,
    "IsSuccess": isSuccess,
  };
}

class GetAllRolesDatum {
  GetAllRolesCheckermaker checkermaker;
  String id;
  String rolename;
  bool status;
  bool isDeleted;
  dynamic deletedBy;
  GetAllRolesAtedBy createdBy;
  GetAllRolesAtedBy? updatedBy;
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  GetAllRolesDatum({
    required this.checkermaker,
    required this.id,
    required this.rolename,
    required this.status,
    required this.isDeleted,
    required this.deletedBy,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory GetAllRolesDatum.fromJson(Map<String, dynamic> json) =>
      GetAllRolesDatum(
        checkermaker: GetAllRolesCheckermaker.fromJson(json["checkermaker"]),
        id: json["_id"],
        rolename: json["rolename"],
        status: json["status"],
        isDeleted: json["isDeleted"],
        deletedBy: json["deletedBy"],
        createdBy: GetAllRolesAtedBy.fromJson(json["createdBy"]),
        updatedBy: json["updatedBy"] == null
            ? null
            : GetAllRolesAtedBy.fromJson(json["updatedBy"]),
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
    "checkermaker": checkermaker.toJson(),
    "_id": id,
    "rolename": rolename,
    "status": status,
    "isDeleted": isDeleted,
    "deletedBy": deletedBy,
    "createdBy": createdBy.toJson(),
    "updatedBy": updatedBy?.toJson(),
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "__v": v,
  };
}

class GetAllRolesCheckermaker {
  bool edit;
  bool view;

  GetAllRolesCheckermaker({required this.edit, required this.view});

  factory GetAllRolesCheckermaker.fromJson(Map<String, dynamic> json) =>
      GetAllRolesCheckermaker(edit: json["edit"], view: json["view"]);

  Map<String, dynamic> toJson() => {"edit": edit, "view": view};
}

class GetAllRolesAtedBy {
  String id;
  String name;
  String profilepic;

  GetAllRolesAtedBy({
    required this.id,
    required this.name,
    required this.profilepic,
  });

  factory GetAllRolesAtedBy.fromJson(Map<String, dynamic> json) =>
      GetAllRolesAtedBy(
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
