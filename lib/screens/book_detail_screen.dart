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
        actions: [
          if (book != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditBookScreen(book: book!),
                  ),
                );
                loadBook();
              },
            ),
        ],
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

// Edit Book Screen
class EditBookScreen extends StatefulWidget {
  final Map<String, dynamic> book;
  const EditBookScreen({super.key, required this.book});

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController authorController;
  late TextEditingController isbnController;
  late TextEditingController categoryController;
  late TextEditingController yearController;
  late bool isActive;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.book['title']);
    authorController = TextEditingController(text: widget.book['author']);
    isbnController = TextEditingController(text: widget.book['isbn']);
    categoryController = TextEditingController(text: widget.book['category'] ?? '');
    yearController = TextEditingController(text: '${widget.book['publication_year']}');
    isActive = widget.book['is_active'];
  }

  Future<void> submitEdit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    final result = await ApiService.updateBook(widget.book['id'], {
      'title': titleController.text.trim(),
      'author': authorController.text.trim(),
      'isbn': isbnController.text.trim(),
      'category': categoryController.text.trim(),
      'publication_year': int.parse(yearController.text.trim()),
      'is_active': isActive,
    });
    setState(() => isLoading = false);

    if (result['success'] && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book updated successfully!'),
          backgroundColor: Colors.green));
      Navigator.pop(context);
    } else {
      final errors = result['data'];
      String message = 'Failed to update book';
      if (errors is Map) {
        message = errors.values.first is List
            ? errors.values.first[0]
            : errors.values.first.toString();
      }if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Book'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title *', border: OutlineInputBorder()),
                validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: authorController,
                decoration: const InputDecoration(labelText: 'Author *', border: OutlineInputBorder()),
                validator: (v) => v == null || v.trim().isEmpty ? 'Author is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: isbnController,
                decoration: const InputDecoration(labelText: 'ISBN *', border: OutlineInputBorder()),
                validator: (v) => v == null || v.trim().isEmpty ? 'ISBN is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: yearController,
                decoration: const InputDecoration(labelText: 'Publication Year *', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Year is required';
                  final year = int.tryParse(v.trim());
                  if (year == null || year < 1000 || year > 2026) return 'Enter a valid year (1000-2026)';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Active Status'),
                value: isActive,
                onChanged: (val) => setState(() => isActive = val),
                activeThumbColor: Colors.indigo,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : submitEdit,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Update Book', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}