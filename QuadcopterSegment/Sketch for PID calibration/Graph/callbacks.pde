public void CONNECT(int theValue) {
  if (millis()>10000)
  {
    arduino = new Serial(this, Serial.list()[COM_PORT_id], 115200);
    arduino.bufferUntil('\n');
  }
}


void controlEvent(ControlEvent theEvent) {
  if(theEvent.isAssignableFrom(Textfield.class)) {
    println("controlEvent: accessing a string from controller '"
            +theEvent.getName()+"': "
            +theEvent.getStringValue()
            );
  }  
  //println(theEvent.getName());
  
  if (theEvent.getName() == PID_select_label) {
    if(theEvent.isGroup()) {
      PID_id = (byte)theEvent.group().value();
    }
  }
  
  if (theEvent.getName() == PORT_select_label) {
    if(theEvent.isGroup()) {
      COM_PORT_id = (byte)theEvent.group().value();
    }
  }  
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

