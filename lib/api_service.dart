import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://127.0.0.1:8000/api';

class ApiService {
  // Get all books with search and filter
  static Future<List<dynamic>> getBooks({String search = '', String status = 'all'}) async {
    String url = '$baseUrl/books/?status=$status';
    if (search.isNotEmpty) {
      url += '&search=${Uri.encodeComponent(search)}';
    }
    final response = await http.get(Uri.parse(url));
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
  static Future<Map<String, dynamic>> addBook(Map<String, dynamic> bookData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/books/create/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(bookData),
    );
    return {
      'success': response.statusCode == 201,
      'data': jsonDecode(response.body),
    };
  }

  // Update a book
  static Future<Map<String, dynamic>> updateBook(int id, Map<String, dynamic> bookData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/books/$id/update/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(bookData),
    );
    return {
      'success': response.statusCode == 200,
      'data': jsonDecode(response.body),
    };
  }
}