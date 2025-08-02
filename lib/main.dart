import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tradewise/screens/signin.dart';
import 'package:tradewise/state/accountState.dart';
import 'package:tradewise/state/appState.dart';
import 'package:tradewise/state/authState.dart';
import 'package:tradewise/state/tradeState.dart';
import 'package:tradewise/theme/theme.dart';
import 'package:tradewise/widgets/bottomNavBar.dart';
import 'package:device_preview/device_preview.dart';

Future<void> main() async {
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyC2lCFW2Qoeh5GSBP8Rax-94oAMRyMzE1Y',
      appId: '1:1022188132513:android:2a7c5b5baaf1aa21e5f8e0',
      messagingSenderId: '1022188132513',
      projectId: 'tradewise-73483',
    ),
  );

  runApp(
    // DevicePreview(
    //   enabled: true, // Enables only in debug
    //   builder: (context) => 
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppState>(create: (_) => AppState()),
          ChangeNotifierProvider<AuthState>(create: (_) => AuthState()),
          ChangeNotifierProvider<AccountState>(create: (_) => AccountState()),
          ChangeNotifierProvider<TradeState>(create: (_) => TradeState()),
        ],
        child: const MainApp(),
      ),
    );
  // );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    late AuthState authState = Provider.of<AuthState>(context, listen: false);
    bool authStatus = authState.checkAuthStatus();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: authStatus ? const BottomNavScreen() : const SignInScreen(),
    );
  }
}
