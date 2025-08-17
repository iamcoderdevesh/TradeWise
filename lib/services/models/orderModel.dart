import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  String? key;
  String? orderId;
  String? tradeId;
  String accountId;
  String userId;
  String assetName;
  String orderPrice;
  String orderAction;
  String orderType;
  String orderStatus;
  String orderQuantity;
  String ltp;
  String? stopLossPrice;
  String? targetPrice;
  String createdBy;
  String updatedBy;
  Timestamp createdOn;
  Timestamp updatedOn;

  OrderModel({
    this.key,
    required this.orderId,
    required this.tradeId,
    required this.accountId,
    required this.userId,
    required this.assetName,
    required this.orderPrice,
    required this.orderAction,
    required this.orderType,
    required this.orderStatus,
    required this.orderQuantity,
    required this.stopLossPrice,
    required this.targetPrice,
    required this.ltp,
    required this.createdBy,
    required this.updatedBy,
    required this.createdOn,
    required this.updatedOn,
  });

  factory OrderModel.fromJson(Map<dynamic, dynamic> json) => OrderModel(
        key: json["orderId"],
        orderId: json["orderId"],
        tradeId: json["tradeId"],
        accountId: json["accountId"],
        userId: json["userId"],
        assetName: json["assetName"],
        orderPrice: json["orderPrice"],
        orderAction: json["orderAction"],
        orderType: json["orderType"],
        orderStatus: json["orderStatus"],
        orderQuantity: json["orderQuantity"],
        stopLossPrice: json["stopLossPrice"],
        targetPrice: json["targetPrice"],
        ltp: json["ltp"],
        createdBy: json["createdBy"],
        updatedBy: json["updatedBy"],
        createdOn: json["createdOn"],
        updatedOn: json["updatedOn"],
      );

  Map<String, dynamic> toJson() => {
        "key": orderId,
        "orderId": orderId,
        "tradeId": tradeId,
        "accountId": accountId,
        "userId": userId,
        "assetName": assetName,
        "orderPrice": orderPrice,
        "orderAction": orderAction,
        "orderType": orderType,
        "orderStatus": orderStatus,
        "orderQuantity": orderQuantity,
        "stopLossPrice": stopLossPrice,
        "targetPrice": targetPrice,
        "ltp": ltp,
        "createdBy": createdBy,
        "updatedBy": updatedBy,
        "createdOn": createdOn,
        "updatedOn": updatedOn,
      };
}
