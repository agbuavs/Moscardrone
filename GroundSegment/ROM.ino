/* 
  ROMk functions:
  
  ROMsaveJoystickCalibration: 
    - loads global variables from the defined ROM addresses
  
  ROMsaveJoystickCalibration:
    - saves global variables to ROM in the defined addresses
*/  


//Addresses
#define DIR_JOY_IS_CAL 10
#define DIR_JOY_X_MAX 11
#define DIR_JOY_Y_MAX 12
#define DIR_JOY_Z_MAX 13
#define DIR_JOY_T_MAX 14
#define DIR_JOY_X_MIN 15
#define DIR_JOY_Y_MIN 16
#define DIR_JOY_Z_MIN 17
#define DIR_JOY_T_MIN 18


int ROMsaveJoystickCalibration() {
  
  EEPROM.write(DIR_JOY_X_MAX, joy_x_max/4);
  EEPROM.write(DIR_JOY_Y_MAX, joy_y_max/4);
  EEPROM.write(DIR_JOY_Z_MAX, joy_z_max/4);
  EEPROM.write(DIR_JOY_T_MAX, joy_t_max/4);
  EEPROM.write(DIR_JOY_X_MIN, joy_x_min);
  EEPROM.write(DIR_JOY_Y_MIN, joy_y_min);
  EEPROM.write(DIR_JOY_Z_MIN, joy_z_min);
  EEPROM.write(DIR_JOY_T_MIN, joy_t_min);
  EEPROM.write(DIR_JOY_IS_CAL, JOY_IS_CAL);
  
  return(0);
}

int ROMclearJoystickCalibration() {
 
  EEPROM.write(DIR_JOY_IS_CAL, 0); 
  JOY_calibrated = 0;
  joy_x_max = 0;
  joy_y_max = 0;
  joy_z_max = 0;
  joy_t_max = 0;
  joy_x_min = 1024;
  joy_y_min = 1024;
  joy_z_min = 1024;
  joy_t_min = 1024;
  analogWrite(LED_CALIBRATE_OK,0);
  
  return(0); 
}


int JoystickPreviouslyCalibrated() {
 
  return (EEPROM.read(DIR_JOY_IS_CAL));
}


int ROMloadJoystickCalibration() {
  
  joy_x_max = 4*EEPROM.read(DIR_JOY_X_MAX);
  joy_y_max = 4*EEPROM.read(DIR_JOY_Y_MAX);
  joy_z_max = 4*EEPROM.read(DIR_JOY_Z_MAX);
  joy_t_max = 4*EEPROM.read(DIR_JOY_T_MAX);
  joy_x_min = EEPROM.read(DIR_JOY_X_MIN);
  joy_y_min = EEPROM.read(DIR_JOY_Y_MIN);
  joy_z_min = EEPROM.read(DIR_JOY_Z_MIN);
  joy_t_min = EEPROM.read(DIR_JOY_T_MIN);
  
  return(0);
}


