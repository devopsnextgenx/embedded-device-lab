// Blink Configuration Header
// Define pins, timing, and constants for blink_test sketch

#ifndef BLINK_CONFIG_H
#define BLINK_CONFIG_H

// Pin Definitions (refer to pin-layout.md for ESP32 pin details)
#ifndef LED_PIN
  #define LED_PIN 2  // GPIO2 - Change as needed per pin-layout.md
#endif

// Timing Constants
#define BLINK_INTERVAL 500  // Milliseconds between toggle

#endif // BLINK_CONFIG_H
