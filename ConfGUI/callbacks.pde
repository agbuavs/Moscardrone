public void CONNECT(int theValue) {
  if (millis()>10000)
  {
    CONNECTED = true;
    arduino = new Serial(this, Serial.list()[COM_PORT_id], 115200);
    arduino.bufferUntil('\n');
  }
}


//When typing enter on a PID box, the value shall be sent to Arduino as a byte array
void controlEvent(ControlEvent theEvent) {
  if(theEvent.isAssignableFrom(Textfield.class)) {
    println("controlEvent: accessing a string from controller '"
            +theEvent.getName()+"': "
            +theEvent.getStringValue()
            );
  }
  println(theEvent.getName()); 
 
  if (theEvent.getName() == PORT_select_label) {
    if(theEvent.isGroup()) {
      COM_PORT_id = (byte)theEvent.group().value();
    }
  } 
  else {
      
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
        arduino.write(PT_PID_CHANGE);
        arduino.write(PID_id);   // angleX, angleY, rateX, rateY or rateZ
        arduino.write(PID_term); // P, I or D ?
        arduino.write(floatToByteArray(value)); //This makes the conversion from float string to byte array
      } 
      println(PT_PID_CHANGE); 
      println(PID_id);   // angleX, angleY, rateX, rateY or rateZ
      println(PID_term); // P, I or D ?
      println(floatToByteArray(value)); //This makes the conversion from float string to byte array
    }
  }
}


//Change Rate or Angle mode
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


//Clear PID inputs
public void clear() {
  cp5.get(Textfield.class,PID_P_label).clear();
  cp5.get(Textfield.class,PID_I_label).clear();
  cp5.get(Textfield.class,PID_D_label).clear();
}


//clear joystick calibration
public void Clear_Cal () {
  if (CONNECTED) {
        arduino.write(PT_JOY_CAL_CLEAR);
        println(PT_JOY_CAL_CLEAR);
  } 
}

//save joystick calibration
public void Save_Cal () {
  if (CONNECTED) {
        arduino.write(PT_JOY_CAL_SAVE);
        println(PT_JOY_CAL_SAVE);
  } 
}


//take the string the arduino sends and parse it
void serialEvent(Serial arduino)
{
  String read = arduino.readString();
  //arduino.clear();
  String[] s = split(read, " ");
  //println(read);

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
      
    case 10: //pot measures
      stringX = s[1];
      stringY = s[2];
      stringZ = s[3];
      stringT = s[4];
      break;
  }
}
