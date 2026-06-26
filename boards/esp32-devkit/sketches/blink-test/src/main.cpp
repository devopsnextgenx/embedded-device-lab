// Blink Test - ESP32 DevKit
// Simple GPIO control sketch demonstrating LED blink functionality
// See ../pin-layout.md for GPIO pin assignments

#include <Arduino.h>
#include "blink_config.h"
#include "version.h"

void setup() {
  Serial.begin(9600);
  delay(1000); // Allow serial monitor to connect

  Serial.print("Sketch: ");
  Serial.println(SKETCH_NAME);
  Serial.print("Version: ");
  Serial.println(SKETCH_VERSION);
  Serial.print("Author: ");
  Serial.println(SKETCH_AUTHOR);
  Serial.print("Date: ");
  Serial.println(SKETCH_DATE);
  
  pinMode(LED_PIN, OUTPUT);
  Serial.println("Blink Test initialized on ESP32 DevKit");
  Serial.print("LED Pin: ");
  Serial.println(LED_PIN);
}

void loop() {
  digitalWrite(LED_PIN, HIGH);
  Serial.println("LED ON");
  delay(BLINK_INTERVAL);
  
  digitalWrite(LED_PIN, LOW);
  Serial.println("LED OFF");
  delay(BLINK_INTERVAL);
}
