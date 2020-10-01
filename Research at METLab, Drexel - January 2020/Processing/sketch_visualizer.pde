import processing.serial.*;

Serial port;

final float space = 3.5;

//VALUES TO ADJUST

//important ones:
final float trim = .25; // percentage of data
final int zSpeed = 10; // degrees of change per instant z_axis is sensed
// ----------------

final int accuracy = 100; // iterations of averager loop
final int xyzAccuracy = 3; // num of stored xyz coords
final int xyzMappedAccuracy = 100;
final int servoFOV = 30; // (90 - fov) to (90 + fov) is range of rotation for servo

final int scale = 50;
final float time = 0.060241; // 16.6 readings per second - .06 seconds per frame

final int keyThickness = 100;
final int keyNum = 3; // arduino atm is setup for 3
final int keyRows = 1; // and 1
final int keyHeight = 150;

//---------------------------

String reading;

float d1, d2, dz;
float x, y, z, xMapped, yMapped, zMapped;
float [][] storedxyz = new float [xyzAccuracy][3]; // (xyzAccuracy) rows, 3 columns for x,y,z
float [][] storedxyzMapped = new float [xyzMappedAccuracy][3]; // (xyzAccuracy) rows, 3 columns for x,y,z

float [] velocities, accelerations;
float aveAcceleration;

boolean [] calibratingSteps = new boolean[3];
int calibratingAccuracy = 20;
boolean initialized = false;
int counter = 0;
String text = "top left";
String text2 = "click mouse when object is in position:";
String point1 = "";
String point2 = "";
String pointz = "";
String sensed = "";
float [] topLeft = new float[2]; // two coordinates of the range at topLeft
float [] topRight = new float [2]; //" "
float [] bottom = new float [2]; //" "
float maxY; // after calcualtions, only maxY's Y values is stored
int xlen, ylen; // length of visual space

float [] d1Values = new float[calibratingAccuracy]; // (accuracy) numbers of d1
float [] d2Values = new float[calibratingAccuracy]; // (accuracy) numbers of d2
float [] dzValues = new float[calibratingAccuracy]; // (accuracy) numbers of dz - maybe be less?

int angle = 90; //of servo: 0 is upright, -90 to 90

//for drawing:

float [] rot = {0, 0, 0};
float fov = PI/3.0;
float cameraZ = (height/2.0) / tan(fov/2.0);
float xPos = width/2;
float yPos = height/2;

int transX = 700; // starting location for center of xyz axis
int transY = 500;

float[][] keyRanges = new float[keyNum * keyNum * keyRows][8]; //x1, y1, x2, y2, r, g, b, pressed? (1 or 0) - makes up 8






void setup () {

  for (int i = 0; i < Serial.list().length; i++) { // list of available serials
    println(Serial.list()[i]);
  }

  port = new Serial(this, "/dev/tty.usbmodem29267401", 19200);

  size(displayWidth, displayHeight, P3D); //set to 3d graphics

  port.write("n"); // tells arduino that process has started
}



void draw () {

  // For calibrating:

  if (initialized == false) { 

    calibrate();

    if (initialized) { // runs once - after calibration is done

      port.write(str(sort(bottom)[0] + 5)); // sends arduino smaller of the 2  farthest away distance readings - becomes threshold for out of range

      delay(1000); // buffer for arduino to recieve ^

      d1Values = new float[accuracy]; // (accuracy) numbers of d1 --reset for purpose after calibration 
      d2Values = new float[accuracy]; // (accuracy) numbers of d2

      topLeft = rawCoordinates(topLeft[0], topLeft[1]); // arrays of coordintes of points used in calibration, borders of values to be read
      topRight = rawCoordinates(topRight[0], topRight[1]);
      bottom = rawCoordinates(bottom[0], bottom[1]);


      maxY = bottom[1]; //used as theshold: larger values will be ignored

      xlen = int(abs(topLeft[0] - topRight[0]) * scale); //boundaries of space in visualization
      ylen = int((bottom[1] - ((topLeft[1] + topRight[1]) / 2)) * scale);

      keyRanges = createKeys(xlen, ylen); // creates array of keys for synth
    }

    //------
    if (keyPressed == true) {


      d1Values = new float[accuracy]; // (accuracy) numbers of d1 --reset for purpose after calibration 
      d2Values = new float[accuracy]; // (accuracy) numbers of d2

      topLeft = rawCoordinates(16, 17); // arrays of coordintes of points used in calibration, borders of values to be read
      topRight = rawCoordinates(17, 16);
      bottom = rawCoordinates(23, 23);
      port.write(str(26)); // sends arduino smaller of the 2  farthest away distance readings - becomes threshold for out of range

      maxY = bottom[1]; //used as theshold: larger values will be ignored

      delay(1000); // buffer for arduino to recieve ^

      xlen = int(abs(topLeft[0] - topRight[0]) * scale); //boundaries of space in visualization
      ylen = int((bottom[1] - ((topLeft[1] + topRight[1]) / 2)) * scale);

      keyRanges = createKeys(xlen, ylen); // creates array of keys for synth
      initialized = true;

      //---------
    }
  } else {


    //-------------------------------------------------------------------------------------------------


    if (port.available() > 0) {

      reading = port.readStringUntil('\n'); // reads one line of serial

      if (reading != null) { // run here

        float [] distances = readSerial(); // Array of each desired item
        d1 = distances[0]; //raw reading of left US
        d2 = distances[1]; //raw reading of right US
        dz = distances[2]; // raw reading of Z-axis US

        point1 = str(d1); //for displaying on screen
        point2 = str(d2);
        pointz = str(dz);


        getNewDistances(); // stores new raw distances reading to their array of distance histories


        angle = check_zAxis(angle); // adjust zAxis using raw arrays

        d1 = getNormalDistribution(d1Values, trim); //set distances to average of their arrays
        d2 = getNormalDistribution(d2Values, trim);
        dz = getNormalDistribution(dzValues, trim);




        xMapped = getCoordinates()[0]; //values mapped to coordinate plane of visuals
        yMapped = getCoordinates()[1];
        zMapped = getCoordinates()[2];

        float [] xyzMapped = {xMapped, yMapped, zMapped}; // stores new coordinates to array of coordinate history
        storedxyzMapped = shift2dArray(storedxyzMapped, xyzMapped); 



        xMapped = getNormalDistribution(seperateCoordinates()[0], trim); // sets mapped x y z values to average of their array histories
        yMapped = getNormalDistribution(seperateCoordinates()[1], trim);
        zMapped = getNormalDistribution(seperateCoordinates()[2], trim);


        render(xMapped, yMapped, zMapped); // renders mapped xyz

        checkKeys(keyRanges, xMapped, yMapped, zMapped);



        //displayMath(); // displays velocity and acceleration
      }

      //textSize(30); //temporary***
      //fill(0);
      ////text(str(round(velocities[velocities.length - 1])) + " in/s", 100, 100);
      ////text(str(round(aveAcceleration)) + " in/s^2", 100, 170);
      //text(point1, 600, 100);
      //text(point2, 800, 100);
      //text(pointz, 1000, 100);

      //text("X: " + str(int(xMapped)) + " Y: " + str(int(yMapped)) + " Z: " + str(int(zMapped)), 100, height - 200);
      //text("xlen: " + xlen + " ylen: " + ylen, 100, height - 100);
      //text("angle: "+str(radians(angle - 90)), 100, 400);
      //text("maxY: "+maxY, 100, 500);
      //text("sensed: "+sensed, 300, 300);
    }
  }
}
