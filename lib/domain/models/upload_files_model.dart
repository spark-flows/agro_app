// To parse this JSON data, do
//
//     final uploadFiles = uploadFilesFromJson(jsonString);

import 'dart:convert';

UploadFiles uploadFilesFromJson(String str) =>
    UploadFiles.fromJson(json.decode(str));

String uploadFilesToJson(UploadFiles data) => json.encode(data.toJson());

class UploadFiles {
  String? message;
  List<UploadFilesDatum>? data;
  int? status;
  bool? isSuccess;

  UploadFiles({this.message, this.data, this.status, this.isSuccess});

  factory UploadFiles.fromJson(Map<String, dynamic> json) => UploadFiles(
    message: json["Message"],
    data: json["Data"] == null
        ? []
        : List<UploadFilesDatum>.from(
            json["Data"]!.map((x) => UploadFilesDatum.fromJson(x)),
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

class UploadFilesDatum {
  String? url;

  UploadFilesDatum({this.url});

  factory UploadFilesDatum.fromJson(Map<String, dynamic> json) =>
      UploadFilesDatum(url: json["url"]);

  Map<String, dynamic> toJson() => {"url": url};
}
