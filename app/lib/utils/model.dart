import 'dart:convert';
import 'package:http/http.dart' as http;

class HelperFunction {
  Future<int?> getCurrentAQI() async {
    final url = Uri.parse(
        "https://api.waqi.info/feed/delhi/?token=db08cb881a4e251a39e89b3f73c89d52edb2b77e");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data']['aqi'];
      } else {
        print("failed to fetch current aqi:${response.statusCode}");
        return null;
      }
    } catch (err) {
      print("error : $err");
      return null;
    }
  }
}

Future<double> getAQIPrediction(List<double> inputData) async {
  final response = await http.post(
    Uri.parse('https://your-flask-api-url.com/predict'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'input': inputData}),
  );

  if (response.statusCode == 200) {
    final result = jsonDecode(response.body);
    return result['prediction'][0];
  } else {
    throw Exception('Failed to get prediction');
  }
}
