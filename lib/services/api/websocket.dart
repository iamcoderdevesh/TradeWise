// binance_websocket_service.dart

import 'dart:convert';
import 'package:web_socket_channel/io.dart';

typedef TickerCallback = void Function(String symbol, double price);

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;

  WebSocketService._internal();

  IOWebSocketChannel? _channel;
  final Map<String, TickerCallback> _callbacks = {};

  void connect(List<String> symbols, TickerCallback onTickerUpdate) {
    final streams = symbols.map((s) => '${s.toLowerCase()}@ticker').join('/');
    final url = 'wss://stream.binance.com:9443/stream?streams=$streams';

    _channel?.sink.close(); // Close previous connection if any
    _channel = IOWebSocketChannel.connect(Uri.parse(url));

    _channel?.stream.listen((message) {
      final data = jsonDecode(message);
      if (data.containsKey('data')) {
        final streamData = data['data'];
        final symbol = streamData['s']; // e.g., BTCUSDT
        final price = double.tryParse(streamData['c']) ?? 0.0; // current price

        if (_callbacks.containsKey(symbol)) {
          _callbacks[symbol]?.call(symbol, price);
        }
      }
    });
  }

  void registerCallback(String symbol, TickerCallback callback) {
    _callbacks[symbol] = callback;
  }

  void unregisterCallback(String symbol) {
    _callbacks.remove(symbol);
  }

  void disconnect() {
    _channel?.sink.close();
    _callbacks.clear();
  }
}
