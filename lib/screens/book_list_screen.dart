import 'package:flutter/material.dart';
import '../api_service.dart';
import 'book_detail_screen.dart';
import 'add_book_screen.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  List<dynamic> books = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

  Future<void> loadBooks() async {
    try {
      setState(() { isLoading = true; error = null; });
      final data = await ApiService.getBooks();
      setState(() { books = data; isLoading = false; });
    } catch (e) {
      setState(() { error = 'Failed to load books'; isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library Books'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadBooks)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddBookScreen()));
          loadBooks();
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 10),
                    ElevatedButton(onPressed: loadBooks, child: const Text('Retry')),
                  ],
                ))
              : books.isEmpty
                  ? const Center(child: Text('No books yet. Add one!'))
                  : RefreshIndicator(
                      onRefresh: loadBooks,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          final book = books[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.indigo,
                                child: Text(
                                  book['title'][0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(book['title'],
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${book['author']} • ${book['publication_year']}'),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: book['is_active'] ? Colors.green[100] : Colors.red[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  book['is_active'] ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    color: book['is_active'] ? Colors.green[800] : Colors.red[800],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              onTap: () => Navigator.push(context,
                                MaterialPageRoute(
                                  builder: (_) => BookDetailScreen(bookId: book['id']))),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}