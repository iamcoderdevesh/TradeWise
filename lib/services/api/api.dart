import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tradewise/helpers/helper.dart';
import 'package:tradewise/helpers/sharedPreferences.dart';

class ApiService {
  static const String baseCryptoSpotUrl = 'https://api.binance.com/api/v3/ticker/24hr';
  static const String baseCryptoFuturesUrl = 'https://fapi.binance.com/fapi/v1/ticker/24hr';

  static String nseBaseUrl = "https://www.nseindia.com/api/";
  static String nseOptionChainUrl = "https://www.nseindia.com/option-chain";

  static String optionContractUrl = 'https://api.upstox.com/v2/option/contract?instrument_key=NSE_INDEX%7CNifty%2050';
  static String optionDataUrl = 'https://api.upstox.com/v2/option/chain?instrument_key=NSE_INDEX%7CNifty%2050';
  static String optionLtpUrl = 'https://api.upstox.com/v3/market-quote/ltp';

  Map<String, String> defaultHeaders = {
    "User-Agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36",
  };

  Map<String, String> nseHeaders = {
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

  //crypto section
  static Future<List<Map<String, dynamic>>> fetchTickerData(
    List<String> symbols, {
    bool isFuture = false,
  }) async {
    try {
      final response = await http
          .get(Uri.parse(isFuture ? baseCryptoFuturesUrl : baseCryptoSpotUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        // Filter for pairs that contain "USDT"
        data = data
            .where((item) => item['symbol'].toString().contains('USDT'))
            .toList();

        // If symbols are provided, filter the data
        if (symbols.isNotEmpty) {
          data = data
              .where((item) => symbols.contains(item['symbol']))
              .map<Map<String, dynamic>>((item) => {
                    "symbol": item['symbol'].toString(),
                    "lastPrice": item['lastPrice'].toString(),
                    "priceChangePercent": item['priceChangePercent'].toString(),
                    "identifier": item['symbol'].toString(),
                  })
              .toList();
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
      if (marketType == 'stocks') {
        List<Map<String, dynamic>> getToken = await getCachedData(key: "accessToken");
        Map<String, String> headers = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${getToken[0]['accessToken']}',
        };

        var response = await http.get(Uri.parse('$optionLtpUrl?instrument_key=$identifier'), headers: headers);

        if(response.statusCode == 200) {

          final Map<String, dynamic> data = jsonDecode(response.body);
          final firstKey = data['data'].keys.first;


          return {
            'assetPrice': data['data'][firstKey]['last_price'].toString(),
            'assetPriceChange': '0.00',
          };
        }
        else {
          throw Exception('Failed to load data:- ${response.statusCode}');
        }

      } else {
        final url =
            marketSegment == 'Spot' ? baseCryptoSpotUrl : baseCryptoFuturesUrl;
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
          throw Exception('Failed to load crypto data:- ${response.statusCode}');
        }
      }
    } catch (e) {
      throw Exception('Error occurred while fetching data: $e');
    }
  }
  //crypto section end.

  //stocks section
  Future<http.Response> nseUrlFetch(String url,
      {String originOptionChainUrl = "https://www.nseindia.com"}) async {
    // Step 1: Initial request to get cookies
    var initResponse = await http.get(Uri.parse(originOptionChainUrl),
        headers: defaultHeaders);

    // Extract cookies from the initial response
    String? rawCookie = initResponse.headers['set-cookie'];
    String cookie = rawCookie != null ? rawCookie.split(';')[0] : "";

    // Step 2: Second request with headers and cookies
    var finalHeaders = Map<String, String>.from(nseHeaders);
    if (cookie.isNotEmpty) {
      finalHeaders['cookie'] = cookie;
    }

    final response = await http.get(Uri.parse(url), headers: finalHeaders);
    return response;
  }

  static Future<List<Map<String, dynamic>>> getOptionChainData() async {

    List<Map<String, dynamic>> getToken = await getCachedData(key: "accessToken");
    List<Map<String, dynamic>> getExpiryDates = await getCachedData(key: "expiryDates");

    String accessToken = getToken.isNotEmpty ? getToken[0]['accessToken'] : '';
    String expiryDate = getExpiryDates.isNotEmpty ? getExpiryDates[0]['expiryDates'] : '';

    if(accessToken.isEmpty || expiryDate.isEmpty) {
      return [];
    }

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    var optionContractsResponse0 = await http.get(Uri.parse(optionContractUrl), headers: headers);
    var optionChainResponse0 = await http.get(Uri.parse('$optionDataUrl&expiry_date=$expiryDate'), headers: headers);

    if (optionContractsResponse0.statusCode == 200 && optionChainResponse0.statusCode == 200) {

      var optionContractsResponse = json.decode(optionContractsResponse0.body);
      var optionChainResponse = json.decode(optionChainResponse0.body);

      List<dynamic> optionContractsList = optionContractsResponse['data'] ?? [];
      List<dynamic> optionChainList = optionChainResponse['data'] ?? [];

      // Create a map of instrument_key -> ltp for quick lookup
      Map<String, dynamic> ltpMap = {};

      for (var chainItem in optionChainList) {
        var callOption = chainItem['call_options'];
        var putOption = chainItem['put_options'];

        if (callOption != null && callOption['instrument_key'] != null) {
          ltpMap[callOption['instrument_key']] = callOption['market_data']?['ltp'] ?? 0.0;
        }

        if (putOption != null && putOption['instrument_key'] != null) {
          ltpMap[putOption['instrument_key']] = putOption['market_data']?['ltp'] ?? 0.0;
        }
      }

      // Filter contracts and merge LTP
      List<Map<String, dynamic>> filteredData = optionContractsList.where((item) => item['expiry'].toString().contains(expiryDate)).map<Map<String, dynamic>>((item) {
        String instrumentKey = item['instrument_key'].toString();
        double ltp = ltpMap[instrumentKey] ?? 0.0;

        return {
          "symbol": item['trading_symbol'].toString().replaceFirst(" 25", ""),
          "identifier": instrumentKey,
          "strikePrice": item['strike_price'].toString(),
          "priceChangePercent": '0.00',
          "lastPrice": ltp.toString(),
        };
      }).toList();

      filteredData.sort((a, b) => double.parse(b['strikePrice'].toString()).compareTo(double.parse(a['strikePrice'].toString())));

      return List<Map<String, dynamic>>.from(filteredData);
    } else {
      throw Exception('Failed to load data:- ${optionContractsResponse0.statusCode}');
    }
  }

  // static Future<void> setExpiryDates({String symbol = 'NIFTY'}) async {
  //   try {
  //     symbol = symbol.trim().toUpperCase();
  //     List<String> indicesList = ['NIFTY', 'BANKNIFTY', 'FINNIFTY'];

  //     String endpoint = indicesList.any((index) => symbol.contains(index))
  //         ? "option-chain-indices?symbol=$symbol"
  //         : "option-chain-equities?symbol=$symbol";

  //     var response = await ApiService().nseUrlFetch(nseBaseUrl + endpoint,
  //         originOptionChainUrl: nseOptionChainUrl);

  //     if (response.statusCode == 200) {
  //       var data = json.decode(response.body);
  //       List<dynamic> expiryDates = data['records']['expiryDates'] ?? [];

  //       await cacheData(key: "expiryDates", data: [{"expiryDates": expiryDates}]);
  //     } else {
  //       throw Exception('Failed to load data:- ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     throw Exception('Error fetching data: $e');
  //   }
  // }
  //stocks section ends.
}