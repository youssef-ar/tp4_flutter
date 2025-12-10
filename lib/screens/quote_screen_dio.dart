import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/quote.dart';
import '../services/quote_api_service.dart';
import '../widgets/info_banner.dart';
import '../widgets/quote_card.dart';

class QuoteScreenDio extends StatefulWidget {
  const QuoteScreenDio({super.key});

  @override
  State<QuoteScreenDio> createState() => _QuoteScreenDioState();
}

class _QuoteScreenDioState extends State<QuoteScreenDio> {
  late QuoteApiService _apiService;
  List<Quote> quotes = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _apiService = QuoteApiService(Dio());
    _fetchQuotes();
  }

  Future<void> _fetchQuotes() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      List<Quote> fetchedQuotes = await _apiService.getQuotes();
      setState(() {
        quotes = fetchedQuotes;
        isLoading = false;
      });
    } on DioException catch (e) {
      String message = 'Network error occurred';

      if (e.type == DioExceptionType.connectionTimeout) {
        message = 'Connection timeout';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        message = 'Receive timeout';
      } else if (e.type == DioExceptionType.badResponse) {
        message = 'Server error: ${e.response?.statusCode}';
      } else if (e.type == DioExceptionType.connectionError) {
        message = 'Connection error';
      }

      setState(() {
        quotes = [];
        isLoading = false;
        errorMessage = message;
      });
    } catch (e) {
      setState(() {
        quotes = [];
        isLoading = false;
        errorMessage = 'Unexpected error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Quotes (Dio + Retrofit)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          const InfoBanner(
            text: 'Using Dio + Retrofit',
            icon: Icons.code,
            color: Colors.green,
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
                      badge: 'Dio',
                      badgeColor: Colors.green,
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
