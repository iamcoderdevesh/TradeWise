import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tradewise/screens/accounts.dart';
import 'package:tradewise/state/state.dart';
import 'package:tradewise/widgets/widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerSection("Profile"),
          profileSection(context),
          Expanded(
            child: Stack(
              children: [
                curveAreaSection(context, 40),
                Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AccountMenu(),
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
                            onPressed: () {},
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
      ),
    );
  }

  Widget profileSection(BuildContext context) {
    late TradeWiseProvider state =
        Provider.of<TradeWiseProvider>(context, listen: false);
    String themeMode = Provider.of<TradeWiseProvider>(context).theme;

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
                  const Text(
                    "Ram Sharma",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "ramsharma@gmail.com",
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

class AccountMenu extends StatelessWidget {
  const AccountMenu({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          elevation: 2,
        ),
        onPressed: () {},
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Account Balance",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "\$2,34,650.00",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF757575),
            ),
          ],
        ),
      ),
    );
  }
}
