import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tradewise/screens/signin.dart';
import 'package:tradewise/state/state.dart';

Future<void> main() async {

  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (context) => TradeWiseProvider(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // var brightness = MediaQuery.of(context).platformBrightness;
    // bool isDarkMode = brightness == Brightness.dark;
    // late TradeWiseProvider state =
    //     Provider.of<TradeWiseProvider>(context, listen: false);
    // if (state.theme == 'sys') {
    //   state.toggleTheme(mode: isDarkMode ? 'dark' : 'light', isSys: 'sys');
    // }

    return Consumer<TradeWiseProvider>(
      builder: (context, theme, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme.themeData,
          home: const SignInScreen(),
        );
      },
    );
  }
}
