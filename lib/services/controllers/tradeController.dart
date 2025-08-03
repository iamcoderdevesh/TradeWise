import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tradewise/services/models/TradeModel.dart' hide TradeModel;
import 'package:tradewise/services/models/tradeModel.dart';
import 'package:tradewise/state/accountState.dart';
import 'package:tradewise/state/authState.dart';
import 'package:tradewise/state/tradeState.dart';

class TradeController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'tradeDetails';

  // Create Account
  Future<Map<String, dynamic>> createTrade({
    required BuildContext context,
    required String tradeName,
    required String assetName,
    required String marketSegment,
    required String status,
    required String quantity,
    required String margin,
    required String ltp,
    required String entryPrice,
    required String action,
    required String totalFees,
  }) async {
    try {
      late AuthState state = Provider.of<AuthState>(context, listen: false);
      late AccountState accountState = Provider.of<AccountState>(context, listen: false);

      String userId = state.userId as String;
      String accountId = accountState.accountId as String;

      // Create a new account
      TradeModel trade = TradeModel(
        key: null,
        tradeId: null,
        accountId: accountId,
        userId: userId,
        marketSegment: marketSegment,
        assetName: assetName,
        tradeName: tradeName,
        status: status,
        quantity: quantity,
        ltp: ltp,
        entryPrice: entryPrice,
        entryDate: Timestamp.now(),
        action: action,
        totalFees: totalFees,
        createdBy: userId,
        updatedBy: userId,
        createdOn: Timestamp.now(),
        updatedOn: Timestamp.now(),
      );

      DocumentReference docRef =
          await _db.collection(_collection).add(trade.toJson());
      await docRef.update({"key": docRef.id, "tradeId": docRef.id});

      return {"status": true, "tradeId": docRef.id};
    } catch (e) {
      print("Error creating account: $e");
    }

    return {"status": false};
  }

  void getActiveTrades({required BuildContext context}) async {

    QuerySnapshot snapshot = await _db.collection(_collection).where('status', isEqualTo: 'OPEN').get();
    final trades = snapshot.docs
          .map((doc) => TradeModel.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();

    // ignore: use_build_context_synchronously
    late TradeState tradeState = Provider.of<TradeState>(context, listen: false);
    tradeState.setActiveTrades(trades.cast<TradeModel>());
  }
}