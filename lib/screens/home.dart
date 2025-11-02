import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tradewise/state/accountState.dart';
import 'package:tradewise/state/appState.dart';
import 'package:tradewise/state/authState.dart';
import 'package:tradewise/widgets/widgets.dart';
import 'package:tradewise/helpers/helper.dart';
import 'package:tradewise/services/api/api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isOnline = false;
  String marketType = '';
  late List<String> trackedSymbols = ['BTCUSDT', 'ETHUSDT', 'TRXUSDT', 'XRPUSDT'];

  // ignore: prefer_final_fields
  late Future<List<Map<String, dynamic>>> _tickerList = Future.value([]);

  @override
  void initState() {
    marketType = Provider.of<AppState>(context, listen: false).marketType;
    isOnline = Provider.of<AppState>(context, listen: false).isOnline;

    _tickerList = marketType == "stocks" ? ApiService.getIndexData(isOnline: isOnline) : ApiService.fetchTickerData(isOnline: isOnline);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return homeScreen(context);
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
      child: tickerSection(
        context: context,
        tickerList: _tickerList,
        tickerSymbols: trackedSymbols,
        isHomeFeatured: true,
        scrollDirection: Axis.horizontal,
      ),
    );
  }

  Widget trendingSection(context) {
    return Expanded(
      child: tickerSection(
        context: context,
        tickerList: _tickerList,
        tickerSymbols: trackedSymbols,
      ),
    );
  }
}
