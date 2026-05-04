// To parse this JSON data, do
//
//     final sendMessageModel = sendMessageModelFromJson(jsonString);

import 'dart:convert';

SendMessageModel sendMessageModelFromJson(String str) =>
    SendMessageModel.fromJson(json.decode(str));

String sendMessageModelToJson(SendMessageModel data) =>
    json.encode(data.toJson());

class SendMessageModel {
  String? message;
  SendMessageData? data;
  int? status;
  bool? isSuccess;

  SendMessageModel({this.message, this.data, this.status, this.isSuccess});

  SendMessageModel copyWith({
    String? message,
    SendMessageData? data,
    int? status,
    bool? isSuccess,
  }) => SendMessageModel(
    message: message ?? this.message,
    data: data ?? this.data,
    status: status ?? this.status,
    isSuccess: isSuccess ?? this.isSuccess,
  );

  factory SendMessageModel.fromJson(Map<String, dynamic> json) =>
      SendMessageModel(
        message: json["Message"],
        data: json["Data"] == null
            ? null
            : SendMessageData.fromJson(json["Data"]),
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

class SendMessageData {
  String? senderid;
  String? receiverid;
  String? message;
  List<SendMessageFileurl>? fileurl;
  List<dynamic>? producturl;
  List<String>? seenBy;
  List<dynamic>? deliveredTo;
  String? status;
  DateTime? timestamp;

  SendMessageData({
    this.senderid,
    this.receiverid,
    this.message,
    this.fileurl,
    this.producturl,
    this.seenBy,
    this.deliveredTo,
    this.status,
    this.timestamp,
  });

  SendMessageData copyWith({
    String? senderid,
    String? receiverid,
    String? message,
    List<SendMessageFileurl>? fileurl,
    List<dynamic>? producturl,
    List<String>? seenBy,
    List<dynamic>? deliveredTo,
    String? status,
    DateTime? timestamp,
  }) => SendMessageData(
    senderid: senderid ?? this.senderid,
    receiverid: receiverid ?? this.receiverid,
    message: message ?? this.message,
    fileurl: fileurl ?? this.fileurl,
    producturl: producturl ?? this.producturl,
    seenBy: seenBy ?? this.seenBy,
    deliveredTo: deliveredTo ?? this.deliveredTo,
    status: status ?? this.status,
    timestamp: timestamp ?? this.timestamp,
  );

  factory SendMessageData.fromJson(Map<String, dynamic> json) =>
      SendMessageData(
        senderid: json["senderid"],
        receiverid: json["receiverid"],
        message: json["message"],
        fileurl: json["fileurl"] == null
            ? []
            : List<SendMessageFileurl>.from(
                json["fileurl"]!.map((x) => SendMessageFileurl.fromJson(x)),
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
        timestamp: json["timestamp"] == null
            ? null
            : DateTime.parse(json["timestamp"]),
      );

  Map<String, dynamic> toJson() => {
    "senderid": senderid,
    "receiverid": receiverid,
    "message": message,
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
    "timestamp": timestamp?.toIso8601String(),
  };
}

class SendMessageFileurl {
  String? url;

  SendMessageFileurl({this.url});

  SendMessageFileurl copyWith({String? url}) =>
      SendMessageFileurl(url: url ?? this.url);

  factory SendMessageFileurl.fromJson(Map<String, dynamic> json) =>
      SendMessageFileurl(url: json["url"]);

  Map<String, dynamic> toJson() => {"url": url};
}
