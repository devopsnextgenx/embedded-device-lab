// Shared Utilities - Common Hardware Abstraction
// Shared across all boards and sketches

#ifndef SHARED_UTILS_H
#define SHARED_UTILS_H

#include <Arduino.h>

/**
 * Pin safety check - validates pin exists on the platform
 * Returns: true if pin is valid, false otherwise
 */
inline bool isValidPin(uint8_t pin) {
  #ifdef BOARD_ESP32_DEVKIT
    return (pin >= 0 && pin <= 39);  // ESP32 typical GPIO range
  #elif defined(BOARD_ARDUINO_NANO)
    return (pin >= 0 && pin <= 19);  // Arduino Nano D0-D19
  #else
    return true;  // Unknown board, assume valid
  #endif
}

/**
 * Serial initialization with timeout
 * Waits up to 3 seconds for serial monitor to connect
 */
void initSerial(unsigned long baudrate = 115200) {
  Serial.begin(baudrate);
  unsigned long startTime = millis();
  while (!Serial && (millis() - startTime < 3000)) {
    delay(10);  // Wait for serial connection
  }
  if (Serial) {
    Serial.println("\n=== Serial Monitor Connected ===");
  }
}

/**
 * Heartbeat: Blink LED and output to serial
 * Useful for diagnostic purposes
 */
void heartbeat(uint8_t pin, uint16_t interval = 1000) {
  digitalWrite(pin, HIGH);
  delay(interval / 2);
  digitalWrite(pin, LOW);
  delay(interval / 2);
}

#endif // SHARED_UTILS_H
