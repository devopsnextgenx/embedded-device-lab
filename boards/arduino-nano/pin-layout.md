# Arduino Nano (ATmega328P) - Complete Hardware Reference

> Board: **Arduino Nano v3.x (ATmega328P)**
>
> This document serves as the complete hardware reference for the Arduino Nano used in this project.

---

# Board Specifications

| Item                | Value                   |
| ------------------- | ----------------------- |
| MCU                 | ATmega328P              |
| Architecture        | 8-bit AVR               |
| Clock Speed         | 16 MHz                  |
| Flash Memory        | 32 KB (2 KB bootloader) |
| SRAM                | 2 KB                    |
| EEPROM              | 1 KB                    |
| Operating Voltage   | 5V                      |
| Input Voltage (VIN) | 7V–12V recommended      |
| Digital I/O Pins    | 14                      |
| Analog Inputs       | 8                       |
| PWM Outputs         | 6                       |
| UART                | 1                       |
| SPI                 | Hardware SPI            |
| I2C                 | Hardware TWI            |
| ADC Resolution      | 10-bit                  |
| Analog Channels     | 8                       |

---

# Physical Pin Layout

## Left Side Header (USB Connector Up)

| Physical Pin | Arduino Label | Port | Functions        | Notes                  |
| ------------ | ------------- | ---- | ---------------- | ---------------------- |
| 13           | D13           | PB5  | SCK              | Built-in LED           |
| —            | 3V3           | —    | 3.3V Output      | ~50mA max              |
| —            | AREF          | —    | Analog Reference | External ADC reference |
| 14           | A0            | PC0  | ADC0             | Analog/Digital         |
| 15           | A1            | PC1  | ADC1             | Analog/Digital         |
| 16           | A2            | PC2  | ADC2             | Analog/Digital         |
| 17           | A3            | PC3  | ADC3             | Analog/Digital         |
| 18           | A4            | PC4  | ADC4, SDA        | I2C Data               |
| 19           | A5            | PC5  | ADC5, SCL        | I2C Clock              |
| 20           | A6            | ADC6 | Analog Only      | No digital I/O         |
| 21           | A7            | ADC7 | Analog Only      | No digital I/O         |
| —            | 5V            | —    | 5V Rail          | Regulated              |
| —            | RST           | PC6  | Reset            | Active LOW             |
| —            | GND           | —    | Ground           |                        |
| —            | VIN           | —    | 7–12V Input      | Through regulator      |

---

## Right Side Header (USB Connector Up)

| Physical Pin | Arduino Label | Port | Functions  | Notes           |
| ------------ | ------------- | ---- | ---------- | --------------- |
| 12           | D12           | PB4  | MISO       | SPI             |
| 11           | D11           | PB3  | MOSI, OC2A | PWM             |
| 10           | D10           | PB2  | SS, OC1B   | PWM             |
| 9            | D9            | PB1  | OC1A       | PWM             |
| 8            | D8            | PB0  | ICP1, CLKO |                 |
| 7            | D7            | PD7  | AIN1       |                 |
| 6            | D6            | PD6  | OC0A       | PWM             |
| 5            | D5            | PD5  | OC0B       | PWM             |
| 4            | D4            | PD4  | T0/XCK     |                 |
| 3            | D3            | PD3  | INT1, OC2B | PWM + Interrupt |
| 2            | D2            | PD2  | INT0       | Interrupt       |
| 1            | D1            | PD1  | TXD        | UART TX         |
| 0            | D0            | PD0  | RXD        | UART RX         |
| —            | RST           | PC6  | Reset      |                 |
| —            | GND           | —    | Ground     |                 |
| —            | 5V            | —    | 5V Rail    |                 |

---

# Pin Capability Matrix

| Pin | Digital | Analog | PWM | SPI  | I2C | UART | Interrupt |
| --- | ------- | ------ | --- | ---- | --- | ---- | --------- |
| D0  | ✓       |        |     |      |     | RX   |           |
| D1  | ✓       |        |     |      |     | TX   |           |
| D2  | ✓       |        |     |      |     |      | INT0      |
| D3  | ✓       |        | ✓   |      |     |      | INT1      |
| D4  | ✓       |        |     |      |     |      |           |
| D5  | ✓       |        | ✓   |      |     |      |           |
| D6  | ✓       |        | ✓   |      |     |      |           |
| D7  | ✓       |        |     |      |     |      |           |
| D8  | ✓       |        |     |      |     |      |           |
| D9  | ✓       |        | ✓   |      |     |      |           |
| D10 | ✓       |        | ✓   | SS   |     |      |           |
| D11 | ✓       |        | ✓   | MOSI |     |      |           |
| D12 | ✓       |        |     | MISO |     |      |           |
| D13 | ✓       |        |     | SCK  |     |      |           |
| A0  | ✓       | ✓      |     |      |     |      |           |
| A1  | ✓       | ✓      |     |      |     |      |           |
| A2  | ✓       | ✓      |     |      |     |      |           |
| A3  | ✓       | ✓      |     |      |     |      |           |
| A4  | ✓       | ✓      |     |      | SDA |      |           |
| A5  | ✓       | ✓      |     |      | SCL |      |           |
| A6  |         | ✓      |     |      |     |      |           |
| A7  |         | ✓      |     |      |     |      |           |

---

# Digital GPIO

All D0–D13 pins support digital input/output.

```cpp
pinMode(7, OUTPUT);
digitalWrite(7, HIGH);

pinMode(2, INPUT_PULLUP);
int state = digitalRead(2);
```

## Limits

| Parameter           | Value             |
| ------------------- | ----------------- |
| Max per pin         | 40mA absolute max |
| Recommended per pin | <20mA             |
| Total MCU current   | 200mA max         |

---

# PWM Outputs

Arduino Nano supports PWM on six pins.

| Pin | Timer   | Default Frequency |
| --- | ------- | ----------------- |
| D3  | Timer2B | ~490Hz            |
| D5  | Timer0B | ~980Hz            |
| D6  | Timer0A | ~980Hz            |
| D9  | Timer1A | ~490Hz            |
| D10 | Timer1B | ~490Hz            |
| D11 | Timer2A | ~490Hz            |

```cpp
analogWrite(9, 128);
```

Produces approximately 50% duty cycle.

## Timer Relationships

| Timer  | Pins    |
| ------ | ------- |
| Timer0 | D5, D6  |
| Timer1 | D9, D10 |
| Timer2 | D3, D11 |

### Important

Changing timer frequency affects all pins sharing that timer.

Example:

* D9 frequency changes ⇒ D10 frequency changes
* D3 frequency changes ⇒ D11 frequency changes

### Timer0 Warning

Timer0 drives:

* millis()
* micros()
* delay()

Modifying Timer0 can break timing functions.

---

# Analog Inputs

ADC resolution is 10-bit.

```cpp
int raw = analogRead(A0);
```

Range:

```text
0 → 1023
```

Voltage calculation:

```cpp
float volts = raw * (5.0 / 1023.0);
```

---

## Analog Reference Options

```cpp
analogReference(DEFAULT);
analogReference(INTERNAL);
analogReference(EXTERNAL);
```

| Mode     | Voltage            |
| -------- | ------------------ |
| DEFAULT  | VCC (typically 5V) |
| INTERNAL | 1.1V               |
| EXTERNAL | AREF Pin           |

### AREF Warning

Never drive AREF externally while using:

```cpp
analogReference(DEFAULT);
```

This can short the internal reference network.

---

# A6 / A7 Special Notes

A6 and A7 are:

* Analog input only
* No digital I/O
* No pullups
* Not usable with pinMode()

Valid:

```cpp
analogRead(A6);
```

Invalid:

```cpp
pinMode(A6, INPUT_PULLUP);
digitalRead(A6);
digitalWrite(A6, HIGH);
```

---

# UART (Serial)

| Pin | Function |
| --- | -------- |
| D0  | RX       |
| D1  | TX       |

```cpp
Serial.begin(115200);
Serial.println("Hello");
```

## Upload Conflict

D0 and D1 are shared with:

* CH340
* FT232
* USB serial interface

Disconnect attached devices before uploading sketches.

---

# SPI Interface

| Pin | Function |
| --- | -------- |
| D13 | SCK      |
| D12 | MISO     |
| D11 | MOSI     |
| D10 | SS       |

```cpp
#include <SPI.h>

SPI.begin();
SPI.transfer(0x55);
```

## SPI Master Mode Requirement

D10 should remain:

```cpp
pinMode(10, OUTPUT);
```

Otherwise SPI can unintentionally enter slave mode.

---

# I2C Interface

| Pin | Function |
| --- | -------- |
| A4  | SDA      |
| A5  | SCL      |

```cpp
#include <Wire.h>

Wire.begin();
```

Typical pullups:

```text
4.7kΩ → 5V
```

Many sensor breakout boards already include pullups.

---

# External Interrupts

Dedicated interrupt pins:

| Pin | Interrupt |
| --- | --------- |
| D2  | INT0      |
| D3  | INT1      |

```cpp
attachInterrupt(
    digitalPinToInterrupt(2),
    myISR,
    FALLING
);
```

Supported trigger modes:

* LOW
* CHANGE
* RISING
* FALLING

---

# Power Pins

| Pin  | Function       |
| ---- | -------------- |
| VIN  | 7–12V input    |
| 5V   | Regulated 5V   |
| 3V3  | Regulated 3.3V |
| GND  | Ground         |
| AREF | ADC reference  |
| RST  | Reset MCU      |

---

# Power Budget

## USB Powered

```text
USB → 5V Rail
```

Available current typically:

```text
~500mA
```

depends on USB source.

## VIN Powered

```text
VIN → Regulator → 5V Rail
```

Higher VIN voltage increases regulator heat.

Recommended:

```text
7V–12V
```

Avoid powering motors directly from Nano 5V rail.

---

# Bootloader & Upload Considerations

## D0 / D1

Devices connected to UART pins can block uploads.

## D13

Bootloader flashes onboard LED during reset.

Avoid connecting:

* Relay inputs
* MOSFET gates
* Critical enable signals

to D13 if startup glitches matter.

## RST

Holding RESET low prevents execution and uploading.

---

# Common Wiring Examples

## DHT22 / DHT11

```text
DHT GND  → Nano GND
DHT VCC  → Nano 5V
DHT DATA → D4

10kΩ pullup between DATA and 5V
```

---

## SSD1306 OLED (I2C)

```text
OLED GND → GND
OLED VCC → 5V
OLED SDA → A4
OLED SCL → A5
```

---

## Potentiometer

```text
GND      → GND
Center   → A0
5V       → 5V
```

---

## Relay Module

```text
Relay GND → GND
Relay VCC → 5V
Relay IN  → D8
```

---

## L298N Motor Driver

```text
Nano D5  → IN1
Nano D6  → IN2

Motor → OUT1/OUT2
```

> Do not power motors directly from the Nano.

---

# Memory Optimization Tips

## SRAM Conservation

Use flash-stored strings:

```cpp
Serial.println(F("System Ready"));
```

instead of:

```cpp
Serial.println("System Ready");
```

This saves SRAM.

---

# EEPROM

Available:

```text
1024 bytes
```

Example:

```cpp
#include <EEPROM.h>

EEPROM.write(0, 123);
byte value = EEPROM.read(0);
```

Useful for:

* Calibration values
* Configuration settings
* Persistent parameters

---

# USB Interface

Most Nano boards use:

* CH340G
* FT232RL

Windows may require drivers.

---

# Quick Reference Summary

| Function            | Pins                     |
| ------------------- | ------------------------ |
| UART                | D0, D1                   |
| External Interrupts | D2, D3                   |
| PWM                 | D3, D5, D6, D9, D10, D11 |
| SPI                 | D10–D13                  |
| I2C                 | A4, A5                   |
| Analog Inputs       | A0–A7                    |
| Analog Only         | A6, A7                   |
| Built-in LED        | D13                      |
| Reset               | RST                      |
| Analog Reference    | AREF                     |

---

**Project Note:** If using communication modules (GPS, Bluetooth, LoRa, GSM, ESP8266, etc.), avoid D0/D1 unless hardware UART is specifically required. Prefer SoftwareSerial or AltSoftSerial on other pins to prevent upload conflicts.
