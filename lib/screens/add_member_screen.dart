import 'package:flutter/material.dart';
import '../api_service.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  bool isActive = true;
  bool isLoading = false;

  Future<void> submitMember() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    final result = await ApiService.addMember({
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'is_active': isActive,
    });
    setState(() => isLoading = false);
    if (!mounted) return;
    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member added!'), backgroundColor: Colors.green));
      Navigator.pop(context);
    } else {
      final errors = result['data'];
      String message = 'Failed to add member';
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
        title: const Text('Add Member'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name *', border: OutlineInputBorder()),
                validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email *', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email is required';
                  if (!v.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Active Status'),
                value: isActive,
                onChanged: (val) => setState(() => isActive = val),
                activeThumbColor: Colors.teal,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : submitMember,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Add Member', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}