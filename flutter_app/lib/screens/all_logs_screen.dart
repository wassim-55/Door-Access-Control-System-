import 'package:flutter/material.dart';

class AllLogsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> logs;

  AllLogsScreen({required this.logs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Access Logs'),
        centerTitle: true,
      ),
      body: logs.isEmpty
          ? Center(child: Text('No logs available'))
          : ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
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
              title: Text(
                'Action By: ${log['name'] ?? 'Unknown'}', // Use 'user_name' if available, else 'Unknown'
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status: ${log['status'] ?? 'Unknown'}'), // Status (Granted/Denied)
                  Text('Timestamp: ${log['timestamp'] ?? 'No Timestamp'}'), // Timestamp of action
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
