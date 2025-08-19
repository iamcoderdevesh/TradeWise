import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tradewise/helpers/helper.dart';

class ApiService {
  static const String baseSpotUrl =
      'https://api.binance.com/api/v3/ticker/24hr';
  static const String baseFutureUrl =
      'https://fapi.binance.com/fapi/v1/ticker/24hr';
  late Helper helper = Helper();

  // Fetches ticker data, filters by symbols if provided.
  static Future<List<Map<String, dynamic>>> fetchCryptoData(
    List<String> symbols, {
    bool isFuture = false,
  }) async {
    try {
      final response = await http.get(Uri.parse(isFuture ? baseFutureUrl : baseSpotUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        // Filter for pairs that contain "USDT"
        data = data.where((item) => item['symbol'].toString().contains('USDT')).toList();

        // If symbols are provided, filter the data
        if (symbols.isNotEmpty) {
          data = data.where((item) => symbols.contains(item['symbol'])).toList();
        }

        // Sort by price in descending order
        data.sort((a, b) => double.parse(b['lastPrice'].toString()).compareTo(double.parse(a['lastPrice'].toString())));

        // Convert filtered list to a List<Map<String, dynamic>>
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to load crypto data');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  Future<Map<String, dynamic>> getTickerPrice(String assetName) async {
    try {
      final response =
          await http.get(Uri.parse('$baseSpotUrl?symbol=$assetName'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        final String assetPrice =
            helper.formatNumber(value: data['lastPrice'], formatNumber: 4);
        final String assetPriceChange =
            helper.formatNumber(value: data['priceChangePercent']);

        return {
          'assetPrice': assetPrice,
          'assetPriceChange': assetPriceChange,
        };
      } else {
        throw Exception('Failed to load crypto data');
      }
    } catch (e) {
      throw Exception('Error occurred while fetching data: $e');
    }
  }
}
