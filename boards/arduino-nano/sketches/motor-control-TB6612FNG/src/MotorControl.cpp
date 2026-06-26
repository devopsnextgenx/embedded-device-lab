#include <Arduino.h>
#include "MotorPins.h"
#include "MotorControl.h"

namespace {

bool readDirectionReversed() {
  return digitalRead(kMotorDirectionControlPin) == LOW;
}

void setMotorDirection(bool reversed) {
  if (reversed) {
    digitalWrite(kMotorIn1Pin, LOW);
    digitalWrite(kMotorIn2Pin, HIGH);
  } else {
    digitalWrite(kMotorIn1Pin, HIGH);
    digitalWrite(kMotorIn2Pin, LOW);
  }

  Serial.print("Direction: ");
  Serial.println(reversed ? "REVERSED" : "NORMAL");
}

void syncMotorDirection(bool &currentDirectionReversed) {
  const bool newDirectionReversed = readDirectionReversed();
  if (newDirectionReversed != currentDirectionReversed) {
    currentDirectionReversed = newDirectionReversed;
    setMotorDirection(newDirectionReversed);
  }
}

void applySpeed(int speed) {
  speed = constrain(speed, 0, 255);
  analogWrite(kMotorPwmPin, speed);
  Serial.print("Speed: ");
  Serial.println(speed);
}

} // namespace

void motorInitialize() {
  pinMode(kMotorIn1Pin, OUTPUT);
  pinMode(kMotorIn2Pin, OUTPUT);
  pinMode(kMotorPwmPin, OUTPUT);
  pinMode(kMotorDirectionControlPin, INPUT_PULLUP);
  pinMode(kMotorStatusLedPin, OUTPUT);

  applySpeed(0);
  bool currentDirectionReversed = false;
  syncMotorDirection(currentDirectionReversed);
}

void motorRampSpeed(int startSpeed, int endSpeed) {
  const bool increasing = endSpeed > startSpeed;
  digitalWrite(kMotorStatusLedPin, increasing ? HIGH : LOW);

  bool currentDirectionReversed = readDirectionReversed();
  setMotorDirection(currentDirectionReversed);

  for (int speed = startSpeed; increasing ? speed <= endSpeed : speed >= endSpeed; speed += increasing ? 1 : -1) {
    syncMotorDirection(currentDirectionReversed);
    applySpeed(speed);

    delay(kMotorStepDelayMs);
  }
}
