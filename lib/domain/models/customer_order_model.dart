import 'dart:convert';

class CustomerOrderListResponse {
  String? message;
  int? status;
  bool? isSuccess;
  CustomerOrderListData? data;

  CustomerOrderListResponse.fromJson(Map<String, dynamic> json) {
    message = json['Message'] ?? json['message'];
    status = json['Status'] ?? json['status'];
    isSuccess = json['IsSuccess'] ?? json['isSuccess'] ?? json['issuccess'];
    data = (json['Data'] ?? json['data']) != null ? CustomerOrderListData.fromJson(json['Data'] ?? json['data']) : null;
  }
}

class CustomerOrderListData {
  List<CustomerOrderDoc>? docs;
  int? totalDocs;
  int? limit;
  int? totalPages;
  int? page;
  int? pagingCounter;
  bool? hasPrevPage;
  bool? hasNextPage;
  int? prevPage;
  int? nextPage;

  CustomerOrderListData.fromJson(Map<String, dynamic> json) {
    if (json['docs'] != null) {
      docs = <CustomerOrderDoc>[];
      json['docs'].forEach((v) {
        docs!.add(CustomerOrderDoc.fromJson(v));
      });
    }
    totalDocs = json['totalDocs'];
    limit = json['limit'];
    totalPages = json['totalPages'];
    page = json['page'];
    pagingCounter = json['pagingCounter'];
    hasPrevPage = json['hasPrevPage'];
    hasNextPage = json['hasNextPage'];
    prevPage = json['prevPage'];
    nextPage = json['nextPage'];
  }
}

class CustomerOrderDoc {
  String? id;
  String? customerorderid;
  dynamic distributorid;
  dynamic customerid;
  String? image;
  String? remark1;
  String? remark2;
  String? remark3;
  String? createdAt;

  CustomerOrderDoc.fromJson(Map<String, dynamic> json) {
    id = json['_id']?.toString();
    customerorderid = json['customerorderid']?.toString();
    distributorid = json['distributorid'];
    customerid = json['customerid'];
    image = json['image']?.toString();
    remark1 = json['remark1']?.toString();
    remark2 = json['remark2']?.toString();
    remark3 = json['remark3']?.toString();
    createdAt = json['createdAt']?.toString();
  }
}

class CustomerOrderCreateResponse {
  String? message;
  int? status;
  bool? isSuccess;
  CustomerOrderDoc? data;

  CustomerOrderCreateResponse.fromJson(Map<String, dynamic> json) {
    message = json['Message'] ?? json['message'];
    status = json['Status'] ?? json['status'];
    isSuccess = json['IsSuccess'] ?? json['isSuccess'] ?? json['issuccess'];
    var dataJson = json['Data'] ?? json['data'];
    data = dataJson != null ? CustomerOrderDoc.fromJson(dataJson) : null;
  }
}

class UploadImageResponse {
  String? message;
  int? status;
  bool? isSuccess;
  UploadImageData? data;

  UploadImageResponse.fromJson(Map<String, dynamic> json) {
    message = json['Message'] ?? json['message'];
    status = json['Status'] ?? json['status'];
    isSuccess = json['IsSuccess'] ?? json['isSuccess'] ?? json['issuccess'];
    var dataField = json['Data'] ?? json['data'];
    if (dataField != null) {
      if (dataField is String) {
        data = UploadImageData()..url = dataField;
      } else if (dataField is Map<String, dynamic>) {
        data = UploadImageData.fromJson(dataField);
      }
    }
  }
}

class UploadImageData {
  String? url;

  UploadImageData();

  UploadImageData.fromJson(Map<String, dynamic> json) {
    url = json['url']?.toString() ?? json['image']?.toString();
  }
}
