#include "wiring_private.h"
#include "pins_arduino.h"

#include <Servo.h>
//need more power, swap teensy with arduino??

Servo servoL;
Servo servoR;

const int chords [][3] = { {0, 4, 7} , {7, 10, 13} , {7, 11, 14} ,
  {11, 14, 19} , {9, 12, 16} , {7, 9, 12} , {5, 9, 12} , {9, 12, 17} , {12, 17, 21}
};

const int servoLPin = 4; //***needs to support pwm
const int servoRPin = 3; //***needs to support pwm


const int trig1 = 12;
const int echo1 = 11;
const int trig2 = 10;
const int echo2 = 9;
const int trigz = 8;
const int echoz = 7;

int maxInches = 30;
float d1, d2, dz;

int angle;
String readString;

int oldValue = 0;

int octave = 5;

void setup() {

  Serial.begin(19200);

  pinMode(trig1, OUTPUT);
  pinMode(trig2, OUTPUT);
  pinMode(trigz, OUTPUT);

  pinMode(echo1, INPUT);
  pinMode(echo2, INPUT);
  pinMode(echoz, INPUT);

  servoL.attach(servoLPin);
  servoR.attach(servoRPin);
}

void loop() {


  delay(20);
  d2 = readDistance(trig2, echo2, 30);
  delay(20);
  dz = readDistance(trigz, echoz, 30);
  delay(20);
  d1 = readDistance(trig1, echo1, 30);
  sendtoP(); // sends distances to processing

  while (Serial.available()) { // if data is available

    delay(2);  //delay to allow byte to arrive in input buffer
    char c = Serial.read();
    readString += c;

  }

  if (readString.length() > 0) {

    if (readString == "n") { // if processing tells arduino code is restarted

      maxInches = 30;

      moveServos(90); // move servo to starting position
      delay(1000); // wait for servos to reach ^

    } else if (maxInches == 30) { // have not recieved new max inches from processing yet (after calibration)

      maxInches = readString.toInt();

    } else if (readString.substring(0, 1) == "s") { // s for sound - following characters are sound instructions

      int value = (readString.substring(1)).toInt();

      oldValue = sendToGB(value, octave, oldValue);

    } else if (readString.substring(0, 1) == "o") { //

      usbMIDI.sendNoteOn(63, 127, 1);
      octave = (readString.substring(1)).toInt();

    } else { // move servos

      moveServos(readString.toInt()); // writes to servo
    }

    readString = ""; // clear readString
  }
}
