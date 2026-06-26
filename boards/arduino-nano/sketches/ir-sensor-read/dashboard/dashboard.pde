import processing.serial.*;

// IR Sensor Dashboard
// Serial protocol:
// - Metadata lines: "Sketch:", "Version:", "Author:", "Date:", "Sensor Pin:".
// - Analog telemetry: "Raw ADC: 512 | Voltage: 2.50 V"
// - Digital state: "Obstacle: ACTIVE" / "Obstacle: LOW"

// Serial
Serial myPort;
final int BAUD_RATE = 9600;

// Sensor / metadata state
int latestRaw = -1;
float latestVoltage = -1;
boolean obstacleActive = false;
boolean hasAnalogData = false;
boolean hasDigitalData = false;
float approxDistanceCm = -1;

String sketchName = "ir-sensor-read";
String sketchVersion = "-";
String sketchAuthor = "-";
String sketchDate = "-";
String sensorPin = "A0";
String connStatus = "Connecting...";

// Calibration for rough distance approximation in analog mode.
final int ADC_NEAR = 850;
final int ADC_FAR = 180;
final float DIST_NEAR_CM = 5.0;
final float DIST_FAR_CM = 40.0;
final int OBSTACLE_THRESHOLD_ADC = 500;

// Layout constants
final int INITIAL_W = 940;
final int INITIAL_H = 620;

final int ORB_R = 95;
final int PANEL_MARGIN = 20;
final int PANEL_Y = 70;
final int PANEL_MIN_W = 320;
final int PANEL_MAX_W = 430;
final int PANEL_MIN_H = 360;

// Colors
color COL_BG = color(18, 18, 24);
color COL_PANEL_BG = color(28, 30, 42);
color COL_PANEL_EDGE = color(60, 65, 90);
color COL_TITLE = color(220, 226, 255);
color COL_LABEL = color(130, 140, 180);
color COL_VALUE = color(220, 225, 255);
color COL_ACTIVE = color(230, 60, 70);
color COL_ACTIVE_GLOW = color(245, 80, 92, 70);
color COL_IDLE = color(96, 100, 114);
color COL_RING = color(50, 55, 75);
color COL_STATUS_OK = color(80, 230, 160);
color COL_STATUS_WAIT = color(200, 180, 80);

void settings() {
  size(INITIAL_W, INITIAL_H, P2D);
}

void setup() {
  surface.setTitle("IR Sensor Dashboard");
  textFont(createFont("Monospaced", 13));

  String[] ports = Serial.list();
  if (ports.length == 0) {
    connStatus = "No serial ports found";
    return;
  }

  try {
    myPort = new Serial(this, ports[0], BAUD_RATE);
    connStatus = "Connected: " + ports[0];
  } catch (Exception e) {
    connStatus = "Port error: " + e.getMessage();
  }
}

void draw() {
  if (myPort != null) {
    while (myPort.available() > 0) {
      String raw = myPort.readStringUntil('\n');
      if (raw != null) {
        parseSerial(trim(raw));
      }
    }
  }

  background(COL_BG);
  drawTitle();
  drawObstacleIndicator();
  drawStatusPanel();
}

void drawTitle() {
  fill(COL_TITLE);
  textSize(18);
  textAlign(LEFT, TOP);
  text("IR Obstacle Dashboard", 20, 22);

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

void drawObstacleIndicator() {
  int panelX = getPanelX();
  int sceneLeft = 26;
  int sceneRight = panelX - 24;
  int sceneW = max(220, sceneRight - sceneLeft);
  int groundY = int(height * 0.69);
  int sensorX = sceneLeft + 52;
  int sensorY = groundY - 26;
  boolean active = getObstacleState();
  boolean hasDistance = hasAnalogData && approxDistanceCm > 0;

  float nearX = sensorX + 120;
  float farX = sceneRight - 110;
  float normalizedDistance = hasDistance
    ? map(approxDistanceCm, DIST_NEAR_CM, DIST_FAR_CM, 0, 1)
    : 0.65;
  normalizedDistance = constrain(normalizedDistance, 0, 1);
  int mountainBaseX = int(lerp(nearX, farX, normalizedDistance));
  int mountainTopY = groundY - int(120 + 24 * sin(frameCount * 0.02));

  textSize(13);
  fill(COL_LABEL);
  textAlign(CENTER, BASELINE);
  text("SENSOR VIEW", sceneLeft + sceneW / 2, PANEL_Y + 16);

  noStroke();
  fill(24, 28, 39);
  rect(sceneLeft, PANEL_Y + 28, sceneW, groundY - (PANEL_Y + 28), 8);

  fill(34, 46, 36);
  rect(sceneLeft, groundY, sceneW, 44, 0, 0, 8, 8);

  drawSensorIcon(sensorX, sensorY, active);
  drawMountainObstacle(mountainBaseX, groundY, mountainTopY, active);
  drawDistanceBeam(sensorX + 24, sensorY - 8, mountainBaseX - 30, mountainTopY + 40, active, hasDistance);

  fill(COL_LABEL);
  textAlign(LEFT, BASELINE);
  textSize(11);
  text("IR Sensor", sensorX - 22, sensorY + 44);

  textAlign(CENTER, BASELINE);
  fill(COL_VALUE);
  textSize(16);
  if (hasDistance) {
    String d = nf(approxDistanceCm, 0, 1) + " cm";
    float labelX = (sensorX + mountainBaseX) * 0.5;
    float labelY = sensorY - 38 + 6 * sin(frameCount * 0.08);
    fill(10, 12, 18, 190);
    rect(labelX - 66, labelY - 17, 132, 26, 6);
    fill(COL_VALUE);
    text("Approx: " + d, labelX, labelY + 2);
  } else {
    text("Approx Distance: --", sceneLeft + sceneW / 2, groundY - 52);
  }

  fill(active ? COL_ACTIVE : COL_IDLE);
  textSize(14);
  text("State: " + (active ? "ACTIVE" : "LOW"), sceneLeft + sceneW / 2, groundY + 28);

  textAlign(LEFT, BASELINE);
  noStroke();
}

void drawSensorIcon(int x, int y, boolean active) {
  noStroke();
  fill(78, 84, 102);
  rect(x - 16, y + 4, 28, 28, 6);

  fill(53, 56, 70);
  rect(x - 22, y + 22, 42, 9, 4);

  fill(active ? color(240, 88, 94) : color(130, 136, 152));
  ellipse(x + 16, y + 14, 15, 15);

  fill(245, 248, 255, active ? 200 : 130);
  ellipse(x + 16, y + 14, 5, 5);
}

void drawMountainObstacle(int baseX, int groundY, int peakY, boolean active) {
  int mountainW = 160;

  noStroke();
  fill(active ? color(136, 79, 68) : color(90, 92, 98));
  triangle(baseX - mountainW / 2, groundY, baseX, peakY, baseX + mountainW / 2, groundY);

  fill(active ? color(166, 98, 86) : color(112, 114, 122));
  triangle(baseX - mountainW / 4, groundY, baseX + 18, peakY + 30, baseX + mountainW / 2, groundY);

  fill(236, 239, 245, active ? 215 : 160);
  triangle(baseX - 18, peakY + 20, baseX, peakY, baseX + 22, peakY + 22);
}

void drawDistanceBeam(float sx, float sy, float ex, float ey, boolean active, boolean hasDistance) {
  color beam = active ? color(244, 96, 102) : color(128, 136, 148);
  float alpha = hasDistance ? 220 : 120;

  stroke(beam, alpha);
  strokeWeight(2.5);
  line(sx, sy, ex, ey);

  stroke(beam, alpha * 0.35);
  strokeWeight(7);
  line(sx, sy, ex, ey);

  noStroke();
  int particles = 6;
  for (int i = 0; i < particles; i++) {
    float t = ((frameCount * 0.02) + i * 0.17) % 1.0;
    float px = lerp(sx, ex, t);
    float py = lerp(sy, ey, t);
    float a = (active ? 190 : 120) * (0.55 + 0.45 * sin(frameCount * 0.09 + i));
    fill(red(beam), green(beam), blue(beam), a);
    ellipse(px, py, 5, 5);
  }
}

void drawStatusPanel() {
  int panelW = getPanelW();
  int panelX = getPanelX();
  int panelH = getPanelH();

  fill(COL_PANEL_BG);
  stroke(COL_PANEL_EDGE);
  strokeWeight(1);
  rect(panelX, PANEL_Y, panelW, panelH, 8);
  noStroke();

  fill(COL_TITLE);
  textSize(13);
  textAlign(LEFT, BASELINE);
  text("Status", panelX + 14, PANEL_Y + 22);

  stroke(COL_PANEL_EDGE);
  line(panelX + 10, PANEL_Y + 30, panelX + panelW - 10, PANEL_Y + 30);
  noStroke();

  int rowH = 30;
  int startY = PANEL_Y + 52;

  drawInfoRow("Sketch", sketchName, panelX + 14, startY);
  drawInfoRow("Version", sketchVersion, panelX + 14, startY + rowH);
  drawInfoRow("Author", sketchAuthor, panelX + 14, startY + rowH * 2);
  drawInfoRow("Date", sketchDate, panelX + 14, startY + rowH * 3);
  drawInfoRow("Sensor Pin", sensorPin, panelX + 14, startY + rowH * 4);
  drawInfoRow("Baud", str(BAUD_RATE) + " bps", panelX + 14, startY + rowH * 5);
  drawInfoRow("Raw ADC", latestRaw >= 0 ? str(latestRaw) : "--", panelX + 14, startY + rowH * 6);
  drawInfoRow("Voltage", latestVoltage >= 0 ? nf(latestVoltage, 0, 2) + " V" : "--", panelX + 14, startY + rowH * 7);
  drawInfoRow("Obstacle", getObstacleState() ? "ACTIVE" : "LOW", panelX + 14, startY + rowH * 8);
  drawInfoRow("Mode", getModeLabel(), panelX + 14, startY + rowH * 9);
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

boolean getObstacleState() {
  if (hasDigitalData) {
    return obstacleActive;
  }
  if (hasAnalogData && latestRaw >= 0) {
    return latestRaw >= OBSTACLE_THRESHOLD_ADC;
  }
  return false;
}

String getModeLabel() {
  if (hasDigitalData) return "Digital ACTIVE/LOW";
  if (hasAnalogData) return "Analog estimate";
  return "Unknown";
}

float computeApproxDistanceCm(int raw) {
  int clamped = constrain(raw, ADC_FAR, ADC_NEAR);
  float mapped = map(clamped, ADC_FAR, ADC_NEAR, DIST_FAR_CM, DIST_NEAR_CM);
  return constrain(mapped, DIST_NEAR_CM, DIST_FAR_CM);
}

void parseSerial(String raw) {
  if (raw.length() == 0) return;

  if (raw.startsWith("Sketch:")) {
    sketchName = trim(raw.substring("Sketch:".length()));
    return;
  }
  if (raw.startsWith("Version:")) {
    sketchVersion = trim(raw.substring("Version:".length()));
    return;
  }
  if (raw.startsWith("Author:")) {
    sketchAuthor = trim(raw.substring("Author:".length()));
    return;
  }
  if (raw.startsWith("Date:")) {
    sketchDate = trim(raw.substring("Date:".length()));
    return;
  }
  if (raw.startsWith("Sensor Pin:")) {
    sensorPin = trim(raw.substring("Sensor Pin:".length()));
    return;
  }

  if (raw.startsWith("Raw ADC:")) {
    hasAnalogData = true;

    int rawIdx = raw.indexOf("Raw ADC:") + 8;
    int pipeIdx = raw.indexOf("|");
    if (pipeIdx > rawIdx) {
      String rawPart = trim(raw.substring(rawIdx, pipeIdx));
      try {
        latestRaw = int(rawPart);
        approxDistanceCm = computeApproxDistanceCm(latestRaw);
      } catch (Exception e) {
        // Ignore malformed value
      }
    }

    int voltIdx = raw.indexOf("Voltage:");
    int vUnitIdx = raw.indexOf("V", voltIdx);
    if (voltIdx >= 0) {
      String vPart = (vUnitIdx > voltIdx)
        ? trim(raw.substring(voltIdx + 8, vUnitIdx))
        : trim(raw.substring(voltIdx + 8));
      try {
        latestVoltage = float(vPart);
      } catch (Exception e) {
        // Ignore malformed value
      }
    }
    return;
  }

  if (raw.startsWith("Obstacle:")) {
    hasDigitalData = true;
    String state = trim(raw.substring("Obstacle:".length()));
    obstacleActive = state.equals("ACTIVE") || state.equals("HIGH") || state.equals("DETECTED");
    return;
  }

  try {
    int rawValue = int(raw);
    latestRaw = rawValue;
    hasAnalogData = true;
    approxDistanceCm = computeApproxDistanceCm(rawValue);
  } catch (Exception e) {
    // Ignore unknown lines
  }
}
