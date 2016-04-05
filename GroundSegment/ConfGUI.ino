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
#define PT_JOY_CAL_SAVE 102
#define PT_JOY_CAL_CLEAR 103
#define PT_PID_CAL_SAVE 104
#define PT_PID_CAL_CLEAR 105
#define PT_ABORT 106

byte PT = 0; //Packet Type. It gets a new value every time GS receives a msg from ConfGUI.


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
      //sendAckToGUI(PID_id,PID_term,PID_value.asFloat); //(used to test comms without quadcopter)
      break;
      
    case PT_JOY_MODE:
      addMSG_type = PT_JOY_MODE;
      addMSG_data = Serial.read();
      break;
      
    case PT_JOY_CAL_SAVE:
      ROMsaveJoystickCalibration();
      break;
      
    case PT_JOY_CAL_CLEAR:
      ROMclearJoystickCalibration();
      break;
      
    case PT_PID_CAL_SAVE:
      addMSG_type = PT_PID_CAL_SAVE;
      break;
      
    case PT_PID_CAL_CLEAR:
      addMSG_type = PT_PID_CAL_CLEAR;
      break;
      
    case PT_ABORT:
      addMSG_type = PT_ABORT;
      break;
  }
  Serial.flush();  
  
  lastGUIpacket = millis(); 
}


void sendAckToGUI(byte id, byte term, float value) {
  
  Serial.print(id);     Serial.print(" ");
  Serial.print(term);   Serial.print(" ");
  Serial.print(value,4); 
  Serial.print(" ");
  Serial.print(addMSG_type_ACK);
  Serial.print(" ");
  Serial.print(addMSG_data_ACK);
  Serial.println(" ");
}


void send4ValuesToGUI(byte x, byte y, byte z, byte t) {
  
  Serial.print("10"); Serial.print(" ");    
  Serial.print(x); Serial.print(" ");        
  Serial.print(y); Serial.print(" ");
  Serial.print(z); Serial.print(" ");
  Serial.print(t); Serial.println(" ");  
}
