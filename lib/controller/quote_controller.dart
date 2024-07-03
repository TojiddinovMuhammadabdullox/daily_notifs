import 'dart:convert';
import 'package:daily_notifications/models/quotes.dart';
import 'package:http/http.dart' as http;

class DailyQuoteController {
  Future<DailyQuote> fetchDailyQuote() async {
    final response = await http.get(Uri.parse('https://type.fit/api/quotes'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return DailyQuote(
          author: data[0]['author'] ?? 'Unknown',
          text: data[0]['text'] ?? 'No quote available',
        );
      }
    }
    return DailyQuote(author: 'Unknown', text: 'No quote available');
  }
}
