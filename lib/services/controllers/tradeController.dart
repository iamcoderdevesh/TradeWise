import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tradewise/helpers/helper.dart';
import 'package:tradewise/services/models/tradeModel.dart';
import 'package:tradewise/state/accountState.dart';
import 'package:tradewise/state/authState.dart';

class TradeController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'tradeDetails';
  late Helper helper = Helper();

  // Create Trade
  Future<Map<String, dynamic>> handleTrade({
    required BuildContext context,
    String assetName = '',
    String identifier = '',
    String marketSegment = '',
    String status = '',
    String quantity = '',
    String leverage = '',
    String ltp = '',
    String entryPrice = '',
    String action = '',
    String tradeId = '',
    String exitPrice = '',
    String orderType = '',
  }) async {
    try {
      late AuthState state = Provider.of<AuthState>(context, listen: false);
      late AccountState accountState = Provider.of<AccountState>(context, listen: false);

      String userId = state.userId as String;
      String accountId = accountState.accountId as String;

      // Create a new trade
      if (tradeId.isEmpty) {

        final String tradeMargin = helper.calculateTradeMargin(quantity: quantity, price: entryPrice, leverage: leverage);
        final String totalFees = helper.calculateFees(segment: accountState.marketType, orderType: orderType, margin: tradeMargin, leverage: leverage);

        TradeModel trade = TradeModel(
          key: null,
          tradeId: null,
          accountId: accountId,
          userId: userId,
          marketSegment: marketSegment,
          assetName: assetName,
          identifier: identifier,
          status: status,
          quantity: quantity,
          ltp: ltp,
          entryPrice: entryPrice,
          entryDate: Timestamp.now(),
          action: action,
          totalFees: totalFees,
          leverage: leverage,
          createdBy: userId,
          updatedBy: userId,
          createdOn: Timestamp.now(),
          updatedOn: Timestamp.now(),
        );

        DocumentReference docRef =
            await _db.collection(_collection).add(trade.toJson());
        await docRef.update({"key": docRef.id, "tradeId": docRef.id});

        return {"status": true, "tradeId": docRef.id};
      }
      //Update trade
      else {
        DocumentSnapshot tradeData =
            await _db.collection(_collection).doc(tradeId).get();

        String totalFees = tradeData['totalFees'] as String;
        String entryPrice = tradeData['entryPrice'] as String;
        String quantity = tradeData['quantity'] as String;
        String action = tradeData['action'] as String;

        String grossPnl = helper.calculatePnL(action: action, currentPrice: exitPrice, buyPrice: entryPrice, quantity: quantity).toString();
        double netPnl = double.parse(grossPnl) - double.parse(totalFees);

        await _db.collection(_collection).doc(tradeId).update({
          "netPnl": netPnl.toStringAsFixed(2).toString(),
          "exitPrice": exitPrice,
          "exitDate": Timestamp.now(),
          "status": status,
          "ltp": ltp,
          "updatedBy": userId,
          "updatedOn": Timestamp.now(),
        });

        DocumentSnapshot accountData = await FirebaseFirestore.instance.collection('accountDetails').doc(accountId).get();

        String accountTotalBalance = accountData['totalBalance'] as String;
        double updatedTotalBalance = double.parse(accountTotalBalance) + netPnl;

        await _db.collection('accountDetails').doc(accountId).update({
          "totalBalance": updatedTotalBalance.toStringAsFixed(2).toString(),
          "updatedBy": userId,
          "updatedOn": Timestamp.now(),
        });

        return {"status": true, "tradeId": tradeId};
      }
    } catch (e) {
      print("Error creating trade: $e");
    }

    return {"status": false};
  }

  Future<void> updateLtp({
    required String tradeId,
    required String userId,
    required String ltp,
  }) async {
    try {
      await _db.collection(_collection).doc(tradeId).update({
        "ltp": ltp,
        "updatedBy": userId,
        "updatedOn": Timestamp.now(),
      });
    } catch (e) {
      print("Error creating trade: $e");
    }
  }

  Future<List<TradeModel>> getTrades({
    required String status,
  }) async {
    QuerySnapshot snapshot = await _db
        .collection(_collection)
        .where('status', isEqualTo: status)
        .get();
    return snapshot.docs
        .map((doc) =>
            TradeModel.fromFirestore(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
