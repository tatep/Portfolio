float getMedian (float [] values) {

  float [] nums = sort(values); //sorts by ascending numbers

  int len = nums.length;

  if (len % 2 == 0) {
    return (nums[len/2] + nums[(len/2) - 1]) / 2; // even elements
  } else {
    return nums[(len/2) - (len/2) % 1 + 1]; // odd elements
  }
}



float getTrimmedMean (float [] values, float percentage) {

  float [] nums = sort(values);

  int len = int(nums.length * percentage);

  float sum = 0;
  int counter = 0;

  int startingIndex;
  int endingIndex;

  if (percentage == 1) {
    startingIndex = 0;
    endingIndex = values.length;
  } else {

    startingIndex = ((nums.length - len) / 2) - 1;
    endingIndex = nums.length - ((nums.length - len) / 2);
  }

  for (int i = startingIndex; i < endingIndex; i++) { //only looks at specificed index to index
    sum += nums[i];
    counter += 1;
  }

  return sum/counter;
}


float getStandardDeviation (float [] values) {

  float num = getTrimmedMean(values, 1); //mean of values

  float [] valuesClone = new float[values.length];
  for (int i = 0; i < values.length; i++) {
    valuesClone[i] = pow(values[i] - num, 2);
  }

  num = getTrimmedMean(valuesClone, 1); // average of (value - mean)^2

  num = num / values.length;

  num = pow(num, .5); //sqrt of num

  return num;
}


float getNormalDistribution(float [] values, float percentage) {

  float pi = 3.142;
  float e = 2.718;
  
  float standardDeviation = (values.length * percentage) / 3;
  
  float [] weights = new float[values.length];
  
  for (int i = 0; i < values.length; i++) {

    int x = i - values.length; // x values go from -values.length to 0 in equation
    
    float y = (1 / (standardDeviation * pow(2 * pi, .5))) * pow(e, (-1 * x*x) / (2 * pow(standardDeviation, 2))); // normal distribution equation: { 1/[ σ * sqrt(2π) ] } * e-(x)2/2σ2
    
    weights[i] = y;
    
  }
  
  float sum = 0;
  
  for (int i = 0; i < weights.length; i++) {  
    sum += weights[i];
  }
  
  for (int i = 0; i < weights.length; i++) {  
    weights[i] = weights[i] / sum; // scales from 0 - 1: sum of all = 1
  }
  
  
  sum = 0;
  
  for (int i = 0; i < values.length; i++) {
    sum += values[i] * weights[i];
  }
  
  return sum;
}





float [] getVelocities (float [][] data) { //takes set of coordinates and returns array of velocities

  float [] velocities = new float[data.length - 1]; // n - 1 number of differences to measure velocity

  for (int i = 0; i < data.length - 1; i++) { 

    float x1 = data[i][0];
    float x2 = data[i + 1][0];
    float y1 = data[i][1];
    float y2 = data[i + 1][1];
    float z1 = data[i][2];
    float z2 = data[i + 1][2];

    float distance = pow(pow((x1 - x2), 2) + pow((y1 - y2), 2) + pow((z1 - z2), 2), .5); //3d distance formula

    velocities[i] = distance / time;
  }

  return velocities;
}


float [] getAccelerations( float [] velocities) {

  float [] accelerations = new float[velocities.length - 1]; // n - 1 number of differences to measure acceleration

  for (int i = 0; i < velocities.length - 1; i++) { 

    float changeInV = abs(velocities[i] - velocities[i + 1]);

    accelerations[i] = changeInV / time;
  }

  return accelerations;
}


void displayMath () {

  x = getCoordinates()[3]; //raw values in inches
  y = getCoordinates()[4];
  z = getCoordinates()[5];

  float [] xyz = {x, y, z}; // these are raw values - xyz is used for math_functions
  storedxyz = shift2dArray(storedxyz, xyz); //adds new xyz coordinates to memory for speed / acceleration calc

  velocities = getVelocities(storedxyz);

  accelerations = getAccelerations(velocities);
  aveAcceleration = getTrimmedMean(accelerations, 1); // in inches per second^2
}
