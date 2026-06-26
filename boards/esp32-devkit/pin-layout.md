# ESP32 DevKit Board - Pin Layout & Documentation

## Board Overview
**Name:** ESP32-DOIT DevKit v1  
**Processor:** Xtensa dual-core 32-bit LX6 microprocessor  
**Clock Speed:** 160 MHz (adjustable to 240 MHz)  
**RAM:** 520 KB SRAM  
**Flash:** 4 MB (partitionable)  
**GPIO Pins:** 34 (input only on some), 25 (input/output)  
**ADC:** 12-bit, 18 channels  
**DAC:** 2 channels (8-bit)  
**UART:** 3 (UART0, UART1, UART2)  
**SPI:** 4 (SPI0, SPI1, SPI2, SPI3)  
**I2C:** 2 (configurable on any GPIO)  
**Power Supply:** 5V USB or 3.3V direct

---

## Pin Mapping & Allocation

### **Power & Ground**
| Pin | Function     | Notes                            |
|-----|--------------|----------------------------------|
| VIN | 5V Input     | USB power input (5V)             |
| 3V3 | 3.3V Rail    | Regulated 3.3V output (~500mA)  |
| GND | Ground       | Common ground (multiple pins)   |

### **Serial Communication (UART0 - Default)**
| Pin | Signal | Function                    | Notes                               |
|-----|--------|-----------------------------|------------------------------------|
| RX0 | GPIO3  | UART0 Receive               | Connected to USB bridge (RX)        |
| TX0 | GPIO1  | UART0 Transmit              | Connected to USB bridge (TX)        |

### **General Purpose GPIO (Input/Output)**
| Pin | GPIO   | Alternate Function | ADC/DAC    | Notes                                      |
|-----|--------|-------------------|------------|---------------------------------------------|
| D0  | GPIO16 | RTC GPIO0         | None       | Strapping pin (pull-down at boot)         |
| D1  | GPIO17 | RTC GPIO1         | None       | High impedance - use carefully            |
| D2  | GPIO4  | RTC GPIO4         | ADC2_CH0   | Strapping pin (pull-down at boot)         |
| D3  | GPIO0  | RTC GPIO11        | ADC2_CH1   | Strapping pin (must be floating at boot)  |
| D4  | GPIO2  | RTC GPIO12        | ADC2_CH2   | Strapping pin (must be floating at boot)  |
| D5  | GPIO14 | RTC GPIO16        | ADC2_CH6   | Output-only on ESP32-DOIT                 |
| D6  | GPIO27 | RTC GPIO17        | ADC2_CH7   | Standard GPIO                             |
| D7  | GPIO26 | RTC GPIO18        | ADC2_CH9   | Standard GPIO                             |
| D8  | GPIO25 | RTC GPIO8         | ADC2_CH8   | Standard GPIO (DAC1)                      |
| D9  | GPIO32 | RTC GPIO9         | ADC1_CH4   | Standard GPIO (INPUT_ONLY on variant)    |
| D10 | GPIO33 | RTC GPIO10        | ADC1_CH5   | Standard GPIO (INPUT_ONLY on variant)    |
| D11 | GPIO34 | RTC GPIO4         | ADC1_CH6   | INPUT-ONLY, no internal pull-up           |
| D12 | GPIO35 | RTC GPIO5         | ADC1_CH7   | INPUT-ONLY, no internal pull-up           |
| D13 | GPIO36 | RTC GPIO0         | ADC1_CH0   | INPUT-ONLY (SensorVP)                     |
| D14 | GPIO39 | RTC GPIO3         | ADC1_CH3   | INPUT-ONLY (SensorVN)                     |

### **SPI Pins (for SD Card, Flash memory, etc.)**
| Pin | GPIO   | Function | Notes              |
|-----|--------|----------|---------------------|
| D23 | GPIO23 | MOSI     | SPI Master Out      |
| D19 | GPIO19 | MISO     | SPI Master In       |
| D18 | GPIO18 | SCK      | SPI Clock           |
| D5  | GPIO5  | CS0      | Chip Select (SPI)   |

### **I2C Pins (Default)**
| Pin | GPIO   | Function | Notes                       |
|-----|--------|----------|------------------------------|
| D21 | GPIO21 | SDA      | I2C Data (pullup inside)    |
| D22 | GPIO22 | SCL      | I2C Clock (pullup inside)   |

### **Analog Pins (ADC1 & ADC2)**
| ADC1 Channels | GPIO   | ADC2 Channels | GPIO   |
|---------------|--------|---------------|--------|
| CH0 (VP)      | GPIO36 | CH0           | GPIO4  |
| CH1 (VN)      | GPIO39 | CH1           | GPIO0  |
| CH2           | GPIO34 | CH2           | GPIO2  |
| CH3           | GPIO35 | CH3           | GPIO15 |
| CH4           | GPIO32 | CH4           | GPIO13 |
| CH5           | GPIO33 | CH5           | GPIO12 |
| CH6           | GPIO34 | CH6           | GPIO14 |
| CH7           | GPIO35 | CH7           | GPIO27 |
|               |        | CH8           | GPIO25 |
|               |        | CH9           | GPIO26 |

---

## Special Pin Behavior

### **Strapping Pins (Pull-Down at Boot)**
Pins GPIO0, GPIO2, GPIO4, GPIO5, GPIO15, GPIO16 are sampled at boot to configure boot mode:
- Keep floating or externally pulled high during normal operation
- Avoid driving to GND during power-on or reset

### **ADC2 Channel Conflict**
When WiFi is active, ADC2 channels are **unavailable**. Use ADC1 for WiFi applications.

### **I2C Flexibility**
I2C can be configured on **any GPIO pair** via software I2C. Default is GPIO21 (SDA) and GPIO22 (SCL).

### **RTC & Deep Sleep**
RTC GPIOs (GPIO0, GPIO2, GPIO4, GPIO12-16, GPIO25-26) support deep-sleep wake-up via `esp_sleep_enable_ext1_wakeup()`.

---

## Common Peripheral Wiring

### **DHT Sensor (Temperature/Humidity)**
```
DHT GND  → ESP32 GND
DHT VCC  → ESP32 3V3
DHT DATA → ESP32 GPIO23 (or any GPIO)
         + 10kΩ pull-up to VCC (optional, sensor has internal)
```

### **OLED Display (I2C SSD1306)**
```
OLED GND  → ESP32 GND
OLED VCC  → ESP32 3V3
OLED SDA  → ESP32 GPIO21 (I2C)
OLED SCL  → ESP32 GPIO22 (I2C)
```

### **Relay Module (5V)**
```
Relay GND    → ESP32 GND
Relay VCC    → ESP32 5V
Relay Signal → ESP32 GPIO18 (through 1kΩ resistor if needed)
```

### **DS18B20 Temperature Sensor (OneWire)**
```
DS18B20 GND  → ESP32 GND
DS18B20 VCC  → ESP32 3V3
DS18B20 DQ   → ESP32 GPIO4
             + 4.7kΩ pull-up to 3V3
```

---

## Developer Notes

1. **Power Budget:** The on-board 3.3V regulator can supply ~500mA. For high-current applications (sensors, motors), use external 3.3V supply.
2. **USB Connection:** The DevKit includes a built-in USB-to-UART bridge (CH340 or CP2102 depending on batch). Drivers may be needed on Windows.
3. **Voltage Levels:** ESP32 GPIO is 3.3V. For 5V sensors, use a level shifter or voltage divider.
4. **ADC Resolution:** Default 12-bit (4096 levels). Calibration may be needed for precision measurements.

See `pin-layout.png` for a visual schematic of all pin locations.
