import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class RFIDHistoryScreen extends StatefulWidget {
  final User user;
  final Function(String) onDelete;

  RFIDHistoryScreen({
    required this.user,
    required this.onDelete,
  });

  @override
  _RFIDHistoryScreenState createState() => _RFIDHistoryScreenState();
}

class _RFIDHistoryScreenState extends State<RFIDHistoryScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLogs(); // Fetch logs for the current user
  }

  Future<void> _fetchLogs() async {
    try {
      print('Fetching logs for UID: ${widget.user.uid}');
      final logs = await _apiService.getUserLogs(widget.user.uid);
      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching logs: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load logs: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _deleteUser() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete User'),
          content: Text('Are you sure you want to delete ${widget.user.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldDelete ?? false) {
      try {
        await _apiService.deleteUser(widget.user.uid);
        widget.onDelete(widget.user.uid); // Notify parent screen
        Navigator.pop(context);
      } catch (e) {
        print('Error deleting user: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete user')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logs for ${widget.user.name}'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteUser,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Loading spinner
          : _logs.isEmpty
          ? Center(child: Text('No logs available for this user.'))
          : ListView.builder(
        itemCount: _logs.length,
        itemBuilder: (context, index) {
          final log = _logs[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: Icon(
                log['status'] == 'Granted'
                    ? Icons.check_circle
                    : Icons.cancel,
                color: log['status'] == 'Granted'
                    ? Colors.green
                    : Colors.red,
              ),
              title: Text('Status: ${log['status']}'),
              subtitle: Text('Timestamp: ${log['timestamp']}'),
            ),
          );
        },
      ),
    );
  }
}
