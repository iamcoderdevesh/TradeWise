import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tradewise/helpers/helper.dart';

class ApiService {
  static const String baseUrl = 'https://api.binance.com/api/v3/ticker/24hr';
  late Helper helper = Helper();

  // Fetches ticker data, filters by symbols if provided.
  static Future<List<Map<String, dynamic>>> fetchCryptoData(List<String> symbols) async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        // If symbols are provided, filter the data
        if (symbols.isNotEmpty) {
          data = data.where((item) => symbols.contains(item['symbol'])).toList();
        }

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
      final response = await http.get(Uri.parse('$baseUrl?symbol=$assetName'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        final String assetPrice = helper.formatNumber(value: data['lastPrice'], formatNumber: 4);
        final String assetPriceChange = helper.formatNumber(value: data['priceChangePercent']);
        
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
