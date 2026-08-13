import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://127.0.0.1:8000/api';

class ApiService {
  // Get all books
  static Future<List<dynamic>> getBooks() async {
    final response = await http.get(Uri.parse('$baseUrl/books/'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load books');
  }

  // Get single book
  static Future<Map<String, dynamic>> getBook(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/books/$id/'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load book');
  }

  // Add a book
  static Future<bool> addBook(Map<String, dynamic> bookData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/books/create/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(bookData),
    );
    return response.statusCode == 201;
  }
}