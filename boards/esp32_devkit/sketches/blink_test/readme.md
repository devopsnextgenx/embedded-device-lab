# Blink Test Sketch - Documentation

## Overview
This is a simple GPIO control sketch that toggles an LED connected to GPIO2 on the ESP32 DevKit.

## Hardware Setup
1. **LED Anode** → 330Ω resistor → **GPIO2 (D2)**
2. **LED Cathode** → **GND**

Refer to `../pin-layout.md` for the complete GPIO layout and alternative pins.

## Expected Output
```
Blink Test initialized on ESP32 DevKit
LED Pin: 2
LED ON
LED OFF
LED ON
LED OFF
...
```

## Customization
- Change `LED_PIN` in `include/blink_config.h` to use a different GPIO pin
- Modify `BLINK_INTERVAL` to change the blink frequency (in milliseconds)

## Serial Communication
- Baud Rate: 115200
- Flow Control: None
