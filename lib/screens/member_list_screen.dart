import 'package:flutter/material.dart';
import '../api_service.dart';
import 'member_detail_screen.dart';
import 'add_member_screen.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  List<dynamic> members = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadMembers();
  }

  Future<void> loadMembers() async {
    try {
      setState(() { isLoading = true; error = null; });
      final data = await ApiService.getMembers();
      setState(() { members = data; isLoading = false; });
    } catch (e) {
      setState(() { error = 'Failed to load members'; isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library Members'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadMembers)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddMemberScreen()));
          loadMembers();
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
              : members.isEmpty
                  ? const Center(child: Text('No members yet. Add one!'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.teal,
                              child: Text(
                                member['name'][0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(member['name'],
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(member['email']),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: member['is_active'] ? Colors.green[100] : Colors.red[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                member['is_active'] ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  color: member['is_active'] ? Colors.green[800] : Colors.red[800],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            onTap: () async {
                              await Navigator.push(context,
                                MaterialPageRoute(
                                  builder: (_) => MemberDetailScreen(memberId: member['id'])));
                              loadMembers();
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}