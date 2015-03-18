/*
  This file contains functions to communicate over serial with ConfGUI (Processing sketch)
  
  Its main purpose is to receive PID parameters from a Graphical User Interface, making
  PID calibration much easier.
  
  The plan is to design it in a way that this functionality can be included both 
  at the Quadcopter (first calibrations) and at the GroundSegment (calibration on the air).
  For the latter option, some adjustments shall be made in the data link functions.
*/

/************************ Definitions *********************/
//Define types of messages between ConfGUI and Arduino
#define PT_PID_CHANGE 100
#define PT_JOY_MODE 101

byte PT = 0; //Packet Type. It gets a new value every time GS receives a msg from ConfGUI.

#ifndef GUI_CONF_OVER_RF //Compile if ConfGUI is used to calibrate PIDs. 

/************************* Functions **********************/
void receiveDataFromGUI() {
  
  //There will be several types of messages
  PT = Serial.read();
  switch (PT) {
    case PT_PID_CHANGE:
      PID_id = Serial.read();   // angleX, angleY, rateX, rateY or rateZ
      PID_term = Serial.read(); // P, I or D ? 
      PID_value.asBytes[0] = Serial.read();
      PID_value.asBytes[1] = Serial.read();
      PID_value.asBytes[2] = Serial.read();
      PID_value.asBytes[3] = Serial.read();
      //sendAckToGUI(PID_id,PID_term,PID_value.asFloat); //(used to test comms without quad
      break;
    case PT_JOY_MODE:
      addMSG_type = PT_JOY_MODE;
      addMSG_data = Serial.read();
      break;
  }
  Serial.flush();  
  
  //This piece of code doesn't exist in Ground Segment code.............
  calibratePID(PID_id, PID_term, PID_value.asDouble);
  double val = 0;
  switch(PID_id) {
    case 1:
      val = PID_X_angle.GetValue(PID_term);
      break;
    case 2:
      val = PID_Y_angle.GetValue(PID_term);
      break;
    case 3:
      val = PID_X.GetValue(PID_term);
      break;
    case 4:
      val = PID_Y.GetValue(PID_term);
      break;
    case 5:
      val = PID_Z.GetValue(PID_term);
      break;
  }
  sendAckToGUI(PID_id, PID_term, val);
  //....................................................................
  
  lastGUIpacket = millis();
  
}


void sendAckToGUI(byte id, byte term, float value) {
  Serial.print(id);
  Serial.print(" ");
  Serial.print(term);
  Serial.print(" ");
  Serial.print(value,4);
  Serial.print(" // ");
  Serial.print(addMSG_type);
  Serial.print(" ");
  Serial.println(addMSG_data);
}


#endif
