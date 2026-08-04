import 'dart:convert';

GetAllExpensesModel getAllExpensesModelFromJson(String str) =>
    GetAllExpensesModel.fromJson(json.decode(str));

String getAllExpensesModelToJson(GetAllExpensesModel data) =>
    json.encode(data.toJson());

CreateExpenseModel createExpenseModelFromJson(String str) =>
    CreateExpenseModel.fromJson(json.decode(str));

String createExpenseModelToJson(CreateExpenseModel data) =>
    json.encode(data.toJson());

GetAllParticularsModel getAllParticularsModelFromJson(String str) =>
    GetAllParticularsModel.fromJson(json.decode(str));

String getAllParticularsModelToJson(GetAllParticularsModel data) =>
    json.encode(data.toJson());

CreateParticularModel createParticularModelFromJson(String str) =>
    CreateParticularModel.fromJson(json.decode(str));

String createParticularModelToJson(CreateParticularModel data) =>
    json.encode(data.toJson());


class GetAllExpensesModel {
  String? message;
  ExpenseData? data;
  int? status;
  bool? isSuccess;

  GetAllExpensesModel({this.message, this.data, this.status, this.isSuccess});

  factory GetAllExpensesModel.fromJson(Map<String, dynamic> json) =>
      GetAllExpensesModel(
        message: json["Message"],
        data: json["Data"] == null ? null : ExpenseData.fromJson(json["Data"]),
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

class ExpenseData {
  List<ExpenseDoc>? docs;
  int? totalDocs;
  int? limit;
  int? totalPages;
  int? page;
  int? pagingCounter;
  bool? hasPrevPage;
  bool? hasNextPage;
  dynamic prevPage;
  dynamic nextPage;

  ExpenseData({
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

  factory ExpenseData.fromJson(Map<String, dynamic> json) => ExpenseData(
    docs: json["docs"] == null
        ? []
        : List<ExpenseDoc>.from(
            json["docs"]!.map((x) => ExpenseDoc.fromJson(x)),
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

class ExpenseDoc {
  String? id;
  String? expenseid;
  String? date;
  ExpenseUser? userid;
  ParticularDoc? particularid;
  String? amount;
  String? image;
  String? remark;
  String? branchid;
  bool? isDeleted;
  String? createdAt;
  String? updatedAt;
  String? status;

  ExpenseDoc({
    this.id,
    this.expenseid,
    this.date,
    this.userid,
    this.particularid,
    this.amount,
    this.image,
    this.remark,
    this.branchid,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.status,
  });

  factory ExpenseDoc.fromJson(Map<String, dynamic> json) => ExpenseDoc(
    id: json["_id"],
    expenseid: json["expenseid"],
    date: json["date"],
    userid: json["userid"] == null
        ? null
        : json["userid"] is Map<String, dynamic>
        ? ExpenseUser.fromJson(json["userid"])
        : ExpenseUser(id: json["userid"].toString()),
    particularid: json["particularid"] == null
        ? null
        : json["particularid"] is Map<String, dynamic>
        ? ParticularDoc.fromJson(json["particularid"])
        : ParticularDoc(id: json["particularid"].toString()),
    amount: json["amount"]?.toString(),
    image: json["image"]?.toString(),
    remark: json["remark"],
    branchid: json["branchid"]?.toString() ?? json["branchId"]?.toString(),
    isDeleted: json["isDeleted"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    status: json["status"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "expenseid": expenseid,
    "date": date,
    "userid": userid?.toJson(),
    "particularid": particularid?.toJson(),
    "amount": amount,
    "image": image,
    "remark": remark,
    "branchid": branchid,
    "isDeleted": isDeleted,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "status": status,
  };
}

class ExpenseUser {
  String? id;
  String? name;
  String? mobile;
  String? email;
  String? role;

  ExpenseUser({this.id, this.name, this.mobile, this.email, this.role});

  factory ExpenseUser.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return ExpenseUser(
        id: json["_id"],
        name: json["name"],
        mobile: json["mobile"],
        email: json["email"],
        role: json["role"]?.toString() ?? json["rolename"]?.toString(),
      );
    } else if (json is String) {
      return ExpenseUser(id: json);
    }
    return ExpenseUser();
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "mobile": mobile,
    "email": email,
    "role": role,
  };
}

class ParticularDoc {
  String? id;
  String? name;

  ParticularDoc({this.id, this.name});

  factory ParticularDoc.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return ParticularDoc(
        id: json["_id"] ?? json["id"],
        name:
            json["name"] ?? json["particularname"] ?? json["particular"] ?? '',
      );
    } else if (json is String) {
      return ParticularDoc(id: json, name: '');
    }
    return ParticularDoc();
  }

  Map<String, dynamic> toJson() => {"_id": id, "name": name};
}

class CreateExpenseModel {
  String? message;
  ExpenseDoc? data;
  int? status;
  bool? isSuccess;

  CreateExpenseModel({this.message, this.data, this.status, this.isSuccess});

  factory CreateExpenseModel.fromJson(Map<String, dynamic> json) =>
      CreateExpenseModel(
        message: json["Message"],
        data: json["Data"] == null ? null : ExpenseDoc.fromJson(json["Data"]),
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

class GetAllParticularsModel {
  String? message;
  List<ParticularDoc>? data;
  int? status;
  bool? isSuccess;

  GetAllParticularsModel({
    this.message,
    this.data,
    this.status,
    this.isSuccess,
  });

  factory GetAllParticularsModel.fromJson(Map<String, dynamic> json) {
    final dataJson = json["Data"];
    List<ParticularDoc> particularsList = [];
    if (dataJson is List) {
      particularsList = List<ParticularDoc>.from(
        dataJson.map((x) => ParticularDoc.fromJson(x)),
      );
    } else if (dataJson is Map<String, dynamic> && dataJson["docs"] is List) {
      particularsList = List<ParticularDoc>.from(
        dataJson["docs"].map((x) => ParticularDoc.fromJson(x)),
      );
    }
    return GetAllParticularsModel(
      message: json["Message"],
      data: particularsList,
      status: json["Status"],
      isSuccess: json["IsSuccess"],
    );
  }

  Map<String, dynamic> toJson() => {
        "Message": message,
        "Data": data != null ? List<dynamic>.from(data!.map((x) => x.toJson())) : null,
        "Status": status,
        "IsSuccess": isSuccess,
      };
}

class CreateParticularModel {
  String? message;
  ParticularDoc? data;
  int? status;
  bool? isSuccess;

  CreateParticularModel({this.message, this.data, this.status, this.isSuccess});

  factory CreateParticularModel.fromJson(Map<String, dynamic> json) =>
      CreateParticularModel(
        message: json["Message"],
        data: json["Data"] == null ? null : ParticularDoc.fromJson(json["Data"]),
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
