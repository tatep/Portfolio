float readDistance (int trigPin, int echoPin, float maxInches) {

  digitalWrite(trigPin, LOW); // trig pin sends series of signals w small delay
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(20); // what does changing these do?
  digitalWrite(trigPin, LOW);

  unsigned long timeout = maxInches * 74 * 2; // converts inches to microseconds
  
  float duration = pulseIn(echoPin, HIGH, timeout); // collects duration of signal

  float in;
  
  if (duration == 0) { // timeout reached, distance was greater than maxInches
    
     in = pow(maxInches, 2); // send a distance comfortably over maxInches
     
  } else { // allowed distance was measured
   
   in = (duration / 74) / 2; // 74 microqseconds per inch, devide by 2 bc signal travels back and forth
  }
  
  return in;
}



void sendtoP() { // sends to processing in this format:
  Serial.print(d1);
  Serial.print(" ");
  Serial.print(d2);
  Serial.print(" ");
  Serial.println(dz);
  
}

void moveServos (int angle) {
  
  servoL.write(angle);
  servoR.write(180 - angle);
}
