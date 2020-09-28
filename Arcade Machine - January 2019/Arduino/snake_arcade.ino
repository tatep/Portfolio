#include "FastLED.h"
#define NUM_LEDS 256
CRGB leds[NUM_LEDS];
const int maxlen = 64;

int snakeX[maxlen];
int tempXs[maxlen];
int snakeY[maxlen];
int tempYs[maxlen];

int original_speed = 400;//base speed
int snake_speed = 0; //speed of snake changes

int len = 3;

String dir = "up"; //default direction
String moving_dir = "up";

//240-255
int xPin = A1; 
int yPin = A0;
int buttonPin = 2; 

int joystickX = 0; //  joystick values
int joystickY = 0;
int buttonState = 0;

int piezoPin = 9; // buzzzer pin
int button_lower = 3;
int button_higher = 4;

int fruitX = 0; // fruit coordinates
int fruitY = 0;

int temp_tailX = 0;
int temp_tailY = 0;

boolean end_game = false;
boolean is_eaten = false;
boolean restart = false;
int counter = 0;






int coord(int row,int column) { //coordinates --> led #
  if ((row%2)==0) {
    return ((row-1)*16)+(column-1);
  }
  else {
    return ((row-1)*16)+(16-column);
  }
}




void movement(){
 
   for (int i=0; i < len; i++) {
    tempXs[i] = snakeX[i];
    tempYs[i] = snakeY[i];
//    Serial.print("X value: ");
//    Serial.println(snakeX[i]);
//    Serial.print("Y value: "); 
//    Serial.println(snakeY[i]);
   }
  
  for (int i=len-1; i>0; i--) { //shifts all values exept for head
    snakeX[i] = snakeX[i-1];
    snakeY[i] = snakeY[i-1];
  }

  if (fruit_eaten() == true) {
    snakeX[len] = tempXs[len-1];
    snakeY[len] = tempYs[len-1];
    temp_tailX = snakeX[len];
    temp_tailY = snakeY[len];
    len += 1;
    is_eaten = true;
    fruit();
  }
  
//  Serial.print("Direction: ");
//  Serial.println(dir);
  
  if (dir == "up") { //UP // sets new head
    snakeY[0] = snakeY[0]+1;
    moving_dir = "up";
  }
  if (dir == "down") { // DOWN
    snakeY[0] = snakeY[0]-1;
    moving_dir = "down";
  }
  if (dir == "left") { //LEFT
    snakeX[0]=snakeX[0]-1;
    moving_dir = "left";
  }
  if (dir == "right") { //RIGHT
    snakeX[0] = snakeX[0]+1;
    moving_dir = "right";
  }
  
  for(int i=1; i<len; i++){ //displays new snake
    leds[coord(snakeX[i],snakeY[i])] = CRGB::Green; FastLED.show();
  }
  
  if (counter == 1) {
    counter = 0;
    is_eaten = false;
    leds[coord(temp_tailX,temp_tailY)] = CRGB::Black; FastLED.show(); // removes the tail normally
  }
  if (is_eaten == true) {
    counter += 1;
  }
  leds[coord(tempXs[len-1],tempYs[len-1])] = CRGB::Black; FastLED.show(); // removes the tail normally
  leds[coord(snakeX[0],snakeY[0])] = CRGB::Olive; FastLED.show();//head color


  if (touching_self() == true) {
    end_game = true;
    tone(piezoPin, 1000, 400);
    tone(piezoPin, 800, 400);
    tone(piezoPin, 600, 400);
    tone(piezoPin, 400, 400);
    for(int i=0; i<len; i++){ //death animation
      leds[coord(snakeX[i],snakeY[i])] = CRGB::Black; FastLED.show();
      delay(5);
    }
    for(int i=0; i<len; i++){ //death animation
      leds[coord(snakeX[i],snakeY[i])] = CRGB::Red; FastLED.show();
      delay(5);
    }
  }

}




void fruit() {
  int valid = false;
  while (valid == false) { // so it does not choose a point occupied by the snake
    fruitX = random(1,17);
    fruitY = random(1,17);
    int counter = 0;
    for (int i=0;i<len;i++) {
      if (fruitX != snakeX[i] and fruitY != snakeY[i]) {
        counter += 1;
      }
    }
    if (counter == len) {
      valid = true;
    }
  }
  leds[coord(fruitX,fruitY)] = CRGB::Red; FastLED.show();
}




int fruit_eaten() {
  if(fruitX == snakeX[0] and fruitY == snakeY[0]) {
    tone(piezoPin, 1000, 300);
    leds[coord(fruitX,fruitY)] = CRGB::Black; FastLED.show();
    return true;
  }
  else {
    return false;
  }
}




int touching_self() {
  for (int i = 1; i < len-1; i++) {
    if (snakeX[0] == snakeX[i] and snakeY[0] == snakeY[i]) {
      return true;
    }
  }

  if (snakeY[0] == 17 or snakeY[0] == 0 or snakeX[0] == 0 or snakeX[0] == 17) {
    return true;
  }
  else {
    return false;
  }
}



void clear_board() {
  for(int i = 0; i <= 16; i++) {
    for(int j = 0; j<= 16; j++) {
      leds[coord(i,j)] = CRGB::Black; FastLED.show();
    }
  }
}
  


void setup() {
  FastLED.addLeds<NEOPIXEL, 8>(leds, NUM_LEDS);

  pinMode(button_lower, INPUT_PULLUP);
  pinMode(button_higher, INPUT_PULLUP);
  
  
  // initialize serial communications at 9600 bps:
  Serial.begin(9600); 
  
  pinMode(xPin, INPUT);
  pinMode(yPin, INPUT);

  //activate pull-up resistor on the push-button pin
  pinMode(buttonPin, INPUT_PULLUP); 
  
}

void loop() {
  len = 3;
  dir = "up";
  moving_dir = "up";
  snake_speed = original_speed;
  temp_tailX = 0;
  temp_tailY = 0;
  end_game = false;
  is_eaten = false;
  restart = false;
  counter = 0;
  for(int i=0; i<maxlen; i++){//clear snake coordinates
    snakeX[i] = snakeY[i] = -1;
    tempXs[i] = tempYs[i] = -1;
  }
  snakeX[0] = 8; //initial snake is 3 pixels long
  snakeY[0] = 8;
  snakeX[1] = 8;
  snakeY[1] = 7;
  snakeX[2] = 8;
  snakeY[2] = 6;

  fruit();
  int higher_value = digitalRead(button_higher);
  int lower_value = digitalRead(button_lower);
  
  while(end_game == false) {
    joystickX = analogRead(xPin);
    joystickY = analogRead(yPin);
    buttonState = digitalRead(buttonPin);
    higher_value = digitalRead(button_higher);
    lower_value = digitalRead(button_lower);
  
    if (joystickX<300 and moving_dir != "down") { //UP
      dir = "up";
    }
    if (joystickX>900 and moving_dir != "up") { // DOWN
      dir = "down";
    }
    if (joystickY>700 and moving_dir != "right") { //LEFT 
      dir = "left";
    }
    if (joystickY<200 and moving_dir != "left") { //RIGHT
      dir = "right";
    }
    
    if (lower_value == LOW) {
      snake_speed = original_speed - 350;
      tone(piezoPin, 5000, 200);
    }
    else {
      snake_speed = original_speed;
    }
   
   movement();
 
   delay(snake_speed); 
  }
  
  while (higher_value == HIGH) {
    delay(1);
    Serial.println("HIGH:");
    Serial.println(higher_value);
    higher_value = digitalRead(button_higher);
  }
  end_game = false;
  clear_board();
  
}
