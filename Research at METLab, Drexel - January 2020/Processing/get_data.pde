void getNewDistances () {

  if (d1Values == null) { //when first initialized, need to fill data with some number

    for (int i = 0; i < accuracy; i++) {

      d1Values[i] = d1; //sets all (accuracy) elements to first read to start
      d2Values[i] = d2;
      dzValues[i] = 0;
    }
  } else {//otherwise just shift array

    if (d1 > 1 &&  d1 < maxY + 3 && d2 < maxY + 3 && d2 > 1) { // if both d1 and d2 can update - gives a little leeway with maxY so user can bring object to the edge
      d1Values = shiftArray(d1Values, d1);
      d2Values = shiftArray(d2Values, d2);
    }
  }

  dzValues = shiftArray(dzValues, dz);
}




float [] getCoordinates () {

  float theta = (d1 * d1 + space * space - d2 * d2) / (2 * d1 * space); // law of cosine

  float y2d = d1 * cos(theta); //why is it reversed
  float x2d = d1 * sin(theta) - (space/2); //x = 0 is at center
  float x2dMapped = map(constrain(x2d, topLeft[0], topRight[0]), topLeft[0], topRight[0], -xlen, xlen); // constrained to sensors' range, mapped to screen coor  
  float y2dMapped = map(constrain(y2d, (topLeft[1] + topRight[1]) / 2, maxY), 0, maxY, 0, maxY * 2 * scale); // --averages Y values of top right and top left
  
  
  //---------------------- 3D readings: 

  float theta3d = radians(angle - 90);

  if (theta3d == 0) { // sin 0 = 0
    theta3d = .0001;
  }
  float xMapped = x2dMapped; //x does not change from 2d to 3d
  float yMapped = -map(y2dMapped * sin(theta3d), 0, maxY * 2 * scale * sin(radians(90 + fov)), 0, 12 * scale); // 12 is about the range of the y axis
  float zMapped = map((y2dMapped  * cos(theta3d)), (topLeft[1] + topRight[1]) * scale, maxY * 2 * scale, -ylen, ylen);

  pointz = str(y2dMapped * sin(theta3d)) + "  " + str(yMapped); 
  float x = x2d; // x does not change from 2d to 3d
  float y = y2d * sin(theta3d);
  float z = y2d * cos(theta3d);
  float [] coordinates = {xMapped, yMapped, zMapped, x, y, z};

  return coordinates;
}




int check_zAxis (int angle) {


  if (moveUp() && angle < 90 + servoFOV) { // if in range of Z-axis US

    angle += zSpeed;
    port.write(str(angle)); // arduino takes string of int
    sensed = "true";

  } else if (moveDown() && angle > 90) {


    angle -= zSpeed;
    port.write(str(angle)); // arduino takes string of int
    sensed = "false";

  } else {
    sensed = "false";
  }

  return angle;
}
