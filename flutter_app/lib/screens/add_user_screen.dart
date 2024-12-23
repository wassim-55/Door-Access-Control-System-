import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for input formatting
import '../services/api_service.dart';
import '../models/user.dart';  // Correctly import User class

class AddUserScreen extends StatefulWidget {
  final Function(User) onSave; // Save user function after API call

  // Constructor to accept onSave
  AddUserScreen({required this.onSave});

  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  String uid = '';
  String name = '';
  final ApiService apiService = ApiService(); // Initialize api_service.dart

  // Regular expression to match the format xx:xx:xx:xx
  final RegExp uidRegExp = RegExp(r'^[a-zA-Z0-9]{2}(:[a-zA-Z0-9]{2}){3}$');

  // Function to handle saving the user
  Future<void> _saveUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final response = await apiService.addUser({
          'uid': uid,
          'name': name,
        });

        if (response['message'] == 'User added successfully') {
          widget.onSave(User(uid: uid, name: name, isLocked: true));

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User "$name" added successfully!')),
          );

          Future.delayed(Duration(milliseconds: 500), () {
            Navigator.pop(context);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add user')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // Input Formatters to assist with formatting
  List<TextInputFormatter> get uidInputFormatters {
    return [
      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9:]')),
      LengthLimitingTextInputFormatter(11), // Format xx:xx:xx:xx has 11 characters
      _UIDInputFormatter(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New User'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'UID',
                  hintText: 'Format: xx:xx:xx:xx',
                ),
                keyboardType: TextInputType.text,
                inputFormatters: uidInputFormatters, // Apply input formatters
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a UID';
                  }
                  if (!uidRegExp.hasMatch(value)) {
                    return 'UID must follow the format xx:xx:xx:xx';
                  }
                  return null;
                },
                onSaved: (value) {
                  uid = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) {
                  name = value!;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveUser,
                child: Text('Save User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom InputFormatter to automatically insert colons at the correct positions
class _UIDInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.toUpperCase();

    // Remove any existing colons
    text = text.replaceAll(':', '');

    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      // Insert colon after every 2 characters, but not after the last group
      if ((i + 1) % 2 == 0 && i + 1 != text.length && i + 1 < 8) {
        buffer.write(':');
      }
    }

    String formatted = buffer.toString();
    if (formatted.length > 11) {
      formatted = formatted.substring(0, 11);
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}