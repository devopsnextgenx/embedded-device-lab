// LED Blink Test - Arduino Nano
// Blink cycle: 3s ON, 2s OFF (5s total period)
// See ../pin-layout.md for digital pin assignments

#include <Arduino.h>
#include "blink_config.h"
#include "version.h"
#include "shared_version_utils.h"

const unsigned long METADATA_INTERVAL_MS = 10000;
unsigned long lastMetadataMs = 0;

void setup() {
  Serial.begin(9600);
  delay(1000); // Allow serial monitor to connect

  pinMode(LED_PIN, OUTPUT);

  printSketchMetadata();
  lastMetadataMs = millis();

  Serial.println("LED Blink Test initialized on Arduino Nano");
  Serial.print("LED Pin: ");
  Serial.println(LED_PIN);
  Serial.print("ON duration:  ");
  Serial.print(LED_ON_DURATION);
  Serial.println(" ms");
  Serial.print("OFF duration: ");
  Serial.print(LED_OFF_DURATION);
  Serial.println(" ms");
}

void loop() {
  if (millis() - lastMetadataMs >= METADATA_INTERVAL_MS) {
    printSketchMetadata();
    lastMetadataMs = millis();
  }

  // ON phase
  digitalWrite(LED_PIN, HIGH);
  Serial.println("{\"LED\":\"ON\"}");
  delay(LED_ON_DURATION);

  // OFF phase
  digitalWrite(LED_PIN, LOW);
  Serial.println("{\"LED\":\"OFF\"}");
  delay(LED_OFF_DURATION);
}
