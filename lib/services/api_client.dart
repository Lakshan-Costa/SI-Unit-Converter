import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final Uri currencyURL = Uri.https("api.exchangeratesapi.io", "v1/latest", {"apiKey": "1a0f0d4fcd32a68fc1bb4a6b17f29751"});



  Future <List<String>> getCurrencies() async {
    http.Response res = await http.get(currencyURL);
    if (res.statusCode == 200) {
    var body = jsonDecode(res.body);
    var list = body["results"];
    List<String> currencies = (list.keys).toList();
    print(currencies);
    return currencies;

  } else {
    throw Exception("Failed to connect to API");
    }
  }

}



