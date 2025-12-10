import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/quote.dart';
import '../widgets/info_banner.dart';
import '../widgets/quote_card.dart';

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  static const String address = 'https://zenquotes.io/api/quotes';
  List<Quote> quotes = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchQuotes();
  }

  Future<void> _fetchQuotes() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final Uri url = Uri.parse(address);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List quotesJson = json.decode(response.body);
        List<Quote> fetchedQuotes = quotesJson
            .map(
              (quoteData) => Quote.fromJson(quoteData as Map<String, dynamic>),
            )
            .toList();
        setState(() {
          quotes = fetchedQuotes;
          isLoading = false;
        });
      } else {
        setState(() {
          quotes = [];
          isLoading = false;
          errorMessage =
              'Failed to load quotes. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        quotes = [];
        isLoading = false;
        errorMessage = 'Error while fetching quotes';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Quotes (http.dart)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          const InfoBanner(
            text: 'Using http.dart',
            icon: Icons.http,
            color: Colors.blue,
          ),
          if (errorMessage != null)
            InfoBanner(
              text: errorMessage!,
              icon: Icons.error_outline,
              color: Colors.red,
            ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : quotes.isEmpty
                ? const Center(
                    child: Text(
                      'No quotes available.\nTap refresh to load quotes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: quotes.length,
                    itemBuilder: (context, index) => QuoteCard(
                      quote: quotes[index],
                      index: index,
                      badge: 'http.dart',
                      badgeColor: Colors.blue,
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: isLoading ? null : _fetchQuotes,
        tooltip: 'Refresh Quotes',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
