# RFID-Based Access Control System with Flutter Admin App

This project is an RFID-based access control system with a Flutter Admin App. The system involves an ESP32-based device for RFID reading and access control, a backend server for UID validation, and a Flutter Admin app for managing users and access attempts.

## Features

- **Access Control**: Authenticate users using RFID and grant or deny access.
- **User Management**: Add or remove users through the Flutter app.
- **Door Control**: Remotely open the door for any user from the admin app.
- **Access Logs**: Track and view all access attempts (granted or denied).
- **Real-time Notifications**: Firebase notifications for access attempts.
- **Relay Control**: Control a relay to unlock/lock the door.

## 1. Setting Up the Backend Server

### Install the required dependencies:

```bash
npm install
```

### Set up a MongoDB database:

- Set up either a local or cloud MongoDB database for storing user data and access logs.

### Configure Firebase in the backend:

1. Follow the [Firebase setup guide](https://firebase.google.com/docs/admin/setup) to initialize Firebase in your backend.
2. Obtain the Firebase Admin SDK credentials and store them in the server.

### Start the server:

```bash
node server.js
```

The server will listen for incoming requests on the specified port (default is 5000).

## 2. Setting Up the ESP32

### Install the required libraries in Arduino IDE:
- **WiFi**: For connecting to the network.
- **ESP-NOW**: For receiving data over the ESP-NOW protocol.
- **HTTPClient**: For sending POST requests to the server.

### Program the ESP32:
1. Open Arduino IDE and load the provided ESP32 code.
2. Set up Wi-Fi credentials (SSID and password).
3. Set the correct server URL in the code (`serverURL`).

### Wire the hardware:
1. Connect the RFID reader to the ESP32.
2. Connect the relay module to the ESP32 for controlling the door.

### Upload the code to the ESP32 using Arduino IDE.

## 3. Setting Up the Flutter Admin App

### Clone the repository and navigate to the Flutter app folder:

```bash
git clone <repository-url>
cd flutter-admin-app
```

### Install Flutter dependencies:

```bash
flutter pub get
```

### Set up Firebase in the Flutter app:

1. Follow the [Firebase setup guide for Flutter](https://firebase.flutter.dev/docs/overview) to integrate Firebase with the Flutter app.
2. Add the Firebase configuration to the `android/app` and `ios/Runner` directories as per the Firebase setup instructions.

### Run the app on an emulator or device:

```bash
flutter run
```

## 4. Testing

### Scan RFID Tag:
Once both the server and ESP32 are running, scan an RFID tag to test the access control.

### Grant or Deny Access:
The system will send the UID to the server for validation. If the UID exists, the system will grant access, unlocking the door. Otherwise, access will be denied.

### Flutter App Interaction:
The admin can:
- View a list of access attempts.
- Add new users by sending a request to the server.
- Remove users via the Flutter app interface.
- Open the door remotely for any user.

### Log Access:
Every access attempt is logged, and Firebase notifications are sent to the admin.

## Code Structure

### Backend (server.js)
- **validateUID**: Endpoint to validate the UID by querying the database and sending a notification.
- **Log**: Logs access attempts in the database.
- **User**: Model for storing user data, including UID and name.

### ESP32 Firmware
- **Wi-Fi Setup**: Connects the ESP32 to the specified Wi-Fi network.
- **ESP-NOW Setup**: Receives the UID via ESP-NOW from the RFID reader.
- **HTTP Request**: Sends the UID to the server for validation.
- **Relay Control**: Grants or denies access based on the server's response.

### Flutter Admin App
- **User Management**: Allows the admin to add or remove users.
- **Access Logs**: Displays a list of access attempts (granted/denied).
- **Door Control**: Allows the admin to open the door remotely.
- **Firebase Notifications**: Listens for notifications regarding access attempts.

## Troubleshooting

### Wi-Fi Issues:
- Ensure the ESP32 is connected to the correct Wi-Fi network and that the network allows internet access.

### Server Connection:
- Double-check the server URL in the ESP32 code to ensure it's correct.
- Ensure the server is running and accessible from the ESP32.

### Relay Not Working:
- Check the wiring and ensure the relay is connected to the correct GPIO pin.
- Verify the relay's functionality by testing with a simple GPIO control code.

### Firewall Issues:
- If you encounter connectivity issues, ensure that the Microsoft Defender Firewall is turned off or configured to allow communication with the server.

### UID Not Found:
- Ensure that the UID is present in the database before testing.

### Firebase Notifications:
- Ensure that Firebase Cloud Messaging is properly set up in both the backend and Flutter app.

## Conclusion

This RFID-based access control system with an admin Flutter app provides a secure and efficient way to manage access control. The app allows for easy user management and remote door control, while the server handles UID validation and logging. The system is perfect for securing locations and providing administrators with real-time access control insights.


