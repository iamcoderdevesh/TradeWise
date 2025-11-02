const String baseCryptoSpotUrl = 'https://api.binance.com/api/v3/ticker/24hr';
const String baseCryptoFuturesUrl = 'https://fapi.binance.com/fapi/v1/ticker/24hr';

const String nseBaseUrl = "https://www.nseindia.com/api/";
const String nseOptionChainUrl = "https://www.nseindia.com/option-chain";
const String nseIndexUrl = "https://www.nseindia.com/api/NextApi/apiClient?functionName=getIndexData&&type=all";

String optionContractUrl = 'https://api.upstox.com/v2/option/contract?instrument_key=NSE_INDEX%7CNifty%2050';
const String optionDataUrl = 'https://api.upstox.com/v2/option/chain?instrument_key=NSE_INDEX%7CNifty%2050';
const String optionLtpUrl = 'https://api.upstox.com/v3/market-quote/ltp';

Map<String, String> defaultHeaders = {
  "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36",
};

Map<String, String> nseHeaders = {
  "referer": "https://www.nseindia.com/",
  "Connection": "keep-alive",
  "Cache-Control": "max-age=0",
  "DNT": "1",
  "Upgrade-Insecure-Requests": "1",
  "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36",
  "Sec-Fetch-User": "?1",
  "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
  "Sec-Fetch-Site": "none",
  "Sec-Fetch-Mode": "navigate",
  "Accept-Language": "en-US,en;q=0.9,hi;q=0.8"
};

//Cache keys
const cryptoSpotList = 'cryptoSpotList';
const cryptoFuturesList = 'cryptoFuturesList';

const indexList = 'indexList';
const stockList = 'stockList';
const optionsList = 'stockList';

const cryptoApiCall = 'cryptoApiCall';
const indexApiCall = 'indexApiCall';
const stocksApiCall = 'stocksApiCall';
const optionDataApiCall = 'optionDataApiCall';
const optionChainApiCall = 'optionChainApiCall';