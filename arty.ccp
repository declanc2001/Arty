#define BUTTON_PIN 7       // Original button
#define RESET_BUTTON_PIN 8 // Reset button
#define RED_PIN 9          // RGB Red (player LED)
#define BLUE_PIN 10        // RGB Blue (player LED)
#define GREEN_PIN 11       // RGB Green (player LED)

int input;
int buttonState = LOW;
int lastButtonState = LOW;
int resetButtonState = LOW;
int lastResetButtonState = LOW;

bool rgbState = false;
int activeRGB = 0;

int targetColorIndex = 0;

enum ActiveLED { BLUE_LED, YELLOW_LED, RED_LED, WHITE_LED } currentLED;

// Define Color struct
struct Color {
  int r, g, b;
};

// All colors from your list mapped by activeRGB index
Color colors[17] = {
  {0, 0, 0},          // 0: off / no color
  {255, 0, 0},        // 1: Red
  {255, 255, 0},      // 2: Yellow
  {0, 0, 255},        // 3: Blue
  {255, 255, 255},    // 4: White
  {255, 165, 0},      // 5: Orange
  {138, 43, 226},     // 6: Purple
  {0, 255, 0},        // 7: Green
  {255, 192, 203},    // 8: Pink
  {255, 254, 224},    // 9: Light Yellow
  {173, 216, 230},    // 10: Light Blue
  {33, 10, 121},      // 11: Violet Blue
  {144, 238, 144},    // 12: Light Green
  {0, 255, 255},      // 13: Cyan
  {255, 0, 255},      // 14: Magenta
  {195, 73, 70},      // 15: Blood Orange
  {139, 69, 19}       // 16: Brown
};

void setup() {
  Serial.begin(9600);

  pinMode(2, OUTPUT);  // Red Indicator
  pinMode(3, OUTPUT);  // Yellow Indicator
  pinMode(4, OUTPUT);  // Blue Indicator
  pinMode(5, OUTPUT);  // White Indicator

  pinMode(RED_PIN, OUTPUT);
  pinMode(GREEN_PIN, OUTPUT);
  pinMode(BLUE_PIN, OUTPUT);

  pinMode(BUTTON_PIN, INPUT);
  pinMode(RESET_BUTTON_PIN, INPUT); // Set reset button as input

  digitalWrite(2, LOW);
  digitalWrite(3, LOW);
  digitalWrite(4, LOW);
  digitalWrite(5, LOW);
  
  
  randomSeed(analogRead(A1));
  resetRGB();
}

void loop() {
  //--- ANALOG INPUT LED CONTROL ---
  input = analogRead(A0);

  if (input < 256) {
    setIndicator(1, 0, 0, 0);   // Red
    currentLED = RED_LED;
  } else if (input < 512) {
    setIndicator(0, 1, 0, 0);   // Yellow
    currentLED = YELLOW_LED;
  } else if (input < 768) {
    setIndicator(0, 0, 1, 0);   // Blue
    currentLED = BLUE_LED;
  } else {
    setIndicator(0, 0, 0, 1);   // White
    currentLED = WHITE_LED;
  }

  //--- BUTTON PRESS HANDLING ---
  buttonState = digitalRead(BUTTON_PIN);
  if (buttonState == HIGH && lastButtonState == LOW) {
    handleButtonPress();
    delay(50);  // Simple debounce
  }

  //--- RESET BUTTON HANDLING ---
  resetButtonState = digitalRead(RESET_BUTTON_PIN);
  if (resetButtonState == HIGH && lastResetButtonState == LOW) {
    resetRGB();
    delay(50);  // Simple debounce
  }

  lastButtonState = buttonState;
  lastResetButtonState = resetButtonState;

}

// Set indicator LEDs
void setIndicator(bool red, bool yellow, bool green, bool white) {
  digitalWrite(2, red ? HIGH : LOW);
  digitalWrite(3, yellow ? HIGH : LOW);
  digitalWrite(4, green ? HIGH : LOW);
  digitalWrite(5, white ? HIGH : LOW);
}

// Handle the button press based on the current LED state
void handleButtonPress() {
  if (activeRGB >= 8) return; // If RGB is locked, do nothing

  switch (currentLED) {
    case RED_LED:
      if (activeRGB == 2) activeRGB = 5;
      else if (activeRGB == 3) activeRGB = 6;
      else if (activeRGB == 4) activeRGB = 8;
      else if (activeRGB == 5) activeRGB = 15;
      else if (activeRGB == 7) activeRGB = 16;
      else if (activeRGB == 0) activeRGB = 1;
      break;

    case YELLOW_LED:
      if (activeRGB == 3) activeRGB = 7;
      else if (activeRGB == 1) activeRGB = 5;
      else if (activeRGB == 4) activeRGB = 9;
      else if (activeRGB == 7) activeRGB = 12;
      else if (activeRGB == 6) activeRGB = 16;
      else if (activeRGB == 0) activeRGB = 2;
      break;

    case BLUE_LED:
      if (activeRGB == 2) activeRGB = 7;
      else if (activeRGB == 1) activeRGB = 6;
      else if (activeRGB == 4) activeRGB = 10;
      else if (activeRGB == 6) activeRGB = 11;
      else if (activeRGB == 7) activeRGB = 13;
      else if (activeRGB == 5) activeRGB = 16;
      else if (activeRGB == 0) activeRGB = 3;
      break;

    case WHITE_LED:
      if (activeRGB == 1) activeRGB = 8;
      else if (activeRGB == 2) activeRGB = 9;
      else if (activeRGB == 3) activeRGB = 10;
      else if (activeRGB == 6) activeRGB = 14;
      else if (activeRGB == 7) activeRGB = 12;
      else if (activeRGB == 0) activeRGB = 4;
      break;
  }

  Serial.print("Selected color index: ");
  Serial.println(activeRGB);
  Serial.print("RGB Values: R=");
  Serial.print(colors[activeRGB].r);
  Serial.print(" G=");
  Serial.print(colors[activeRGB].g);
  Serial.print(" B=");
  Serial.println(colors[activeRGB].b);


  setColor(colors[activeRGB].r, colors[activeRGB].g, colors[activeRGB].b);
}

// Reset the RGB LED (turn it off)
void resetRGB() {
  setColor(0, 0, 0);  // Turn off RGB LED
  activeRGB = 0;      // Reset activeRGB state
  rgbState = false;   // Reset RGB state
  setIndicator(0, 0, 0, 0); // Turn off all indicator LEDs
}

// Set RGB color for player LED
void setColor(int r, int g, int b) {
  analogWrite(RED_PIN, r);
  analogWrite(GREEN_PIN, g);
  analogWrite(BLUE_PIN, b);
}

