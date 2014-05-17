/*
  This file contains functions to communicate over serial with ConfGUI (Processing sketch)
  
  Its main purpose is to receive PID parameters from a Graphical User Interface, making
  PID calibration much easier.
  
  The plan is to design it in a way that this functionality can be included both 
  at the Quadcopter (first calibrations) and at the GroundSegment (calibration on the air).
  For the latter option, some adjustments shall be made in the data link functions.
*/


void receiveDataFromGUI() {
  
  PID_id = Serial.read();   // angleX, angleY, rateX, rateY or rateZ
  PID_term = Serial.read(); // P, I or D ? 
  PID_value.asBytes[0] = Serial.read();
  PID_value.asBytes[1] = Serial.read();
  PID_value.asBytes[2] = Serial.read();
  PID_value.asBytes[3] = Serial.read();
  Serial.flush();
  
  lastGUIpacket = millis();
  
  //sendAckToGUI(PID_id,PID_term,PID_value.asFloat);
  
}


void sendAckToGUI(byte id, byte term, float value) {
  Serial.print(id);
  Serial.print(" ");
  Serial.print(term);
  Serial.print(" ");
  Serial.println(value,4);
}

