import 'package:flutter/material.dart';
import '../api_service.dart';
import 'borrow_screen.dart';

class MemberDetailScreen extends StatefulWidget {
  final int memberId;
  const MemberDetailScreen({super.key, required this.memberId});

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  Map<String, dynamic>? member;
  List<dynamic> history = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final m = await ApiService.getMember(widget.memberId);
      final h = await ApiService.getBorrowHistory(memberId: widget.memberId);
      setState(() { member = m; history = h; isLoading = false; });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Widget detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 120,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Details'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : member == null
              ? const Center(child: Text('Member not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Member Info Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: CircleAvatar(
                                  radius: 35,
                                  backgroundColor: Colors.teal,
                                  child: Text(member!['name'][0].toUpperCase(),
                                    style: const TextStyle(fontSize: 28, color: Colors.white)),
                                ),
                              ),
                              const SizedBox(height: 16),
                              detailRow('ID', '${member!['id']}'),
                              const Divider(),
                              detailRow('Name', member!['name']),
                              const Divider(),
                              detailRow('Email', member!['email']),
                              const Divider(),
                              detailRow('Joined', member!['joined_date'] ?? 'N/A'),
                              const Divider(),
                              detailRow('Status', member!['is_active'] ? 'Active' : 'Inactive'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Borrow Button
                      if (member!['is_active'])
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.push(context,
                                MaterialPageRoute(
                                  builder: (_) => BorrowScreen(member: member!)));
                              loadData();
                            },
                            icon: const Icon(Icons.book, color: Colors.white),
                            label: const Text('Borrow a Book',
                              style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding: const EdgeInsets.all(14),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Borrow History
                      const Text('Borrow History',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      history.isEmpty
                          ? const Text('No borrowing history.')
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: history.length,
                              itemBuilder: (context, index) {
                                final record = history[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: Icon(
                                      record['is_returned'] ? Icons.check_circle : Icons.book,
                                      color: record['is_returned'] ? Colors.green : Colors.orange,
                                    ),
                                    title: Text(record['book_title'] ?? 'Unknown'),
                                    subtitle: Text(
                                      'Copy: ${record['copy_number']} • Borrowed: ${record['borrowed_at'].toString().substring(0, 10)}'
                                      '${record['is_returned'] ? '\nReturned: ${record['returned_at'].toString().substring(0, 10)}' : ''}',
                                    ),
                                    trailing: record['is_returned']
                                        ? null
                                        : ElevatedButton(
                                            onPressed: () async {
                                              final result = await ApiService.returnBook(record['id']);
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(result['success']
                                                      ? 'Book returned!' : 'Failed to return'),
                                                  backgroundColor: result['success']
                                                      ? Colors.green : Colors.red,
                                                ));
                                              if (result['success']) loadData();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange),
                                            child: const Text('Return',
                                              style: TextStyle(color: Colors.white)),
                                          ),
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
    );
  }
}