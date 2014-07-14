import processing.serial.*; 
Serial arduino; 
int WIDTH = 1000;

String stringInputX_angle; 
String stringInputY_angle; 
String stringInputX; 
String stringInputY; 
String stringInputZ;  

String stringSetpointX_angle; 
String stringSetpointY_angle; 
String stringSetpointX; 
String stringSetpointY; 
String stringSetpointZ;  

String stringOutputX_angle; 
String stringOutputY_angle; 
String stringOutputX; 
String stringOutputY; 
String stringOutputZ;  

String stringPID_X_angle_ITerm; 
String stringPID_Y_angle_ITerm; 
String stringPID_X_ITerm; 
String stringPID_Y_ITerm; 
String stringPID_Z_ITerm; 

String stringMot1; 
String stringMot2; 
String stringMot3;         
String stringMot4; 


float[] InputX_angle = new float[WIDTH];
float[] InputY_angle = new float[WIDTH];
float[] InputX = new float[WIDTH];
float[] InputY = new float[WIDTH];
float[] InputZ = new float[WIDTH];

float[] SetpointX_angle = new float[WIDTH];
float[] SetpointY_angle = new float[WIDTH];
float[] SetpointX = new float[WIDTH];
float[] SetpointY = new float[WIDTH];
float[] SetpointZ = new float[WIDTH];

float[] OutputX_angle = new float[WIDTH];
float[] OutputY_angle = new float[WIDTH];
float[] OutputX = new float[WIDTH];
float[] OutputY = new float[WIDTH];
float[] OutputZ = new float[WIDTH];

float[] PID_X_angle_ITerm = new float[WIDTH];
float[] PID_Y_angle_ITerm = new float[WIDTH];
float[] PID_X_ITerm = new float[WIDTH];
float[] PID_Y_ITerm = new float[WIDTH];
float[] PID_Z_ITerm = new float[WIDTH];

float[] Mot1 = new float[WIDTH];
float[] Mot2 = new float[WIDTH];
float[] Mot3 = new float[WIDTH];
float[] Mot4 = new float[WIDTH];



void setup() {  
  size(WIDTH, 800);

  println(arduino.list()); // Use this to print connected serial devices
  arduino = new Serial(this, "COM19", 115200); //2nd parameter = serial port being used
  arduino.bufferUntil('\n'); // Buffer until line feed

  for (int i=0;i<WIDTH;i++) { // center all variables    
    InputX_angle[i] = height/2;
    InputY_angle[i] = height/2;
    InputX[i] = height/2;
    InputY[i] = height/2;
    InputZ[i] = height/2;
    
    SetpointX_angle[i] = height/2;
    SetpointY_angle[i] = height/2;
    SetpointX[i] = height/2;
    SetpointY[i] = height/2;
    SetpointZ[i] = height/2;
    
    OutputX_angle[i] = height/2;
    OutputY_angle[i] = height/2;
    OutputX[i] = height/2;
    OutputY[i] = height/2;
    OutputZ[i] = height/2;
    
    PID_X_angle_ITerm[i] = height/2;
    PID_Y_angle_ITerm[i] = height/2;
    PID_X_ITerm[i] = height/2;
    PID_Y_ITerm[i] = height/2;
    PID_Z_ITerm[i] = height/2;
    
    Mot1[i] = height/2;
    Mot2[i] = height/2;
    Mot3[i] = height/2;
    Mot4[i] = height/2;
  }
}

void draw()
{ 
  // Draw graphPaper
  background(255); // white
  for (int i = 0 ;i<=width/10;i++) {      
    stroke(200); // gray
    line((-frameCount%10)+i*10, 0, (-frameCount%10)+i*10, height);
    line(0, i*10, width, i*10);
  }

  stroke(0); // black
  for (int i = 1; i <= 3; i++)
    line(0, height/4*i, width, height/4*i); // Draw line, indicating 90 deg, 180 deg, and 270 deg
    
  int[] BLUE = new int[3]; BLUE[0] = 255; BLUE[1] = 0; BLUE[2] = 0;
  int[] GREEN = new int[3]; GREEN[0] = 0; GREEN[1] = 255; GREEN[2] = 0;
  int[] RED = new int[3]; RED[0] = 0; RED[1] = 0; RED[2] = 255;
  
  //Pitch gyro rate:
  convert(stringInputX,InputX,-250,250);         drawX(InputX,BLUE);
  convert(stringSetpointX,SetpointX,-250,250);   drawX(SetpointX,GREEN);
  convert(stringOutputX,OutputX,-250,250);       drawX(OutputX,RED);
}



void serialEvent (Serial arduino) {
  // get the ASCII strings:  
   stringInputX_angle = arduino.readStringUntil('\t'); 
   stringInputY_angle = arduino.readStringUntil('\t'); 
   stringInputX = arduino.readStringUntil('\t'); 
   stringInputY = arduino.readStringUntil('\t'); 
   stringInputZ = arduino.readStringUntil('\t');  
  
   stringSetpointX_angle = arduino.readStringUntil('\t'); 
   stringSetpointY_angle = arduino.readStringUntil('\t'); 
   stringSetpointX = arduino.readStringUntil('\t'); 
   stringSetpointY = arduino.readStringUntil('\t'); 
   stringSetpointZ = arduino.readStringUntil('\t');  
  
   stringOutputX_angle = arduino.readStringUntil('\t'); 
   stringOutputY_angle = arduino.readStringUntil('\t'); 
   stringOutputX = arduino.readStringUntil('\t'); 
   stringOutputY = arduino.readStringUntil('\t'); 
   stringOutputZ = arduino.readStringUntil('\t');  
  
   stringPID_X_angle_ITerm = arduino.readStringUntil('\t'); 
   stringPID_Y_angle_ITerm = arduino.readStringUntil('\t'); 
   stringPID_X_ITerm = arduino.readStringUntil('\t'); 
   stringPID_Y_ITerm = arduino.readStringUntil('\t'); 
   stringPID_Z_ITerm = arduino.readStringUntil('\t'); 
  
   stringMot1 = arduino.readStringUntil('\t'); 
   stringMot2 = arduino.readStringUntil('\t'); 
   stringMot3 = arduino.readStringUntil('\t');         
   stringMot4 = arduino.readStringUntil('\t'); 

  arduino.clear(); // Clear buffer

  //printAxis(); // slows down the process and can result in error readings - use for debugging
}


//Print on serial
void printAxis() {  
   print(stringInputX);
   print(stringInputY);   
   print(stringInputZ); 
  
}
