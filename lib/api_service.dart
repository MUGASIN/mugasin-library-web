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

  // ── MEMBERS ──────────────────────────────────────

  static Future<List<dynamic>> getMembers() async {
    final response = await http.get(Uri.parse('$baseUrl/members/'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load members');
  }

  static Future<Map<String, dynamic>> getMember(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/members/$id/'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load member');
  }

  static Future<Map<String, dynamic>> addMember(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/members/create/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return {'success': response.statusCode == 201, 'data': jsonDecode(response.body)};
  }

  // ── BOOK COPIES ───────────────────────────────────

  static Future<List<dynamic>> getBookCopies(int bookId) async {
    final response = await http.get(Uri.parse('$baseUrl/books/$bookId/copies/'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load copies');
  }

  static Future<Map<String, dynamic>> addBookCopy(int bookId, String copyNumber) async {
    final response = await http.post(
      Uri.parse('$baseUrl/books/$bookId/copies/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'book': bookId, 'copy_number': copyNumber, 'status': 'available'}),
    );
    return {'success': response.statusCode == 201, 'data': jsonDecode(response.body)};
  }

  // ── BORROW & RETURN ───────────────────────────────

  static Future<Map<String, dynamic>> borrowBook(int memberId, int copyId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/borrow/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'member_id': memberId, 'copy_id': copyId}),
    );
    return {'success': response.statusCode == 201, 'data': jsonDecode(response.body)};
  }

  static Future<Map<String, dynamic>> returnBook(int recordId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/return/$recordId/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({}),
    );
    return {'success': response.statusCode == 200, 'data': jsonDecode(response.body)};
  }

  static Future<List<dynamic>> getBorrowHistory({int? memberId}) async {
    String url = '$baseUrl/borrow/history/';
    if (memberId != null) url += '?member_id=$memberId';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load history');
  }
}