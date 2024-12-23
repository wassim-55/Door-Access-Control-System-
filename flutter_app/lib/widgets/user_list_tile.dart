import 'package:flutter/material.dart';
import '../models/user.dart';

class UserListTile extends StatelessWidget {
  final User user;
  final Function onOpenDoor;
  final Function onViewLogs;
  final bool buttonState; // State of the "Open Door" button

  UserListTile({
    required this.user,
    required this.onOpenDoor,
    required this.onViewLogs,
    required this.buttonState,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue,
        child: Text(user.name.substring(0, 1).toUpperCase()),
      ),
      title: Text(user.name),
      subtitle: Text('UID: ${user.uid}'),
      trailing: ElevatedButton(
        onPressed: () => onOpenDoor(),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonState ? Colors.green : Colors.red,
        ),
        child: Text(buttonState ? 'Opening...' : 'Open Door'),
      ),
      onTap: () => onViewLogs(),
    );
  }
}
