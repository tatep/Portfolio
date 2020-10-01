float [] readSerial() {

  String[] strArray = reading.split("\\s+"); //splits by space, arduino sends x and y like: 12 45
  float [] distances = new float[strArray.length];
  for (int i = 0; i < strArray.length; i++) {
    distances[i] = float(strArray[i]);
  }
  return distances;
}





float [] shiftArray (float [] values, float newValue) {

  float [] shiftedArray = new float[values.length]; // creates new array same size as inputted array

  for (int i = 1; i < values.length + 1; i++) { // loops starting at second element

    if (i != values.length) { // not the last value
      shiftedArray[i - 1] = values[i];
    } else {
      shiftedArray[values.length - 1] = newValue; //last element = the new value
    }
  }
  return shiftedArray;
}



float [][] shift2dArray (float [][] values, float [] newValue) {

  boolean empty = true;

  for (int i = 0; i < values.length; i++) {

    if (values[i][0] != 0) {
      empty = false;
    }
  }

  float [][] shiftedArray = new float [values.length][values[0].length];

  if (empty) {
    for (int i = 0; i < values.length; i++) { // fill array with new Value
      shiftedArray[i] = newValue;
    }
    
  } else { //if array contains stuff

    for (int i = 1; i < values.length + 1; i++) { // loops starting at second element

      if (i != values.length) { // not the last value
        shiftedArray[i - 1] = values[i];
      } else {
        shiftedArray[values.length - 1] = newValue; //last element = the new value
      }
    }
  }
  return shiftedArray;
}

float [][] seperateCoordinates() {

  float [] xValues = new float [storedxyzMapped.length];
  float [] yValues = new float [storedxyzMapped.length];
  float [] zValues = new float [storedxyzMapped.length];

  for (int i = 0; i < storedxyzMapped.length; i++) { //set xyz values to their respective columns in storedxyzMapped
    xValues[i] = storedxyzMapped[i][0];
    yValues[i] = storedxyzMapped[i][1];
    zValues[i] = storedxyzMapped[i][2];
  }

  float [][] xyzValues = {xValues, yValues, zValues};

  return xyzValues;
}


boolean moveDown () {
  if (d1 > maxY && d2 > maxY && dz > maxY) { // hand is below sensors' range = move down
    return true;
  }
  return false;
}


boolean moveUp () {

  if (dz < maxY && dz > .2) {
    return true;
  }

  return false;
}
