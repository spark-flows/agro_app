import 'dart:convert';

GetLedgerEntriesModel getLedgerEntriesModelFromJson(String str) =>
    GetLedgerEntriesModel.fromJson(json.decode(str));

String getLedgerEntriesModelToJson(GetLedgerEntriesModel data) =>
    json.encode(data.toJson());

class GetLedgerEntriesModel {
  String? message;
  LedgerEntriesData? data;
  int? status;
  bool? isSuccess;

  GetLedgerEntriesModel({this.message, this.data, this.status, this.isSuccess});

  factory GetLedgerEntriesModel.fromJson(Map<String, dynamic> json) =>
      GetLedgerEntriesModel(
        message: json["Message"] ?? json["message"],
        data: (json["Data"] ?? json["data"]) == null
            ? null
            : LedgerEntriesData.fromJson(json["Data"] ?? json["data"]),
        status: json["Status"] ?? json["status"],
        isSuccess: json["IsSuccess"] ?? json["isSuccess"] ?? json["issuccess"],
      );

  Map<String, dynamic> toJson() => {
        "Message": message,
        "Data": data?.toJson(),
        "Status": status,
        "IsSuccess": isSuccess,
      };
}

class LedgerEntriesData {
  List<LedgerEntryDoc>? docs;
  int? totalDocs;
  int? limit;
  int? totalPages;
  int? page;
  int? pagingCounter;
  bool? hasPrevPage;
  bool? hasNextPage;
  dynamic closingBalance;

  LedgerEntriesData({
    this.docs,
    this.totalDocs,
    this.limit,
    this.totalPages,
    this.page,
    this.pagingCounter,
    this.hasPrevPage,
    this.hasNextPage,
    this.closingBalance,
  });

  factory LedgerEntriesData.fromJson(Map<String, dynamic> json) =>
      LedgerEntriesData(
        docs: json["docs"] == null
            ? []
            : List<LedgerEntryDoc>.from(
                json["docs"]!.map((x) => LedgerEntryDoc.fromJson(x)),
              ),
        totalDocs: json["totalDocs"],
        limit: json["limit"],
        totalPages: json["totalPages"],
        page: json["page"],
        pagingCounter: json["pagingCounter"],
        hasPrevPage: json["hasPrevPage"],
        hasNextPage: json["hasNextPage"],
        closingBalance: json["closingBalance"],
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
        "closingBalance": closingBalance,
      };
}

class LedgerEntryDoc {
  String? id;
  String? ledgerName;
  String? particular;
  String? particulars;
  String? vouchertype;
  String? voucherno;
  dynamic debit;
  dynamic credit;
  dynamic balance;
  String? date;
  String? dateString;
  dynamic branchid;
  bool? isDeleted;
  String? createdAt;
  String? updatedAt;
  List<LedgerEntryItem>? items;
  Map<String, dynamic>? rawJson;

  LedgerEntryDoc({
    this.id,
    this.ledgerName,
    this.particular,
    this.particulars,
    this.vouchertype,
    this.voucherno,
    this.debit,
    this.credit,
    this.balance,
    this.date,
    this.dateString,
    this.branchid,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.items,
    this.rawJson,
  });

  factory LedgerEntryDoc.fromJson(Map<String, dynamic> json) => LedgerEntryDoc(
        id: json["_id"]?.toString() ?? json["id"]?.toString(),
        ledgerName: json["ledgerName"]?.toString() ?? json["ledgername"]?.toString(),
        particular: json["particular"]?.toString() ?? json["narration"]?.toString() ?? json["description"]?.toString(),
        particulars: json["particulars"]?.toString() ?? json["particular"]?.toString() ?? json["narration"]?.toString(),
        vouchertype: json["vouchertype"]?.toString() ?? json["voucherType"]?.toString() ?? json["type"]?.toString(),
        voucherno: json["voucherno"]?.toString() ?? json["voucherNo"]?.toString() ?? json["reference"]?.toString(),
        debit: json["debit"] ?? json["debitAmount"] ?? 0,
        credit: json["credit"] ?? json["creditAmount"] ?? 0,
        balance: json["balance"] ?? json["balanceAmount"] ?? 0,
        date: json["date"]?.toString() ?? json["createdAt"]?.toString(),
        dateString: json["dateString"]?.toString() ?? json["date_string"]?.toString(),
        branchid: json["branchid"],
        isDeleted: json["isDeleted"],
        createdAt: json["createdAt"]?.toString(),
        updatedAt: json["updatedAt"]?.toString(),
        items: json["items"] == null
            ? []
            : List<LedgerEntryItem>.from(
                json["items"]!.map((x) => LedgerEntryItem.fromJson(x)),
              ),
        rawJson: json,
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "ledgerName": ledgerName,
        "particular": particular,
        "particulars": particulars,
        "vouchertype": vouchertype,
        "voucherno": voucherno,
        "debit": debit,
        "credit": credit,
        "balance": balance,
        "date": date,
        "dateString": dateString,
        "branchid": branchid,
        "isDeleted": isDeleted,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
      };
}

class LedgerEntryItem {
  String? productName;
  dynamic quantity;
  dynamic rate;
  dynamic amount;
  String? id;

  LedgerEntryItem({
    this.productName,
    this.quantity,
    this.rate,
    this.amount,
    this.id,
  });

  factory LedgerEntryItem.fromJson(Map<String, dynamic> json) =>
      LedgerEntryItem(
        productName: json["productName"]?.toString() ?? json["productname"]?.toString() ?? json["name"]?.toString(),
        quantity: json["quantity"] ?? json["qty"] ?? 0,
        rate: json["rate"] ?? json["price"] ?? 0,
        amount: json["amount"] ?? 0,
        id: json["_id"]?.toString() ?? json["id"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "productName": productName,
        "quantity": quantity,
        "rate": rate,
        "amount": amount,
        "_id": id,
      };
}
