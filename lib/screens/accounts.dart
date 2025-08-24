import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tradewise/helpers/helper.dart';
import 'package:tradewise/screens/home.dart';
import 'package:tradewise/screens/profile.dart';
import 'package:tradewise/services/controllers/accountController.dart';
import 'package:tradewise/services/models/accountModel.dart';
import 'package:tradewise/state/accountState.dart';
import 'package:tradewise/state/appState.dart';
import 'package:tradewise/widgets/widgets.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

String? _selectedSegment = 'Stocks';

class _AccountScreenState extends State<AccountScreen> {
  late bool isLoading = false;
  late bool onScreenLoader = false;
  late AccountState state = Provider.of<AccountState>(context, listen: false);

  final TextEditingController accountNameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    accountNameController.dispose();
    amountController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        title: const Text(
          "Manage Account",
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: onScreenLoader
          ? Center(
              child: circularLoader(),
            )
          : SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      labelAreaSection(
                        title: "Balance",
                        subTitle:
                            Helper().formatNumber(value: state.totalBalance),
                        context: context,
                        isDelete: true,
                      ),
                      accountForm(context),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget accountForm(BuildContext context) {
    return Column(
      children: [
        textFormField(
          controller: accountNameController,
          context: context,
          hintText: "Enter your account name",
          labelText: "Account name",
          keyboardType: TextInputType.name,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.singleLineFormatter
          ],
        ),
        textFormField(
          controller: amountController,
          context: context,
          hintText: "2,34,650.00",
          labelText: "Initial Balance",
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
        ),
        const SizedBox(height: 25),
        labelAreaSection(
            title: "Select segment", bottomPadding: 5, context: context),
        const RadioListTileExample(),
        const SizedBox(height: 8),
        elevatedButton(
          isLoading: isLoading,
          buttonLabel: "Continue",
          onPressed: () {
            handleAccount(context: context);
          },
        ),
      ],
    );
  }

  Widget labelAreaSection({
    required String title,
    required BuildContext context,
    String subTitle = "",
    double bottomPadding = 20,
    bool isDelete = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    subTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              isDelete
                  ? IconButton(
                      onPressed: () {
                        deleteAccount();
                      },
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red,
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 10),
          Divider(
            thickness: 0.5,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ],
      ),
    );
  }

  Future<void> handleAccount({required BuildContext context}) async {
    String accountName = accountNameController.text.trim();
    String initialBalance = amountController.text.trim();

    if (accountName.isEmpty || initialBalance.isEmpty) {
      showSnackbar(context,
          message: "Please fill all the fields.", type: SnackbarType.error);
    } else {
      setState(() {
        isLoading = true;
      });

      final accountController = AccountController();
      final response = await accountController.createAccount(
        context: context,
        accountName: accountName,
        accountType: _selectedSegment as String,
        initialBalance: initialBalance,
      );

      bool status = response["status"] as bool;

      if (status) {
        String userId = response["userId"] as String;
        // ignore: use_build_context_synchronously
        await accountController.setAccountBalance(
            context: context, userId: userId);

        // ignore: use_build_context_synchronously
        showSnackbar(context,
            message: "Account created successfully.",
            type: SnackbarType.success);

        Future.delayed(const Duration(milliseconds: 200), () {
          final appState = Provider.of<AppState>(context, listen: false);
          appState.setPageIndex = 3;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        });
      }
    }
  }

  Future<void> deleteAccount() async {
    setState(() {
      onScreenLoader = true;
    });

    final accountController = AccountController();
    final response =
        await accountController.deleteAccount(accountId: state.accountId ?? '');

    setState(() {
      onScreenLoader = false;
    });

    bool status = response["status"] as bool;
    String message = response["message"] as String;

    if (status) {
      // ignore: use_build_context_synchronously
      showSnackbar(context, message: message, type: SnackbarType.success);
    }
  }
}

class RadioListTileExample extends StatefulWidget {
  const RadioListTileExample({super.key});

  @override
  State<RadioListTileExample> createState() => _RadioListTileExampleState();
}

class _RadioListTileExampleState extends State<RadioListTileExample> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        RadioListTile<String?>(
          title: const Text('Stocks'),
          value: 'Stocks',
          groupValue: _selectedSegment,
          controlAffinity: ListTileControlAffinity.trailing,
          activeColor: Theme.of(context).colorScheme.primaryContainer,
          onChanged: (String? value) {
            setState(() {
              _selectedSegment = value;
            });
          },
        ),
        RadioListTile<String?>(
          controlAffinity: ListTileControlAffinity.trailing,
          title: const Text('Crypto'),
          value: 'Crypto',
          groupValue: _selectedSegment,
          activeColor: Theme.of(context).colorScheme.primaryContainer,
          onChanged: (String? value) {
            setState(() {
              _selectedSegment = value;
            });
          },
        ),
      ],
    );
  }
}
