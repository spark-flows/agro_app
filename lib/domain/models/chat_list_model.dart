import 'dart:convert';

ChatListModel chatListModelFromJson(String str) =>
    ChatListModel.fromJson(json.decode(str));

class ChatListModel {
  String? message;
  ChatListData? data;
  int? status;
  bool? isSuccess;

  ChatListModel({this.message, this.data, this.status, this.isSuccess});

  factory ChatListModel.fromJson(Map<String, dynamic> json) => ChatListModel(
    message: json["Message"],
    data: (json["Data"] == null || json["Data"] is! Map)
        ? null
        : ChatListData.fromJson(json["Data"]),
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

class ChatListData {
  List<ChatListDoc>? docs;
  int? totalUnseenCount;
  int? totalDocs;
  int? limit;
  int? totalPages;
  int? page;
  int? pagingCounter;
  bool? hasPrevPage;
  bool? hasNextPage;
  dynamic prevPage;
  dynamic nextPage;

  ChatListData({
    this.docs,
    this.totalUnseenCount,
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

  factory ChatListData.fromJson(Map<String, dynamic> json) => ChatListData(
    docs: json["docs"] == null
        ? []
        : List<ChatListDoc>.from(
            json["docs"]!.map((x) => ChatListDoc.fromJson(x)),
          ),
    totalUnseenCount: json["totalUnseenCount"],
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
    "totalUnseenCount": totalUnseenCount,
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

class ChatListDoc {
  ChatPartner? chatPartner;
  UserDetail? userDetail;
  int? unseenMessagesCount;

  ChatListDoc({this.chatPartner, this.userDetail, this.unseenMessagesCount});

  factory ChatListDoc.fromJson(Map<String, dynamic> json) => ChatListDoc(
    chatPartner: json["chatPartner"] == null
        ? null
        : ChatPartner.fromJson(json["chatPartner"]),
    userDetail: json["userDetail"] == null
        ? null
        : UserDetail.fromJson(json["userDetail"]),
    unseenMessagesCount: json["unseenMessagesCount"],
  );

  Map<String, dynamic> toJson() => {
    "chatPartner": chatPartner?.toJson(),
    "userDetail": userDetail?.toJson(),
    "unseenMessagesCount": unseenMessagesCount,
  };
}

class ChatPartner {
  String? peerid;
  bool? isGroup;
  String? lastmessage;
  String? timestamp;
  String? id;
  String? groupName;
  String? groupimage;
  LastMessageObj? lastMessageObj;

  ChatPartner({
    this.peerid,
    this.isGroup,
    this.lastmessage,
    this.timestamp,
    this.id,
    this.groupName,
    this.groupimage,
    this.lastMessageObj,
  });

  factory ChatPartner.fromJson(Map<String, dynamic> json) => ChatPartner(
    peerid: json["peerid"],
    isGroup: json["isGroup"],
    lastmessage: json["lastmessage"],
    timestamp: json["timestamp"],
    id: json["_id"],
    groupName: json["groupname"],
    groupimage: json["groupimage"],
    lastMessageObj: json["lastMessageObj"] == null
        ? null
        : LastMessageObj.fromJson(json["lastMessageObj"]),
  );

  Map<String, dynamic> toJson() => {
    "peerid": peerid,
    "isGroup": isGroup,
    "lastmessage": lastmessage,
    "timestamp": timestamp,
    "_id": id,
    "groupname": groupName,
    "groupimage": groupimage,
    "lastMessageObj": lastMessageObj?.toJson(),
  };
}

class LastMessageObj {
  String? senderid;
  String? receiverid;
  String? message;
  List<dynamic>? fileurl;
  List<dynamic>? producturl;
  List<String>? seenBy;
  List<dynamic>? deliveredTo;
  String? status;
  String? type;
  DateTime? timestamp;
  String? id;
  String? msgId;

  LastMessageObj({
    this.senderid,
    this.receiverid,
    this.message,
    this.fileurl,
    this.producturl,
    this.seenBy,
    this.deliveredTo,
    this.status,
    this.type,
    this.timestamp,
    this.id,
    this.msgId,
  });

  LastMessageObj copyWith({
    String? senderid,
    String? receiverid,
    String? message,
    List<dynamic>? fileurl,
    List<dynamic>? producturl,
    List<String>? seenBy,
    List<dynamic>? deliveredTo,
    String? status,
    String? type,
    DateTime? timestamp,
    String? id,
    String? msgId,
  }) => LastMessageObj(
    senderid: senderid ?? this.senderid,
    receiverid: receiverid ?? this.receiverid,
    message: message ?? this.message,
    fileurl: fileurl ?? this.fileurl,
    producturl: producturl ?? this.producturl,
    seenBy: seenBy ?? this.seenBy,
    deliveredTo: deliveredTo ?? this.deliveredTo,
    status: status ?? this.status,
    type: type ?? this.type,
    timestamp: timestamp ?? this.timestamp,
    id: id ?? this.id,
    msgId: msgId ?? this.msgId,
  );

  factory LastMessageObj.fromJson(Map<String, dynamic> json) => LastMessageObj(
    senderid: json["senderid"],
    receiverid: json["receiverid"],
    message: json["message"],
    fileurl: json["fileurl"] == null
        ? []
        : List<dynamic>.from(json["fileurl"]!.map((x) => x)),
    producturl: json["producturl"] == null
        ? []
        : List<dynamic>.from(json["producturl"]!.map((x) => x)),
    seenBy: json["seenBy"] == null
        ? []
        : List<String>.from(json["seenBy"]!.map((x) => x)),
    deliveredTo: json["deliveredTo"] == null
        ? []
        : List<dynamic>.from(json["deliveredTo"]!.map((x) => x)),
    status: json["status"],
    type: json["type"],
    timestamp: json["timestamp"] == null
        ? null
        : DateTime.parse(json["timestamp"]),
    id: json["_id"],
    msgId: json["msgId"],
  );

  Map<String, dynamic> toJson() => {
    "senderid": senderid,
    "receiverid": receiverid,
    "message": message,
    "fileurl": fileurl == null
        ? []
        : List<dynamic>.from(fileurl!.map((x) => x)),
    "producturl": producturl == null
        ? []
        : List<dynamic>.from(producturl!.map((x) => x)),
    "seenBy": seenBy == null ? [] : List<dynamic>.from(seenBy!.map((x) => x)),
    "deliveredTo": deliveredTo == null
        ? []
        : List<dynamic>.from(deliveredTo!.map((x) => x)),
    "status": status,
    "type": type,
    "timestamp": timestamp?.toIso8601String(),
    "_id": id,
    "msgId": msgId,
  };
}

class UserDetail {
  String? id;
  String? name;
  String? email;
  String? phonenumber;
  String? profile;
  List<dynamic>? blockedusers;
  String? fcmToken;
  bool? isActive;
  dynamic lastSeen;
  bool? isOnline;
  dynamic pswdResetAt;
  String? channelid;
  String? createdAt;
  String? updatedAt;
  int? v;
  String? updatedBy;

  UserDetail({
    this.id,
    this.name,
    this.email,
    this.phonenumber,
    this.profile,
    this.blockedusers,
    this.fcmToken,
    this.isActive,
    this.isOnline,
    this.lastSeen,
    this.pswdResetAt,
    this.channelid,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.updatedBy,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) => UserDetail(
    id: json["_id"],
    name: json["name"],
    email: json["email"],
    phonenumber: json["phonenumber"],
    profile: json["profile"],
    blockedusers: json["blockedusers"] == null
        ? []
        : List<dynamic>.from(json["blockedusers"]!.map((x) => x)),
    fcmToken: json["fcm_token"],
    isActive: json["isActive"],
    isOnline: json["isOnline"],
    lastSeen: json["lastSeen"],
    pswdResetAt: json["pswd_reset_at"],
    channelid: json["channelid"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    v: json["__v"],
    updatedBy: json["updatedBy"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "email": email,
    "phonenumber": phonenumber,
    "profile": profile,
    "blockedusers": blockedusers == null
        ? []
        : List<dynamic>.from(blockedusers!.map((x) => x)),
    "fcm_token": fcmToken,
    "isActive": isActive,
    "isOnline": isOnline,
    "lastSeen": lastSeen,
    "pswd_reset_at": pswdResetAt,
    "channelid": channelid,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "__v": v,
    "updatedBy": updatedBy,
  };
}
