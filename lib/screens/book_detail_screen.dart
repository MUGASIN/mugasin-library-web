import 'package:flutter/material.dart';
import '../api_service.dart';

class BookDetailScreen extends StatefulWidget {
  final int bookId;
  const BookDetailScreen({super.key, required this.bookId});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  Map<String, dynamic>? book;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBook();
  }

  Future<void> loadBook() async {
    try {
      final data = await ApiService.getBook(widget.bookId);
      setState(() { book = data; isLoading = false; });
    } catch (e) {
      setState(() { isLoading = false; });
    }
  }

  Widget detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : book == null
              ? const Center(child: Text('Book not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.indigo,
                              child: Text(
                                book!['title'][0].toUpperCase(),
                                style: const TextStyle(fontSize: 32, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          detailRow('Title', book!['title']),
                          const Divider(),
                          detailRow('Author', book!['author']),
                          const Divider(),
                          detailRow('ISBN', book!['isbn']),
                          const Divider(),
                          detailRow('Category', book!['category'] ?? 'N/A'),
                          const Divider(),
                          detailRow('Published Year', '${book!['publication_year']}'),
                          const Divider(),
                          detailRow('Status', book!['is_active'] ? 'Active' : 'Inactive'),
                          const Divider(),
                          detailRow('Book ID', '${book!['id']}'),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}