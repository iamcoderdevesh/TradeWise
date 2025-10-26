import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tradewise/helpers/sharedPreferences.dart';
import 'package:tradewise/screens/home.dart';
import 'package:tradewise/screens/market.dart';
import 'package:tradewise/screens/portfolio.dart';
import 'package:tradewise/screens/profile.dart';
import 'package:tradewise/services/api/api.dart';
import 'package:tradewise/services/controllers/orderController.dart';
import 'package:tradewise/state/appState.dart';
import 'package:tradewise/widgets/bottomNavBar.dart';
import 'package:tradewise/services/controllers/accountController.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  
  bool isOnline = false;

  @override
  void initState() {
    setUp(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      bottomNavigationBar: const BottomNavBar(),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    final currentSelectedIndex = Provider.of<AppState>(context).pageIndex;

    final pages = [
      const HomeScreen(),
      const MarketScreen(),
      const PortfolioScreen(),
      const ProfileScreen(),
    ];

    return SafeArea(
      child: pages[currentSelectedIndex],
    );
  }

  Future<void> setUp(BuildContext context) async {
    late AppState state = Provider.of<AppState>(context, listen: false);

    final accountController = AccountController();
    final orderController = OrderController();

    isOnline = state.isOnline;

    List<Map<String, dynamic>> cdata = await getCachedData(key: "marketType");
    if(cdata.isNotEmpty) {
      Provider.of<AppState>(context, listen: false).setMarketType(cdata[0]['marketType']); // ignore: use_build_context_synchronously
    }

    // if(state.marketType == "stocks") {
    //   await ApiService.setExpiryDates();
    // }

    bool status = await accountController.setAccountBalance(context: context); // ignore: use_build_context_synchronously
    
    if (status && isOnline) await orderController.handlePendingOrders(context: context); // ignore: use_build_context_synchronously
  }
}
