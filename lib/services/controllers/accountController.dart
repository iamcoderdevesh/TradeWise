import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tradewise/services/models/accountModel.dart';
import 'package:tradewise/state/accountState.dart';
import 'package:tradewise/state/authState.dart';

class AccountController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'accountDetails';

  // Create Account
  Future<Map<String, dynamic>> createAccount({
    required BuildContext context,
    required String accountName,
    required String accountType,
    required String initialBalance,
  }) async {
    try {
      late AuthState state = Provider.of<AuthState>(context, listen: false);
      String userId = state.userId as String;

      // Create a new account
      AccountModel account = AccountModel(
        key: null,
        accountId: null,
        userId: userId,
        accountName: accountName,
        accountType: accountType,
        initialBalance: initialBalance,
        totalBalance: initialBalance,
        createdBy: userId,
        updatedBy: userId,
        createdOn: Timestamp.now(),
        updatedOn: Timestamp.now(),
      );

      DocumentReference docRef =
          await _db.collection(_collection).add(account.toJson());
      await docRef.update({"key": docRef.id, "accountId": docRef.id});

      return {"status": true, "userId": userId};
    } catch (e) {
      print("Error creating account: $e");
    }

    return {"status": false};
  }

  // Read Account by ID
  Future<void> setAccountNameAndBalance(
      {required BuildContext context, required String userId}) async {
    try {
      late AccountState state =
          Provider.of<AccountState>(context, listen: false);
      QuerySnapshot snapshot = await _db
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      // Check if a document exists
      if (snapshot.docs.isNotEmpty) {
        AccountModel? accountData = AccountModel.fromJson(
            snapshot.docs.first.data() as Map<String, dynamic>);
        state.setAccountData(accountId: accountData.accountId, totalBalance: accountData.totalBalance);
      }
    } catch (e) {
      print("Error fetching account: $e");
    }
  }

  // Update Account
  Future<void> updateAccount(AccountModel account) async {
    if (account.key == null) return;

    try {
      await _db
          .collection(_collection)
          .doc(account.key)
          .update(account.toJson());
    } catch (e) {
      print("Error updating account: $e");
    }
  }

  // Delete Account
  Future<void> deleteAccount(String key) async {
    try {
      await _db.collection(_collection).doc(key).delete();
    } catch (e) {
      print("Error deleting account: $e");
    }
  }
}
