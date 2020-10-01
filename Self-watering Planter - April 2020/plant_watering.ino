int motorPin = A0; // pin that turns on the motor
int buttonPin = 8;
int watertime = 20; // how long to water in seconds
int waittime = ; // how long to wait between watering, in hours
int t = 0; // current time
void setup()
{
  pinMode(motorPin, OUTPUT); // set A0 to an output so we can use it to turn on the transistor
  pinMode(buttonPin, INPUT_PULLUP);   // enable internal resistor
}

void loop() {

  delay(10);
  t += 10;
  
  if (t >= waittime * 1000 * 60 * 60) {
     digitalWrite(motorPin, HIGH);
     delay(watertime * 1000);
     digitalWrite(motorPin, LOW);
     t = 0;
       
  }
  
  boolean pressed = digitalRead(buttonPin);

  if (!pressed) {
    digitalWrite(motorPin, HIGH);
  } else {
    digitalWrite(motorPin, LOW);  // turn off the motor
  }

}
