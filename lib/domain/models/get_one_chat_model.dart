import 'dart:convert';

GetOneChatModel getOneChatModelFromJson(String str) =>
    GetOneChatModel.fromJson(json.decode(str));

String getOneChatModelToJson(GetOneChatModel data) =>
    json.encode(data.toJson());

class GetOneChatModel {
  String? message;
  GetOneChatData? data;
  int? status;
  bool? isSuccess;

  GetOneChatModel({this.message, this.data, this.status, this.isSuccess});

  factory GetOneChatModel.fromJson(Map<String, dynamic> json) =>
      GetOneChatModel(
        message: json["Message"],
        data: json["Data"] == null
            ? null
            : GetOneChatData.fromJson(json["Data"]),
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

class GetOneChatData {
  List<GetOneChatDoc>? docs;
  GetOneChatChatList? chatList;
  GetOneChatPeerUser? peerUser;
  dynamic groupMembers;
  int? totalDocs;
  int? limit;
  int? totalPages;
  int? page;
  int? pagingCounter;
  bool? hasPrevPage;
  bool? hasNextPage;
  dynamic prevPage;
  dynamic nextPage;

  GetOneChatData({
    this.docs,
    this.chatList,
    this.peerUser,
    this.groupMembers,
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

  factory GetOneChatData.fromJson(Map<String, dynamic> json) => GetOneChatData(
    docs: json["docs"] == null
        ? []
        : List<GetOneChatDoc>.from(
            json["docs"]!.map((x) => GetOneChatDoc.fromJson(x)),
          ),
    chatList: json["chatList"] == null
        ? null
        : GetOneChatChatList.fromJson(json["chatList"]),
    peerUser: json["peerUser"] == null
        ? null
        : GetOneChatPeerUser.fromJson(json["peerUser"]),
    groupMembers: json["groupMembers"],
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
    "chatList": chatList?.toJson(),
    "peerUser": peerUser?.toJson(),
    "groupMembers": groupMembers,
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

class GetOneChatChatList {
  String? id;
  bool? isGroup;
  dynamic groupname;
  List<dynamic>? groupadmins;
  dynamic groupimage;
  List<String>? participants;

  GetOneChatChatList({
    this.id,
    this.isGroup,
    this.groupname,
    this.groupadmins,
    this.groupimage,
    this.participants,
  });

  factory GetOneChatChatList.fromJson(Map<String, dynamic> json) =>
      GetOneChatChatList(
        id: json["_id"],
        isGroup: json["isGroup"],
        groupname: json["groupname"],
        groupadmins: json["groupadmins"] == null
            ? []
            : List<dynamic>.from(json["groupadmins"]!.map((x) => x)),
        groupimage: json["groupimage"],
        participants: json["participants"] == null
            ? []
            : List<String>.from(json["participants"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "isGroup": isGroup,
    "groupname": groupname,
    "groupadmins": groupadmins == null
        ? []
        : List<dynamic>.from(groupadmins!.map((x) => x)),
    "groupimage": groupimage,
    "participants": participants == null
        ? []
        : List<dynamic>.from(participants!.map((x) => x)),
  };
}

class GetOneChatDoc {
  String? senderid;
  String? receiverid;
  String? message;
  String? type;
  List<GetOneChatFileurl>? fileurl;
  List<dynamic>? producturl;
  List<String>? seenBy;
  List<dynamic>? deliveredTo;
  String? status;
  String? timestamp;
  String? id;

  GetOneChatDoc({
    this.senderid,
    this.receiverid,
    this.message,
    this.type,
    this.fileurl,
    this.producturl,
    this.seenBy,
    this.deliveredTo,
    this.status,
    this.timestamp,
    this.id,
  });

  factory GetOneChatDoc.fromJson(Map<String, dynamic> json) => GetOneChatDoc(
    senderid: json["senderid"],
    receiverid: json["receiverid"],
    message: json["message"],
    type: json["type"] ?? "",
    fileurl: json["fileurl"] == null
        ? []
        : List<GetOneChatFileurl>.from(
            json["fileurl"]!.map((x) => GetOneChatFileurl.fromJson(x)),
          ),
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
    timestamp: json["timestamp"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "senderid": senderid,
    "receiverid": receiverid,
    "message": message,
    "type": type,
    "fileurl": fileurl == null
        ? []
        : List<dynamic>.from(fileurl!.map((x) => x.toJson())),
    "producturl": producturl == null
        ? []
        : List<dynamic>.from(producturl!.map((x) => x)),
    "seenBy": seenBy == null ? [] : List<dynamic>.from(seenBy!.map((x) => x)),
    "deliveredTo": deliveredTo == null
        ? []
        : List<dynamic>.from(deliveredTo!.map((x) => x)),
    "status": status,
    "timestamp": timestamp,
    "_id": id,
  };
}

class GetOneChatFileurl {
  String? url;
  String? id;

  GetOneChatFileurl({this.url, this.id});

  GetOneChatFileurl copyWith({String? url, String? id}) =>
      GetOneChatFileurl(url: url ?? this.url, id: id ?? this.id);

  factory GetOneChatFileurl.fromJson(Map<String, dynamic> json) =>
      GetOneChatFileurl(url: json["url"], id: json["_id"]);

  Map<String, dynamic> toJson() => {"url": url, "_id": id};
}

class GetOneChatPeerUser {
  String? id;
  String? name;
  String? profile;

  GetOneChatPeerUser({this.id, this.name, this.profile});

  factory GetOneChatPeerUser.fromJson(Map<String, dynamic> json) =>
      GetOneChatPeerUser(
        id: json["_id"],
        name: json["name"],
        profile: json["profile"],
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "profile": profile,
  };
}
