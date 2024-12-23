#include <WiFi.h>

#include <esp_now.h>

#include <HTTPClient.h>

#include <esp_wifi.h> // Include esp_wifi.h for Wi-Fi functions


// Wi-Fi credentials

const char* ssid = "*******";          // Replace with your Wi-Fi SSID

const char* password = "**************"; // Replace with your Wi-Fi password


// Wi-Fi channel (must match the sender)

#define WIFI_CHANNEL 6  // Replace with the correct channel of the sender


// Server URL

const char* serverURL = "http://********/api/validate-uid"; // Replace with your server's URL or IP


// Structure to hold the received data

typedef struct struct_message {

  char msg[32]; // Buffer to store the UID (formatted as D3:EC:62:1A)

} struct_message;


struct_message receivedData;  // Instance to hold the received data

String uidToSend = "";        // Store UID for HTTP sending

bool hasNewUID = false;       // Flag to indicate a new UID

// Relay pin
const int relayPin = 5; // Change to the GPIO pin connected to the relay


void setup() {

  Serial.begin(115200);


  // Print the ESP32's MAC address

  String macAddress = WiFi.macAddress();

  Serial.println("ESP32 MAC Address: " + macAddress);


  // Configure Wi-Fi

  WiFi.mode(WIFI_STA);         // Set ESP32 as a station (client)

  WiFi.disconnect();           // Disconnect from any previous connections

  esp_wifi_set_promiscuous(true);

  esp_wifi_set_channel(WIFI_CHANNEL, WIFI_SECOND_CHAN_NONE); // Set the same channel as the sender

  esp_wifi_set_promiscuous(false);


  // Connect to Wi-Fi

  WiFi.begin(ssid, password);

  Serial.print("Connecting to Wi-Fi");

  while (WiFi.status() != WL_CONNECTED) {

    delay(500);

    Serial.print(".");

  }

  Serial.println("\nWi-Fi connected");


  // Initialize ESP-NOW

  if (esp_now_init() != ESP_OK) {

    Serial.println("Error initializing ESP-NOW");

    return;

  }

  Serial.print("ESP32 IP Address: ");

  Serial.println(WiFi.localIP());

  // Register the receive callback function

  esp_now_register_recv_cb(onDataReceived);

  Serial.println("ESP-NOW initialized and callback registered");

  // Initialize relay pin
  pinMode(relayPin, OUTPUT);
  digitalWrite(relayPin, LOW); // Ensure relay is off initially
}


void loop() {

  // Ensure Wi-Fi is connected before sending data

  if (WiFi.status() != WL_CONNECTED) {

    Serial.println("Wi-Fi disconnected. Reconnecting...");

    WiFi.begin(ssid, password);

    while (WiFi.status() != WL_CONNECTED) {

      delay(500);

      Serial.print(".");

    }

    Serial.println("\nWi-Fi reconnected");

  }


  // Process HTTP request if there's a new UID

  if (hasNewUID) {

    sendToServer(uidToSend);

    hasNewUID = false; // Reset flag after processing

  }

}


// Callback function to handle incoming data

void onDataReceived(const uint8_t* mac, const uint8_t* incomingData, int len) {

  Serial.println("Callback triggered for incoming data");


  if (len == sizeof(struct_message)) {

    memcpy(&receivedData, incomingData, sizeof(struct_message));


    // Format UID with colons

    uidToSend = String(receivedData.msg);


    Serial.print("Received UID: ");

    Serial.println(uidToSend);


    // Set flag to indicate a new UID

    hasNewUID = true;

  } else {

    Serial.println("Invalid data length received");

  }

}


// Function to send the UID to the server

void sendToServer(String uid) {

  if (WiFi.status() == WL_CONNECTED) {

    HTTPClient http;

    http.begin(serverURL);  // Specify the server URL

    http.addHeader("Content-Type", "application/json"); // Set content type to JSON


    // Set timeout to 10 seconds

    http.setTimeout(20000);  // Timeout of 10 seconds


    // Create JSON payload

    String payload = "{\"uid\": \"" + uid + "\"}";


    // Send POST request

    int httpResponseCode = http.POST(payload);


    if (httpResponseCode > 0) {

      Serial.print("HTTP Response code: ");

      Serial.println(httpResponseCode);


      // Handle server response

      String response = http.getString();

      Serial.println("Server Response: " + response);


      if (httpResponseCode == 200) {

        Serial.println("Access Granted: UID is valid");

        grantAccess();

      } else if (httpResponseCode == 404) {

        Serial.println("Access Denied: UID not found");

        denyAccess();

      } else {

        Serial.println("Error: Invalid response from server");

      }

    } else {

      Serial.print("Error in sending POST: ");

      Serial.println(http.errorToString(httpResponseCode).c_str());

    }


    http.end(); // Close connection

  } else {

    Serial.println("Wi-Fi not connected. Cannot send data to server.");

  }

}


// Function to grant access

void grantAccess() {

  Serial.println("Activating green LED for access granted");

  // Activate relay to unlock door
  digitalWrite(relayPin, HIGH); // Turn relay on (unlock)
  delay(5000);                 // Keep it unlocked for 5 seconds
  digitalWrite(relayPin, LOW);  // Turn relay off (lock)
}


// Function to deny access

void denyAccess() {

  Serial.println("Activating red LED for access denied");

  // Add hardware control logic here (e.g., turning on a red LED)
}