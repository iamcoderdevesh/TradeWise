import 'package:flutter/material.dart';
import 'package:tradewise/services/api/api.dart';
import 'package:tradewise/widgets/widgets.dart';

// ignore: must_be_immutable
class WatchlistScreen extends StatefulWidget {
  late bool isFuture = false;
  WatchlistScreen({super.key, this.isFuture = false});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  final List<String> trackedSymbols = [
    'BTCUSDT',
    'ETHUSDT',
    'TRXUSDT',
    'SOLUSDT',
    'XRPUSDT',
    'DOGEUSDT',
    'ADAUSDT'
  ];
  late Future<List<Map<String, dynamic>>> _cryptoData;

  @override
  void initState() {
    _cryptoData = ApiService.fetchCryptoData(trackedSymbols, isFuture: widget.isFuture);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        curveAreaSection(context, 40),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: searchBox(context),
        ),
        tickerListSections(context)
      ],
    );
  }

  Widget tickerListSections(context) {
    return Padding(
      padding: const EdgeInsets.only(top: 70, left: 20, right: 20),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _cryptoData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: circularLoader());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data!;

          return ListView.builder(
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
              );
            },
          );
        },
      ),
    );
  }
}
