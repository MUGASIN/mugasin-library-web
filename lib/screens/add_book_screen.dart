import 'package:flutter/material.dart';
import '../api_service.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final isbnController = TextEditingController();
  final categoryController = TextEditingController();
  final yearController = TextEditingController();
  bool isActive = true;
  bool isLoading = false;

  Future<void> submitBook() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    final result = await ApiService.addBook({
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
        const SnackBar(content: Text('Book added successfully!'),
          backgroundColor: Colors.green));
      Navigator.pop(context);
    } else {
      // Show API error (e.g. duplicate)
      final errors = result['data'];
      String message = 'Failed to add book';
      if (errors is Map) {
        message = errors.values.first is List
            ? errors.values.first[0]
            : errors.values.first.toString();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Book'),
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
                activeColor: Colors.indigo,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : submitBook,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Add Book', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}