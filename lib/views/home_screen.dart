import 'package:daily_notifications/controller/quote_controller.dart';
import 'package:daily_notifications/models/quotes.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DailyQuoteController _controller = DailyQuoteController();
  late DailyQuote _dailyQuote;

  @override
  void initState() {
    super.initState();
    _fetchDailyQuote();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchDailyQuote();
  }

  Future<void> _fetchDailyQuote() async {
    final quote = await _controller.fetchDailyQuote();
    setState(() {
      _dailyQuote = quote;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
      ),
      body: Center(
        child: _dailyQuote == null
            ? CircularProgressIndicator()
            : Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _dailyQuote.text,
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '- ${_dailyQuote.author}',
                      textAlign: TextAlign.end,
                      style:
                          TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
