import java.nio.ByteBuffer;
import processing.serial.*;
import controlP5.*;
//import javax.swing.JOptionPane.*;

ControlP5 cp5;
Serial arduino;

//Define colors
color YELLOW = color(255,255,0);
color PINK = color(255,0,255);
color BLUE = color(0,0,255);
color GREEN = color(0,255,0);
color RED = color(255,0,0);


//Define packet types between ConfGUI and Arduino
int PT_PID_CHANGE = 100;
int PT_JOY_MODE = 101;
int PT_JOY_CAL_SAVE = 102;
int PT_JOY_CAL_CLEAR = 103;
int PT_PID_CAL_SAVE = 104;
int PT_PID_CAL_CLEAR = 105;

//Set to false when you only want to see the GUI format.
boolean CONNECTED = false;

String outputFileName = ""; // if you'd like to output data to a file, specify the path here

//String textWarning = "First of all, calibrate joystick.\nCalibration done when light turns green";
//String textInstructions = "Write PID values and type enter\n to send them to Arduino\nFeedback will be printed on the right column";
String textWarning = "";
String textInstructions = "";

//GUI items frame definition:
int WINDOW_SIZE_X = 650;
int margin = 5;
int PIDboxSizeX = 100;
int PIDboxSizeY = 30;
int PIDackboxSizeX = 60;
int PIDackboxSizeY = 30;
int X_commands = 120;
int Y_commands = 70;
int X_feedback = X_commands + PIDboxSizeX + margin;
int Y_feedback = Y_commands;

//Graphs for josytick
String stringX;
String stringY;
String stringZ;
String stringT;
int graphYpos = 250; //The graphs are belowfrom Y=graphYpos
float[] X = new float[WINDOW_SIZE_X];
float[] Y = new float[WINDOW_SIZE_X];
float[] Z = new float[WINDOW_SIZE_X];
float[] T = new float[WINDOW_SIZE_X];

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
String PID_I_label = "I";
String PID_D_label = "D";

DropdownList PORT_selection;
String PORT_select_label = "PORT_selection";
int COM_PORT_id = 0;
int numberOfPorts = 0;
String portList [];

int joystickMode = 0; // rate=0 / angle=1
int joystickMode_ack = 0; // rate=0 / angle=1 (used to save ack received from Arduino)

//PID calibration widgets
byte PID_id = 0;
byte PID_term = 0;

//PID calibratio step by step:
float PID_STEP = 0.001;




void setup() {
  println(Serial.list());     
  portList = Serial.list();
  
  size(WINDOW_SIZE_X,graphYpos+255);
  //frame.setResizable(true);
  
  for (int i=0;i<WINDOW_SIZE_X;i++) { // center all variables    
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
    .setPosition(margin, margin + 15)
        ;
  customizeCOMselection(PORT_selection);
  
  cp5.addButton("CONNECT")
    .setValue(1)
      .setPosition(X_commands, margin)
      //.setPosition(20, 100 + margin)          //posición del botón
        .setSize(PIDboxSizeX, PIDboxSizeY)              //tamaño del botón
          .setColorActive(#40BF44)     //color del botón cuando es pulsado
            .setColorBackground(#AEAEAE)//color de fondo con botón en reposo
              .setColorForeground(#6A6A6A)  //color cuando deslizamos el puntero sobre el botón
                .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
                  ;  
                  
  // create a toggle to control angle/rate mode
  // and change the default look to a (on/off) switch look
  cp5.addToggle("PID_mode")
     .setPosition(X_commands + PIDboxSizeX + margin, margin)
     .setSize(40,20)
     .setValue(true)
     .setMode(ControlP5.SWITCH)
     ;
  
  // create a DropdownList for PID identifier selection
  PID_selection = cp5.addDropdownList(PID_select_label)
          //.setPosition(X_commands, Y_commands - margin - 80)
          .setPosition(margin, Y_commands + 70)
          ;          
  customize(PID_selection);
  
  PID_P = cp5.addTextfield(PID_P_label)
     .setPosition(X_commands,Y_commands + margin)
     .setSize(PIDboxSizeX,PIDboxSizeY)
     .setFont(font)
     .setAutoClear(false)
     .setFocus(true)
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
     
     
  cp5.addButton("Clear_PID")
    .setValue(1)
      .setPosition(X_commands + PIDboxSizeX + 5*PIDackboxSizeX + 2*margin ,Y_commands + margin)   //posición del botón
        .setSize(PIDboxSizeX, PIDboxSizeY)              //tamaño del botón
          .setColorActive(#40BF44)     //color del botón cuando es pulsado
            .setColorBackground(#AEAEAE)//color de fondo con botón en reposo
              .setColorForeground(#6A6A6A)  //color cuando deslizamos el puntero sobre el botón
                .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
                  ;  
                  
  cp5.addButton("Save_PID")
    .setValue(1)
      .setPosition(X_commands + PIDboxSizeX + 5*PIDackboxSizeX + 2*margin ,Y_commands + PIDackboxSizeY + 2*margin)          //posición del botón
        .setSize(PIDboxSizeX, PIDboxSizeY)              //tamaño del botón
          .setColorActive(#40BF44)     //color del botón cuando es pulsado
            .setColorBackground(#AEAEAE)//color de fondo con botón en reposo
              .setColorForeground(#6A6A6A)  //color cuando deslizamos el puntero sobre el botón
                .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
                  ;  
                  
  cp5.addButton("P_up")
    .setValue(1)
      .setPosition(X_commands+80,Y_commands + margin)
        .setSize(20, 10)              //tamaño del botón
          .setColorActive(#40BF44)     //color del botón cuando es pulsado
            .setColorBackground(#AEAEAE)//color de fondo con botón en reposo
              .setColorForeground(#6A6A6A)  //color cuando deslizamos el puntero sobre el botón
                .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
                  ; 
  cp5.addButton("P_down")
    .setValue(1)
      .setPosition(X_commands+80,Y_commands + margin + 20)
        .setSize(20, 10)              //tamaño del botón
          .setColorActive(#40BF44)     //color del botón cuando es pulsado
            .setColorBackground(#AEAEAE)//color de fondo con botón en reposo
              .setColorForeground(#6A6A6A)  //color cuando deslizamos el puntero sobre el botón
                .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
                  ; 
                  
  cp5.addButton("I_up")
    .setValue(1)
      .setPosition(X_commands+80,Y_commands + PIDboxSizeY + 2*margin)
        .setSize(20, 10)              //tamaño del botón
          .setColorActive(#40BF44)     //color del botón cuando es pulsado
            .setColorBackground(#AEAEAE)//color de fondo con botón en reposo
              .setColorForeground(#6A6A6A)  //color cuando deslizamos el puntero sobre el botón
                .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
                  ; 
  cp5.addButton("I_down")
    .setValue(1)
      .setPosition(X_commands+80,Y_commands + PIDboxSizeY + 2*margin +20)
        .setSize(20, 10)              //tamaño del botón
          .setColorActive(#40BF44)     //color del botón cuando es pulsado
            .setColorBackground(#AEAEAE)//color de fondo con botón en reposo
              .setColorForeground(#6A6A6A)  //color cuando deslizamos el puntero sobre el botón
                .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
                  ;
                 
  cp5.addButton("D_up")
    .setValue(1)
      .setPosition(X_commands+80,Y_commands + 2*PIDboxSizeY + 3*margin)
        .setSize(20, 10)              //tamaño del botón
          .setColorActive(#40BF44)     //color del botón cuando es pulsado
            .setColorBackground(#AEAEAE)//color de fondo con botón en reposo
              .setColorForeground(#6A6A6A)  //color cuando deslizamos el puntero sobre el botón
                .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
                  ; 
  cp5.addButton("D_down")
    .setValue(1)
      .setPosition(X_commands+80,Y_commands + 2*PIDboxSizeY + 3*margin +20)
        .setSize(20, 10)              //tamaño del botón
          .setColorActive(#40BF44)     //color del botón cuando es pulsado
            .setColorBackground(#AEAEAE)//color de fondo con botón en reposo
              .setColorForeground(#6A6A6A)  //color cuando deslizamos el puntero sobre el botón
                .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
                  ;  
     
  cp5.addBang("copy")
     .setPosition(X_commands, Y_commands + 3*PIDboxSizeY + 4*margin)
     .setSize(PIDboxSizeX/2, PIDboxSizeY)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     ;    
     
  cp5.addBang("clear")
     .setPosition(X_commands + PIDboxSizeX/2 + margin, Y_commands + 3*PIDboxSizeY + 4*margin)
     .setSize(PIDboxSizeX/2, PIDboxSizeY)
     .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
     ;
    
  cp5.addButton("Clear_Cal")
    .setValue(1)
      .setPosition(300, graphYpos - PIDboxSizeY)          //posición del botón
        .setSize(PIDboxSizeX, PIDboxSizeY)              //tamaño del botón
          .setColorActive(#40BF44)     //color del botón cuando es pulsado
            .setColorBackground(#AEAEAE)//color de fondo con botón en reposo
              .setColorForeground(#6A6A6A)  //color cuando deslizamos el puntero sobre el botón
                .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
                  ;  
                  
  cp5.addButton("Save_Cal")
    .setValue(1)
      .setPosition(420, graphYpos - PIDboxSizeY)          //posición del botón
        .setSize(PIDboxSizeX, PIDboxSizeY)              //tamaño del botón
          .setColorActive(#40BF44)     //color del botón cuando es pulsado
            .setColorBackground(#AEAEAE)//color de fondo con botón en reposo
              .setColorForeground(#6A6A6A)  //color cuando deslizamos el puntero sobre el botón
                .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
                  ;    
  
  textFont(font);
  
  PID_P.setText("0");
  PID_I.setText("0");
  PID_D.setText("0");
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
    text("Rate Mode", X_commands + PIDboxSizeX + 100, margin + PIDboxSizeY);
  else
    text("Angle Mode", X_commands + PIDboxSizeX + 100, margin + PIDboxSizeY); 
  if (joystickMode == joystickMode_ack)
    text("OK", X_commands + PIDboxSizeX + 220, margin + PIDboxSizeY); 
  else
    text("......", X_commands + PIDboxSizeX + 200, margin + PIDboxSizeY);
    
  //Joystick visualization 
  convert();
  drawAxis(); 
}



public void input(String theText) {
  // automatically receives results from controller input
  println("a textfield event for controller 'input' : "+theText);
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
