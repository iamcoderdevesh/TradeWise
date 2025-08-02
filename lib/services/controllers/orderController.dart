import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tradewise/services/controllers/tradeController.dart';
import 'package:tradewise/services/models/OrderModel.dart';
import 'package:tradewise/state/accountState.dart';
import 'package:tradewise/state/authState.dart';

class OrderController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'orderDetails';

  // Create Account
  Future<Map<String, dynamic>> createOrder({
    required BuildContext context,
    required String assetName,
    required String marketSegment,
    required String margin,
    required String totalFees,
    required String orderPrice,
    required String orderName,
    required String orderAction,
    required String orderType,
    required String orderStatus,
    required String orderQuantity,
    required String ltp,
  }) async {
    try {
      late AuthState state = Provider.of<AuthState>(context, listen: false);
      late AccountState accountState =
          Provider.of<AccountState>(context, listen: false);

      String userId = state.userId as String;
      String accountId = accountState.accountId as String;

      // Create a new account
      OrderModel order = OrderModel(
        key: null,
        orderId: null,
        tradeId: null,
        accountId: accountId,
        userId: userId,
        orderPrice: orderPrice,
        orderName: orderName,
        orderAction: orderAction,
        orderType: orderType,
        orderStatus: orderStatus,
        orderQuantity: orderQuantity,
        ltp: ltp,
        createdBy: userId,
        updatedBy: userId,
        createdOn: Timestamp.now(),
        updatedOn: Timestamp.now(),
      );

      DocumentReference docRef =
          await _db.collection(_collection).add(order.toJson());
      await docRef.update({"key": docRef.id, "orderId": docRef.id});

      if (orderType == 'MARKET') {
        final tradeController = TradeController();
        // ignore: use_build_context_synchronously
        final response = await tradeController.createTrade(
          context: context,
          action: orderAction,
          assetName: assetName,
          entryPrice: orderPrice,
          ltp: ltp,
          margin: margin,
          marketSegment: marketSegment,
          quantity: orderQuantity,
          totalFees: totalFees,
          tradeName: orderName, 
          status: orderStatus,
        );

        bool status = response["status"] as bool;
        if (status) {
          String tradeId = response["tradeId"] as String;
          await docRef.update({"tradeId": tradeId});
        }
      }

      return {"status": true};
    } catch (e) {
      print("Error creating account: $e");
    }

    return {"status": false};
  }
}
