import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tradewise/helpers/helper.dart';
import 'package:tradewise/services/api/api.dart';
import 'package:tradewise/services/controllers/tradeController.dart';
import 'package:tradewise/services/models/OrderModel.dart';
import 'package:tradewise/state/accountState.dart';
import 'package:tradewise/state/authState.dart';
import 'package:tradewise/state/tradeState.dart';

class OrderController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'orderDetails';
  final tradeController = TradeController();
  late Helper helper = Helper();
  final ApiService apiService = ApiService();
  late Timer _timer;
  late bool isProcessing = false;

  // Create Order
  Future<Map<String, dynamic>> handleOrder({
    required BuildContext context,
    required String assetName,
    required String marketSegment,
    required String margin,
    required String orderPrice,
    required String orderAction,
    required String orderType,
    required String orderQuantity,
    required String ltp,
    String stopLossPrice = '',
    String targetPrice = '',
    String tradeId = '',
    String exitPrice = '',
  }) async {
    try {
      late AuthState state = Provider.of<AuthState>(context, listen: false);
      late AccountState accountState =
          Provider.of<AccountState>(context, listen: false);

      String userId = state.userId as String;
      String accountId = accountState.accountId as String;

      String orderStatus = orderType == "MARKET" ? "CLOSED" : "OPEN";
      String action = tradeId.isNotEmpty
          ? (orderAction == 'BUY' ? 'SELL' : 'BUY')
          : orderAction;

      // Create a new order
      OrderModel order = OrderModel(
        key: null,
        orderId: null,
        tradeId: null,
        accountId: accountId,
        userId: userId,
        orderPrice: orderPrice,
        assetName: assetName,
        orderAction: action,
        orderType: orderType,
        orderStatus: orderStatus,
        orderQuantity: orderQuantity,
        ltp: ltp,
        marketSegment: marketSegment,
        stopLossPrice: null,
        targetPrice: null,
        createdBy: userId,
        updatedBy: userId,
        createdOn: Timestamp.now(),
        updatedOn: Timestamp.now(),
      );

      DocumentReference docRef =
          await _db.collection(_collection).add(order.toJson());
      await docRef.update({"key": docRef.id, "orderId": docRef.id});

      if (tradeId.isNotEmpty) {
        await docRef.update({"tradeId": tradeId});
      }

      if (orderType == "MARKET") {
        String tradeStatus = tradeId.isEmpty ? "OPEN" : "CLOSED";

        // ignore: use_build_context_synchronously
        final response = await tradeController.handleTrade(
          context: context,
          action: action,
          assetName: assetName,
          entryPrice: orderPrice,
          ltp: ltp,
          margin: margin,
          marketSegment: marketSegment,
          quantity: orderQuantity,
          status: tradeStatus,
          exitPrice: exitPrice,
          tradeId: tradeId,
        );

        bool status = response["status"] as bool;
        if (status) {
          String tradeId = response["tradeId"] as String;
          await docRef.update({"tradeId": tradeId});
        }
      }

      return {
        "status": true,
        "message": tradeId.isNotEmpty && orderType == "MARKET"
            ? "Trade Exit Successfully."
            : "Order Placed Successfully."
      };
    } catch (e) {
      print("Error creating account: $e");
    }

    return {"status": false};
  }

  //SL & Target Order
  Future<Map<String, dynamic>> handleSLAndTargetOrders({
    required BuildContext context,
    required String assetName,
    required String marketSegment,
    required String margin,
    required String orderPrice,
    required String orderAction,
    required String orderType,
    required String orderQuantity,
    required String ltp,
    String stopLossPrice = '',
    String targetPrice = '',
    String tradeId = '',
  }) async {
    try {
      late AuthState state = Provider.of<AuthState>(context, listen: false);
      late AccountState accountState =
          Provider.of<AccountState>(context, listen: false);

      String userId = state.userId as String;
      String accountId = accountState.accountId as String;

      String action = (orderAction == 'BUY' ? 'SELL' : 'BUY');

      if (tradeId.isNotEmpty) {
        QuerySnapshot snapshot = await _db
            .collection(_collection)
            .where('tradeId', isEqualTo: tradeId)
            .where('orderStatus', isEqualTo: 'OPEN')
            .where('orderAction', isEqualTo: action)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          DocumentSnapshot doc = snapshot.docs.first;
          String orderId = doc['orderId'];

          await _db.collection(_collection).doc(orderId).update({
            stopLossPrice: stopLossPrice,
            targetPrice: targetPrice,
            "updatedBy": userId,
            "updatedOn": Timestamp.now(),
          });
        } else {
          // Create a new order
          OrderModel order = OrderModel(
            key: null,
            orderId: null,
            tradeId: null,
            accountId: accountId,
            userId: userId,
            orderPrice: orderPrice,
            assetName: assetName,
            orderAction: action,
            orderType: orderType,
            orderStatus: "OPEN",
            orderQuantity: orderQuantity,
            stopLossPrice: stopLossPrice,
            targetPrice: targetPrice,
            ltp: ltp,
            marketSegment: marketSegment,
            createdBy: userId,
            updatedBy: userId,
            createdOn: Timestamp.now(),
            updatedOn: Timestamp.now(),
          );

          DocumentReference docRef =
              await _db.collection(_collection).add(order.toJson());
          await docRef.update({"key": docRef.id, "orderId": docRef.id});

          if (tradeId.isNotEmpty) {
            await docRef.update({"tradeId": tradeId});
          }
        }
        // ignore: use_build_context_synchronously
        await handlePendingOrders(context: context);
      }

      return {"status": true, "message": "Saved."};
    } catch (e) {
      print("Error creating account: $e");
    }

    return {"status": false};
  }

  Future<void> handlePendingOrders({required BuildContext context}) async {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer t) async {
      if (!isProcessing) {
        try {
          isProcessing = true;
          late AuthState authState =
              Provider.of<AuthState>(context, listen: false);
          late AccountState accountState =
              Provider.of<AccountState>(context, listen: false);

          String userId = authState.userId as String;
          String accountId = accountState.accountId as String;

          QuerySnapshot snapshot = await _db
              .collection(_collection)
              .where('accountId', isEqualTo: accountId)
              .where('orderStatus', isEqualTo: 'OPEN')
              .where('orderType', isEqualTo: 'LIMIT')
              .get();

          if (snapshot.docs.isNotEmpty) {
            for (var doc in snapshot.docs) {
              final orderId = doc['orderId'];
              final assetName = doc['assetName'];
              final orderPrice = doc['orderPrice'];
              final orderQuantity = doc['orderQuantity'];
              final marketSegment = doc['marketSegment'];

              String action = doc['orderAction'];
              String tradeId = doc['tradeId'] ?? '';
              String stopLossPrice = doc['stopLossPrice'] ?? '';
              String targetPrice = doc['targetPrice'] ?? '';

              final currentTickerData = await apiService.getTickerPrice(assetName, marketSegment: marketSegment);
              final currentPrice = currentTickerData['assetPrice'];

              bool buyLimitCond = false;
              bool buySLCond = false;
              bool buyTargetCond = false;
              bool sellLimitCond = false;
              bool sellTargetCond = false;
              bool sellSLCond = false;

              if (tradeId.isNotEmpty) {
                action = action == "BUY" ? "SELL" : "BUY";

                buyTargetCond = targetPrice.isNotEmpty
                    ? (action == 'BUY' &&
                        double.parse(currentPrice) >= double.parse(targetPrice))
                    : false;
                sellTargetCond = targetPrice.isNotEmpty
                    ? (action == 'SELL' &&
                        double.parse(currentPrice) <= double.parse(targetPrice))
                    : false;

                buySLCond = stopLossPrice.isNotEmpty
                    ? (action == 'BUY' &&
                        double.parse(currentPrice) <=
                            double.parse(stopLossPrice))
                    : false;
                sellSLCond = stopLossPrice.isNotEmpty
                    ? (action == 'SELL' &&
                        double.parse(currentPrice) >=
                            double.parse(stopLossPrice))
                    : false;
              } else {
                buyLimitCond = (action == 'BUY' &&
                    double.parse(currentPrice) <= double.parse(orderPrice));
                sellLimitCond = (action == 'SELL' &&
                    double.parse(currentPrice) >= double.parse(orderPrice));
              }

              if (buyLimitCond || sellLimitCond || buyTargetCond || sellTargetCond || buySLCond || sellSLCond) {
                // ignore: use_build_context_synchronously
                final response = await tradeController.handleTrade(
                  context: context,
                  action: action,
                  assetName: assetName,
                  entryPrice: currentPrice,
                  ltp: currentPrice,
                  marketSegment: "Spot",
                  quantity: orderQuantity,
                  status: tradeId.isEmpty ? "OPEN" : "CLOSED",
                  margin: "",
                  exitPrice: currentPrice,
                  tradeId: tradeId,
                );

                bool status = response["status"] as bool;
                if (status) {
                  tradeId = response["tradeId"];
                  await _db.collection(_collection).doc(orderId).update({
                    "orderStatus": "CLOSED",
                    "updatedBy": userId,
                    "tradeId": tradeId,
                    "ltp": currentPrice,
                    "updatedOn": Timestamp.now(),
                  });

                  // ignore: use_build_context_synchronously
                  Provider.of<TradeState>(context, listen: false).initPosition();
                }
              }
            }
          } else {
            _timer.cancel();
          }

          isProcessing = false;
        } catch (e) {
          print("Error fetching account: $e");
        }
      }
    });
  }

  Future<List<Map<String, dynamic>>> getOrders(
      {required BuildContext context}) async {
    QuerySnapshot snapshot =
        await _db.collection(_collection).orderBy('createdOn').get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }
}
