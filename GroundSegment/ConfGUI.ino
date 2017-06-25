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
#define PT_PID_AUTOTEST_SET 107
#define PT_PID_AUTOTEST_MODE 108

byte PT = 0; //Packet Type. It gets a new value every time GS receives a msg from ConfGUI.
int rowCount = 0; //Used to know the number of rows of an autotest definition file.

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
      //forwardAckToGUI(PID_id,PID_term,PID_value.asFloat); //(used to test comms without quadcopter)
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
    
    case PT_PID_AUTOTEST_SET:
      rowCount = Serial.read();
      for (int i = 0; i < rowCount; i++) {
         csvTable[i][0] =  Serial.read();
         csvTable[i][1] =  Serial.read();
         csvTable[i][2] =  Serial.read();
      }
      autoTest_start = millis();
      autoTest_step = 0;
      autoTest_on = 1;
      sendAckToGUI(PT_PID_AUTOTEST_MODE, autoTest_on);
      break;
      
    case PT_PID_AUTOTEST_MODE:
      autoTest_on = Serial.read();
      sendAckToGUI(PT_PID_AUTOTEST_MODE, autoTest_on);
      break;
  }    
  Serial.flush();   
  lastGUIpacket = millis(); 
}


void sendAckToGUI (int ack_type, int ack_data) {
  Serial.print(ack_type);   Serial.print(" ");
  Serial.print(ack_data); 
  Serial.println(" ");
}


void forwardAckToGUI(byte id, byte term, float value) {
  
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
