import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tradewise/helpers/helper.dart';
import 'package:tradewise/helpers/sharedPreferences.dart';
import 'package:tradewise/screens/accounts.dart';
import 'package:tradewise/screens/signin.dart';
import 'package:tradewise/state/accountState.dart';
import 'package:tradewise/state/appState.dart';
import 'package:tradewise/state/authState.dart';
import 'package:tradewise/widgets/widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Helper helper = Helper();
  bool accountSwtich = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    late AuthState state = Provider.of<AuthState>(context, listen: false);
    accountSwtich = state.marketType == 'crypto' ? true : false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        headerSection("Profile"),
        profileSection(
            context: context,
            profileName: state.user?.displayName,
            email: state.user?.email),
        Expanded(
          child: Stack(
            children: [
              curveAreaSection(context, 40),
              Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  accountMenu(context),
                  const SizedBox(height: 15),
                  ProfileMenu(
                    text: "Account Settings",
                    subText: "Manage Accounts",
                    press: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AccountScreen(),
                        ),
                      ),
                    },
                  ),
                  ProfileMenu(
                    text: "Notifications",
                    subText: "Choose notifications to recieve",
                    press: () {},
                  ),
                  ProfileMenu(
                    text: "Help & Support",
                    subText: "Get help with your account",
                    press: () {},
                  ),
                  ProfileMenu(
                    text: "About Us",
                    subText: "About, Terms of Use & Privacy Policy",
                    press: () {},
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: TextButton(
                          onPressed: () {
                            state.singOut();
                            showSnackbar(context,
                                message: "Signout successfully.",
                                type: SnackbarType.success);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignInScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Logout",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget accountMenu(BuildContext context) {
    late AccountState accountState =
        Provider.of<AccountState>(context, listen: true);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          padding:
              const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          elevation: 2,
        ),
        onPressed: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Account Balance",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      Helper().formatNumber(value: accountState.totalBalance),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF757575),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  accountSwtich ? "Crypto" : "Stocks",
                  style: const TextStyle(
                    letterSpacing: 0.9,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 20),
                Transform.scale(
                  scale: 0.65, // Adjust as needed (1.0 for original size)
                  child: CupertinoSwitch(
                    value: accountSwtich,
                    activeColor: Colors.blue,
                    onChanged: (bool value) {
                      setSegment(switchState: value);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget profileSection({
    required BuildContext context,
    required String? profileName,
    required String? email,
  }) {
    late AppState state = Provider.of<AppState>(context, listen: false);
    String themeMode = Provider.of<AppState>(context).theme;

    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10, left: 20, right: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const ProfilePic(),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profileName!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    email!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            iconSize: 25,
            onPressed: () {
              setState(() {
                state.toggleTheme(mode: themeMode == 'dark' ? 'light' : 'dark');
              });
            },
            icon:
                Icon(themeMode == 'dark' ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
    );
  }

  Future<void> setSegment({required bool switchState}) async {
    String marketType = switchState ? "crypto" : "stocks";

    await cacheApiData(key: 'marketType', data: [{"marketType": marketType}]);
    Provider.of<AuthState>(context, listen: false).setMarketType = marketType; // ignore: use_build_context_synchronously
    setState(() {
      accountSwtich = switchState;
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      showSnackbar(context, message: "Switch to $marketType", type: SnackbarType.success);
    });
  }
}

class ProfilePic extends StatelessWidget {
  const ProfilePic({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 40,
        width: 40,
        child: Stack(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                "https://i.pinimg.com/736x/ca/d5/5d/cad55dbf9a29100cd010bd8b9cdac301.jpg",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    super.key,
    required this.text,
    required this.subText,
    this.press,
  });

  final String text;
  final String subText;
  final VoidCallback? press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: press,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subText,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Divider(
              thickness: 0.5,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ],
        ),
      ),
    );
  }
}
