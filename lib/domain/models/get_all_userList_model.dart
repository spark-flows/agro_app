// To parse this JSON data, do
//
//     final userListModel = userListModelFromJson(jsonString);

import 'dart:convert';

UserListModel userListModelFromJson(String str) =>
    UserListModel.fromJson(json.decode(str));

String userListModelToJson(UserListModel data) => json.encode(data.toJson());

class UserListModel {
  String? message;
  UserListData? data;
  int? status;
  bool? isSuccess;

  UserListModel({this.message, this.data, this.status, this.isSuccess});

  UserListModel copyWith({
    String? message,
    UserListData? data,
    int? status,
    bool? isSuccess,
  }) => UserListModel(
    message: message ?? this.message,
    data: data ?? this.data,
    status: status ?? this.status,
    isSuccess: isSuccess ?? this.isSuccess,
  );

  factory UserListModel.fromJson(Map<String, dynamic> json) => UserListModel(
    message: json["Message"],
    data: (json["Data"] == null || json["Data"] is! Map)
        ? null
        : UserListData.fromJson(json["Data"]),
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

class UserListData {
  List<UserListDoc>? docs;
  int? totalDocs;
  int? limit;
  int? totalPages;
  int? page;
  int? pagingCounter;
  bool? hasPrevPage;
  bool? hasNextPage;
  dynamic prevPage;
  dynamic nextPage;

  UserListData({
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

  UserListData copyWith({
    List<UserListDoc>? docs,
    int? totalDocs,
    int? limit,
    int? totalPages,
    int? page,
    int? pagingCounter,
    bool? hasPrevPage,
    bool? hasNextPage,
    dynamic prevPage,
    dynamic nextPage,
  }) => UserListData(
    docs: docs ?? this.docs,
    totalDocs: totalDocs ?? this.totalDocs,
    limit: limit ?? this.limit,
    totalPages: totalPages ?? this.totalPages,
    page: page ?? this.page,
    pagingCounter: pagingCounter ?? this.pagingCounter,
    hasPrevPage: hasPrevPage ?? this.hasPrevPage,
    hasNextPage: hasNextPage ?? this.hasNextPage,
    prevPage: prevPage ?? this.prevPage,
    nextPage: nextPage ?? this.nextPage,
  );

  factory UserListData.fromJson(Map<String, dynamic> json) => UserListData(
    docs: json["docs"] == null
        ? []
        : List<UserListDoc>.from(
            json["docs"]!.map((x) => UserListDoc.fromJson(x)),
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

class UserListDoc {
  String? id;
  String? name;
  String? email;
  String? phonenumber;
  bool? isOnline;
  DateTime? lastSeen;
  String? docId;
  String? profile;

  UserListDoc({
    this.id,
    this.name,
    this.email,
    this.phonenumber,
    this.isOnline,
    this.lastSeen,
    this.docId,
    this.profile,
  });

  UserListDoc copyWith({
    String? id,
    String? name,
    String? email,
    String? phonenumber,
    bool? isOnline,
    DateTime? lastSeen,
    String? docId,
    String? profile,
  }) => UserListDoc(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    phonenumber: phonenumber ?? this.phonenumber,
    isOnline: isOnline ?? this.isOnline,
    lastSeen: lastSeen ?? this.lastSeen,
    docId: docId ?? this.docId,
    profile: profile ?? this.profile,
  );

  factory UserListDoc.fromJson(Map<String, dynamic> json) => UserListDoc(
    id: json["_id"],
    name: json["name"],
    email: json["email"],
    phonenumber: json["phonenumber"],
    isOnline: json["isOnline"],
    lastSeen: json["lastSeen"] == null
        ? null
        : DateTime.parse(json["lastSeen"]),
    docId: json["id"],
    profile: json["profile"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "email": email,
    "phonenumber": phonenumber,
    "isOnline": isOnline,
    "lastSeen": lastSeen?.toIso8601String(),
    "id": docId,
    "profile": profile,
  };
}
