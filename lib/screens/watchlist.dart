import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tradewise/services/api/api.dart';
import 'package:tradewise/state/appState.dart';
import 'package:tradewise/widgets/widgets.dart';

// ignore: must_be_immutable
class WatchlistScreen extends StatefulWidget {
  late bool isFuture = false;
  WatchlistScreen({super.key, this.isFuture = false});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  bool isOnline = true;
  final List<String> trackedSymbols = [];
  late Future<List<Map<String, dynamic>>> _tickerList;

  late String _searchQuery = '';

  @override
  void initState() {
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
    isOnline = Provider.of<AppState>(context, listen: false).isOnline;
    if(isOnline) initTickerList(context);
    
    return Padding(
      padding: const EdgeInsets.only(top: 70, left: 20, right: 20),
      child: isOnline
          ? FutureBuilder<List<Map<String, dynamic>>>(
              future: _tickerList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
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
                      marketSegment: widget.isFuture ? "Futures" : "Spot",
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

  Future<void> initTickerList(BuildContext context) async {
    if (isOnline) {
      _tickerList = ApiService.fetchCryptoData(trackedSymbols, isFuture: widget.isFuture);
    }
  }
}
