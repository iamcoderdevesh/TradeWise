import 'dart:async';

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
  late Timer _timer;
  final List<String> trackedSymbols = [];
  late Future<List<Map<String, dynamic>>> _cryptoList;

  late String _searchQuery = '';

  @override
  void initState() {
    initTickerList();
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        curveAreaSection(context, 40),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: searchBox(context, onChanged: (value) {
            setState(() {
              setState(() {
                _searchQuery = value.trim().toUpperCase();
              });
            });
          }),
        ),
        tickerListSections(context)
      ],
    );
  }

  Widget tickerListSections(context) {
    return Padding(
      padding: const EdgeInsets.only(top: 70, left: 20, right: 20),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _cryptoList,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: circularLoader());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          List<Map<String, dynamic>>? filteredData = snapshot.data!;
          if (_searchQuery.isNotEmpty) {
            filteredData = snapshot.data!
                .where((item) => item['symbol']
                    .toString()
                    .toUpperCase()
                    .contains(_searchQuery))
                .toList();
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: filteredData.length,
            itemBuilder: (context, index) {
              final crypto = filteredData![index];
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

  void initTickerList() {
    _cryptoList =
        ApiService.fetchCryptoData(trackedSymbols, isFuture: widget.isFuture);
    _timer = Timer.periodic(const Duration(seconds: 10), (Timer t) {
      setState(() {
        _cryptoList = ApiService.fetchCryptoData(trackedSymbols,
            isFuture: widget.isFuture);
      });
    });
  }
}
