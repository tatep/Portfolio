

void calibrate() {

  background(255);
  drawDiagram(text, counter);

  fill(0);
  textSize(20);
  text(text, 1150, 200);
  text(text2, 750, 200);
  textSize(15);
  text(point1, 430, 60);
  text(point2, 500, 60);
  if (port.available() > 0) {

    reading = port.readStringUntil('\n'); // reads one line of serial

    if (reading != null) { // run here

      float [] distances = readSerial(); // Array of each desired item
      d1Values[counter] = distances[0]; //raw reading of left US
      d2Values[counter] = distances[1]; //raw reading of right US

      point1 = str(d1Values[counter])  + " in";
      point2 = str(d2Values[counter])  + " in";
      counter++;


      if (mousePressed && calibratingSteps[0] == false) { //1st
        calibratingSteps[0] = true;
        text2 = "reading position: \nverify correct distance readings";
        d1Values = new float[calibratingAccuracy]; // wipe the gathered values
        d2Values = new float[calibratingAccuracy];
        counter = 0;
        delay(100);
      } else if (mousePressed && calibratingSteps[1] == false) { //2nd
        calibratingSteps[1] = true;
        text2 = "reading position: \nverify correct distance readings";
        d1Values = new float[calibratingAccuracy]; // wipe the gathered values
        d2Values = new float[calibratingAccuracy];
        counter = 0;
        delay(100);
      } else if (mousePressed && calibratingSteps[2] == false) { //3rd
        calibratingSteps[2] = true;
        text2 = "reading position: \nverify correct distance readings";
        d1Values = new float[calibratingAccuracy]; // wipe the gathered values
        d2Values = new float[calibratingAccuracy];
        counter = 0;
        delay(100);
      }


      if (counter == calibratingAccuracy) { //if arrays of distance are full

        if (getStandardDeviation(d1Values) < 1 && getStandardDeviation(d2Values) < 1 &&
        rawCoordinates(getMedian(d1Values), getMedian(d2Values))[1] > 1 && rawCoordinates(getMedian(d1Values), getMedian(d2Values))[1] < 100) { //if values are sufficent in accuracy

          if (calibratingSteps[2]) { //bottom checks first, last one to be true

            bottom[0] = getMedian(d1Values); //coordinates for top right position are set
            bottom[1] = getMedian(d2Values);

            initialized = true; //done with calibration
          } else if (calibratingSteps[1] && topRight[0] == 0) { //top right

            topRight[0] = getMedian(d1Values); //coordinates for top right position are set
            topRight[1] = getMedian(d2Values);

            text = "bottom";
            text2 = "click mouse when object is in position:";
          } else if (calibratingSteps[0] && topLeft[0] == 0) { //top left

            topLeft[0] = getMedian(d1Values); //coordinates for top right position are set
            topLeft[1] = getMedian(d2Values);

            text = "top right";
            text2 = "click mouse when object is in position:";
          }
        }

        // values are not sufficient in accuracy:
        d1Values = new float[calibratingAccuracy]; // wipe the gathered values
        d2Values = new float[calibratingAccuracy];
        counter = 0; //reset starting value of assinging arrays
      }
    }
  }
}











void drawDiagram(String text, int counter) {

  noStroke();
  fill(0);
  rect(430, 70, 70, 20);
  rect(500, 70, 70, 20);
  fill(200);
  rect(440, 80, 20, 20); //main body
  rect(470, 80, 20, 20);
  rect(510, 80, 20, 20);
  rect(540, 80, 20, 20);

  //-----------------------

  stroke(1);
  noFill();
  triangle(465, 100, 265, 400, 665, 400); //ranges
  triangle(535, 100, 335, 400, 735, 400);

  //-----------------------

  rect(419, 273, 161, 127);
  //(419, 273), (580, 400)
  fill(0);

  for (int i = 1; i < 16; i++) { //grided area showing range of sensors
    line(419 + (10*i), 273, 419 + (10*i), 400);
  }
  for (int i = 1; i < 13; i++) {
    line(419, 273 + (10*i), 580, 273 + (10*i));
  }

  //-----------------------

  //displaying indicator circles:

  int [] coord = {-1000, -100}; //out of range - wont see it unless text = ...

  if (text == "top left") {

    coord[0] = 419;
    coord[1] = 273;
  } else if (text == "top right") {

    coord[0] = 580;
    coord[1] = 273;
  } else if (text == "bottom") {

    coord[0] = 500;
    coord[1] = 400;
  }

  strokeWeight(3);
  stroke(255, 0, 0);
  noFill();

  float radius = abs((calibratingAccuracy / 2) - counter);
  radius = map(radius * 3, 0, calibratingAccuracy, 0, 50);

  ellipse(coord[0], coord[1], radius, radius); //red circle
  strokeWeight(1);
  
  //-------------
  
 if( text2 == "reading position: \nverify correct distance readings") {
    
    noFill();
    stroke(0);
    strokeWeight(4);
    rect(800, 300, 200, 20);
    strokeWeight(1);
    
    fill(0, 255, 0);
    float x = 0;
    if (getStandardDeviation(d1Values) < 2 && getStandardDeviation(d2Values) < 2 && rawCoordinates(getMedian(d1Values), getMedian(d2Values))[1] > 1) {
      x = map(counter, calibratingAccuracy / 2, calibratingAccuracy, 0, 200);
    }
    
    rect(800, 300, x, 20);
  }
}



float [] rawCoordinates(float d1, float d2) {

  float theta = (d1 * d1 + space * space - d2 * d2) / (2 * d1 * space); // law of cosine

  float y2d = d1 * cos(theta); //why is it reversed
  float x2d = d1 * sin(theta) - (space/2); //x = 0 is at center

  float [] coord = {x2d, y2d};
  return coord;
}
