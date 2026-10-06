// To parse this JSON data, do
//
//     final notificationModel = notificationModelFromJson(jsonString);

import 'dart:convert';

NotificationModel notificationModelFromJson(String str) {
  final decoded = json.decode(str);
  return NotificationModel.fromJson(
    decoded is Map<String, dynamic> ? decoded : {},
  );
}

String notificationModelToJson(NotificationModel data) =>
    json.encode(data.toJson());

class NotificationModel {
  String? message;
  NotificationData? data;
  int? status;
  bool? isSuccess;

  NotificationModel({this.message, this.data, this.status, this.isSuccess});

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        message: json["Message"] ?? json["message"],
        data: (json["Data"] == null && json["data"] == null)
            ? null
            : NotificationData.fromJson(json["Data"] ?? json["data"]),
        status: json["Status"] ?? json["status"],
        isSuccess: json["IsSuccess"] ?? json["isSuccess"],
      );

  Map<String, dynamic> toJson() => {
    "Message": message,
    "Data": data?.toJson(),
    "Status": status,
    "IsSuccess": isSuccess,
  };
}

class NotificationData {
  List<NotificationDoc>? docs;
  int? totalDocs;
  int? limit;
  int? totalPages;
  int? page;
  int? unreadCount;
  bool? isAdmin;
  int? pagingCounter;
  bool? hasPrevPage;
  bool? hasNextPage;
  dynamic prevPage;
  dynamic nextPage;

  NotificationData({
    this.docs,
    this.totalDocs,
    this.limit,
    this.totalPages,
    this.page,
    this.unreadCount,
    this.isAdmin,
    this.pagingCounter,
    this.hasPrevPage,
    this.hasNextPage,
    this.prevPage,
    this.nextPage,
  });

  factory NotificationData.fromJson(dynamic json) {
    if (json is List) {
      return NotificationData(
        docs: List<NotificationDoc>.from(
          json.map((x) => NotificationDoc.fromJson(x)),
        ),
      );
    }
    if (json is Map<String, dynamic>) {
      final dynamic rawDocs = json["docs"] ?? json["data"];
      return NotificationData(
        docs: rawDocs == null
            ? []
            : (rawDocs is List
                  ? List<NotificationDoc>.from(
                      rawDocs.map((x) => NotificationDoc.fromJson(x)),
                    )
                  : []),
        totalDocs: json["totalDocs"],
        limit: json["limit"],
        totalPages: json["totalPages"],
        page: json["page"],
        unreadCount: json["unreadCount"],
        isAdmin: json["isAdmin"],
        pagingCounter: json["pagingCounter"],
        hasPrevPage: json["hasPrevPage"],
        hasNextPage: json["hasNextPage"],
        prevPage: json["prevPage"],
        nextPage: json["nextPage"],
      );
    }
    return NotificationData();
  }

  Map<String, dynamic> toJson() => {
    "docs": docs == null
        ? []
        : List<dynamic>.from(docs!.map((x) => x.toJson())),
    "totalDocs": totalDocs,
    "limit": limit,
    "totalPages": totalPages,
    "page": page,
    "unreadCount": unreadCount,
    "isAdmin": isAdmin,
    "pagingCounter": pagingCounter,
    "hasPrevPage": hasPrevPage,
    "hasNextPage": hasNextPage,
    "prevPage": prevPage,
    "nextPage": nextPage,
  };
}

class NotificationDoc {
  String? id;
  dynamic recipientId;
  dynamic senderId;
  bool? forAdmin;
  String? title;
  String? body;
  String? type;
  String? entityId;
  NotificationPayload? data;
  bool? isRead;
  dynamic readAt;
  bool? isDeleted;
  dynamic createdBy;
  dynamic updatedBy;
  String? createdAt;
  String? updatedAt;
  int? v;

  NotificationDoc({
    this.id,
    this.recipientId,
    this.senderId,
    this.forAdmin,
    this.title,
    this.body,
    this.type,
    this.entityId,
    this.data,
    this.isRead,
    this.readAt,
    this.isDeleted,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory NotificationDoc.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      return NotificationDoc();
    }
    return NotificationDoc(
      id: (json["_id"] ?? json["id"])?.toString(),
      recipientId: json["recipientId"],
      senderId: json["senderId"],
      forAdmin: json["forAdmin"],
      title: json["title"],
      body: json["body"],
      type: json["type"],
      entityId: json["entityId"]?.toString(),
      data: json["data"] == null
          ? null
          : NotificationPayload.fromJson(json["data"]),
      isRead: json["isRead"] ?? false,
      readAt: json["readAt"],
      isDeleted: json["isDeleted"] ?? false,
      createdBy: json["createdBy"],
      updatedBy: json["updatedBy"],
      createdAt: json["createdAt"]?.toString(),
      updatedAt: json["updatedAt"]?.toString(),
      v: json["__v"],
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "recipientId": recipientId is Map
        ? recipientId
        : (recipientId?.toString() ?? ""),
    "senderId": senderId is Map ? senderId : (senderId?.toString() ?? ""),
    "forAdmin": forAdmin,
    "title": title,
    "body": body,
    "type": type,
    "entityId": entityId,
    "data": data?.toJson(),
    "isRead": isRead,
    "readAt": readAt,
    "isDeleted": isDeleted,
    "createdBy": createdBy is Map ? createdBy : (createdBy?.toString() ?? ""),
    "updatedBy": updatedBy is Map ? updatedBy : (updatedBy?.toString() ?? ""),
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "__v": v,
  };

  String get recipientIdString {
    if (recipientId is String) return recipientId as String;
    if (recipientId is Map) {
      return (recipientId["_id"] ?? recipientId["id"] ?? "").toString();
    }
    return recipientId?.toString() ?? "";
  }

  String get senderIdString {
    if (senderId is String) return senderId as String;
    if (senderId is Map) {
      return (senderId["_id"] ?? senderId["id"] ?? "").toString();
    }
    return senderId?.toString() ?? "";
  }

  String get senderName {
    if (senderId is Map) {
      return (senderId["name"] ??
              senderId["userName"] ??
              senderId["email"] ??
              "")
          .toString();
    }
    return "";
  }
}

class NotificationPayload {
  String? taskid;
  String? orderid;
  String? customerid;
  String? entityid;
  Map<String, dynamic>? rawData;

  NotificationPayload({
    this.taskid,
    this.orderid,
    this.customerid,
    this.entityid,
    this.rawData,
  });

  factory NotificationPayload.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return NotificationPayload(
        taskid: (json["taskid"] ?? json["taskId"])?.toString(),
        orderid: (json["orderid"] ?? json["orderId"])?.toString(),
        customerid: (json["customerid"] ?? json["customerId"])?.toString(),
        entityid: (json["entityid"] ?? json["entityId"])?.toString(),
        rawData: Map<String, dynamic>.from(json),
      );
    }
    return NotificationPayload();
  }

  Map<String, dynamic> toJson() {
    if (rawData != null && rawData!.isNotEmpty) {
      return rawData!;
    }
    return {
      if (taskid != null) "taskid": taskid,
      if (orderid != null) "orderid": orderid,
      if (customerid != null) "customerid": customerid,
      if (entityid != null) "entityid": entityid,
    };
  }

  dynamic operator [](String key) => rawData?[key];
}
