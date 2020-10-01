float[][] createKeys(float xlen, float ylen) {

  float [][] keyRanges = new float[keyNum * keyNum * keyRows][8]; // for each of nine keys, two x and y coordinates for locating, 3 color values

  float x, y;

  for (int k = 0; k < keyRows; k++) {

    for (int i = 0; i < keyNum; i++) { // inputs values for keyRanges based on length and width

      y = -ylen;
      x = -xlen + ((xlen * 2) / keyNum) * i;

      for (int j = 0; j < keyNum; j++) { 

        int index = k * keyNum * keyNum + i * keyNum + j;

        keyRanges[index][0] = x; // first two elements are corner coordinates
        keyRanges[index][1] = y;

        y += (ylen * 2) / keyNum;

        keyRanges[index][2] = x + (xlen * 2) / keyNum; // second two are opposite corner coordinates
        keyRanges[index][3] = y;

        keyRanges[index][4] = random(75, 255); // sets each key to random color
        keyRanges[index][5] = random(75, 255);
        keyRanges[index][6] = random(75, 255);
      }
    }
  }

  return keyRanges;
}


void drawKeys(float[][] keyRanges) {


  for (int i = 0; i < keyRanges.length; i++) {
    pushMatrix();

    //tint(255, 50); // sets transparency

    int row = floor(i / (keyNum * keyNum));

    translate(keyRanges[i][0] + xlen / keyNum, -keyHeight * row, keyRanges[i][1] + ylen / keyNum); // translate to first coord pair in keyRanges

    int transparency;

    if (keyRanges[i][7] == 1) { // if key is pressed, change transparency to indicate so

      transparency = 240;
      keyRanges[i][7] = 0;
    } else {

      transparency = 60;
    }

    fill(keyRanges[i][4], keyRanges[i][5], keyRanges[i][6], transparency); // set color

    noStroke();

    box(keyRanges[i][0] - keyRanges[i][2], keyThickness, keyRanges[i][1] - keyRanges[i][3]);

    popMatrix();
  }
}

void checkKeys(float [][] keyRanges, float x, float y, float z) {

  int keyCount = 0;
  


  for (int i = 0; i < keyRanges.length; i ++) {
    
    int row = floor(i / (keyNum * keyNum));

    if (x > keyRanges[i][0] && x < keyRanges[i][2] && z > keyRanges[i][1] && z < keyRanges[i][3] && y < (keyThickness / 2) - keyHeight * row && y > (-keyThickness / 2) - keyHeight * row) { //add y

      keyRanges[i][7] = 1; // sets key to true

      port.write("s" + str(i)); // sends signal "s" as well as index to arduino
    } else {
      keyCount++;
    }
  }

  if (keyCount == keyRanges.length) {
    port.write("s-1"); // tells arduino no keys are pressed
  }
}
