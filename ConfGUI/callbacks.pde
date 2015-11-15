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
      copyPID_parameters();
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
        setPID_ackColor(PID_term, RED); //Set the PID ack box as "not acknowledged:
      }      
          
      println(PT_PID_CHANGE); 
      println(PID_id);   // angleX, angleY, rateX, rateY or rateZ
      println(PID_term); // P, I or D ?
      println(floatToByteArray(value)); //This makes the conversion from float string to byte array
    }
  }
}


//Change Rate or Angle mode
void PID_mode(boolean theFlag) {
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
}


//
// PID parameters up/down buttons:
//

public void P_up () {  
  float value = 0;  
  value = float(PID_P.getText());
  value = value + PID_STEP;
  PID_P.setText(str(value));
  if (CONNECTED) {
     arduino.write(PT_PID_CHANGE);
     arduino.write(PID_id);   // angleX, angleY, rateX, rateY or rateZ
     arduino.write(1); // P, I or D ?
     arduino.write(floatToByteArray(value)); 
     setPID_ackColor(1, RED);  
  } 
}

public void P_down () {  
  float value = 0;  
  value = float(PID_P.getText());
  if (value > PID_STEP) {
    value = value - PID_STEP;
    PID_P.setText(str(value));
    if (CONNECTED) {
     arduino.write(PT_PID_CHANGE);
     arduino.write(PID_id);   // angleX, angleY, rateX, rateY or rateZ
     arduino.write(1); // P, I or D ?
     arduino.write(floatToByteArray(value)); 
     setPID_ackColor(1, RED);  
    } 
  }
}


public void I_up () {  
  float value = 0;  
  value = float(PID_I.getText());
  value = value + PID_STEP;
  PID_I.setText(str(value));
  if (CONNECTED) {
     arduino.write(PT_PID_CHANGE);
     arduino.write(PID_id);   // angleX, angleY, rateX, rateY or rateZ
     arduino.write(2); // P, I or D ?
     arduino.write(floatToByteArray(value)); 
     setPID_ackColor(2, RED);  
  } 
}

public void I_down () {  
  float value = 0;  
  value = float(PID_I.getText());
  if (value > PID_STEP) {
    value = value - PID_STEP;
    PID_I.setText(str(value));
    if (CONNECTED) {
     arduino.write(PT_PID_CHANGE);
     arduino.write(PID_id);   // angleX, angleY, rateX, rateY or rateZ
     arduino.write(2); // P, I or D ?
     arduino.write(floatToByteArray(value)); 
     setPID_ackColor(2, RED);  
    } 
  }
}


public void D_up () {  
  float value = 0;  
  value = float(PID_D.getText());
  value = value + PID_STEP;
  PID_D.setText(str(value));
  if (CONNECTED) {
     arduino.write(PT_PID_CHANGE);
     arduino.write(PID_id);   // angleX, angleY, rateX, rateY or rateZ
     arduino.write(3); // P, I or D ?
     arduino.write(floatToByteArray(value)); 
     setPID_ackColor(3, RED);  
  } 
}

public void D_down () {  
  float value = 0;  
  value = float(PID_D.getText());
  if (value > PID_STEP) {
    value = value - PID_STEP;
    PID_D.setText(trim(str(value)));  
    if (CONNECTED) {
     arduino.write(PT_PID_CHANGE);
     arduino.write(PID_id);   // angleX, angleY, rateX, rateY or rateZ
     arduino.write(3); // P, I or D ?
     arduino.write(floatToByteArray(value)); 
     setPID_ackColor(3, RED);  
    } 
  }
}



//Clear PID inputs
public void clear() {
  PID_P.setText("0");
  PID_I.setText("0");
  PID_D.setText("0");
}

//Copy PID inputs
public void copy() {
  copyPID_parameters();
}

//clear PID calibration
public void Clear_PID () {
  if (CONNECTED) {
        arduino.write(PT_PID_CAL_CLEAR);
        println(PT_PID_CAL_CLEAR);     
  } 
}

//save PID calibration
public void Save_PID () {
  if (CONNECTED) {
        arduino.write(PT_PID_CAL_SAVE);
        println(PT_PID_CAL_SAVE);
  } 
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
  arduino.clear();
  String[] s = split(read, " ");
  println(read);

  switch (parseInt(s[0])) {
    case 1:
      if (parseInt(s[1])==1) {
        PID_Xangle_P_ack.setText(s[2]);
        PID_Xangle_P_ack.setColorBackground(BLUE);
      }
      if (parseInt(s[1])==2) {
        PID_Xangle_I_ack.setText(s[2]);
        PID_Xangle_I_ack.setColorBackground(BLUE);
      }
      if (parseInt(s[1])==3) {
        PID_Xangle_D_ack.setText(s[2]);
        PID_Xangle_D_ack.setColorBackground(BLUE);
      }
      //The following 2 lines should not be inside this switch-case.
      if (parseInt(s[3]) == PT_JOY_MODE)
       joystickMode_ack = parseInt(s[4]);
      break;
      
    case 2:
      if (parseInt(s[1])==1) {
        PID_Yangle_P_ack.setText(s[2]);
        PID_Yangle_P_ack.setColorBackground(BLUE);
      }
      if (parseInt(s[1])==2) {
        PID_Yangle_I_ack.setText(s[2]);
        PID_Yangle_I_ack.setColorBackground(BLUE);
      }
      if (parseInt(s[1])==3) {
        PID_Yangle_D_ack.setText(s[2]);
        PID_Yangle_D_ack.setColorBackground(BLUE);
      }
      break;
      
    case 3:
      if (parseInt(s[1])==1) {
        PID_X_P_ack.setText(s[2]);
        PID_X_P_ack.setColorBackground(BLUE);
      }
      if (parseInt(s[1])==2) {
        PID_X_I_ack.setText(s[2]);
        PID_X_I_ack.setColorBackground(BLUE);
      }
      if (parseInt(s[1])==3) {
        PID_X_D_ack.setText(s[2]);
        PID_X_D_ack.setColorBackground(BLUE);
      }
      break;
      
    case 4:
      if (parseInt(s[1])==1) {
        PID_Y_P_ack.setText(s[2]);
        PID_Y_P_ack.setColorBackground(BLUE);
      }
      if (parseInt(s[1])==2) {
        PID_Y_I_ack.setText(s[2]);
        PID_Y_I_ack.setColorBackground(BLUE);
      }
      if (parseInt(s[1])==3) {
        PID_Y_D_ack.setText(s[2]);
        PID_Y_D_ack.setColorBackground(BLUE);
      }
      break;
      
    case 5:
      if (parseInt(s[1])==1) {
        PID_Z_P_ack.setText(s[2]);
        PID_Z_P_ack.setColorBackground(BLUE);
      }
      if (parseInt(s[1])==2) {
        PID_Z_I_ack.setText(s[2]);
        PID_Z_I_ack.setColorBackground(BLUE);
      }
      if (parseInt(s[1])==3) {
        PID_Z_D_ack.setText(s[2]);
        PID_Z_D_ack.setColorBackground(BLUE);
      }
      break;      
      
    case 10: //pot measures
      stringX = s[1];
      stringY = s[2];
      stringZ = s[3];
      stringT = s[4];
      break;
  }
  
}



//////////////////////////////////////////////
///////// AUXILIARY FUNCTIONS ////////////////
//////////////////////////////////////////////

public void setPID_ackColor(int PID_term, color col) {
  switch (PID_id) {
   case 1:
    if (PID_term==1) PID_Xangle_P_ack.setColorBackground(col);
    if (PID_term==2) PID_Xangle_I_ack.setColorBackground(col);
    if (PID_term==3) PID_Xangle_D_ack.setColorBackground(col);
    break;
   case 2:
    if (PID_term==1) PID_Yangle_P_ack.setColorBackground(col);
    if (PID_term==2) PID_Yangle_I_ack.setColorBackground(col);
    if (PID_term==3) PID_Yangle_D_ack.setColorBackground(col);
    break;
   case 3:
    if (PID_term==1) PID_X_P_ack.setColorBackground(col);
    if (PID_term==2) PID_X_I_ack.setColorBackground(col);
    if (PID_term==3) PID_X_D_ack.setColorBackground(col);
    break;
   case 4:
    if (PID_term==1) PID_Y_P_ack.setColorBackground(col);
    if (PID_term==2) PID_Y_I_ack.setColorBackground(col);
    if (PID_term==3) PID_Y_D_ack.setColorBackground(col);
    break;
   case 5:
    if (PID_term==1) PID_Z_P_ack.setColorBackground(col);
    if (PID_term==2) PID_Z_I_ack.setColorBackground(col);
    if (PID_term==3) PID_Z_D_ack.setColorBackground(col);
    break;          
  }  
}


public void copyPID_parameters() {
  switch (PID_id) {
   case 1:
    PID_P.setText(PID_Xangle_P_ack.getText());
    PID_I.setText(PID_Xangle_I_ack.getText());
    PID_D.setText(PID_Xangle_D_ack.getText());
    break;
   case 2:
    PID_P.setText(PID_Yangle_P_ack.getText());
    PID_I.setText(PID_Yangle_I_ack.getText());
    PID_D.setText(PID_Yangle_D_ack.getText());
    break;
   case 3:
    PID_P.setText(PID_X_P_ack.getText());
    PID_I.setText(PID_X_I_ack.getText());
    PID_D.setText(PID_X_D_ack.getText());
    break;
   case 4:
    PID_P.setText(PID_Y_P_ack.getText());
    PID_I.setText(PID_Y_I_ack.getText());
    PID_D.setText(PID_Y_D_ack.getText());
    break;
   case 5:
    PID_P.setText(PID_Z_P_ack.getText());
    PID_I.setText(PID_Z_I_ack.getText());
    PID_D.setText(PID_Z_D_ack.getText());
    break;          
  }  
}
