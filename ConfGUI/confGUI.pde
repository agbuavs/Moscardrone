
import java.nio.ByteBuffer;
import processing.serial.*;
import controlP5.*;

ControlP5 cp5;
Serial myPort;

String outputFileName = ""; // if you'd like to output data to 
// a file, specify the path here

String textWarning = "First of all, calibrate joystick.\nCalibration done when light turns green";
String textInstructions = "Write PID values and type enter\n to send them to Arduino\nFeedback will be printed on the wright column";

//GUI items frame definition:
int margin = 20;
int PIDboxSizeX = 80;
int PIDboxSizeY = 40;
int X_commands = 20;
int Y_commands = 70;
int X_feedback = X_commands + PIDboxSizeX + margin;
int Y_feedback = Y_commands;

controlP5.Textfield PID_P,PID_I,PID_D,PID_P_ack,PID_I_ack,PID_D_ack;
String PID_P_label = "P";
String PID_P_ack_label = "P ack";
String PID_I_label = "I";
String PID_I_ack_label = "I ack";
String PID_D_label = "D";
String PID_D_ack_label = "D ack";


void setup() {
  println(Serial.list());                                           // * Initialize Serial
  myPort = new Serial(this, Serial.list()[2], 115200);                //   Communication with
  myPort.bufferUntil(10); 
  
  size(700,400);
  
  PFont font = createFont("arial",20);
  
  text("To Arduino",20,50);
  
  cp5 = new ControlP5(this);
  
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
  text(textInstructions, 300,180);
  text(textWarning, 300, 80);
  text("To Quad",X_commands,Y_commands);
  text("From Quad",X_feedback,Y_feedback);
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
  
  byte PID_id = 4;      //This will be choosable in GUI (angleX, angleY, rateX, rateY or rateZ)....
  byte PID_term = 0;
  float value = 0;
  String a = theEvent.getName();
  if (a.equals("P")) {
     PID_term = 1;
     value = float(PID_P.getText());
  }
  if (a.equals("I")) {
     PID_term = 2;
     value = float(PID_I.getText());
  }
  if (a.equals("D"))  {
     PID_term = 3;
     value = float(PID_D.getText());
  }
  
  //Send the PID term identifier information and value to Arduino over serial
  myPort.write(PID_id);   // angleX, angleY, rateX, rateY or rateZ
  myPort.write(PID_term); // P, I or D ?
  myPort.write(floatToByteArray(value)); //This makes the conversion from float string to byte array
  /*
  println(PID_id);   // angleX, angleY, rateX, rateY or rateZ
  println(PID_term); // P, I or D ?
  println(floatToByteArray(value)); //This makes the conversion from float string to byte array
  */
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
  
  if (parseInt(s[1])==1) PID_P_ack.setText(s[2]);
  if (parseInt(s[1])==2) PID_I_ack.setText(s[2]);
  if (parseInt(s[1])==3) PID_D_ack.setText(s[2]);

}
