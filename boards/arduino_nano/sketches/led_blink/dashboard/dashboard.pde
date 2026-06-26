// LED Blink Dashboard
// Processing sketch for visualizing LED on/off state from Arduino Nano
// Serial protocol: JSON lines {"LED":"ON"} / {"LED":"OFF"}
// Also parses setup info lines: "Sketch: ...", "Version: ...", "LED Pin: ...", "Baud: ..."

import processing.serial.*;

// ─── Serial ──────────────────────────────────────────────────────────────────
Serial myPort;
final int BAUD_RATE = 9600;

// ─── State ───────────────────────────────────────────────────────────────────
boolean ledOn         = false;
String  sketchName    = "led_blink";
String  sketchVersion = "—";
String  sketchAuthor  = "—";
String  sketchDate    = "—";
String  ledPin        = "13 (LED_BUILTIN)";
String  connStatus    = "Connecting...";

// ─── Layout constants ────────────────────────────────────────────────────────
final int INITIAL_W = 920;
final int INITIAL_H = 620;

final int LED_R = 80;

final int PANEL_MARGIN = 20;
final int PANEL_Y      = 70;
final int PANEL_MIN_W  = 300;
final int PANEL_MAX_W  = 420;
final int PANEL_MIN_H  = 340;

// ─── Colors ──────────────────────────────────────────────────────────────────
color COL_BG          = color(18, 18, 24);
color COL_PANEL_BG    = color(28, 30, 42);
color COL_PANEL_EDGE  = color(60, 65, 90);
color COL_TITLE       = color(200, 210, 255);
color COL_LABEL       = color(130, 140, 180);
color COL_VALUE       = color(220, 225, 255);
color COL_LED_ON      = color(0, 200, 255);   // neon blue
color COL_LED_GLOW    = color(0, 140, 220, 80);
color COL_LED_OFF     = color(80, 85, 100);   // gray
color COL_LED_RING    = color(50, 55, 75);
color COL_STATUS_OK   = color(80, 230, 160);
color COL_STATUS_WAIT = color(200, 180, 80);

// ─── Setup ───────────────────────────────────────────────────────────────────
void settings() {
  // Use P2D to avoid Java2D/AWT back-buffer crashes during live resize.
  size(INITIAL_W, INITIAL_H, P2D);
}

void setup() {
  surface.setTitle("LED Blink Dashboard");
  textFont(createFont("Monospaced", 13));

  String[] ports = Serial.list();
  if (ports.length == 0) {
    connStatus = "No serial ports found";
    return;
  }

  // Try the first available port; update COM_PORT in the call below if needed
  // To target a specific port: new Serial(this, "COM3", BAUD_RATE)
  try {
    myPort = new Serial(this, ports[0], BAUD_RATE);
    // Do NOT call bufferUntil() — poll in draw() for reliable updates
    connStatus = "Connected: " + ports[0];
  } catch (Exception e) {
    connStatus = "Port error: " + e.getMessage();
  }
}

// ─── Draw ─────────────────────────────────────────────────────────────────────
void draw() {
  // Poll serial every frame — more reliable than serialEvent() callback
  if (myPort != null) {
    while (myPort.available() > 0) {
      String raw = myPort.readStringUntil('\n');
      if (raw != null) parseSerial(trim(raw));
    }
  }

  background(COL_BG);
  drawTitle();
  drawLedIndicator();
  drawStatusPanel();
}

void drawTitle() {
  fill(COL_TITLE);
  textSize(18);
  textAlign(LEFT, TOP);
  text("LED Blink Dashboard", 20, 22);

  // connection status dot + text
  float dot = 10;
  boolean connected = (myPort != null);
  fill(connected ? COL_STATUS_OK : COL_STATUS_WAIT);
  noStroke();
  ellipse(22, height - 22, dot, dot);

  textSize(11);
  fill(connected ? COL_STATUS_OK : COL_STATUS_WAIT);
  textAlign(LEFT, CENTER);
  text(connStatus, 32, height - 22);
  textAlign(LEFT, BASELINE);
}

void drawLedIndicator() {
  int panelX = getPanelX();
  int ledCx = max(120, panelX / 2);
  int ledCy = height / 2;

  // Label above
  textSize(13);
  fill(COL_LABEL);
  textAlign(CENTER, BASELINE);
  text("LED", ledCx, ledCy - LED_R - 18);

  if (ledOn) {
    // Outer glow
    noStroke();
    for (int r = LED_R + 40; r > LED_R; r -= 6) {
      float alpha = map(r, LED_R, LED_R + 40, 60, 0);
      fill(red(COL_LED_ON), green(COL_LED_ON), blue(COL_LED_ON), alpha);
      ellipse(ledCx, ledCy, r * 2, r * 2);
    }

    // Main circle — neon blue
    stroke(COL_LED_ON);
    strokeWeight(3);
    fill(COL_LED_ON);
    ellipse(ledCx, ledCy, LED_R * 2, LED_R * 2);

    // Inner highlight
    noStroke();
    fill(200, 240, 255, 160);
    ellipse(ledCx - LED_R * 0.28, ledCy - LED_R * 0.28,
            LED_R * 0.55, LED_R * 0.55);

    // State label
    fill(10, 10, 20);
    textSize(22);
    textAlign(CENTER, CENTER);
    text("ON", ledCx, ledCy + 4);
  } else {
    // Ring
    stroke(COL_LED_RING);
    strokeWeight(2);
    fill(COL_LED_OFF);
    ellipse(ledCx, ledCy, LED_R * 2, LED_R * 2);

    // State label
    fill(150, 155, 170);
    textSize(22);
    textAlign(CENTER, CENTER);
    text("OFF", ledCx, ledCy + 4);
  }

  noStroke();
  textAlign(LEFT, BASELINE);
}

void drawStatusPanel() {
  int panelW = getPanelW();
  int panelX = getPanelX();
  int panelH = getPanelH();

  // Panel background
  fill(COL_PANEL_BG);
  stroke(COL_PANEL_EDGE);
  strokeWeight(1);
  rect(panelX, PANEL_Y, panelW, panelH, 8);
  noStroke();

  // Panel title
  fill(COL_TITLE);
  textSize(13);
  textAlign(LEFT, BASELINE);
  text("Status", panelX + 14, PANEL_Y + 22);

  // Divider
  stroke(COL_PANEL_EDGE);
  line(panelX + 10, PANEL_Y + 30, panelX + panelW - 10, PANEL_Y + 30);
  noStroke();

  int rowH = 34;
  int startY = PANEL_Y + 52;

  drawInfoRow("Sketch",   sketchName,                panelX + 14, startY);
  drawInfoRow("Version",  sketchVersion,             panelX + 14, startY + rowH);
  drawInfoRow("Author",   sketchAuthor,              panelX + 14, startY + rowH * 2);
  drawInfoRow("Date",     sketchDate,                panelX + 14, startY + rowH * 3);
  drawInfoRow("LED Pin",  ledPin,                    panelX + 14, startY + rowH * 4);
  drawInfoRow("Baud",     str(BAUD_RATE) + " bps",  panelX + 14, startY + rowH * 5);
  drawInfoRow("State",    ledOn ? "ON" : "OFF",      panelX + 14, startY + rowH * 6);

  textAlign(LEFT, BASELINE);
}

void drawInfoRow(String label, String value, int x, int y) {
  textSize(11);
  fill(COL_LABEL);
  text(label, x, y);

  textSize(13);
  fill(COL_VALUE);
  String shown = value;
  float maxW = getPanelW() - 28;
  while (textWidth(shown) > maxW && shown.length() > 4) {
    shown = shown.substring(0, shown.length() - 2);
  }
  if (!shown.equals(value)) {
    shown = shown + "...";
  }
  text(shown, x, y + 16);
}

int getPanelW() {
  return constrain(width / 2, PANEL_MIN_W, PANEL_MAX_W);
}

int getPanelX() {
  return width - getPanelW() - PANEL_MARGIN;
}

int getPanelH() {
  return max(PANEL_MIN_H, height - (PANEL_Y + PANEL_MARGIN));
}

// ─── Serial parsing ──────────────────────────────────────────────────────────
void parseSerial(String raw) {
  if (raw.length() == 0) return;

  // JSON state lines
  if (raw.equals("{\"LED\":\"ON\"}")) {
    ledOn = true;
    return;
  }
  if (raw.equals("{\"LED\":\"OFF\"}")) {
    ledOn = false;
    return;
  }

  // Setup info lines emitted by the sketch
  if (raw.startsWith("Sketch:")) {
    sketchName = trim(raw.substring("Sketch:".length()));
  } else if (raw.startsWith("Version:")) {
    sketchVersion = trim(raw.substring("Version:".length()));
  } else if (raw.startsWith("Author:")) {
    sketchAuthor = trim(raw.substring("Author:".length()));
  } else if (raw.startsWith("Date:")) {
    sketchDate = trim(raw.substring("Date:".length()));
  } else if (raw.startsWith("LED Pin:")) {
    ledPin = trim(raw.substring("LED Pin:".length()));
  }
}
