import 'package:cloud_firestore/cloud_firestore.dart';

class AccountModel {

  String? key;
  String? accountId;
  String userId;
  String accountName;
  String accountType;
  String initialBalance;
  String totalBalance;
  String createdBy;
  String updatedBy;
  Timestamp createdOn;
  Timestamp updatedOn;

  AccountModel({
    this.key,
    required this.accountId,
    required this.userId,
    required this.accountName,
    required this.accountType,
    required this.initialBalance,
    required this.totalBalance,
    required this.createdBy,
    required this.updatedBy,
    required this.createdOn,
    required this.updatedOn,
  });

  factory AccountModel.fromJson(Map<dynamic, dynamic> json) => AccountModel(
        key: json["accountId"],
        accountId: json["accountId"],
        userId: json["userId"],
        accountName: json["accountName"],
        accountType: json["accountType"],
        initialBalance: json["initialBalance"],
        totalBalance: json["totalBalance"],
        createdBy: json["createdBy"],
        updatedBy: json["updatedBy"],
        createdOn: json["createdOn"],
        updatedOn: json["updatedOn"],
      );

  Map<String, dynamic> toJson() => {
        "key": key,
        "accountId": accountId,
        "userId": userId,
        "accountName": accountName,
        "accountType": accountType,
        "initialBalance": initialBalance,
        "totalBalance": totalBalance,
        "createdBy": createdBy,
        "updatedBy": updatedBy,
        "createdOn": createdOn,
        "updatedOn": updatedOn,
      };
}
