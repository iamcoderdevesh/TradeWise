import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tradewise/constant/constant.dart';
import 'package:tradewise/helpers/helper.dart';
import 'package:tradewise/helpers/sharedPreferences.dart';

class ApiService {

  late Helper helper = Helper();

  //crypto section
  static Future<List<Map<String, dynamic>>> fetchTickerData({
    required bool isOnline,
    bool isFuture = false,
  }) async {
    try {
      String cacheKey = isFuture ? cryptoFuturesList : cryptoSpotList;

      if(isOnline) {
        final response = await http.get(Uri.parse(isFuture ? baseCryptoFuturesUrl : baseCryptoSpotUrl));

        if (response.statusCode == 200) {
          List<dynamic> data = jsonDecode(response.body);

          data = data.where((item) => item['symbol'].toString().contains('USDT')).toList();
          data.sort((a, b) => double.parse(b['lastPrice'].toString()).compareTo(double.parse(a['lastPrice'].toString()))); // Sort by price in descending order

          List<Map<String, dynamic>> filteredData = List<Map<String, dynamic>>.from(data);
          await cacheData(key: cacheKey, data: filteredData);

          await Helper().cacheApiCallCount(cacheKey: cryptoApiCall);
          
          return filteredData;
        }
      }

      List<dynamic> data = await getCachedData(key: cacheKey);
      return List<Map<String, dynamic>>.from(data);

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

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final firstKey = data['data'].keys.first;

          await helper.cacheApiCallCount(cacheKey: optionDataApiCall);

          return {
            'assetPrice': data['data'][firstKey]['last_price'].toString(),
            'assetPriceChange': '0.00',
          };
        } else {
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

          await helper.cacheApiCallCount(cacheKey: cryptoApiCall);

          return {
            'assetPrice': assetPrice,
            'assetPriceChange': assetPriceChange,
          };
        } else {
          throw Exception(
              'Failed to load crypto data:- ${response.statusCode}');
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

  static Future<List<Map<String, dynamic>>> getOptionChainData({
    required bool isOnline
  }) async {

    String cacheKey = optionsList;

    List<Map<String, dynamic>> getToken = await getCachedData(key: "accessToken");
    List<Map<String, dynamic>> getExpiryDates = await getCachedData(key: "expiryDates");

    String accessToken = getToken.isNotEmpty ? getToken[0]['accessToken'] : '';
    String expiryDate = getExpiryDates.isNotEmpty ? getExpiryDates[0]['expiryDates'] : '';

    if (expiryDate.isEmpty) {
      return throw Exception('Expiry date is not set');
    }
    else if(accessToken.isEmpty) {
      return throw Exception('Token is not set');
    }

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    if(isOnline) {
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

        await cacheData(key: cacheKey, data: filteredData);
        await Helper().cacheApiCallCount(cacheKey: optionChainApiCall);
        
        return filteredData;
      }
    }

    List<dynamic> data = await getCachedData(key: cacheKey);
    return List<Map<String, dynamic>>.from(data);
  }

  static Future<List<Map<String, dynamic>>> getIndexData({required bool isOnline}) async {
    try {
      String cacheKey = indexList;
      List<String> indicesList = ['NIFTY 50', 'NIFTY BANK', 'NIFTY FIN SERVICE'];

      if(isOnline) {
        var response = await ApiService().nseUrlFetch(nseIndexUrl);

        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          List<dynamic> indexData = data['data'] ?? [];

          List<Map<String, dynamic>> filteredData = indexData
              .where((item) => indicesList.contains(item['indexName']))
              .map<Map<String, dynamic>>((item) => {
                    "symbol": item["indexName"],
                    "lastPrice": item["last"].toString(),
                    "priceChangePercent": item["percChange"].toString(),
                  })
              .toList();

          await cacheData(key: cacheKey, data: filteredData);
          await Helper().cacheApiCallCount(cacheKey: indexApiCall);

          return List<Map<String, dynamic>>.from(filteredData);
        }
      }

      List<dynamic> data = await getCachedData(key: cacheKey);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  static Future<void> setExpiryDates({String symbol = 'NIFTY'}) async {
    try {
      symbol = symbol.trim().toUpperCase();
      List<String> indicesList = ['NIFTY', 'BANKNIFTY', 'FINNIFTY'];

      String endpoint = indicesList.any((index) => symbol.contains(index))
          ? "option-chain-indices?symbol=$symbol"
          : "option-chain-equities?symbol=$symbol";

      var response = await ApiService().nseUrlFetch(nseBaseUrl + endpoint, originOptionChainUrl: nseOptionChainUrl);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<dynamic> expiryDates = data['records']['expiryDates'] ?? [];

        await cacheData(key: "expiryDates", data: [
          {"expiryDates": expiryDates}
        ]);
      } else {
        throw Exception('Failed to load data:- ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }
  //stocks section ends.
}
