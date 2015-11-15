import processing.serial.*;
import controlP5.*;
ControlP5 cp5;

Serial arduino; 
int WIDTH = 1000;
int HEIGHT = 700;
int HEIGHT_GRAPH = 500;

/********** Quadcopter definitions **********/
int MAX_ABS_GYRO_RATE = 250;
//Boundaries defined by user (copy from configQuadSeg.h)
int MAX_PWM_PID_OUTPUT = 300;
int MIN_PITCH_ANGLE = 150;
int MAX_PITCH_ANGLE = 210;
int MIN_ROLL_ANGLE = 150;
int MAX_ROLL_ANGLE = 210;
int LIMIT_GYRO_XY_RATE = 100;
int LIMIT_GYRO_Z_RATE = 100;
/********************************************/

//Widget list
DropdownList PID_selection;
String PID_select_label = "PID_selection";
byte PID_id = 0;
DropdownList PORT_selection;
String PORT_select_label = "PORT_selection";
int COM_PORT_id = 0;
int numberOfPorts = 0;
String portList [];

Slider MOT1,MOT2,MOT3,MOT4;
int MIN_PWM_THROTTLE = 1000;
int MAX_PWM_THROTTLE = 2000;
float meanT = 0;

Textlabel IX_angle, IY_angle, IX, IY, IZ; 

//Serial port inputs
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

String stringCycleTime;

//Graph vectors
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

controlP5.Textfield CycleTime; //used to monitor arduino cycle time

void setup() {  
  size(WIDTH, HEIGHT);

  println(arduino.list()); // Use this to print connected serial devices
  portList = arduino.list();

  for (int i=0;i<WIDTH;i++) { // center all variables    
    InputX_angle[i] = HEIGHT_GRAPH/2;
    InputY_angle[i] = HEIGHT_GRAPH/2;
    InputX[i] = HEIGHT_GRAPH/2;
    InputY[i] = HEIGHT_GRAPH/2;
    InputZ[i] = HEIGHT_GRAPH/2;
    
    SetpointX_angle[i] = HEIGHT_GRAPH/2;
    SetpointY_angle[i] = HEIGHT_GRAPH/2;
    SetpointX[i] = HEIGHT_GRAPH/2;
    SetpointY[i] = HEIGHT_GRAPH/2;
    SetpointZ[i] = HEIGHT_GRAPH/2;
    
    OutputX_angle[i] = HEIGHT_GRAPH/2;
    OutputY_angle[i] = HEIGHT_GRAPH/2;
    OutputX[i] = HEIGHT_GRAPH/2;
    OutputY[i] = HEIGHT_GRAPH/2;
    OutputZ[i] = HEIGHT_GRAPH/2;
  }
  
  cp5 = new ControlP5(this);
  
  // create a DropdownList for PID identifier selection
  PID_selection = cp5.addDropdownList(PID_select_label)
    .setPosition(120, 20+HEIGHT_GRAPH)
        ;
  customizePIDselection(PID_selection);
  
  // create a DropdownList for COM port selection        
  PORT_selection = cp5.addDropdownList(PORT_select_label)
    .setPosition(20, 20+HEIGHT_GRAPH)
        ;
  customizeCOMselection(PORT_selection);
  
  cp5.addButton("CONNECT")
    .setValue(1)
      .setPosition(20, HEIGHT_GRAPH + 100 + 40)          //posición del botón
        .setSize(90, 40)              //tamaño del botón
          .setColorActive(#40BF44)     //color del botón cuando es pulsado
            .setColorBackground(#AEAEAE)//color de fondo con botón en reposo
              .setColorForeground(#6A6A6A)  //color cuando deslizamos el puntero sobre el botón
                .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
                  ;

   MOT1 = cp5.addSlider("Mot1")
    .setPosition(500, 20 + HEIGHT_GRAPH)
      .setSize(25, 100)
        .setRange(MIN_PWM_THROTTLE, MAX_PWM_THROTTLE)
          .setValue(MIN_PWM_THROTTLE)
            .setColorActive(#6A6A6A) 
              .setColorForeground(#AEAEAE) 
                ;
                        
   MOT2 = cp5.addSlider("Mot2")
    .setPosition(550, 20 + HEIGHT_GRAPH)
      .setSize(25, 100)
        .setRange(MIN_PWM_THROTTLE, MAX_PWM_THROTTLE)
          .setValue(MIN_PWM_THROTTLE)
            .setColorActive(#6A6A6A) 
              .setColorForeground(#AEAEAE) 
                ;
                        
   MOT3 = cp5.addSlider("Mot3")
    .setPosition(600, 20 + HEIGHT_GRAPH)
      .setSize(25, 100)
        .setRange(MIN_PWM_THROTTLE, MAX_PWM_THROTTLE)
          .setValue(MIN_PWM_THROTTLE)
            .setColorActive(#6A6A6A) 
              .setColorForeground(#AEAEAE) 
                ;            
            
    MOT4 = cp5.addSlider("Mot4")
    .setPosition(650, 20 + HEIGHT_GRAPH)
      .setSize(25, 100)
        .setRange(MIN_PWM_THROTTLE, MAX_PWM_THROTTLE)
          .setValue(MIN_PWM_THROTTLE)
            .setColorActive(#6A6A6A) 
              .setColorForeground(#AEAEAE) 
                ;
            
            
   CycleTime = cp5.addTextfield("CycleTime(ms)")
     .setPosition(845, 20 + HEIGHT_GRAPH)
     .setSize(100,20)
     .setAutoClear(false)
     .setFocus(true)
     ;
     
     
   IX_angle = cp5.addTextlabel("X_angle_ITerm")
     .setPosition(220, 20+HEIGHT_GRAPH)
     .setSize(100,15)
     .setText("no data")
     .setColor(0)
     ;
     
   IY_angle = cp5.addTextlabel("Y_angle_ITerm")
     .setPosition(220, 36+HEIGHT_GRAPH)
     .setSize(100,15)
     .setText("no data")
     .setColor(0)
     ;
     
   IX = cp5.addTextlabel("X_ITerm")
     .setPosition(220, 52+HEIGHT_GRAPH)
     .setSize(100,15)
     .setText("no data")
     .setColor(0)
     ;
     
   IY = cp5.addTextlabel("Y_ITerm")
     .setPosition(220, 68+HEIGHT_GRAPH)
     .setSize(100,15)
     .setText("no data")
     .setColor(0)
     ;
     
   IZ = cp5.addTextlabel("Z_ITerm")
     .setPosition(220, 84+HEIGHT_GRAPH)
     .setSize(100,15)
     .setText("no data")
     .setColor(0)
     ;
}

void draw()
{ 
  //Update port list
  portList = arduino.list();
  if (numberOfPorts != portList.length) {
    println(arduino.list());
    customizeCOMselection(PORT_selection);
  }
  
  //Draw graphPaper
  background(150);
  for (int i = 0 ;i<=width/10;i++) {      
    stroke(200); // gray
    line((-frameCount%10)+i*10, 0, (-frameCount%10)+i*10, HEIGHT_GRAPH);
  }
  for (int i = 0; i<=HEIGHT_GRAPH/10; i++){
    stroke(200); // gray
    line(0, i*10, width, i*10);
  }
  
  //Draw line, indicating 90 deg, 180 deg, and 270 deg
  stroke(0); // black
  for (int i = 1; i <= 3; i++)
    line(0, HEIGHT_GRAPH/4*i, width, HEIGHT_GRAPH/4*i); 
    
  //Color definitions
  int[] BLUE = new int[3]; BLUE[0] = 255; BLUE[1] = 0; BLUE[2] = 0;
  int[] GREEN = new int[3]; GREEN[0] = 0; GREEN[1] = 255; GREEN[2] = 0;
  int[] RED = new int[3]; RED[0] = 0; RED[1] = 0; RED[2] = 255;
  
  
  //convertAll();
  convert(stringInputX_angle,InputX_angle, 0, 360);  
  convert(stringSetpointX_angle,SetpointX_angle, 0, 360); 
  convert(stringOutputX_angle,OutputX_angle,-MAX_ABS_GYRO_RATE,MAX_ABS_GYRO_RATE);       
  
  convert(stringInputY_angle,InputY_angle, 0, 360);  
  convert(stringSetpointY_angle,SetpointY_angle, 0, 360);  
  convert(stringOutputY_angle,OutputY_angle,-MAX_ABS_GYRO_RATE,MAX_ABS_GYRO_RATE); 
  
  convert(stringInputX,InputX,-MAX_ABS_GYRO_RATE,MAX_ABS_GYRO_RATE);   
  convert(stringSetpointX,SetpointX,-MAX_ABS_GYRO_RATE,MAX_ABS_GYRO_RATE); 
  convert(stringOutputX,OutputX,-MAX_PWM_PID_OUTPUT,MAX_PWM_PID_OUTPUT); 
  
  convert(stringInputY,InputY,-MAX_ABS_GYRO_RATE,MAX_ABS_GYRO_RATE);  
  convert(stringSetpointY,SetpointY,-MAX_ABS_GYRO_RATE,MAX_ABS_GYRO_RATE);
  convert(stringOutputY,OutputY,-MAX_PWM_PID_OUTPUT,MAX_PWM_PID_OUTPUT); 
  
  convert(stringInputZ,InputZ,-MAX_ABS_GYRO_RATE,MAX_ABS_GYRO_RATE);
  convert(stringSetpointZ,SetpointZ,-MAX_ABS_GYRO_RATE,MAX_ABS_GYRO_RATE); 
  convert(stringOutputZ,OutputZ,-MAX_PWM_PID_OUTPUT,MAX_PWM_PID_OUTPUT);
  
  //PID Graphs
  switch(PID_id) {  
    case 1:  //CASE Pitch angle
      drawX(InputX_angle,BLUE);
      drawX(SetpointX_angle,GREEN);
      drawX(OutputX_angle,RED);
      break;
    
    case 2://CASE Roll angle
      drawX(InputY_angle,BLUE);
      drawX(SetpointY_angle,GREEN);
      drawX(OutputY_angle,RED);
      break;
  
    case 3: //CASE Pitch gyro rate
      drawX(InputX,BLUE);
      drawX(SetpointX,GREEN);
      drawX(OutputX,RED);
      break;
  
    case 4: //CASE Roll gyro rate
      drawX(InputY,BLUE);
      drawX(SetpointY,GREEN);
      drawX(OutputY,RED);
      break;
      
    case 5: //CASE Yaw gyro rate
      drawX(InputZ,BLUE);
      drawX(SetpointZ,GREEN);
      drawX(OutputZ,RED);
      break;
  }
  
  //Show ITerm values
  if (stringPID_X_angle_ITerm != null) IX_angle.setValue(stringPID_X_angle_ITerm);
  if (stringPID_Y_angle_ITerm != null) IY_angle.setValue(stringPID_Y_angle_ITerm);
  if (stringPID_X_ITerm != null) IX.setValue(stringPID_X_ITerm);
  if (stringPID_Y_ITerm != null) IY.setValue(stringPID_Y_ITerm);
  if (stringPID_Z_ITerm != null) IZ.setValue(stringPID_Z_ITerm);
  remarkITerm(PID_id);
  
  //Edit sliders with Motor values
  if (stringMot1 != null) MOT1.setValue(float(trim(stringMot1)));
  if (stringMot2 != null) MOT2.setValue(float(trim(stringMot2)));
  if (stringMot3 != null) MOT3.setValue(float(trim(stringMot3)));
  if (stringMot4 != null) MOT4.setValue(float(trim(stringMot4)));
  
  //Edit Cycle Time Box (cycle time would be much lower if you avoid monitoring through COM)
  if (stringCycleTime != null) CycleTime.setText(trim(stringCycleTime));
  
  //Draw mean throttle line
  meanT = (MOT1.getValue() + MOT2.getValue() + MOT3.getValue() + MOT4.getValue())/4;
  stroke(50);
  line(480, 20 + HEIGHT_GRAPH + 100 - int((meanT-1000)/10), 700, 20 + HEIGHT_GRAPH + 100 - int((meanT-1000)/10)); 
}



void printAxis() {  
   print(stringInputX);
   print(stringInputY);   
   print(stringInputZ); 
}


void customizePIDselection(DropdownList ddl) {
  // a convenience function to customize a DropdownList
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(15);
  ddl.setBarHeight(15);
  ddl.captionLabel().set("PID id election");
  ddl.captionLabel().style().marginTop = 3;
  ddl.captionLabel().style().marginLeft = 3;
  ddl.valueLabel().style().marginTop = 3;
  
  //Add possible PID identifiers
  ddl.addItem("Pitch Angle", 1);
  ddl.addItem("Roll Angle", 2);
  ddl.addItem("Pitch Rate", 3);
  ddl.addItem("Roll Rate", 4);
  ddl.addItem("Yaw Rate", 5);
  
  //ddl.scroll(0);
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
}



void customizeCOMselection(DropdownList p1) {
  // a convenience function to customize a DropdownList
  p1.setBackgroundColor(color(190));
  p1.setItemHeight(15);
  p1.setBarHeight(15);
  p1.captionLabel().set("PUERTO COM");
  p1.captionLabel().style().marginTop = 3;
  p1.captionLabel().style().marginLeft = 3;
  p1.valueLabel().style().marginTop = 3;
  p1.clear();
  for (int i=0;i<portList.length;i++) {
    p1.addItem(portList[i], i);
  }
  numberOfPorts = portList.length;
  p1.setColorBackground(color(60));
  p1.setColorActive(color(255, 128));
}



void remarkITerm(int PID_id) {  
  IX_angle.setColor(0);
  IY_angle.setColor(0);
  IX.setColor(0);
  IY.setColor(0);
  IZ.setColor(0);  
  switch(PID_id) {
    case 1:
       IX_angle.setColor(#FF0000);
       break;     
    case 2:
       IY_angle.setColor(#FF0000);
       break;       
    case 3:
       IX.setColor(#FF0000);
       break;       
    case 4:
       IY.setColor(#FF0000);
       break;       
    case 5:
       IZ.setColor(#FF0000);
       break;
  }
}
