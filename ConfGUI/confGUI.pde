
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
int PIDboxSizeX = 100;
int PIDboxSizeY = 40;
int X_commands = 20;
int Y_commands = 120;
int X_feedback = X_commands + PIDboxSizeX + margin;
int Y_feedback = Y_commands;

DropdownList PID_selection;
String PID_select_label = "Select PID to calibrate";
controlP5.Textfield PID_P,PID_I,PID_D,PID_P_ack,PID_I_ack,PID_D_ack;
String PID_P_label = "P";
String PID_P_ack_label = "P ack";
String PID_I_label = "I";
String PID_I_ack_label = "I ack";
String PID_D_label = "D";
String PID_D_ack_label = "D ack";

//Set to false when you only want to see the GUI format.
boolean CONNECTED = true;

//best values 
//(2014-05-16 trials) : P 1.3, I 0.01, D 0.55
//(2014-05-17 trials) : P 1.1, I 0.0175, D 0.45
//maybe it's necessary to change format to add decimal numbers.


void setup() {
  println(Serial.list());                                           // * Initialize Serial
  if (CONNECTED) {
    myPort = new Serial(this, Serial.list()[2], 115200);        
    myPort.bufferUntil(10); 
  }
  
  size(800,400);
  
  PFont font = createFont("arial",20);
  
  text("To Arduino",20,50);
  
  cp5 = new ControlP5(this);
  
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
  
  byte PID_id = 2;      //This will be choosable in GUI (angleX, angleY, rateX, rateY or rateZ)....
  byte PID_term = 0;
  float value = 0;
  String a = theEvent.getName();
  if (a.equals("P")) {
     PID_term = 1;
     value = float(PID_P.getText());
     //println(value);
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
  if (CONNECTED) {
  myPort.write(PID_id);   // angleX, angleY, rateX, rateY or rateZ
  myPort.write(PID_term); // P, I or D ?
  myPort.write(floatToByteArray(value)); //This makes the conversion from float string to byte array
  }
  
  println(PID_id);   // angleX, angleY, rateX, rateY or rateZ
  println(PID_term); // P, I or D ?
  println(floatToByteArray(value)); //This makes the conversion from float string to byte array
  
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
