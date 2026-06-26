# ESP32 DevKit V1 (ESP32-WROOM-32) - Complete Hardware Reference

> Board: **ESP32 DOIT DevKit V1**
>
> This document serves as the complete hardware reference for the ESP32 board used in this project.

---

# Board Specifications

| Item                      | Value                |
| ------------------------- | -------------------- |
| MCU                       | ESP32-WROOM-32       |
| CPU                       | Xtensa LX6 Dual-Core |
| Architecture              | 32-bit               |
| Clock Speed               | Up to 240 MHz        |
| SRAM                      | 520 KB               |
| Flash                     | Typically 4 MB       |
| Operating Voltage         | 3.3V                 |
| Input Voltage             | 5V USB or VIN        |
| GPIO Pins                 | 34                   |
| ADC Resolution            | 12-bit               |
| ADC Channels              | 18                   |
| DAC Channels              | 2                    |
| Capacitive Touch Channels | 10                   |
| UARTs                     | 3                    |
| SPI Controllers           | 4                    |
| I2C Controllers           | 2                    |
| WiFi                      | 802.11 b/g/n         |
| Bluetooth                 | BT Classic + BLE     |

---

# Physical Pin Layout

## Left Side Header (USB Connector Up)

| Pin    | GPIO   | Functions                   |
| ------ | ------ | --------------------------- |
| 3V3    | —      | 3.3V Output                 |
| EN     | —      | Chip Enable / Reset         |
| VP     | GPIO36 | ADC1_CH0, Input Only        |
| VN     | GPIO39 | ADC1_CH3, Input Only        |
| GPIO34 | GPIO34 | ADC1_CH6, Input Only        |
| GPIO35 | GPIO35 | ADC1_CH7, Input Only        |
| GPIO32 | GPIO32 | ADC1_CH4, Touch9            |
| GPIO33 | GPIO33 | ADC1_CH5, Touch8            |
| GPIO25 | GPIO25 | ADC2_CH8, DAC2              |
| GPIO26 | GPIO26 | ADC2_CH9, DAC1              |
| GPIO27 | GPIO27 | ADC2_CH7, Touch7            |
| GPIO14 | GPIO14 | ADC2_CH6, Touch6            |
| GPIO12 | GPIO12 | ADC2_CH5, Touch5, Strapping |
| GND    | —      | Ground                      |
| GPIO13 | GPIO13 | ADC2_CH4, Touch4            |
| VIN    | —      | 5V Input                    |

---

## Right Side Header (USB Connector Up)

| Pin    | GPIO   | Functions                   |
| ------ | ------ | --------------------------- |
| GPIO23 | GPIO23 | VSPI MOSI                   |
| GPIO22 | GPIO22 | I2C SCL                     |
| GPIO1  | GPIO1  | UART0 TX                    |
| GPIO3  | GPIO3  | UART0 RX                    |
| GPIO21 | GPIO21 | I2C SDA                     |
| GPIO19 | GPIO19 | VSPI MISO                   |
| GPIO18 | GPIO18 | VSPI SCK                    |
| GPIO5  | GPIO5  | VSPI CS, Strapping          |
| GPIO17 | GPIO17 | UART2 TX                    |
| GPIO16 | GPIO16 | UART2 RX                    |
| GPIO4  | GPIO4  | ADC2_CH0, Touch0            |
| GPIO0  | GPIO0  | ADC2_CH1, Touch1, BOOT      |
| GPIO2  | GPIO2  | ADC2_CH2, Touch2, Strapping |
| GPIO15 | GPIO15 | ADC2_CH3, Touch3, Strapping |
| GND    | —      | Ground                      |
| 5V/VIN | —      | USB 5V Rail                 |

---

# GPIO Capability Matrix

| GPIO | Digital I/O | ADC  | DAC  | Touch | PWM | RTC | Notes               |
| ---- | ----------- | ---- | ---- | ----- | --- | --- | ------------------- |
| 0    | ✓           | ADC2 |      | T1    | ✓   | ✓   | Boot pin            |
| 1    | ✓           |      |      |       | ✓   |     | UART0 TX            |
| 2    | ✓           | ADC2 |      | T2    | ✓   | ✓   | Strapping pin       |
| 3    | ✓           |      |      |       | ✓   |     | UART0 RX            |
| 4    | ✓           | ADC2 |      | T0    | ✓   | ✓   | Strapping pin       |
| 5    | ✓           |      |      |       | ✓   |     | Strapping pin       |
| 12   | ✓           | ADC2 |      | T5    | ✓   | ✓   | Flash voltage strap |
| 13   | ✓           | ADC2 |      | T4    | ✓   | ✓   |                     |
| 14   | ✓           | ADC2 |      | T6    | ✓   | ✓   |                     |
| 15   | ✓           | ADC2 |      | T3    | ✓   | ✓   | Strapping pin       |
| 16   | ✓           |      |      |       | ✓   |     |                     |
| 17   | ✓           |      |      |       | ✓   |     |                     |
| 18   | ✓           |      |      |       | ✓   |     | VSPI CLK            |
| 19   | ✓           |      |      |       | ✓   |     | VSPI MISO           |
| 21   | ✓           |      |      |       | ✓   |     | I2C SDA             |
| 22   | ✓           |      |      |       | ✓   |     | I2C SCL             |
| 23   | ✓           |      |      |       | ✓   |     | VSPI MOSI           |
| 25   | ✓           | ADC2 | DAC2 |       | ✓   | ✓   |                     |
| 26   | ✓           | ADC2 | DAC1 |       | ✓   | ✓   |                     |
| 27   | ✓           | ADC2 |      | T7    | ✓   | ✓   |                     |
| 32   | ✓           | ADC1 |      | T9    | ✓   | ✓   |                     |
| 33   | ✓           | ADC1 |      | T8    | ✓   | ✓   |                     |
| 34   | Input Only  | ADC1 |      |       |     | ✓   | No pullups          |
| 35   | Input Only  | ADC1 |      |       |     | ✓   | No pullups          |
| 36   | Input Only  | ADC1 |      |       |     | ✓   | VP                  |
| 39   | Input Only  | ADC1 |      |       |     | ✓   | VN                  |

---

# Recommended GPIO Usage

## Safe GPIOs (General Purpose)

These are the preferred GPIOs for most projects:

```text
GPIO13
GPIO14
GPIO16
GPIO17
GPIO18
GPIO19
GPIO21
GPIO22
GPIO23
GPIO25
GPIO26
GPIO27
GPIO32
GPIO33
```

---

## Use With Care

```text
GPIO0
GPIO2
GPIO4
GPIO5
GPIO12
GPIO15
```

These are boot-strapping pins and may prevent startup if driven incorrectly.

---

## Avoid for General Use

```text
GPIO1
GPIO3
```

Shared with USB serial.

---

## Never Use

```text
GPIO6
GPIO7
GPIO8
GPIO9
GPIO10
GPIO11
```

Connected to onboard SPI Flash.

---

# PWM (LEDC)

Unlike Arduino, ESP32 PWM can be assigned to almost any output GPIO.

## Features

| Property   | Value         |
| ---------- | ------------- |
| Channels   | 16            |
| Resolution | 1–16 bit      |
| Frequency  | Up to ~40 MHz |
| API        | ledcWrite()   |

Example:

```cpp
ledcAttachPin(18, 0);
ledcSetup(0, 5000, 8);

ledcWrite(0, 128);
```

---

# Analog Inputs (ADC)

Resolution:

```cpp
analogReadResolution(12);
```

Range:

```text
0 – 4095
```

Default reference:

```text
0V – 3.3V
```

---

## ADC1 (WiFi Safe)

Use these pins when WiFi is enabled.

| GPIO |
| ---- |
| 32   |
| 33   |
| 34   |
| 35   |
| 36   |
| 39   |

---

## ADC2 (WiFi Conflict)

Unavailable while WiFi is active.

| GPIO |
| ---- |
| 0    |
| 2    |
| 4    |
| 12   |
| 13   |
| 14   |
| 15   |
| 25   |
| 26   |
| 27   |

---

## ADC Accuracy Notes

ESP32 ADCs are not perfectly linear.

Most accurate range:

```text
0.15V – 3.0V
```

Use:

```cpp
esp_adc_cal
```

for calibrated readings.

---

# DAC Outputs

ESP32 includes two true analog outputs.

| GPIO | DAC  |
| ---- | ---- |
| 25   | DAC2 |
| 26   | DAC1 |

Example:

```cpp
dacWrite(25, 128);
```

Range:

```text
0 – 255
```

Output:

```text
0V – 3.3V
```

---

# Capacitive Touch Inputs

| Touch Channel | GPIO   |
| ------------- | ------ |
| T0            | GPIO4  |
| T1            | GPIO0  |
| T2            | GPIO2  |
| T3            | GPIO15 |
| T4            | GPIO13 |
| T5            | GPIO12 |
| T6            | GPIO14 |
| T7            | GPIO27 |
| T8            | GPIO33 |
| T9            | GPIO32 |

Example:

```cpp
touchRead(GPIO4);
```

Lower values indicate a touch event.

---

# UART Interfaces

## UART0

| GPIO | Function |
| ---- | -------- |
| 1    | TX0      |
| 3    | RX0      |

Used by USB serial and bootloader.

---

## UART1

Default pins overlap flash and are generally remapped.

---

## UART2

| GPIO | Function |
| ---- | -------- |
| 17   | TX2      |
| 16   | RX2      |

Recommended for GPS, GSM, LoRa, Bluetooth modules.

---

# SPI Interfaces

## VSPI (Recommended)

| GPIO | Function |
| ---- | -------- |
| 23   | MOSI     |
| 19   | MISO     |
| 18   | CLK      |
| 5    | CS       |

---

## HSPI

| GPIO | Function |
| ---- | -------- |
| 13   | MOSI     |
| 12   | MISO     |
| 14   | CLK      |
| 15   | CS       |

---

# I2C Interface

Default configuration:

| GPIO | Function |
| ---- | -------- |
| 21   | SDA      |
| 22   | SCL      |

Example:

```cpp
Wire.begin(21, 22);
```

I2C can be remapped to other GPIOs if required.

---

# Deep Sleep & RTC GPIOs

RTC-capable GPIOs:

```text
0
2
4
12
13
14
15
25
26
27
32
33
34
35
36
39
```

Used with:

```cpp
esp_sleep_enable_ext0_wakeup()
esp_sleep_enable_ext1_wakeup()
```

for ultra-low-power applications.

---

# Boot & Strapping Pins

These GPIOs are sampled during reset.

| GPIO | Purpose                 |
| ---- | ----------------------- |
| 0    | Bootloader selection    |
| 2    | Boot mode               |
| 5    | SPI boot config         |
| 12   | Flash voltage selection |
| 15   | Boot logging            |

Improper states during reset can prevent booting.

---

# Power Considerations

## Logic Levels

```text
3.3V ONLY
```

GPIOs are not 5V tolerant.

---

## Current Limits

Recommended:

```text
<12mA per GPIO
```

Absolute maximum:

```text
40mA
```

---

## External Loads

Never power:

* Motors
* Relays
* Solenoids
* LED strips

directly from GPIO pins.

Use drivers, MOSFETs, or external power supplies.

---

# Common Wiring Examples

## SSD1306 OLED

```text
OLED SDA → GPIO21
OLED SCL → GPIO22
OLED VCC → 3V3
OLED GND → GND
```

---

## DHT22

```text
DHT DATA → GPIO23
DHT VCC  → 3V3
DHT GND  → GND
```

---

## DS18B20

```text
DQ → GPIO4

4.7kΩ pullup:
DQ → 3V3
```

---

## SPI SD Card

```text
MOSI → GPIO23
MISO → GPIO19
CLK  → GPIO18
CS   → GPIO5
```

---

## Relay Module

```text
Relay IN  → GPIO18
Relay VCC → 5V
Relay GND → GND
```

Use a transistor driver or optocoupled relay board.

---

# Memory Optimization

## Store Constants in Flash

```cpp
const char* msg = "Hello";
```

Prefer:

```cpp
constexpr char msg[] = "Hello";
```

for compile-time storage.

---

# Performance Notes

## CPU Frequency

```cpp
setCpuFrequencyMhz(240);
```

Supported:

```text
80 MHz
160 MHz
240 MHz
```

---

# USB Interface

Most boards use:

* CP2102
* CH340

Windows users may need drivers.

---

# Quick Reference Summary

| Function       | GPIOs                                     |
| -------------- | ----------------------------------------- |
| UART0          | 1, 3                                      |
| UART2          | 16, 17                                    |
| I2C            | 21, 22                                    |
| VSPI           | 18, 19, 23, 5                             |
| HSPI           | 12, 13, 14, 15                            |
| DAC            | 25, 26                                    |
| ADC1           | 32–39                                     |
| ADC2           | 0,2,4,12–15,25–27                         |
| Touch          | 0,2,4,12–15,27,32,33                      |
| Safe GPIOs     | 13,14,16,17,18,19,21,22,23,25,26,27,32,33 |
| Input Only     | 34,35,36,39                               |
| Flash Reserved | 6–11                                      |
| Boot Pins      | 0,2,5,12,15                               |

---

**Project Note:** For sensors and peripherals, prefer GPIO21/22 (I2C), GPIO18/19/23 (SPI), GPIO16/17 (UART2), and GPIO32/33 (ADC1) to avoid boot, WiFi, and flash conflicts.
