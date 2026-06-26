#pragma once

#include <Arduino.h>
// Motor A control for TB6612FNG on Arduino Nano
// AIN1 -> D2
// AIN2 -> D3
// PWMA -> D9 (PWM control)
// Speed control: D9 (PWM signal, 0-255)
// Direction control: D2 and D3 (IN1 and IN2)
// Direction selector input on the Nano only: D6 (LOW = reverse, HIGH = normal via internal pull-up)
// Built-in LED on while speed is increasing, off while speed is decreasing.

// TB6612FNG motor driver pin mapping for Arduino Nano.
constexpr uint8_t kMotorPwmPin = 9;
constexpr uint8_t kMotorIn1Pin = 2;
constexpr uint8_t kMotorIn2Pin = 3;
constexpr uint8_t kMotorDirectionControlPin = 6;
constexpr uint8_t kMotorStatusLedPin = LED_BUILTIN;

constexpr int kMotorMaxSpeed = 255;
constexpr int kMotorMinSpeed = 150;
constexpr int kMotorStepDelayMs = 50;
