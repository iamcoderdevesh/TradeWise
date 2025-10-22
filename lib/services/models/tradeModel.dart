import 'package:cloud_firestore/cloud_firestore.dart';

class TradeModel {
  String? key;
  String? tradeId;
  String? accountId;
  String? userId;
  String? marketSegment;
  String? assetName;
  String? identifier;
  String? status;
  String? quantity;
  String? leverage;
  String? ltp;
  String? entryPrice;
  String? exitPrice;
  Timestamp? entryDate;
  Timestamp? exitDate;
  String? action;
  String? totalFees;
  String? grossPnl;
  String? netPnl;
  String? createdBy;
  String? updatedBy;
  Timestamp? createdOn;
  Timestamp? updatedOn;

  TradeModel({
    this.key,
    this.tradeId,
    this.accountId,
    this.userId,
    this.marketSegment,
    this.assetName,
    this.identifier,
    this.status,
    this.quantity,
    this.leverage,
    this.ltp,
    this.entryPrice,
    this.exitPrice,
    this.entryDate,
    this.exitDate,
    this.action,
    this.totalFees,
    this.grossPnl,
    this.netPnl,
    this.createdBy,
    this.updatedBy,
    this.createdOn,
    this.updatedOn,
  });

  factory TradeModel.fromFirestore(Map<String, dynamic> json) {
    return TradeModel(
      key: json["tradeId"],
      tradeId: json["tradeId"],
      assetName: json["assetName"],
      identifier: json["identifier"],
      quantity: json["quantity"],
      entryPrice: json["entryPrice"],
      exitPrice: json["exitPrice"],
      action: json["action"],
      netPnl: json["netPnl"],
      marketSegment: json["marketSegment"],
      ltp: json["ltp"],
      userId: json["userId"],
    );
  }

  Map<String, dynamic> toJson() => {
    "key": tradeId,
    "tradeId": tradeId,
    "accountId": accountId,
    "userId": userId,
    "marketSegment": marketSegment,
    "assetName": assetName,
    "identifier": identifier,
    "status": status,
    "quantity": quantity,
    "leverage": leverage,
    "ltp": ltp,
    "entryPrice": entryPrice,
    "exitPrice": exitPrice,
    "entryDate": entryDate,
    "exitDate": exitDate,
    "action": action,
    "totalFees": totalFees,
    "grossPnl": grossPnl,
    "netPnl": netPnl,
    "createdBy": createdBy,
    "updatedBy": updatedBy,
    "createdOn": createdOn,
    "updatedOn": updatedOn,
  };
}
