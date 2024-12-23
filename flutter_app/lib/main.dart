import 'package:flutter/material.dart';
import 'screens/rfid_access_screen.dart';
import 'utils/theme_utils.dart';
import 'models/user.dart';
import 'services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Global key for ScaffoldMessenger
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
  GlobalKey<ScaffoldMessengerState>();

  ThemeMode _themeMode = ThemeMode.system;
  final List<User> _users = [];
  final ApiService _apiService = ApiService();
  Map<String, bool> _buttonState = {};
  List<Map<String, dynamic>> _accessLogs = [];

  @override
  void initState() {
    super.initState();
    _loadThemeMode(); // Load persisted theme
    _fetchUsers();
    _fetchAccessLogs();
  }

  /// Load saved theme mode from local storage
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('themeMode') ?? 'system';
    setState(() {
      _themeMode = savedTheme == 'dark'
          ? ThemeMode.dark
          : savedTheme == 'light'
          ? ThemeMode.light
          : ThemeMode.system;
    });
  }

  /// Persist selected theme mode
  Future<void> _saveThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = _themeMode == ThemeMode.dark
        ? 'dark'
        : _themeMode == ThemeMode.light
        ? 'light'
        : 'system';
    await prefs.setString('themeMode', mode);
  }

  Future<void> _fetchUsers() async {
    try {
      final usersFromApi = await _apiService.getUsers();
      setState(() {
        _users
          ..clear()
          ..addAll(usersFromApi.map((userJson) => User.fromJson(userJson)));
      });
    } catch (e) {
      _showSnackBar('Failed to load users: $e');
    }
  }

  Future<void> _fetchAccessLogs() async {
    try {
      final logsFromApi = await _apiService.getLogs();
      setState(() {
        _accessLogs = logsFromApi;
      });
    } catch (e) {
      _showSnackBar('Failed to load access logs: $e');
    }
  }

  /// Refresh the app data when pulling down
  Future<void> _refreshAppData() async {
    await Future.wait([
      _fetchUsers(),
      _fetchAccessLogs(),
    ]);
    _showSnackBar("Data refreshed!");
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = ThemeUtils.toggleTheme(_themeMode);
      _saveThemeMode(); // Persist the selected theme
    });
  }

  void _addUser(BuildContext context, User user) {
    if (_users.any((existingUser) => existingUser.uid == user.uid)) {
      _showSnackBar('UID ${user.uid} already exists!');
      return;
    }

    setState(() {
      _users.add(user);
    });

    _showSnackBar('User "${user.name}" added successfully!');
  }

  Future<void> _removeUser(String uid) async {
    try {
      final response = await _apiService.deleteUser(uid);

      if (response['message'] == 'User deleted successfully') {
        setState(() {
          _users.removeWhere((user) => user.uid == uid);
        });
        _showSnackBar('User removed successfully!');
      } else {
        _showSnackBar('Failed to delete user: ${response['error']}');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  Future<void> _openDoor(String uid) async {
    try {
      setState(() {
        _buttonState[uid] = true;
      });

      await _apiService.openDoor(uid);

      _showSnackBar('Door opened successfully for UID: $uid');
    } catch (e) {
      _showSnackBar('Failed to open door: $e');
    } finally {
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _buttonState[uid] = false;
          });
        }
      });
    }
  }

  void _showSnackBar(String message) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _scaffoldMessengerKey, // Attach GlobalKey
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: RefreshIndicator(
        onRefresh: _refreshAppData,
        child: RFIDAccessScreen(
          onThemeToggle: _toggleTheme,
          users: _users,
          addUser: (user) => _addUser(context, user),
          removeUser: _removeUser,
          openDoor: _openDoor,
          buttonState: _buttonState,
          accessLogs: _accessLogs,
        ),
      ),
    );
  }
}