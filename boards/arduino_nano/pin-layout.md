# Arduino Nano Board - Pin Layout & Documentation

## Board Overview
**Name:** Arduino Nano v3.x (ATmega328P)  
**Processor:** ATmega328P (8-bit AVR)  
**Clock Speed:** 16 MHz  
**RAM:** 2 KB SRAM  
**Flash:** 32 KB (2 KB bootloader)  
**EEPROM:** 1 KB  
**GPIO Pins:** 22 (14 digital, 8 analog)  
**PWM Pins:** 6 (D3, D5, D6, D9, D10, D11)  
**ADC:** 10-bit, 8 channels (A0-A7)  
**UART:** 1 (Serial)  
**SPI:** Hardware (D10-D13)  
**I2C:** 2 (SDA=A4, SCL=A5)  
**Power Supply:** 5V USB or 5V/7-12V DC jack

---

## Pin Mapping & Allocation

### **Power & Ground**
| Pin    | Function     | Notes                                  |
|--------|--------------|----------------------------------------|
| VIN    | 5-12V Input  | Raw power input (regulated to 5V)      |
| 5V     | 5V Rail      | Regulated 5V output (~500mA depending) |
| 3V3    | 3.3V Rail    | Low-current 3.3V (for sensors, etc.)   |
| GND    | Ground       | Common ground (multiple pins)          |
| AREF   | Analog Ref   | External analog reference input        |

### **Serial Communication (UART - Default)**
| Pin | Signal | Function     | Notes                          |
|-----|--------|--------------|--------------------------------|
| RX  | D0     | UART Receive | Serial.begin(9600) by default  |
| TX  | D1     | UART Transmit| Serial.print() output          |

### **Digital GPIO (D0-D13)**
| Pin | GPIO    | Alternate Function      | PWM | Notes                      |
|-----|---------|-------------------------|-----|----------------------------|
| D0  | PD0     | UART RX                 | No  | Serial receive             |
| D1  | PD1     | UART TX                 | No  | Serial transmit            |
| D2  | PD2     | INT0 (External IRQ)     | No  | Interrupt pin              |
| D3  | PD3     | INT1, OC2B              | Yes | PWM, Interrupt             |
| D4  | PD4     | XCK/T0                  | No  | Timer/counter              |
| D5  | PD5     | OC0B                    | Yes | PWM                        |
| D6  | PD6     | OC0A                    | Yes | PWM                        |
| D7  | PD7     | AIN1                    | No  | Analog comparator          |
| D8  | PB0     | ICP1, CLKO              | No  | Input capture / Oscillator |
| D9  | PB1     | OC1A                    | Yes | PWM (16-bit Timer1)        |
| D10 | PB2     | SS, OC1B                | Yes | PWM (SPI Chip Select)      |
| D11 | PB3     | MOSI, OC2A              | Yes | PWM (SPI Master Out)       |
| D12 | PB4     | MISO                    | No  | SPI Master In              |
| D13 | PB5     | SCK, LED                | No  | SPI Clock (on-board LED)   |

### **Analog Pins (A0-A7 / ADC Inputs)**
| Pin | GPIO    | ADC Channel | 10-bit Range | Notes                    |
|-----|---------|-------------|--------------|--------------------------|
| A0  | PC0     | CH0         | 0-1023       | Standard analog input    |
| A1  | PC1     | CH1         | 0-1023       | Standard analog input    |
| A2  | PC2     | CH2         | 0-1023       | Standard analog input    |
| A3  | PC3     | CH3         | 0-1023       | Standard analog input    |
| A4  | PC4     | CH4, SDA    | 0-1023       | I2C Data (with pullup)   |
| A5  | PC5     | CH5, SCL    | 0-1023       | I2C Clock (with pullup)  |
| A6  | ADC6    | CH6         | 0-1023       | Analog-only (no digital) |
| A7  | ADC7    | CH7         | 0-1023       | Analog-only (no digital) |

### **SPI Pins (Hardware SPI)**
| Pin | GPIO | Function | Notes                   |
|-----|------|----------|-------------------------|
| D13 | PB5  | SCK      | SPI Clock               |
| D12 | PB4  | MISO     | SPI Master In (Data In) |
| D11 | PB3  | MOSI     | SPI Master Out (Data)   |
| D10 | PB2  | SS       | Slave Select (CS)       |

### **I2C Pins (Hardware I2C / TWI)**
| Pin | GPIO | Function | Pullup | Notes             |
|-----|------|----------|--------|-------------------|
| A4  | PC4  | SDA      | 4.7kΩ  | I2C Data          |
| A5  | PC5  | SCL      | 4.7kΩ  | I2C Clock         |

### **External Interrupt Pins**
| Pin | GPIO | Interrupt | Notes                    |
|-----|------|-----------|--------------------------|
| D2  | PD2  | INT0      | attachInterrupt(0, ...)  |
| D3  | PD3  | INT1      | attachInterrupt(1, ...)  |

---

## PWM & Timer Configuration

### **PWM Pins (Analog Output)**
| Pin  | Timer | Frequency | Resolution | Max Value |
|------|-------|-----------|-------------|-----------|
| D3   | Timer2| 490 Hz    | 8-bit      | 255       |
| D5   | Timer0| 976 Hz    | 8-bit      | 255       |
| D6   | Timer0| 976 Hz    | 8-bit      | 255       |
| D9   | Timer1| 490 Hz    | 16-bit     | 65535     |
| D10  | Timer1| 490 Hz    | 16-bit     | 65535     |
| D11  | Timer2| 490 Hz    | 8-bit      | 255       |

Use `analogWrite(pin, 0-255)` to control PWM duty cycle.

---

## Analog Reference Options

By default, analog readings use **5V** as the reference (AREF pin internally connected via 100nF capacitor).

Change reference with: `analogReference(DEFAULT | INTERNAL | EXTERNAL)`

- **DEFAULT (5V):** Uses VCC (5V on Nano)
- **INTERNAL (1.1V):** Uses internal 1.1V reference (better for low-voltage sensors)
- **EXTERNAL:** Uses external voltage on AREF pin (max 5V)

---

## Common Peripheral Wiring

### **DHT Sensor (Temperature/Humidity)**
```
DHT GND  → Nano GND
DHT VCC  → Nano 5V
DHT DATA → Nano D4 (or any GPIO)
         + 10kΩ pull-up to 5V (or internal via pinMode)
```

### **OLED Display (I2C SSD1306)**
```
OLED GND  → Nano GND
OLED VCC  → Nano 5V
OLED SDA  → Nano A4 (I2C Data)
OLED SCL  → Nano A5 (I2C Clock)
```

### **DC Motor with L298N Driver**
```
Motor GND       → Nano GND
Motor VCC       → Nano 5V
Motor IN1       → Nano D5 (PWM for speed)
Motor IN2       → Nano D6 (PWM for direction)
Motor OUT1/OUT2 → Motor leads
```

### **Relay Module (5V)**
```
Relay GND    → Nano GND
Relay VCC    → Nano 5V
Relay Signal → Nano D8 (with 1kΩ resistor if needed)
Relay COM    → 5V supply
Relay NO     → Load positive
Relay GND    → Load negative (returns to Nano GND)
```

### **Potentiometer (Variable Resistor)**
```
Pot GND    → Nano GND
Pot Wiper  → Nano A0 (or A1-A7)
Pot VCC    → Nano 5V
```

---

## Developer Notes

1. **Power Budget:** The on-board 5V regulator can supply ~500mA total. Monitor current draw if powering sensors directly.
2. **Memory:** Total 2KB RAM. Use `F()` macro for string literals to conserve SRAM: `Serial.println(F("text"))`.
3. **Serial Baud Rate:** Default 9600. Can be changed with `Serial.begin(115200)`, but monitor speed must match.
4. **Voltage Divider:** For 5V sensors reading 3.3V signals, use a voltage divider on analog pins to scale input.
5. **USB Driver:** Nano uses CH340G USB bridge (older) or FT232RL (newer). Drivers may be required on Windows.
6. **EEPROM:** 1024 bytes available via `EEPROM.write()` and `EEPROM.read()`. Useful for persistent settings.

See `pin-layout.png` for a visual schematic of all pin locations.
