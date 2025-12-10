import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/quote.dart';
import '../services/quote_api_service.dart';

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
    // Initialize Dio and the API service
    final dio = Dio();
    
    // Add logging interceptor for debugging
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => debugPrint(object.toString()),
      ),
    );
    
    _apiService = QuoteApiService(dio);
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
        actions: [
          IconButton(
            onPressed: isLoading ? null : _fetchQuotes,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Quotes',
          ),
        ],
      ),
      body: Column(
        children: [
          // Technology indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              border: Border.all(color: Colors.green),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.code, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Using Dio + Retrofit',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
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
                    itemBuilder: (context, index) {
                      final quote = quotes[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.format_quote,
                                    size: 24,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Quote ${index + 1}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Dio',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                quote.text,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '— ${quote.author}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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