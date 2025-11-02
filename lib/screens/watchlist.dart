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
  bool isOnline = false;
  final List<String> trackedSymbols = [];
  late Future<List<Map<String, dynamic>>> _tickerList = Future.value([]);
  late String _searchQuery = '';
  late String _marketType = '';

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
        tickerList(context),
      ],
    );
  }

  Widget tickerList(BuildContext context) {
    isOnline = Provider.of<AppState>(context, listen: false).isOnline;
    _marketType = Provider.of<AppState>(context, listen: false).marketType;

    _tickerList = _marketType == "stocks" ? ApiService.getOptionChainData(isOnline: isOnline) : ApiService.fetchTickerData(isFuture: widget.isFuture, isOnline: isOnline);

    return Padding(
      padding: const EdgeInsets.only(top: 70, left: 20, right: 20),
      child: tickerSection(
        context: context,
        tickerList: _tickerList,
        searchQuery: _searchQuery,
        tickerSymbols: trackedSymbols,
        isFuture: widget.isFuture,
      ),
    );
  }
}
