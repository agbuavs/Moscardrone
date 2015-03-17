import java.nio.ByteBuffer;
import processing.serial.*;
import controlP5.*;

ControlP5 cp5;
Serial arduino;

//Define types of messages between ConfGUI and Arduino
int PT_PID_CHANGE = 100;
int PT_JOY_MODE = 101;
int PT_JOY_CAL_SAVE = 102;

//Set to false when you only want to see the GUI format.
boolean CONNECTED = false;

String outputFileName = ""; // if you'd like to output data to a file, specify the path here

//String textWarning = "First of all, calibrate joystick.\nCalibration done when light turns green";
//String textInstructions = "Write PID values and type enter\n to send them to Arduino\nFeedback will be printed on the right column";
String textWarning = "";
String textInstructions = "";

//GUI items frame definition:
int margin = 20;
int PIDboxSizeX = 100;
int PIDboxSizeY = 40;
int PIDackboxSizeX = 40;
int PIDackboxSizeY = 40;
int X_commands = 120;
int Y_commands = 120;
int X_feedback = X_commands + PIDboxSizeX + margin;
int Y_feedback = Y_commands;

//Graphs for josytick
String stringX;
String stringY;
String stringZ;
String stringT;
int graphYpos = 500; //The graphs are belowfrom Y=graphYpos
float[] X = new float[600];
float[] Y = new float[600];
float[] Z = new float[600];
float[] T = new float[600];

//Buttons and boxes
DropdownList PID_selection;
String PID_select_label = "PID_selection";
controlP5.Textfield PID_P,PID_I,PID_D,PID_P_ack,PID_I_ack,PID_D_ack;
controlP5.Textfield PID_Xangle_P_ack, PID_Xangle_I_ack, PID_Xangle_D_ack;
controlP5.Textfield PID_Yangle_P_ack, PID_Yangle_I_ack, PID_Yangle_D_ack;
controlP5.Textfield PID_X_P_ack, PID_X_I_ack, PID_X_D_ack;
controlP5.Textfield PID_Y_P_ack, PID_Y_I_ack, PID_Y_D_ack;
controlP5.Textfield PID_Z_P_ack, PID_Z_I_ack, PID_Z_D_ack;
String PID_P_label = "P";
String PID_P_ack_label = "P ack";
String PID_I_label = "I";
String PID_I_ack_label = "I ack";
String PID_D_label = "D";
String PID_D_ack_label = "D ack";

DropdownList PORT_selection;
String PORT_select_label = "PORT_selection";
int COM_PORT_id = 0;
int numberOfPorts = 0;
String portList [];

byte joystickMode = 0; // rate=0 / angle=1

//PID calibration widgets
byte PID_id = 0;
byte PID_term = 0;


void setup() {
  println(Serial.list());     
  portList = Serial.list();
  
  size(600,graphYpos+255);
  
  for (int i=0;i<600;i++) { // center all variables    
    X[i] = height - graphYpos/2;
    Y[i] = height - graphYpos/2;
    Z[i] = height - graphYpos/2;
    T[i] = height - graphYpos/2;
  }
  
  PFont font = createFont("arial",20);
  PFont font10 = createFont("arial",10);
  
  text("To Arduino",20,50);
  
  cp5 = new ControlP5(this);
  
  
  // create a DropdownList for COM port selection        
  PORT_selection = cp5.addDropdownList(PORT_select_label)
    .setPosition(margin, margin)
        ;
  customizeCOMselection(PORT_selection);
  
  cp5.addButton("CONNECT")
    .setValue(1)
      .setPosition(20, 100 + margin)          //posición del botón
        .setSize(90, 40)              //tamaño del botón
          .setColorActive(#40BF44)     //color del botón cuando es pulsado
            .setColorBackground(#AEAEAE)//color de fondo con botón en reposo
              .setColorForeground(#6A6A6A)  //color cuando deslizamos el puntero sobre el botón
                .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
                  ;  
                  
  // create a toggle to control angle/rate mode
  // and change the default look to a (on/off) switch look
  cp5.addToggle("toggle")
     .setPosition(X_commands + PIDboxSizeX + margin,Y_commands - margin - 80)
     .setSize(50,20)
     .setValue(true)
     .setMode(ControlP5.SWITCH)
     ;
  
  // create a DropdownList for PID identifier selection
  PID_selection = cp5.addDropdownList(PID_select_label)
          .setPosition(X_commands, Y_commands - margin - 80)
          ;
          
  customize(PID_selection);
  
  PID_P = cp5.addTextfield(PID_P_label)
     .setPosition(X_commands,Y_commands + margin)
     .setSize(PIDboxSizeX,PIDboxSizeY)
     .setFont(font)
     .setAutoClear(false)
     .setFocus(true)
     .setColor(color(255,0,0))
     ;
                 
  PID_I = cp5.addTextfield(PID_I_label)
     .setPosition(X_commands,Y_commands + PIDboxSizeY + 2*margin)
     .setSize(PIDboxSizeX,PIDboxSizeY)
     .setFont(font)
     .setAutoClear(false)
     ;
     
  PID_D = cp5.addTextfield(PID_D_label)
     .setPosition(X_commands,Y_commands + 2*PIDboxSizeY + 3*margin)
     .setSize(PIDboxSizeX,PIDboxSizeY)
     .setFont(font)
     .setAutoClear(false)
     ;
  /*   
  PID_P_ack = cp5.addTextfield(PID_P_ack_label)
     .setPosition(X_commands + PIDboxSizeX + margin ,Y_commands + margin)
     .setSize(PIDboxSizeX,PIDboxSizeY)
     .setFont(font)
     .setAutoClear(false)
     ;
     
  PID_I_ack = cp5.addTextfield(PID_I_ack_label)
     .setPosition(X_commands + PIDboxSizeX + margin ,Y_commands + PIDboxSizeY + 2*margin)
     .setSize(PIDboxSizeX,PIDboxSizeY)
     .setFont(font)
     .setAutoClear(false)
     ;
     
  PID_D_ack = cp5.addTextfield(PID_D_ack_label)
     .setPosition(X_commands + PIDboxSizeX + margin ,Y_commands + 2*PIDboxSizeY + 3*margin)
     .setSize(PIDboxSizeX,PIDboxSizeY)
     .setFont(font)
     .setAutoClear(false)
     ;
  */  

  PID_Xangle_P_ack = cp5.addTextfield("X_ang_P")
     .setPosition(X_commands + PIDboxSizeX + margin ,Y_commands + margin)
     .setSize(PIDackboxSizeX,PIDackboxSizeY)
     .setFont(font10)
     .setAutoClear(false)
     ;     
  PID_Xangle_I_ack = cp5.addTextfield("X_ang_I")
     .setPosition(X_commands + PIDboxSizeX + margin ,Y_commands + PIDackboxSizeY + 2*margin)
     .setSize(PIDackboxSizeX,PIDackboxSizeY)
     .setFont(font10)
     .setAutoClear(false)
     ;     
  PID_Xangle_D_ack = cp5.addTextfield("X_ang_D")
     .setPosition(X_commands + PIDboxSizeX + margin ,Y_commands + 2*PIDackboxSizeY + 3*margin)
     .setSize(PIDackboxSizeX,PIDackboxSizeY)
     .setFont(font10)
     .setAutoClear(false)
     ;    
  
  PID_Yangle_P_ack = cp5.addTextfield("Y_ang_P")
     .setPosition(X_commands + PIDboxSizeX + PIDackboxSizeX + margin ,Y_commands + margin)
     .setSize(PIDackboxSizeX,PIDackboxSizeY)
     .setFont(font10)
     .setAutoClear(false)
     ;     
  PID_Yangle_I_ack = cp5.addTextfield("Y_ang_I")
     .setPosition(X_commands + PIDboxSizeX + PIDackboxSizeX + margin ,Y_commands + PIDackboxSizeY + 2*margin)
     .setSize(PIDackboxSizeX,PIDackboxSizeY)
     .setFont(font10)
     .setAutoClear(false)
     ;     
  PID_Yangle_D_ack = cp5.addTextfield("Y_ang_D")
     .setPosition(X_commands + PIDboxSizeX + PIDackboxSizeX + margin ,Y_commands + 2*PIDackboxSizeY + 3*margin)
     .setSize(PIDackboxSizeX,PIDackboxSizeY)
     .setFont(font10)
     .setAutoClear(false)
     ;
    
  PID_X_P_ack = cp5.addTextfield("X_P")
     .setPosition(X_commands + PIDboxSizeX + 2*PIDackboxSizeX + margin ,Y_commands + margin)
     .setSize(PIDackboxSizeX,PIDackboxSizeY)
     .setFont(font10)
     .setAutoClear(false)
     ;     
  PID_X_I_ack = cp5.addTextfield("X_I")
     .setPosition(X_commands + PIDboxSizeX + 2*PIDackboxSizeX + margin ,Y_commands + PIDackboxSizeY + 2*margin)
     .setSize(PIDackboxSizeX,PIDackboxSizeY)
     .setFont(font10)
     .setAutoClear(false)
     ;     
  PID_X_D_ack = cp5.addTextfield("X_D")
     .setPosition(X_commands + PIDboxSizeX + 2*PIDackboxSizeX + margin ,Y_commands + 2*PIDackboxSizeY + 3*margin)
     .setSize(PIDackboxSizeX,PIDackboxSizeY)
     .setFont(font10)
     .setAutoClear(false)
     ;  
    
  PID_Y_P_ack = cp5.addTextfield("Y_P")
     .setPosition(X_commands + PIDboxSizeX + 3*PIDackboxSizeX + margin ,Y_commands + margin)
     .setSize(PIDackboxSizeX,PIDackboxSizeY)
     .setFont(font10)
     .setAutoClear(false)
     ;     
  PID_Y_I_ack = cp5.addTextfield("Y_I")
     .setPosition(X_commands + PIDboxSizeX + 3*PIDackboxSizeX + margin ,Y_commands + PIDackboxSizeY + 2*margin)
     .setSize(PIDackboxSizeX,PIDackboxSizeY)
     .setFont(font10)
     .setAutoClear(false)
     ;     
  PID_Y_D_ack = cp5.addTextfield("Y_D")
     .setPosition(X_commands + PIDboxSizeX + 3*PIDackboxSizeX + margin ,Y_commands + 2*PIDackboxSizeY + 3*margin)
     .setSize(PIDackboxSizeX,PIDackboxSizeY)
     .setFont(font10)
     .setAutoClear(false)
     ;  
     
  PID_Z_P_ack = cp5.addTextfield("Z_P")
     .setPosition(X_commands + PIDboxSizeX + 4*PIDackboxSizeX + margin ,Y_commands + margin)
     .setSize(PIDackboxSizeX,PIDackboxSizeY)
     .setFont(font10)
     .setAutoClear(false)
     ;     
  PID_Z_I_ack = cp5.addTextfield("Z_I")
     .setPosition(X_commands + PIDboxSizeX + 4*PIDackboxSizeX + margin ,Y_commands + PIDackboxSizeY + 2*margin)
     .setSize(PIDackboxSizeX,PIDackboxSizeY)
     .setFont(font10)
     .setAutoClear(false)
     ;     
  PID_Z_D_ack = cp5.addTextfield("Z_D")
     .setPosition(X_commands + PIDboxSizeX + 4*PIDackboxSizeX + margin ,Y_commands + 2*PIDackboxSizeY + 3*margin)
     .setSize(PIDackboxSizeX,PIDackboxSizeY)
     .setFont(font10)
     .setAutoClear(false)
     ;  
     
  cp5.addBang("clear")
     .setPosition(X_commands, Y_commands + 3*PIDboxSizeY + 4*margin)
     .setSize(80,40)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     ;     
  
  textFont(font);
}


void draw() {
  
  //Update port list
  portList = arduino.list();
  if (numberOfPorts != portList.length) {
    println(arduino.list());
    customizeCOMselection(PORT_selection);
  }
  
  background(0);
  fill(255);
  text(textWarning, X_commands + PIDboxSizeX + 4*PIDackboxSizeX + margin, 40);
  text(textInstructions, X_commands + PIDboxSizeX + 4*PIDackboxSizeX + margin + 100, 180);
  text("To Quad",X_commands,Y_commands);
  text("From Quad",X_feedback,Y_feedback);
  text("Joystick RC commands",margin, graphYpos - margin);
  if (joystickMode==0)
    text("Rate Mode",X_commands + PIDboxSizeX + margin,Y_commands - 40);
  else
    text("Angle Mode",X_commands + PIDboxSizeX + margin,Y_commands - 40); 
  
  //Joystick visualization 
  convert();
  drawAxis(); 
}


public void clear() {
  cp5.get(Textfield.class,PID_P_label).clear();
  cp5.get(Textfield.class,PID_I_label).clear();
  cp5.get(Textfield.class,PID_D_label).clear();
}


public void input(String theText) {
  // automatically receives results from controller input
  println("a textfield event for controller 'input' : "+theText);
}


void toggle(boolean theFlag) {
  if(theFlag==true) {
    joystickMode = 0; //JOY_MODE_RATE
    println("mode toggle changes to RATE mode");
  } else {
    joystickMode = 1; //JOY_MODE_ANGLE
    println("mode toggle changes to ANGLE mode");
  } 
  
  //Here shall be the message creation and delivery to GS
  if (CONNECTED) {
    arduino.write(PT_JOY_MODE);
    arduino.write(joystickMode);
  }
  println(PT_JOY_MODE);
  println(joystickMode);
  
  //There must be some feedback from QS through GS, 
  //  which shall be catch in serialEvent
  //  and make some light change color or something.
}


void customize(DropdownList ddl) {
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
