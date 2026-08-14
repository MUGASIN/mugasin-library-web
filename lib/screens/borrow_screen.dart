import 'package:flutter/material.dart';
import '../api_service.dart';

class BorrowScreen extends StatefulWidget {
  final Map<String, dynamic> member;
  const BorrowScreen({super.key, required this.member});

  @override
  State<BorrowScreen> createState() => _BorrowScreenState();
}

class _BorrowScreenState extends State<BorrowScreen> {
  List<dynamic> books = [];
  List<dynamic> copies = [];
  int? selectedBookId;
  int? selectedCopyId;
  bool isLoadingBooks = true;
  bool isLoadingCopies = false;
  bool isBorrowing = false;

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

  Future<void> loadBooks() async {
    try {
      final data = await ApiService.getBooks();
      setState(() { books = data; isLoadingBooks = false; });
    } catch (e) {
      setState(() => isLoadingBooks = false);
    }
  }

  Future<void> loadCopies(int bookId) async {
    setState(() { isLoadingCopies = true; copies = []; selectedCopyId = null; });
    try {
      final data = await ApiService.getBookCopies(bookId);
      setState(() {
        copies = data.where((c) => c['status'] == 'available').toList();
        isLoadingCopies = false;
      });
    } catch (e) {
      setState(() => isLoadingCopies = false);
    }
  }

  Future<void> borrowBook() async {
    if (selectedCopyId == null) return;
    setState(() => isBorrowing = true);
    final result = await ApiService.borrowBook(
      widget.member['id'],
      selectedCopyId!,
    );
    setState(() => isBorrowing = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['success'] ? 'Book borrowed successfully!' : 
          result['data']['error'] ?? 'Failed to borrow'),
        backgroundColor: result['success'] ? Colors.green : Colors.red,
      ));
    if (result['success']) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Borrow Book — ${widget.member['name']}'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: isLoadingBooks
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select a Book',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    hint: const Text('Choose a book'),
                    value: selectedBookId,
                    items: books.map((book) {
                      return DropdownMenuItem<int>(
                        value: book['id'] as int,
                        child: Text(book['title'], overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => selectedBookId = val);
                      if (val != null) loadCopies(val);
                    },
                  ),
                  const SizedBox(height: 20),
                  if (selectedBookId != null) ...[
                    const Text('Select Available Copy',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    isLoadingCopies
                        ? const CircularProgressIndicator()
                        : copies.isEmpty
                            ? const Text('No available copies for this book.',
                                style: TextStyle(color: Colors.red))
                            : DropdownButtonFormField<int>(
                                decoration: const InputDecoration(border: OutlineInputBorder()),
                                hint: const Text('Choose a copy'),
                                value: selectedCopyId,
                                items: copies.map((copy) {
                                  return DropdownMenuItem<int>(
                                    value: copy['id'] as int,
                                    child: Text('Copy ${copy['copy_number']}'),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => selectedCopyId = val),
                              ),
                  ],
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (selectedCopyId == null || isBorrowing) ? null : borrowBook,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                      child: isBorrowing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Confirm Borrow',
                              style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}