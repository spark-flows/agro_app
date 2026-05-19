class CustomerOrderListResponse {
  String? message;
  int? status;
  bool? isSuccess;
  CustomerOrderListData? data;

  CustomerOrderListResponse({
    this.message,
    this.status,
    this.isSuccess,
    this.data,
  });

  CustomerOrderListResponse.fromJson(Map<String, dynamic> json) {
    message = json['Message'] ?? json['message'];
    status = json['Status'] ?? json['status'];
    isSuccess = json['IsSuccess'] ?? json['isSuccess'] ?? json['issuccess'];

    data = (json['Data'] ?? json['data']) != null
        ? CustomerOrderListData.fromJson(json['Data'] ?? json['data'])
        : null;
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

  CustomerOrderListData({
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
  String? orderno;

  /// Sometimes String, Sometimes Object
  dynamic distributorid;

  /// Sometimes String, Sometimes Object
  dynamic customerid;

  String? image;
  String? remark1;
  String? remark2;
  String? remark3;

  String? status;

  bool? isDeleted;

  String? deletedBy;
  String? createdBy;
  String? updatedBy;

  String? createdAt;
  String? updatedAt;

  int? v;

  CustomerOrderDoc({
    this.id,
    this.customerorderid,
    this.orderno,
    this.distributorid,
    this.customerid,
    this.image,
    this.remark1,
    this.remark2,
    this.remark3,
    this.status,
    this.isDeleted,
    this.deletedBy,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  CustomerOrderDoc.fromJson(Map<String, dynamic> json) {
    id = json['_id']?.toString();
    customerorderid = json['customerorderid']?.toString();
    orderno = json['orderno']?.toString();
    distributorid = json['distributorid'];

    /// Handle both Object and String
    if (json['customerid'] is Map<String, dynamic>) {
      customerid = CustomerIdModel.fromJson(json['customerid']);
    } else {
      customerid = json['customerid']?.toString();
    }
    image = json['image']?.toString();
    remark1 = json['remark1']?.toString();
    remark2 = json['remark2']?.toString();
    remark3 = json['remark3']?.toString();
    status = json['status']?.toString();
    isDeleted = json['isDeleted'];
    deletedBy = json['deletedBy']?.toString();
    createdBy = json['createdBy']?.toString();
    updatedBy = json['updatedBy']?.toString();
    createdAt = json['createdAt']?.toString();
    updatedAt = json['updatedAt']?.toString();
    v = json['__v'];
  }
}

class CustomerOrderCreateResponse {
  String? message;
  int? status;
  bool? isSuccess;
  CustomerOrderDoc? data;

  CustomerOrderCreateResponse({
    this.message,
    this.status,
    this.isSuccess,
    this.data,
  });

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

  UploadImageResponse({this.message, this.status, this.isSuccess, this.data});

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

  UploadImageData({this.url});

  UploadImageData.fromJson(Map<String, dynamic> json) {
    url = json['url']?.toString() ?? json['image']?.toString();
  }
}

class CustomerIdModel {
  String? id;
  String? name;

  CustomerIdModel({this.id, this.name});

  CustomerIdModel.fromJson(Map<String, dynamic> json) {
    id = json['_id']?.toString();

    name = json['name']?.toString();
  }
}
