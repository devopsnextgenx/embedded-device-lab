// Blink Configuration Header
// Define pins, timing, and constants for led_blink sketch

#ifndef BLINK_CONFIG_H
#define BLINK_CONFIG_H

// Pin Definitions (refer to pin-layout.md for Arduino Nano pin details)
#ifndef LED_PIN
  #define LED_PIN LED_BUILTIN  // Pin 13 - onboard LED on Arduino Nano
#endif

// Timing Constants (total cycle = ON_DURATION + OFF_DURATION = 5000 ms)
#define LED_ON_DURATION  3000  // Milliseconds LED stays ON
#define LED_OFF_DURATION 2000  // Milliseconds LED stays OFF

#endif // BLINK_CONFIG_H
