// services/websocket/binance_websocket_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

typedef TickerCallback = void Function(String symbol, double price);

class WebSocketService {
  final Map<String, WebSocketChannel> _channels = {};
  final Map<String, StreamSubscription> _subscriptions = {};
  final TickerCallback onTickerUpdate;

  WebSocketService({required this.onTickerUpdate});

  void subscribeToSymbol({required String symbol, bool isFuture = false}) {
    final lowerSymbol = symbol.toLowerCase();
    final url = 'wss://${isFuture ? 'f' : ''}stream.binance.com:9443/ws/$lowerSymbol@ticker';

    if (_channels.containsKey(symbol)) return; // Already subscribed

    try {
      final channel = WebSocketChannel.connect(Uri.parse(url));
      _channels[symbol] = channel;

      final subscription = channel.stream.listen(
        (data) {
          final json = jsonDecode(data);
          if (json != null && json['c'] != null) {
            final price = double.tryParse(json['c']) ?? 0.0;
            // print(symbol + ' :- ' + price.toString());
            onTickerUpdate(symbol, price);
          }
        },
        onError: (error) {
          print("WebSocket error for $symbol: $error");
          _reconnect(symbol, isFuture: isFuture);
        },
        onDone: () {
          print("WebSocket closed for $symbol");
          _reconnect(symbol, isFuture: isFuture);
        },
        cancelOnError: true,
      );

      _subscriptions[symbol] = subscription;
    } catch (e) {
      print("Failed to connect WebSocket for $symbol: $e");
    }
  }

  void unsubscribeFromSymbol(String symbol) {
    _subscriptions[symbol]?.cancel();
    _channels[symbol]?.sink.close();
    _subscriptions.remove(symbol);
    _channels.remove(symbol);
  }

  void _reconnect(String symbol, {bool isFuture = false}) async {
    unsubscribeFromSymbol(symbol);
    await Future.delayed(const Duration(seconds: 3));
    subscribeToSymbol(symbol: symbol);
  }

  void disposeAll() {
    _subscriptions.forEach((_, sub) => sub.cancel());
    _channels.forEach((_, ch) => ch.sink.close());
    _subscriptions.clear();
    _channels.clear();
  }
}
