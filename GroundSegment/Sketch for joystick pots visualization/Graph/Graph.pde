import processing.serial.*; 
Serial arduino; 

String stringX;
String stringY;
String stringZ;
String stringT;

float[] X = new float[600];
float[] Y = new float[600];
float[] Z = new float[600];
float[] T = new float[600];


void setup() {  
  size(600, 255);
  println(arduino.list()); // Use this to print connected serial devices
  arduino = new Serial(this, "COM16", 115200); //2nd parameter = serial port being used
  arduino.bufferUntil('\n'); // Buffer until line feed

  for (int i=0;i<600;i++) { // center all variables    
    X[i] = height/2;
    Y[i] = height/2;
    Z[i] = height/2;
    T[i] = height/2;
  }
}

void draw()
{ 
  // Draw graphPaper
  background(0); // white
//  for (int i = 0 ;i<=width/1 0;i++) {      
//    stroke(200); // gray
//    line((-frameCount%10)+i*10, 0, (-frameCount%10)+i*10, height);
//    line(0, i*10, width, i*10);
//  }
//
//  stroke(0); // black
//  for (int i = 1; i <= 3; i++)
//    line(0, height/4*i, width, height/4*i); // Draw line, indicating 90 deg, 180 deg, and 270 deg

  convert();
  drawAxis();
}


void serialEvent (Serial arduino) {
  // get the ASCII strings:
  stringX = arduino.readStringUntil('\t');
  stringY = arduino.readStringUntil('\t'); 
  stringZ = arduino.readStringUntil('\t');
  stringT = arduino.readStringUntil('\t'); 
  arduino.clear(); // Clear buffer
  //printAxis(); // slows down the process and can result in error readings - use for debugging
}


void printAxis() {
  print(stringX);
  print(stringY);
}
