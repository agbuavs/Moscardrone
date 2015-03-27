/* 
  ROM functions:

  ROMsavePIDCalibration:
    - saves global variables to ROM in the defined addresses
    
  ROMclearPIDCalibration():
   - deletes values stored in ROM
   
  PIDPreviouslyCalibrated():
   - Checks if there are any values to load upon system start-up
    
  ROMloadPIDCalibration: 
    - loads global variables from the defined ROM addresses

*/  


//Addresses (bytes)
#define DIR_PID_IS_CAL 10
#define DIR_PID_X_angle 12
#define DIR_PID_X_angle_P 12
#define DIR_PID_X_angle_I 16
#define DIR_PID_X_angle_D 20
#define DIR_PID_Y_angle 24
#define DIR_PID_Y_angle_P 24
#define DIR_PID_Y_angle_I 28
#define DIR_PID_Y_angle_D 32
#define DIR_PID_X 36
#define DIR_PID_X_P 36
#define DIR_PID_X_I 40
#define DIR_PID_X_D 44
#define DIR_PID_Y 48
#define DIR_PID_Y_P 48
#define DIR_PID_Y_I 52
#define DIR_PID_Y_D 56
#define DIR_PID_Z 60
#define DIR_PID_Z_P 60
#define DIR_PID_Z_I 64
#define DIR_PID_Z_D 68


int ROMsavePIDCalibration() {
  int i = 0;
  for (i = 1; i<4; i++) {
    double_byte.asDouble = PID_X_angle.GetValue(i);
    EEPROM.write(DIR_PID_X_angle + 4*(i-1) + 0, double_byte.asBytes[0]);
    EEPROM.write(DIR_PID_X_angle + 4*(i-1) + 1, double_byte.asBytes[1]);
    EEPROM.write(DIR_PID_X_angle + 4*(i-1) + 2, double_byte.asBytes[2]);
    EEPROM.write(DIR_PID_X_angle + 4*(i-1) + 3, double_byte.asBytes[3]);
  }  
  for (i = 1; i<4; i++) {
    double_byte.asDouble = PID_Y_angle.GetValue(i);
    EEPROM.write(DIR_PID_Y_angle + 4*(i-1) + 0, double_byte.asBytes[0]);
    EEPROM.write(DIR_PID_Y_angle + 4*(i-1) + 1, double_byte.asBytes[1]);
    EEPROM.write(DIR_PID_Y_angle + 4*(i-1) + 2, double_byte.asBytes[2]);
    EEPROM.write(DIR_PID_Y_angle + 4*(i-1) + 3, double_byte.asBytes[3]);
  }  
  for (i = 1; i<4; i++) {
    double_byte.asDouble = PID_X.GetValue(i);
    EEPROM.write(DIR_PID_X + 4*(i-1) + 0, double_byte.asBytes[0]);
    EEPROM.write(DIR_PID_X + 4*(i-1) + 1, double_byte.asBytes[1]);
    EEPROM.write(DIR_PID_X + 4*(i-1) + 2, double_byte.asBytes[2]);
    EEPROM.write(DIR_PID_X + 4*(i-1) + 3, double_byte.asBytes[3]);
  }  
  for (i = 1; i<4; i++) {
    double_byte.asDouble = PID_Y.GetValue(i);
    EEPROM.write(DIR_PID_Y + 4*(i-1) + 0, double_byte.asBytes[0]);
    EEPROM.write(DIR_PID_Y + 4*(i-1) + 1, double_byte.asBytes[1]);
    EEPROM.write(DIR_PID_Y + 4*(i-1) + 2, double_byte.asBytes[2]);
    EEPROM.write(DIR_PID_Y + 4*(i-1) + 3, double_byte.asBytes[3]);
  }  
  for (i = 1; i<4; i++) {
    double_byte.asDouble = PID_Z.GetValue(i);
    EEPROM.write(DIR_PID_Z + 4*(i-1) + 0, double_byte.asBytes[0]);
    EEPROM.write(DIR_PID_Z + 4*(i-1) + 1, double_byte.asBytes[1]);
    EEPROM.write(DIR_PID_Z + 4*(i-1) + 2, double_byte.asBytes[2]);
    EEPROM.write(DIR_PID_Z + 4*(i-1) + 3, double_byte.asBytes[3]);
  }

  EEPROM.write(DIR_PID_IS_CAL, PID_IS_CAL);
  
  return(0);
}

int ROMclearPIDCalibration() {
 
  EEPROM.write(DIR_PID_IS_CAL, 0); 
  return(0); 
}


int PIDPreviouslyCalibrated() {
 
  return (EEPROM.read(DIR_PID_IS_CAL));
}


int ROMloadPIDCalibration() {
  int i = 0;
  for (i = 1; i<4; i++) {
    double_byte.asBytes[0] = EEPROM.read(DIR_PID_X_angle + 4*(i-1) + 0);
    double_byte.asBytes[1] = EEPROM.read(DIR_PID_X_angle + 4*(i-1) + 1);
    double_byte.asBytes[2] = EEPROM.read(DIR_PID_X_angle + 4*(i-1) + 2);
    double_byte.asBytes[3] = EEPROM.read(DIR_PID_X_angle + 4*(i-1) + 3);
    PID_X_angle.SetTuning(i, double_byte.asDouble);
  }  
  for (i = 1; i<4; i++) {
    double_byte.asBytes[0] = EEPROM.read(DIR_PID_Y_angle + 4*(i-1) + 0);
    double_byte.asBytes[1] = EEPROM.read(DIR_PID_Y_angle + 4*(i-1) + 1);
    double_byte.asBytes[2] = EEPROM.read(DIR_PID_Y_angle + 4*(i-1) + 2);
    double_byte.asBytes[3] = EEPROM.read(DIR_PID_Y_angle + 4*(i-1) + 3);
    PID_Y_angle.SetTuning(i, double_byte.asDouble);
  } 
  for (i = 1; i<4; i++) {
    double_byte.asBytes[0] = EEPROM.read(DIR_PID_X + 4*(i-1) + 0);
    double_byte.asBytes[1] = EEPROM.read(DIR_PID_X + 4*(i-1) + 1);
    double_byte.asBytes[2] = EEPROM.read(DIR_PID_X + 4*(i-1) + 2);
    double_byte.asBytes[3] = EEPROM.read(DIR_PID_X + 4*(i-1) + 3);
    PID_X.SetTuning(i, double_byte.asDouble);
  }  
  for (i = 1; i<4; i++) {
    double_byte.asBytes[0] = EEPROM.read(DIR_PID_Y + 4*(i-1) + 0);
    double_byte.asBytes[1] = EEPROM.read(DIR_PID_Y + 4*(i-1) + 1);
    double_byte.asBytes[2] = EEPROM.read(DIR_PID_Y + 4*(i-1) + 2);
    double_byte.asBytes[3] = EEPROM.read(DIR_PID_Y + 4*(i-1) + 3);
    PID_Y.SetTuning(i, double_byte.asDouble);
  }  
  for (i = 1; i<4; i++) {
    double_byte.asBytes[0] = EEPROM.read(DIR_PID_Z + 4*(i-1) + 0);
    double_byte.asBytes[1] = EEPROM.read(DIR_PID_Z + 4*(i-1) + 1);
    double_byte.asBytes[2] = EEPROM.read(DIR_PID_Z + 4*(i-1) + 2);
    double_byte.asBytes[3] = EEPROM.read(DIR_PID_Z + 4*(i-1) + 3);
    PID_Z.SetTuning(i, double_byte.asDouble);
  }  

  return(0);
}

