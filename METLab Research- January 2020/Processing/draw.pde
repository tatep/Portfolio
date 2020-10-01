
void render (float x, float y, float z) {


  if (mousePressed) { //initial mouse press
    xPos = mouseX; //set position to current mouse pos
    yPos = mouseY;
  }

  pushMatrix();
  
  background(255); //white background
  lights(); //shading
  perspective(fov, float(width)/float(height), 
    cameraZ/10.0, 2000);  

  pushMatrix();
  //------------------------------------
  translate(transX, transY);//translate to good viewing point

  rotateY(.4 + rot[0]); //.4 is a good starting viewing angle
  rotateX(rot[1]);
  rotateZ(rot[2]);

  //drawAxes(xlen, ylen);

  drawObject(x, y, z);

  drawDevice();
  
  drawKeys(keyRanges);
  //------------------------------------
  popMatrix();
  
  popMatrix();
}


void mouseDragged() { // mouse clicked and dragged

  if (abs(mouseX - xPos) < 25 && abs(mouseY - yPos) < 25) { //excludes clicking fast back and forth
    rot[0] += map(mouseX - xPos, -500, 500, -2, 2);         //computer is unable to recognize fast enough
    rot[1] -= map(mouseY - yPos, -500, 500, -2, 2);
  }

  xPos = mouseX;
  yPos = mouseY;
}


void mouseWheel(MouseEvent event) { //zoom with mouse wheel

  float e = event.getCount();

  if (abs(e) > 1) {

    e = map(constrain(e, -10, 10), -10, 10, -.01, .01);

    if ( (fov + e) < 2.5 && (fov + e) > .3) { //sets bounds
      fov += e;
    }
  }
}

void keyPressed() {
  
  if (keyCode == UP) {
    transY -= 10;
  } else if (keyCode == DOWN) {
    transY += 10;
  } else if (keyCode == RIGHT) {
    transX += 10;
  } else if (keyCode == LEFT) {
    transX -= 10;
  } else if (key == '1' || key == '2' || key == '3' || key == '4' || key == '5' || key == '6' || key == '7' || key == '8' || key == '9') {
    port.write("o" + str(key));
    println("o" + str(key));
  }
  
}
  




void drawAxes(int xlen, int ylen) {

  strokeWeight(.5);
  stroke(30);


  //refrence grid:

  int shorterLen, longerLen;
  if (xlen < ylen) {
    shorterLen = xlen;
    longerLen = ylen;
  } else {
    shorterLen = ylen;
    longerLen = xlen;
  }

  int dist = scale * 2;

  for (int i = -ylen + dist; i <= ylen; i+= dist) { 
    line(-xlen, 0, i, xlen, 0, i);
  }
  for (int i = -xlen + dist; i <= xlen; i+= dist) { 
    line(i, 0, -ylen, i, 0, ylen);
  }


  line(-xlen, 0, -ylen, xlen, 0, -ylen); //outline box
  line(-xlen, 0, ylen, xlen, 0, ylen);
  line(-xlen, 0, -ylen, -xlen, 0, ylen);
  line(xlen, 0, -ylen, xlen, 0, ylen);
  strokeWeight(2);

  //X  - red
  stroke(192, 0, 0);
  line(-xlen, 0, 0, xlen, 0, 0);
  //Y - green
  stroke(0, 192, 0);
  line(0, -longerLen, 0, 0, longerLen, 0);
  //Z - blue
  stroke(0, 0, 192);
  line(0, 0, -ylen, 0, 0, ylen);
}




void drawObject (float x, float y, float z) {
  pushMatrix();
  translate(x, y, z);
  //println("x:", x, "y:", y, "z:", z);
  fill(175);
  noStroke();
  sphere(50);
  popMatrix();
}

void drawDevice() {
pushMatrix();
  translate(0, 50, -ylen - 700);
  rotateX(radians(angle - 90));
  pushMatrix();
  fill(150);
  translate(0, 0, 0);
  box(600, 100, 100);
  popMatrix();

  pushMatrix();
  fill(255, 0, 0);
  translate(-200, 0, + 100);
  box(100, 50, 50);
  popMatrix();
  
  pushMatrix();
  fill(255, 0, 0);
  translate(200, 0, + 100);
  box(100, 50, 50);
  popMatrix();
  
popMatrix();
}
