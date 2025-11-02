import 'package:flutter/material.dart';
import 'package:tradewise/constant/constant.dart';
import 'package:tradewise/helpers/sharedPreferences.dart';

class ApiCountScreen extends StatefulWidget {
  const ApiCountScreen({super.key});

  @override
  State<ApiCountScreen> createState() => _ApiCountScreenState();
}

class _ApiCountScreenState extends State<ApiCountScreen> {
  String _cryptoApiCall = '0';
  String _indexApiCall = '0';
  String _stocksApiCall = '0';
  String _optionChainApiCall = '0';
  String _optionDataApiCall = '0';

  @override
  void initState() {
    getApiCallCount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        title: const Text(
          "Manage Api Count",
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 15),
            apiMenu("Crypto Api Call", _cryptoApiCall),
            apiMenu("Index Api Call", _indexApiCall),
            apiMenu("Stocks Api Call", _stocksApiCall),
            apiMenu("Option Chain Api Call", _optionChainApiCall),
            apiMenu("Option Data Api Call", _optionDataApiCall),
          ],
        ),
      ),
    );
  }

  Widget apiMenu(String text, String subText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  subText,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Divider(
              thickness: 0.5,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getApiCallCount() async {
    List<Map<String, dynamic>> cryptoApiCallData = await getCachedData(key: cryptoApiCall);
    List<Map<String, dynamic>> indexApiCallData = await getCachedData(key: indexApiCall);
    List<Map<String, dynamic>> stocksApiCallData = await getCachedData(key: stocksApiCall);
    List<Map<String, dynamic>> optionChainApiCallData = await getCachedData(key: optionChainApiCall);
    List<Map<String, dynamic>> optionDataApiCallData = await getCachedData(key: optionDataApiCall);

    setState(() {
      _cryptoApiCall = cryptoApiCallData.isEmpty ? "0" : cryptoApiCallData[0][cryptoApiCall].toString();
      _indexApiCall = indexApiCallData.isEmpty ? "0" : indexApiCallData[0][indexApiCall].toString();
      _stocksApiCall = stocksApiCallData.isEmpty ? "0" : stocksApiCallData[0][stocksApiCall].toString();
      _optionChainApiCall = optionChainApiCallData.isEmpty ? "0" : optionChainApiCallData[0][optionChainApiCall].toString();
      _optionDataApiCall = optionDataApiCallData.isEmpty ? "0" : optionDataApiCallData[0][optionDataApiCall].toString();
    });
  }
}
