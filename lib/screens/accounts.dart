import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tradewise/widgets/widgets.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                labelAreaSection(
                    title: "Balance", subTitle: "\$0", context: context),
                const AccountForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget labelAreaSection({
  required String title,
  required BuildContext context,
  String subTitle = "",
  double bottomPadding = 20,
}) {
  return Padding(
    padding: EdgeInsets.only(bottom: bottomPadding),
    child: Column(
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
        const SizedBox(height: 10),
        Divider(
          thickness: 0.5,
          color: Theme.of(context).colorScheme.tertiary,
        ),
      ],
    ),
  );
}

const authOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Color(0xFF757575)),
  borderRadius: BorderRadius.all(Radius.circular(10)),
);

class AccountForm extends StatelessWidget {
  const AccountForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          textFormField(
            context: context,
            hintText: "Enter your account name",
            labelText: "Account name",
            keyboardType: TextInputType.name,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.singleLineFormatter
            ],
            onSaved: (accountName) {
              return accountName;
            },
            onChanged: (accountName) {
              return accountName;
            },
          ),
          textFormField(
            context: context,
            hintText: "2,34,650.00",
            labelText: "Enter amount",
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            onSaved: (amount) {
              return amount;
            },
            onChanged: (amount) {
              return amount;
            },
          ),
          const SizedBox(height: 25),
          labelAreaSection(
              title: "Select segment", bottomPadding: 5, context: context),
          const RadioListTileExample(),
          const SizedBox(height: 8),
          elevatedButton(
            buttonLabel: "Continue",
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

enum SingingCharacter { stocks, crypto }

class RadioListTileExample extends StatefulWidget {
  const RadioListTileExample({super.key});

  @override
  State<RadioListTileExample> createState() => _RadioListTileExampleState();
}

class _RadioListTileExampleState extends State<RadioListTileExample> {
  SingingCharacter? _character = SingingCharacter.stocks;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        RadioListTile<SingingCharacter>(
          title: const Text('Stocks'),
          value: SingingCharacter.stocks,
          groupValue: _character,
          controlAffinity: ListTileControlAffinity.trailing,
          activeColor: Theme.of(context).colorScheme.primaryContainer,
          onChanged: (SingingCharacter? value) {
            setState(() {
              _character = value;
            });
          },
        ),
        RadioListTile<SingingCharacter>(
          controlAffinity: ListTileControlAffinity.trailing,
          title: const Text('Crypto'),
          value: SingingCharacter.crypto,
          groupValue: _character,
          activeColor: Theme.of(context).colorScheme.primaryContainer,
          onChanged: (SingingCharacter? value) {
            setState(() {
              _character = value;
            });
          },
        ),
      ],
    );
  }
}
