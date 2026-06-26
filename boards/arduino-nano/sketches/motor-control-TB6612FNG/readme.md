# TB6612FNG Motor Control Sketch

## Overview

This sketch controls two DC motors using a TB6612FNG driver board on an Arduino Nano. It demonstrates:
- Motor direction control for Motor A and Motor B
- PWM speed control
- Standby enable/disable
- Serial command interaction for manual testing

## Wiring

Connect the TB6612FNG as follows:

- `STBY` → Nano `D12`
- `PWMA` → Nano `D5`
- `AIN1` → Nano `D7`
- `AIN2` → Nano `D8`
- `PWMB` → Nano `D6`
- `BIN1` → Nano `D9`
- `BIN2` → Nano `D10`
- `GND` (TB6612FNG) → Nano `GND`
- `VM` → external motor power supply
- `VCC` → Nano `5V` (or 3.3V depending on driver board requirements)

> Always share a common ground between the Nano and the motor power supply.

## Serial Commands

Open the serial monitor at `9600` baud and send commands:

- `a <speed>` — set Motor A speed (-255 to 255)
- `b <speed>` — set Motor B speed (-255 to 255)
- `forward` — run both motors forward at default speed
- `reverse` — run both motors reverse at default speed
- `stop` — coast both motors
- `brake` — apply braking for a short duration

## Build & Flash

From the sketch directory:

```bash
pio run --target upload
```

Monitor serial output:

```bash
pio device monitor --baud 9600
```

## Notes

- `MOTOR_DEFAULT_SPEED` is defined in `include/motor_config.h`.
- Change pin assignments in `include/motor_config.h` if you need a different Nano pin layout.
- Ensure motor voltage does not exceed the TB6612FNG and Nano source limits.
