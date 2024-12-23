import 'package:flutter/material.dart';
import '../models/user.dart';
import '../screens/add_user_screen.dart';
import '../screens/rfid_history_screen.dart';
import '../screens/all_logs_screen.dart'; // Import the logs screen
import '../widgets/user_list_tile.dart';

class RFIDAccessScreen extends StatelessWidget {
  final Function() onThemeToggle;
  final List<User> users;
  final Function(User) addUser;
  final Function(String) openDoor; // Updated function
  final Function(String) removeUser;
  final Map<String, bool> buttonState; // Button state map for Open Door
  final List<Map<String, dynamic>> accessLogs; // List of access logs

  RFIDAccessScreen({
    required this.onThemeToggle,
    required this.users,
    required this.addUser,
    required this.openDoor,
    required this.removeUser,
    required this.buttonState,
    required this.accessLogs,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RFID Access Control'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'User Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddUserScreen(onSave: addUser),
                      ),
                    );
                  },
                  child: Text('Add User'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllLogsScreen(logs: accessLogs),
                      ),
                    );
                  },
                  child: Text('Logs'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return UserListTile(
                    user: user,
                    onOpenDoor: () => openDoor(user.uid), // Correct call
                    onViewLogs: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RFIDHistoryScreen(
                            user: user,
                            onDelete: removeUser,
                          ),
                        ),
                      );
                    },
                    buttonState: buttonState[user.uid] ?? false, // Track button state
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.light_mode),
              onPressed: onThemeToggle,
            ),
            IconButton(
              icon: Icon(Icons.dark_mode),
              onPressed: onThemeToggle,
            ),
          ],
        ),
      ),
    );
  }
}
