# IR Sensor Read Sketch - Documentation

## Overview
This sketch demonstrates analog sensor reading on an Arduino Nano using ADC (Analog-to-Digital Converter).

## Hardware Setup
1. **Sensor Signal Output** → **A0 (ADC0)**
2. **Sensor GND** → **Nano GND**
3. **Sensor VCC** → **Nano 5V**

**Example: Potentiometer wiring**
```
Potentiometer:
  - Center (Wiper) → A0
  - One End → GND
  - Other End → 5V
```

Refer to `../pin-layout.md` for the complete ADC layout and other available pins.

## Expected Output
```
Sensor Read initialized on Arduino Nano
Sensor Pin: A0
Raw ADC: 512 | Voltage: 2.50 V
Obstacle: ACTIVE
Raw ADC: 256 | Voltage: 1.25 V
Obstacle: LOW
Raw ADC: 768 | Voltage: 3.75 V
Obstacle: ACTIVE
...
```

## Customization
- Change `SENSOR_PIN` in `include/sensor_config.h` to use a different analog pin (A0-A7)
- Modify `SENSOR_INTERVAL` to change the reading frequency (in milliseconds)
- Scale the voltage calculation if using a different reference voltage

## Serial Communication
- Baud Rate: 9600 (typical for Arduino Nano)
- Flow Control: None

## ADC Reference
- 10-bit resolution (0-1023 for 0-5V)
- Internal reference: 5V (DEFAULT)
- Can be changed to 1.1V internal or external reference in code

## Snapshots

- IR Sensor Read

  ![IR Sensor Read](dashboard/imgs/ir-sensor-read.gif)