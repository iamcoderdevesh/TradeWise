import 'package:cloud_firestore/cloud_firestore.dart';

class TradeModel {
  String? key;
  String? tradeId;
  String accountId;
  String userId;
  String marketSegment;
  String assetName;
  String tradeName;
  String quantity;
  String? margin;
  String ltp;
  String? stopLossPrice;
  String entryPrice;
  String? exitPrice;
  Timestamp entryDate;
  Timestamp? exitDate;
  String action;
  String totalFees;
  String? grossPnl;
  String? netPnl;
  String createdBy;
  String updatedBy;
  Timestamp createdOn;
  Timestamp updatedOn;

  TradeModel({
    this.key,
    this.tradeId,
    required this.accountId,
    required this.userId,
    required this.marketSegment,
    required this.assetName,
    required this.tradeName,
    required this.quantity,
    this.margin,
    required this.ltp,
    this.stopLossPrice,
    required this.entryPrice,
    this.exitPrice,
    required this.entryDate,
    this.exitDate,
    required this.action,
    required this.totalFees,
    this.grossPnl,
    this.netPnl,
    required this.createdBy,
    required this.updatedBy,
    required this.createdOn,
    required this.updatedOn,
  });

  factory TradeModel.fromJson(Map<dynamic, dynamic> json) => TradeModel(
        key: json["tradeId"],
        tradeId: json["tradeId"],
        accountId: json["accountId"],
        userId: json["userId"],
        marketSegment: json["marketSegment"],
        assetName: json["assetName"],
        tradeName: json["tradeName"],
        quantity: json["quantity"],
        margin: json["margin"],
        ltp: json["ltp"],
        stopLossPrice: json["stopLossPrice"],
        entryPrice: json["entryPrice"],
        exitPrice: json["exitPrice"],
        entryDate: json["entryDate"],
        exitDate: json["exitDate"],
        action: json["action"],
        totalFees: json["totalFees"],
        grossPnl: json["grossPnl"],
        netPnl: json["netPnl"],
        createdBy: json["createdBy"],
        updatedBy: json["updatedBy"],
        createdOn: json["createdOn"],
        updatedOn: json["updatedOn"],
      );

  Map<String, dynamic> toJson() => {
        "key": tradeId,
        "tradeId": tradeId,
        "accountId": accountId,
        "userId": userId,
        "marketSegment": marketSegment,
        "assetName": assetName,
        "tradeName": tradeName,
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
