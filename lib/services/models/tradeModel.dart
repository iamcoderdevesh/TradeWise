import 'package:cloud_firestore/cloud_firestore.dart';

class TradeModel {
  String? key;
  String? tradeId;
  String? accountId;
  String? userId;
  String? marketSegment;
  String? assetName;
  String? tradeName;
  String? status;
  String? quantity;
  String? margin;
  String? ltp;
  String? stopLossPrice;
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
    this.tradeName,
    this.status,
    this.quantity,
    this.margin,
    this.ltp,
    this.stopLossPrice,
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
      quantity: json["quantity"],
      entryPrice: json["entryPrice"],
    );
  }

  Map<String, dynamic> toJson() => {
    "key": tradeId,
    "tradeId": tradeId,
    "accountId": accountId,
    "userId": userId,
    "marketSegment": marketSegment,
    "assetName": assetName,
    "tradeName": tradeName,
    "status": status,
    "quantity": quantity,
    "margin": margin,
    "ltp": ltp,
    "stopLossPrice": stopLossPrice,
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
