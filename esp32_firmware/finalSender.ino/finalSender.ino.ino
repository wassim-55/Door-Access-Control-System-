#include <SPI.h>

#include <MFRC522.h>

#include <esp_now.h>

#include <esp_wifi.h>

#include <WiFi.h>


// Pin configuration for MFRC522

#define RST_PIN 0 // Reset pin

#define SS_PIN 5 // Slave Select (SDA) pin


MFRC522 rfid(SS_PIN, RST_PIN); // Create an MFRC522 instance


// MAC address of the receiver ESP32 (replace with your receiver's MAC address)

uint8_t receiverMAC[] = {0xE4, 0x62, 0x63, 0xF2, 0x10, 0x33};


// Wi-Fi channel configuration

#define WIFI_CHANNEL 6 // Set to match the receiver's Wi-Fi channel


// Structure for sending messages

// Structure for sending messages
typedef struct struct_message {
    char msg[32]; // Message buffer to store UID
} struct_message;

struct_message myData;

// Correct UID
const String correctUID = "D3:EC:62:1A";

// Pin configuration for LEDs and buzzer
#define RED_LED_PIN 25
#define GREEN_LED_PIN 33
#define BUZZER_PIN 14

// Callback when a message is sent via ESP-NOW
void onSent(const uint8_t *macAddr, esp_now_send_status_t status) {
    Serial.print("Message delivery status: ");
    Serial.println(status == ESP_NOW_SEND_SUCCESS ? "Success" : "Fail");
}

void setup() {
    Serial.begin(115200);

    // Pin modes for LEDs and buzzer
    pinMode(RED_LED_PIN, OUTPUT);
    pinMode(GREEN_LED_PIN, OUTPUT);
    pinMode(BUZZER_PIN, OUTPUT);

    // Print the MAC address of this ESP32
    String macAddress = WiFi.macAddress();
    Serial.println("Sender ESP32 MAC Address: " + macAddress);

    // Initialize Wi-Fi in station mode
    WiFi.mode(WIFI_STA);

    // Set Wi-Fi channel for ESP-NOW communication
    if (esp_wifi_set_promiscuous(true) == ESP_OK) {
        Serial.println("Wi-Fi promiscuous mode enabled successfully.");
    } else {
        Serial.println("Error enabling Wi-Fi promiscuous mode.");
    }

    if (esp_wifi_set_channel(WIFI_CHANNEL, WIFI_SECOND_CHAN_NONE) == ESP_OK) {
        Serial.println("Wi-Fi channel set successfully.");
    } else {
        Serial.println("Error setting Wi-Fi channel.");
    }
    esp_wifi_set_promiscuous(false);

    // Initialize ESP-NOW
    if (esp_now_init() != ESP_OK) {
        Serial.println("Error initializing ESP-NOW.");
        return;
    }
    Serial.println("ESP-NOW initialized successfully.");

    // Register callback function for sending messages
    esp_now_register_send_cb(onSent);

    // Add the receiver as a peer
    esp_now_peer_info_t peerInfo = {};
    memcpy(peerInfo.peer_addr, receiverMAC, 6);
    peerInfo.channel = WIFI_CHANNEL;
    peerInfo.encrypt = false;

    if (esp_now_add_peer(&peerInfo) == ESP_OK) {
        Serial.println("Receiver added as ESP-NOW peer successfully.");
    } else {
        Serial.println("Failed to add receiver as ESP-NOW peer.");
    }

    // Initialize SPI bus for RFID reader
    SPI.begin();
    rfid.PCD_Init();
    Serial.println("RFID reader initialized.");
}

void loop() {
    // Check for new RFID card
    if (rfid.PICC_IsNewCardPresent() && rfid.PICC_ReadCardSerial()) {
        // Convert the UID to a string
        String uidString = "";
        for (byte i = 0; i < rfid.uid.size; i++) {
            String hexValue = String(rfid.uid.uidByte[i], HEX);
            hexValue.toUpperCase(); // Convert to uppercase
            if (rfid.uid.uidByte[i] < 0x10) uidString += "0"; // Add leading zero for single-digit hex
            uidString += hexValue;
            if (i < rfid.uid.size - 1) {
                uidString += ":"; // Separate bytes with a colon
            }
        }

        // Store UID in the message struct
        strncpy(myData.msg, uidString.c_str(), sizeof(myData.msg) - 1);
        myData.msg[sizeof(myData.msg) - 1] = '\0'; // Null-terminate to prevent buffer overflow

        Serial.print("Card UID: ");
        Serial.println(myData.msg);

        // Send UID to the receiver ESP32 via ESP-NOW
        esp_err_t result = esp_now_send(receiverMAC, (uint8_t *)&myData, sizeof(myData));
        if (result == ESP_OK) {
            Serial.println("Message sent successfully.");
        } else {
            Serial.println("Error sending message.");
        }

        // Verify UID
        if (uidString == correctUID) {
            digitalWrite(GREEN_LED_PIN, HIGH); // Turn on green LED
            digitalWrite(RED_LED_PIN, LOW);   // Turn off red LED
            digitalWrite(BUZZER_PIN, LOW);    // Turn off buzzer
            Serial.println("Access granted.");
            delay(3000);                      // Keep green LED on for 3 seconds
            digitalWrite(GREEN_LED_PIN, LOW); // Turn off green LED
        } else {
            digitalWrite(GREEN_LED_PIN, LOW);  // Turn off green LED
            digitalWrite(RED_LED_PIN, HIGH);  // Turn on red LED
            digitalWrite(BUZZER_PIN, HIGH);   // Turn on buzzer
            Serial.println("Access denied.");
            delay(3000);                      // Keep red LED and buzzer on for 3 seconds
            digitalWrite(RED_LED_PIN, LOW);   // Turn off red LED
            digitalWrite(BUZZER_PIN, LOW);    // Turn off buzzer
        }

        // Halt the card to avoid re-reading
        rfid.PICC_HaltA();
    }

    delay(100); // Short delay to prevent rapid card scanning
}

