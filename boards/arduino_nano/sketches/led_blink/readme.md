# LED Blink Test Sketch - Documentation

## Overview
This sketch tests LED blinking on an Arduino Nano with a fixed 5-second cycle:
- **3 seconds ON**
- **2 seconds OFF**

Uses the onboard LED (Pin 13 / `LED_BUILTIN`) — no external components required.

## Hardware Setup

No external wiring needed. The onboard LED on Pin 13 is used by default.

To use an external LED:
```
External LED:
  - Anode (+) → 220Ω resistor → Pin 13 (or any digital pin)
  - Cathode (−) → GND
```

Update `LED_PIN` in `include/blink_config.h` if using a different pin.  
Refer to `../../pin-layout.md` for the complete digital pin layout.

## Timing

| Phase | Duration |
|-------|----------|
| ON    | 3000 ms  |
| OFF   | 2000 ms  |
| **Cycle** | **5000 ms** |

Timing is configured in `include/blink_config.h` via `LED_ON_DURATION` and `LED_OFF_DURATION`, or overridden via `build_flags` in `platformio.ini`.

## Expected Serial Output
```
LED Blink Test initialized on Arduino Nano
LED Pin: 13
ON duration:  3000 ms
OFF duration: 2000 ms
LED ON
LED OFF
LED ON
LED OFF
...
```

## Build & Flash
```bash
# From this sketch directory
pio run --target upload

# Monitor serial output
pio device monitor --baud 9600
```
