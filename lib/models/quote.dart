class Quote {
  final String text;
  final String author;

  Quote({required this.text, required this.author});

  factory Quote.fromJson(Map<String, dynamic> json) =>
      Quote(text: json['q'] as String, author: json['a'] as String);
}
