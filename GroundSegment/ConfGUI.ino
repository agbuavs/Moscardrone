/*
  This file contains functions to communicate over serial with ConfGUI (Processing sketch)
  
  Its main purpose is to receive PID parameters from a Graphical User Interface, making
  PID calibration much easier.
  
  The plan is to design it in a way that this functionality can be included both 
  at the Quadcopter (first calibrations) and at the GroundSegment (calibration on the air).
  For the latter option, some adjustments shall be made in the data link functions.
*/


void receiveDataFromGUI() {
  
  union {                // This Data structure lets
    byte asBytes[4];     // us take the byte array
    float asFloat;       // sent from processing and
  }                      // easily convert it to a
  foo;                   // float array
  byte PID_id;
  byte PID_term;
  
  PID_id = Serial.read();   // angleX, angleY, rateX, rateY or rateZ
  PID_term = Serial.read(); // P, I or D ? 
  foo.asBytes[0] = Serial.read();
  foo.asBytes[1] = Serial.read();
  foo.asBytes[2] = Serial.read();
  foo.asBytes[3] = Serial.read();
  Serial.flush();
  
  sendAckToGUI(PID_id, PID_term, foo.asFloat);
  
  lastGUIpacket = millis();
  
}


void sendAckToGUI(byte id, byte term, float value) {
  Serial.print(id);
  Serial.print(" ");
  Serial.print(term);
  Serial.print(" ");
  Serial.println(value);
}

