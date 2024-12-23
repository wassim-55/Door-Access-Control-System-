import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://10.0.2.2:5000/api'; // Replace with your backend API URL

  // Add User
  Future<Map<String, dynamic>> addUser(Map<String, String> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add-user'),
      body: json.encode(userData),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Add User Failed: ${response.body}');
      throw Exception('Failed to add user: ${response.statusCode}');
    }
  }

  // Fetch All Users
  Future<List<dynamic>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/get-users'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Fetch Users Failed: ${response.body}');
      throw Exception('Failed to fetch users: ${response.statusCode}');
    }
  }

// Fetch all logs
  Future<List<Map<String, dynamic>>> getLogs() async {
    final response = await http.get(Uri.parse('$baseUrl/logs')); // Properly reference baseUrl

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch logs: ${response.statusCode}');
    }
  }

  // Delete User
  Future<Map<String, dynamic>> deleteUser(String uid) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/remove-user/$uid'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Delete User Failed: ${response.body}');
      throw Exception('Failed to delete user: ${response.statusCode}');
    }
  }

  // Fetch Logs for a Specific User
  Future<List<dynamic>> getUserLogs(String uid) async {
    final response = await http.get(Uri.parse('$baseUrl/logs/$uid'));

    if (response.statusCode == 200) {
      print('Logs Response: ${response.body}');
      return json.decode(response.body);
    } else {
      print('Fetch Logs Failed: ${response.body}');
      throw Exception('Failed to load logs: ${response.statusCode}');
    }
  }


  Future<void> openDoor(String uid) async {
    final url = Uri.parse('$baseUrl/open-door');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'uid': uid}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to open door: ${response.body}');
    }
  }
  }


