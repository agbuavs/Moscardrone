
import java.nio.ByteBuffer;
import processing.serial.*;
import controlP5.*;

ControlP5 cp5;
Serial myPort;

//Define types of messages between ConfGUI and Arduino
int PT_PID_CHANGE = 100;
int PT_JOY_MODE = 101;

//Set to false when you only want to see the GUI format.
boolean CONNECTED = true;

String outputFileName = ""; // if you'd like to output data to 
// a file, specify the path here

String textWarning = "First of all, calibrate joystick.\nCalibration done when light turns green";
String textInstructions = "Write PID values and type enter\n to send them to Arduino\nFeedback will be printed on the right column";

//GUI items frame definition:
int margin = 20;
int PIDboxSizeX = 100;
int PIDboxSizeY = 40;
int PIDackboxSizeX = 40;
int PIDackboxSizeY = 40;
int X_commands = 20;
int Y_commands = 120;
int X_feedback = X_commands + PIDboxSizeX + margin;
int Y_feedback = Y_commands;

DropdownList PID_selection;
String PID_select_label = "Select PID to calibrate";
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

byte joystickMode = 0; // rate=0 / angle=1

//PID calibration widgets
byte PID_id = 0;
byte PID_term = 0;


void setup() {
  println(Serial.list());                                           // * Initialize Serial
  if (CONNECTED) {
    myPort = new Serial(this, Serial.list()[4], 115200);        
    myPort.bufferUntil(10); 
  }
  
  size(800,400);
  
  PFont font = createFont("arial",20);
  PFont font10 = createFont("arial",10);
  
  text("To Arduino",20,50);
  
  cp5 = new ControlP5(this);
  
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
  background(0);
  fill(255);
  text(textInstructions, 400,180);
  text(textWarning, 300, 40);
  text("To Quad",X_commands,Y_commands);
  text("From Quad",X_feedback,Y_feedback);
  if (joystickMode==0)
    text("Rate Mode",X_commands + PIDboxSizeX + margin,Y_commands - 40);
  else
    text("Angle Mode",X_commands + PIDboxSizeX + margin,Y_commands - 40);
  
}


public void clear() {
  cp5.get(Textfield.class,PID_P_label).clear();
  cp5.get(Textfield.class,PID_I_label).clear();
  cp5.get(Textfield.class,PID_D_label).clear();
}


//When typing enter on a PID box, the value shall be sent to Arduino as a byte array
void controlEvent(ControlEvent theEvent) {
  if(theEvent.isAssignableFrom(Textfield.class)) {
    println("controlEvent: accessing a string from controller '"
            +theEvent.getName()+"': "
            +theEvent.getStringValue()
            );
  }  
  
  if(theEvent.isGroup()) {
    PID_id = (byte)theEvent.group().value();
  }
  
  boolean PID_change = false;
  PID_term = 0;
  float value = 0;
  String a = theEvent.getName();
  if (a.equals("P")) {
     PID_term = 1;
     value = float(PID_P.getText());
     PID_change = true;
  }
  if (a.equals("I")) {
     PID_term = 2;
     value = float(PID_I.getText());
     PID_change = true;
  }
  if (a.equals("D"))  {
     PID_term = 3;
     value = float(PID_D.getText());
     PID_change = true;
  }
  
  //Send the PID term identifier information and value to Arduino over serial
  if (PID_change) {
    if (CONNECTED) {
      myPort.write(PT_PID_CHANGE);
      myPort.write(PID_id);   // angleX, angleY, rateX, rateY or rateZ
      myPort.write(PID_term); // P, I or D ?
      myPort.write(floatToByteArray(value)); //This makes the conversion from float string to byte array
    } 
    println(PT_PID_CHANGE); 
    println(PID_id);   // angleX, angleY, rateX, rateY or rateZ
    println(PID_term); // P, I or D ?
    println(floatToByteArray(value)); //This makes the conversion from float string to byte array
  }
}



public void input(String theText) {
  // automatically receives results from controller input
  println("a textfield event for controller 'input' : "+theText);
}


//take the string the arduino sends us and parse it
void serialEvent(Serial myPort)
{
  String read = myPort.readString();
  //myPort.clear();
  String[] s = split(read, " ");
  println(read);

  switch (parseInt(s[0])) {
    case 1:
      if (parseInt(s[1])==1) PID_Xangle_P_ack.setText(s[2]);
      if (parseInt(s[1])==2) PID_Xangle_I_ack.setText(s[2]);
      if (parseInt(s[1])==3) PID_Xangle_D_ack.setText(s[2]);
      break;
    case 2:
      if (parseInt(s[1])==1) PID_Yangle_P_ack.setText(s[2]);
      if (parseInt(s[1])==2) PID_Yangle_I_ack.setText(s[2]);
      if (parseInt(s[1])==3) PID_Yangle_D_ack.setText(s[2]);
      break;
    case 3:
      if (parseInt(s[1])==1) PID_X_P_ack.setText(s[2]);
      if (parseInt(s[1])==2) PID_X_I_ack.setText(s[2]);
      if (parseInt(s[1])==3) PID_X_D_ack.setText(s[2]);
      break;
    case 4:
      if (parseInt(s[1])==1) PID_Y_P_ack.setText(s[2]);
      if (parseInt(s[1])==2) PID_Y_I_ack.setText(s[2]);
      if (parseInt(s[1])==3) PID_Y_D_ack.setText(s[2]);
      break;
    case 5:
      if (parseInt(s[1])==1) PID_Z_P_ack.setText(s[2]);
      if (parseInt(s[1])==2) PID_Z_I_ack.setText(s[2]);
      if (parseInt(s[1])==3) PID_Z_D_ack.setText(s[2]);
      break;
  }
  

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
    myPort.write(PT_JOY_MODE);
    myPort.write(joystickMode);
  }
  println(PT_JOY_MODE);
  println(joystickMode);
  
  //There must be some feedback from QS through GS, 
  //  which shall be catch in serialEvent
  //  and make some light change color or something.
}
