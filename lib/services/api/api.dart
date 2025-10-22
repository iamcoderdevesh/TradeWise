import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tradewise/helpers/helper.dart';

class ApiService {
  static const String baseCryptoSpotUrl = 'https://api.binance.com/api/v3/ticker/24hr';
  static const String baseCryptoFuturesUrl = 'https://fapi.binance.com/fapi/v1/ticker/24hr';

  static String baseStockUrl = "https://www.nseindia.com/api/";
  static String baseIndexUrl = "https://www.nseindia.com/api/NextApi/apiClient?functionName=getIndexData&&type=all";
  static String originOptionChainUrl = "https://www.nseindia.com/option-chain";

  Map<String, String> defaultHeaders = {
    "User-Agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36",
  };

  Map<String, String> headers = {
    "referer": "https://www.nseindia.com/",
    "Connection": "keep-alive",
    "Cache-Control": "max-age=0",
    "DNT": "1",
    "Upgrade-Insecure-Requests": "1",
    "User-Agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36",
    "Sec-Fetch-User": "?1",
    "Accept":
        "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
    "Sec-Fetch-Site": "none",
    "Sec-Fetch-Mode": "navigate",
    "Accept-Language": "en-US,en;q=0.9,hi;q=0.8"
  };

  late Helper helper = Helper();

  // Fetches crypto ticker data, filters by symbols if provided.
  static Future<List<Map<String, dynamic>>> fetchTickerData(
    List<String> symbols, {
    bool isFuture = false,
  }) async {
    try {
      final response = await http.get(Uri.parse(isFuture ? baseCryptoFuturesUrl : baseCryptoSpotUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        // Filter for pairs that contain "USDT"
        data = data.where((item) => item['symbol'].toString().contains('USDT')).toList();

        // If symbols are provided, filter the data
        if (symbols.isNotEmpty) {
          data = data.where((item) => symbols.contains(item['symbol']))
          .map<Map<String, dynamic>>((item) => {
            "symbol": item['symbol'].toString(),
            "lastPrice": item['lastPrice'].toString(),
            "priceChangePercent": item['priceChangePercent'].toString(),
            "identifier": item['symbol'].toString(),
          }).toList();
        }

        // Sort by price in descending order
        data.sort((a, b) => double.parse(b['lastPrice'].toString())
            .compareTo(double.parse(a['lastPrice'].toString())));

        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to load crypto data:- ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  Future<Map<String, dynamic>> getTickerPrice({
    required String identifier, 
    required String marketType,
    required String marketSegment,
  }) async {
    try {

      if(marketType == 'stocks') {
        List<Map<String, dynamic>> response = await getNseOptionChain(symbol: "NIFTY", identifier: identifier);

        return {
          'assetPrice': response[0]['lastPrice'],
          'assetPriceChange': response[0]['priceChangePercent'],
        };
      }
      else {
        final url = marketSegment == 'Spot' ? baseCryptoSpotUrl : baseCryptoFuturesUrl;
        final response = await http.get(Uri.parse('$url?symbol=$identifier'));

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
      }

    } catch (e) {
      throw Exception('Error occurred while fetching data: $e');
    }
  }

  Future<http.Response> nseUrlFetch(String url,
      {String originOptionChainUrl = "https://www.nseindia.com"}) async {
    // Step 1: Initial request to get cookies
    var initResponse = await http.get(Uri.parse(originOptionChainUrl),
        headers: defaultHeaders);

    // Extract cookies from the initial response
    String? rawCookie = initResponse.headers['set-cookie'];
    String cookie = rawCookie != null ? rawCookie.split(';')[0] : "";

    // Step 2: Second request with headers and cookies
    var finalHeaders = Map<String, String>.from(headers);
    if (cookie.isNotEmpty) {
      finalHeaders['cookie'] = cookie;
    }

    final response = await http.get(Uri.parse(url), headers: finalHeaders);
    return response;
  }

  static Future<List<Map<String, dynamic>>> getNseOptionChain({String symbol = '', String identifier = ''}) async {
    try {
      symbol = symbol.trim().toUpperCase();
      List<String> indicesList = ['NIFTY', 'BANKNIFTY', 'FINNIFTY'];

      String endpoint = indicesList.any((index) => symbol.contains(index)) ? "option-chain-indices?symbol=$symbol" : "option-chain-equities?symbol=$symbol";

      var response = await ApiService().nseUrlFetch(baseStockUrl + endpoint, originOptionChainUrl: originOptionChainUrl);

      if (response.statusCode == 200) { 
        var data = json.decode(response.body);

        List<dynamic> indexData = data['records']['data'] ?? [];
        List<dynamic> expiryDates = data['records']['expiryDates'] ?? [];

        List<Map<String, dynamic>> callFilteredData = indexData
                  .where((item) => item['expiryDate'].toString().contains(expiryDates[0]))
                  .where((item) => item.toString().contains("CE"))
                  .map<Map<String, dynamic>>((item) => {
                        "symbol": "NIFTY ${item['expiryDate'].toString().replaceFirst("-2025", "")} ${item['strikePrice']} CE",
                        "lastPrice": item['CE']['lastPrice'].toString(),
                        "priceChangePercent": item['CE']['pChange'].toString(),
                        "identifier": item['CE']['identifier'].toString(),
                        "strikePrice": item['strikePrice'].toString(),
                      })
                  .toList();

        List<Map<String, dynamic>> putFilteredData = indexData
                  .where((item) => item['expiryDate'].toString().contains(expiryDates[0]))
                  .where((item) => item.toString().contains("PE"))
                  .map<Map<String, dynamic>>((item) => {
                        "symbol": "NIFTY ${item['expiryDate'].toString().replaceFirst("-2025", "")} ${item['strikePrice']} PE",
                        "lastPrice": item['PE']['lastPrice'].toString(),
                        "priceChangePercent": item['PE']['pChange'].toString(),
                        "identifier": item['PE']['identifier'].toString(),
                        "strikePrice": item['strikePrice'].toString(),
                      })
                  .toList();

        List<Map<String, dynamic>> combinedData = [...callFilteredData, ...putFilteredData];
        if(identifier.isNotEmpty) combinedData = combinedData.where((item) => item['identifier'].toString().contains(identifier)).toList();
  
        combinedData.sort((a, b) => double.parse(b['strikePrice'].toString()).compareTo(double.parse(a['strikePrice'].toString())));

        return combinedData;
      } 
      else {
        throw Exception('Failed to load data:- ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getIndexData() async {
    try {
      List<String> indicesList = ['NIFTY 50', 'NIFTY BANK', 'NIFTY FIN SERVICE'];

      var response = await ApiService().nseUrlFetch(baseIndexUrl);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<dynamic> indexData = data['data'] ?? [];
        List<Map<String, dynamic>> filteredData = indexData
            .where((item) => indicesList.contains(item['indexName']))
            .map<Map<String, dynamic>>((item) => {
                  "symbol": item["indexName"],
                  "lastPrice": item["last"],
                  "priceChangePercent": item["percChange"],
                })
            .toList();

        return List<Map<String, dynamic>>.from(filteredData);
      } else {
        throw Exception('Failed to load data:- ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }
}
