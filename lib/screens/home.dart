import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:tradewise/assets/svg.dart';
import 'package:tradewise/screens/market.dart';
import 'package:tradewise/screens/portfolio.dart';
import 'package:tradewise/screens/profile.dart';
import 'package:tradewise/services/controllers/orderController.dart';
import 'package:tradewise/state/accountState.dart';
import 'package:tradewise/state/appState.dart';
import 'package:tradewise/state/authState.dart';
import 'package:tradewise/widgets/bottomNavBar.dart';
import 'package:tradewise/widgets/widgets.dart';
import 'package:tradewise/helpers/helper.dart';
import 'package:tradewise/services/api/api.dart';
import 'package:tradewise/services/controllers/accountController.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isOnline = true;
  final List<String> trackedSymbols = [
    'BTCUSDT',
    'ETHUSDT',
    'TRXUSDT',
    'XRPUSDT',
  ];
  late Future<List<Map<String, dynamic>>> _cryptoData;

  @override
  void initState() {
    setUp(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isOnline = Provider.of<AppState>(context, listen: false).isOnline;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      bottomNavigationBar: const BottomNavBar(),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    final currentSelectedIndex = Provider.of<AppState>(context).pageIndex;

    final pages = [
      homeScreen(context),
      const MarketScreen(),
      const PortfolioScreen(),
      const ProfileScreen(),
    ];

    return SafeArea(
      child: pages[currentSelectedIndex],
    );
  }

  Widget homeScreen(context) {
    late AuthState authState = Provider.of<AuthState>(context, listen: false);
    late AccountState accountState =
        Provider.of<AccountState>(context, listen: true);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        headerSection(profileName: authState.user?.displayName),
        Expanded(
          child: Stack(
            children: [
              curveAreaSection(context, 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    heroSection(accountBalance: accountState.totalBalance),
                    labelViewMoreSection(label: "Featured"),
                    cardSection(),
                    labelViewMoreSection(label: "Trending in market"),
                    trendingSection(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget headerSection({required String? profileName}) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: SizedBox(
        height: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '👋 Hello $profileName,',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  'Invest today and get maximum returns in future!',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w300,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget heroSection({required String accountBalance}) {
    late String balance = Helper().formatNumber(value: accountBalance);
    return SizedBox(
      height: 100,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF287BFF),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.2),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          children: [
            // Texts
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      balance,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.white),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Add Funds",
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget labelViewMoreSection({required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              "See All",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget cardSection() {
    return SizedBox(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          cardItems(
              'BTC', btcIcon, const Color(0xE4E8FDFF), '100000.42', "+1.72%"),
          const SizedBox(width: 15),
          cardItems(
              'ETH', ethIcon, const Color(0xFFFDF4F5), '40000.65', "+2.06%"),
          const SizedBox(width: 15),
          cardItems('USDT', usdtIcon, const Color(0xFFFFF7F1), '1.07', "+0.24%")
        ],
      ),
    );
  }

  Widget cardItems(
      String type, String icon, Color bgColor, String price, String gains) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 5),
      child: Container(
        width: 125,
        height: 150,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: Colors.black.withOpacity(.05),
              style: BorderStyle.solid,
              strokeAlign: BorderSide.strokeAlignInside),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 10,
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 36,
                  height: 36,
                  child: Center(
                    child: SizedBox(
                      width: 26,
                      height: 26,
                      child: SvgPicture.string(icon),
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  type,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                price,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  Text(
                    gains,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xE215CC8A),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_drop_up,
                    size: 26,
                    color: Color(0xE215CC8A),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget trendingSection(context) {
    
    if (isOnline) _cryptoData = ApiService.fetchCryptoData(trackedSymbols);

    return Expanded(
      child: isOnline
          ? FutureBuilder<List<Map<String, dynamic>>>(
              future: _cryptoData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: circularLoader());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final data = snapshot.data!;

                return ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: const BouncingScrollPhysics(),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final crypto = data[index];
                    return tickerItems(
                      context: context,
                      perChange: crypto['priceChangePercent'],
                      currentPrice: crypto['lastPrice'],
                      assetName: crypto['symbol'],
                      shortName: crypto['symbol'],
                      marketSegment: "Spot",
                    );
                  },
                );
              },
            )
          : const Center(
              child: Text("Data not found"),
            ),
    );
  }

  Future<void> setUp(BuildContext context) async {
    late AuthState state = Provider.of<AuthState>(context, listen: false);

    final accountController = AccountController();
    final orderController = OrderController();

    String userId = state.userId as String;

    bool status = await accountController.setAccountBalance(context: context, userId: userId);
    
    if (status && isOnline) await orderController.handlePendingOrders(context: context); // ignore: use_build_context_synchronously
  }
}
