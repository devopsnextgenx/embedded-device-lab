# Dashboard Directory

This directory contains Processing-based UI code for real-time visualization of sensor data.

## Overview

Processing is a flexible framework for building interactive visualizations and dashboards.

**Why Processing?**
- Real-time data visualization
- Interactive UI elements (sliders, buttons, graphs)
- Cross-platform (Windows, macOS, Linux)
- Easy serial communication with Arduino/ESP32

## Files

- `dashboard.pde` - Main Processing sketch (if created)
- `data/` - Assets (images, fonts, etc.) - optional

## Getting Started

1. **Install Processing:** Download from [processing.org](https://processing.org)

2. **Open dashboard.pde in Processing IDE**

3. **Verify Serial Configuration:**
   - Check which COM port your device uses: `pio device list`
   - Update in `dashboard.pde`: `myPort = new Serial(this, "COM3", 115200);`

4. **Run the Dashboard:**
   - Click Play button or press Ctrl+R
   - Data from your sketch will appear in real-time

## Example Dashboard Structure

```processing
import processing.serial.*;

Serial myPort;
ArrayList<Integer> data;

void settings() {
  size(800, 600);
}

void setup() {
  myPort = new Serial(this, "COM3", 115200);
  myPort.bufferUntil('\n');
  data = new ArrayList<Integer>();
}

void draw() {
  background(20);
  
  // Draw title, data, graph, etc.
  text("Current: " + data.get(data.size()-1), 20, 20);
  
  // Draw graph
  drawGraph();
}

void serialEvent(Serial p) {
  String inString = p.readStringUntil('\n');
  if (inString != null) {
    int value = int(trim(inString));
    data.add(value);
  }
}

void drawGraph() {
  // Graph drawing code
}
```

## Tips

- **Serial Format:** Send one value per line from Arduino (use `Serial.println(value)`)
- **Data Format:** Simple integers or floats, one per line
- **Real-time:** Processing reads new data automatically
- **Performance:** Limit history size to avoid slowdown

## Resources

- [Processing Reference](https://processing.org/reference/)
- [Serial Communication](https://processing.org/reference/libraries/serial/Serial.html)
- [Graphics Tutorial](https://processing.org/tutorials/drawing)

## Next Steps

Create your dashboard following the structure above and test with your sketch's serial output!
