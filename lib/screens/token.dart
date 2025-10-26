import 'package:flutter/material.dart';
import 'package:tradewise/widgets/widgets.dart';
import 'package:tradewise/helpers/sharedPreferences.dart';

class TokenScreen extends StatefulWidget {
  const TokenScreen({super.key});

  @override
  State<TokenScreen> createState() => _TokenScreenState();
}

class _TokenScreenState extends State<TokenScreen> {
  bool isLoading = false;
  final TextEditingController tokenController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    tokenController.text = "eyJ0eXAiOiJKV1QiLCJrZXlfaWQiOiJza192MS4wIiwiYWxnIjoiSFMyNTYifQ.eyJzdWIiOiI4RkFDS0MiLCJqdGkiOiI2OGZkYzdlMDZmYzliMzVhNWEwNTE0YTgiLCJpc011bHRpQ2xpZW50IjpmYWxzZSwiaXNQbHVzUGxhbiI6ZmFsc2UsImlhdCI6MTc2MTQ2MjI0MCwiaXNzIjoidWRhcGktZ2F0ZXdheS1zZXJ2aWNlIiwiZXhwIjoxNzYxNTE2MDAwfQ.P-tAYDWXLUmLojN4H0ycibIlzmSCi7U80Lk_vCdBOPk";
    dateController.text = '2025-10-28';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        title: const Text(
          "Manage Token",
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                tokenForm()
              ],
            ),
          ),
        ),
      ),
    );
  }

    Widget tokenForm() {
    return Column(
      children: [
        textFormField(
          controller: tokenController,
          context: context,
          hintText: "Enter token",
          labelText: "Token",
          keyboardType: TextInputType.text,
        ),
        textFormField(
          controller: dateController,
          context: context,
          hintText: "Enter expiry date",
          labelText: "Expiry Date",
          keyboardType: TextInputType.text,
        ),
        elevatedButton(
          isLoading: isLoading,
          buttonLabel: "Submit",
          onPressed: () async {

            String token = tokenController.text.trim();
            String dates = dateController.text.trim();

            await cacheData(key: 'accessToken', data: [{"accessToken": token}]);
            await cacheData(key: 'expiryDates', data: [{"expiryDates": dates}]);

            showSnackbar(context, message: "Success.", type: SnackbarType.success); // ignore: use_build_context_synchronously
          },
        ),
      ],
    );
  }
}
