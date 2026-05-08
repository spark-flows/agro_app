import 'dart:convert';

GetAllCategoryModel getAllCategoryModelFromJson(String str) =>
    GetAllCategoryModel.fromJson(json.decode(str));

String getAllCategoryModelToJson(GetAllCategoryModel data) =>
    json.encode(data.toJson());

class GetAllCategoryModel {
  String message;
  GetAllCategoryData data;
  int status;
  bool isSuccess;

  GetAllCategoryModel({
    required this.message,
    required this.data,
    required this.status,
    required this.isSuccess,
  });

  factory GetAllCategoryModel.fromJson(Map<String, dynamic> json) {
    final dataJson = json["Data"];
    GetAllCategoryData data;

    if (dataJson is List) {
      // API returns Data as a direct List of category objects
      final docs = List<GetAllCategoryDoc>.from(
        dataJson.map((x) => GetAllCategoryDoc.fromJson(x)),
      );
      data = GetAllCategoryData(
        docs: docs,
        totalDocs: docs.length,
        limit: docs.length,
        totalPages: 1,
        page: 1,
        pagingCounter: 1,
        hasPrevPage: false,
        hasNextPage: false,
        prevPage: null,
        nextPage: null,
      );
    } else if (dataJson is Map<String, dynamic>) {
      data = GetAllCategoryData.fromJson(dataJson);
    } else {
      data = GetAllCategoryData(
        docs: [],
        totalDocs: 0,
        limit: 0,
        totalPages: 0,
        page: 0,
        pagingCounter: 0,
        hasPrevPage: false,
        hasNextPage: false,
        prevPage: null,
        nextPage: null,
      );
    }

    return GetAllCategoryModel(
      message: json["Message"] ?? '',
      data: data,
      status: json["Status"] ?? 0,
      isSuccess: json["IsSuccess"] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    "Message": message,
    "Data": data.toJson(),
    "Status": status,
    "IsSuccess": isSuccess,
  };
}

class GetAllCategoryData {
  List<GetAllCategoryDoc> docs;
  int totalDocs;
  int limit;
  int totalPages;
  int page;
  int pagingCounter;
  bool hasPrevPage;
  bool hasNextPage;
  dynamic prevPage;
  dynamic nextPage;

  GetAllCategoryData({
    required this.docs,
    required this.totalDocs,
    required this.limit,
    required this.totalPages,
    required this.page,
    required this.pagingCounter,
    required this.hasPrevPage,
    required this.hasNextPage,
    required this.prevPage,
    required this.nextPage,
  });

  factory GetAllCategoryData.fromJson(Map<String, dynamic> json) =>
      GetAllCategoryData(
        docs: json["docs"] == null
            ? []
            : List<GetAllCategoryDoc>.from(
                json["docs"].map((x) => GetAllCategoryDoc.fromJson(x)),
              ),
        totalDocs: json["totalDocs"] ?? 0,
        limit: json["limit"] ?? 0,
        totalPages: json["totalPages"] ?? 0,
        page: json["page"] ?? 0,
        pagingCounter: json["pagingCounter"] ?? 0,
        hasPrevPage: json["hasPrevPage"] ?? false,
        hasNextPage: json["hasNextPage"] ?? false,
        prevPage: json["prevPage"],
        nextPage: json["nextPage"],
      );

  Map<String, dynamic> toJson() => {
    "docs": List<dynamic>.from(docs.map((x) => x.toJson())),
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

class GetAllCategoryDoc {
  String id;
  String name;
  bool status;
  bool isDeleted;
  dynamic deletedBy;
  GetAllCategoryAtedBy createdBy;
  GetAllCategoryAtedBy? updatedBy;
  DateTime createdAt;
  DateTime updatedAt;
  String docId;

  GetAllCategoryDoc({
    required this.id,
    required this.name,
    required this.status,
    required this.isDeleted,
    required this.deletedBy,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
    required this.docId,
  });

  factory GetAllCategoryDoc.fromJson(Map<String, dynamic> json) =>
      GetAllCategoryDoc(
        id: json["_id"] ?? '',
        name: json["name"] ?? '',
        status: json["status"] ?? false,
        isDeleted: json["isDeleted"] ?? false,
        deletedBy: json["deletedBy"],
        createdBy: json["createdBy"] != null
            ? GetAllCategoryAtedBy.fromJson(json["createdBy"])
            : GetAllCategoryAtedBy(id: '', name: '', profilepic: ''),
        updatedBy: json["updatedBy"] == null
            ? null
            : GetAllCategoryAtedBy.fromJson(json["updatedBy"]),
        createdAt: json["createdAt"] != null
            ? DateTime.tryParse(json["createdAt"]) ?? DateTime.now()
            : DateTime.now(),
        updatedAt: json["updatedAt"] != null
            ? DateTime.tryParse(json["updatedAt"]) ?? DateTime.now()
            : DateTime.now(),
        docId: json["id"] ?? '',
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "status": status,
    "isDeleted": isDeleted,
    "deletedBy": deletedBy,
    "createdBy": createdBy.toJson(),
    "updatedBy": updatedBy?.toJson(),
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "id": docId,
  };
}

class GetAllCategoryAtedBy {
  String id;
  String name;
  String profilepic;

  GetAllCategoryAtedBy({
    required this.id,
    required this.name,
    required this.profilepic,
  });

  factory GetAllCategoryAtedBy.fromJson(Map<String, dynamic> json) =>
      GetAllCategoryAtedBy(
        id: json["_id"] ?? '',
        name: json["name"] ?? '',
        profilepic: json["profilepic"] ?? '',
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "profilepic": profilepic,
  };
}
