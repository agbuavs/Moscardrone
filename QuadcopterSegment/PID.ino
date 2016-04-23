void initializePIDs() {
//Avoid strange behaviour when turning on
  
  //Inputs and setpoints start at hovering values  
  SetpointX_angle = 180;
  SetpointY_angle = 180;
  SetpointX = 0;
  SetpointY = 0;
  SetpointZ = 0;
  InputX_angle = 180;
  InputY_angle = 180;
  InputX = 0;
  InputY = 0;
  InputZ = 0;
  
  //Do not throttle on start
  OutputX_angle = 0;
  OutputY_angle = 0;
  OutputX = 0;
  OutputY = 0;
  OutputZ = 0;
  
  //Turn on PIDs
  PID_X_angle.SetMode(AUTOMATIC);
  PID_Y_angle.SetMode(AUTOMATIC);
  PID_X.SetMode(AUTOMATIC);
  PID_Y.SetMode(AUTOMATIC);
  PID_Z.SetMode(AUTOMATIC);
  
  //Constrain PID outputs to be within preconfigured limits
  PID_X_angle.SetOutputLimits(MIN_ANGLE_PID_OUTPUT,MAX_ANGLE_PID_OUTPUT);
  PID_Y_angle.SetOutputLimits(MIN_ANGLE_PID_OUTPUT,MAX_ANGLE_PID_OUTPUT);
  PID_X.SetOutputLimits(MIN_PWM_PID_OUTPUT,MAX_PWM_PID_OUTPUT);
  PID_Y.SetOutputLimits(MIN_PWM_PID_OUTPUT,MAX_PWM_PID_OUTPUT);
  PID_Z.SetOutputLimits(MIN_PWM_PID_OUTPUT,MAX_PWM_PID_OUTPUT);
  
  //Set arduino cycles elapsed between PID iterations
  //rate PIDs are set at 1 loop cycle per sample by default (PID library)
  PID_X_angle.SetLoopsPerSample(8);
  PID_Y_angle.SetLoopsPerSample(8);
  
  //SetSampleTime method is not used because I want the sample time to be the minimum (arduino cycle)
  /*
  PID_X_angle.SetSampleTime(PID_SAMPLETIME_ANGLE);
  PID_Y_angle.SetSampleTime(PID_SAMPLETIME_ANGLE);
  PID_X.SetSampleTime(PID_SAMPLETIME);
  PID_Y.SetSampleTime(PID_SAMPLETIME);
  PID_Z.SetSampleTime(PID_SAMPLETIME);
  */
  
  PID_X_angle.SetITerm(X_angle_ITerm);
  PID_Y_angle.SetITerm(Y_angle_ITerm);
  PID_X.SetITerm(X_ITerm);
  PID_Y.SetITerm(Y_ITerm);
  PID_Z.SetITerm(Z_ITerm);
}



void calibratePID(unsigned char PID_id, unsigned char PID_term, double value) {
  
  switch(PID_id) {
    case 1: //Pitch PID_angle tuning
      PID_X_angle.SetTuning(PID_term, value);
      break;
    case 2: //Roll PID_angle tuning
      PID_Y_angle.SetTuning(PID_term, value);
      break;
    case 3: //Pitch PID tuning
      PID_X.SetTuning(PID_term, value);
      break;
    case 4: //Roll PID tuning
      PID_Y.SetTuning(PID_term, value);
      break;
    case 5: //Yaw rate PID tuning
      PID_Z.SetTuning(PID_term, value);
      break;        
  }
}



int computeInputs() {
//Do necessary calculations on IMU data to get PIDs inputs
  
  /* variables to use
  INPUTS:
  double compAngleX, compAngleY
  double gyroXrate, gyroYrate, gyroZrate
  double gyroXoffset, gyroYoffset, gyroZoffset,
  OUTPUTS:
  double InputX_angle, InputY_angle, InputX, InputY, InputZ;
  */
 
  #ifndef KALMAN_FILTERING
    InputX_angle = compAngleX; //using Complementary filter
    InputY_angle = compAngleY;
  #else
    InputX_angle = kalAngleX; //using Kalman filter
    InputY_angle = kalAngleY;
  #endif
  InputX = gyroXrate_comp - gyroXoffset;
  InputY = gyroYrate_comp - gyroYoffset;
  InputZ = gyroZrate_comp - gyroZoffset;
  /*
  InputX = gyroXrate - gyroXoffset;
  InputY = gyroYrate - gyroYoffset;
  InputZ = gyroZrate - gyroZoffset;
  */
  return(0);
}



int computeSetpoints() {
//Do necessary calculations on received data to get PIDs setpoints
 
  /* variables to use
  INPUTS:
  int joy_x = 0;        // PITCH angle
  int joy_y = 0;        // ROLL angle 
  int joy_z = 0;        // YAW gyro rate
  OUTPUTS:
  double SetpointX, SetpointY, SetpointZ, SetpointX_angle, SetpointY_angle;
  */
  
  //Map values received from joystick (0 to 255) to defined angle margins
  if (joystickMode == JOY_MODE_RATE){
    SetpointX = map(joy_x, 0, 255, -LIMIT_GYRO_XY_RATE, LIMIT_GYRO_XY_RATE);
    SetpointY = map(joy_y, 0, 255, -LIMIT_GYRO_XY_RATE, LIMIT_GYRO_XY_RATE);
  }
  if (joystickMode == JOY_MODE_ANGLE){
    SetpointX_angle = map(joy_x, 0, 255, MIN_PITCH_ANGLE, MAX_PITCH_ANGLE);
    SetpointY_angle = map(joy_y, 0, 255, MIN_ROLL_ANGLE, MAX_ROLL_ANGLE);
    //SetpointX & SetpointY come from PID_X/Y_angle Outputs (see main loop)
  }
  SetpointZ = map(joy_z, 0, 255, -LIMIT_GYRO_Z_RATE, LIMIT_GYRO_Z_RATE);

  return(0);
}



int computeOutputs() {
//Do necessary calculations on PID outputs to get the 4 motor throttle values

  /* variables to use
  INPUTS:
  int joy_t;
  double OutputX, OutputY, OutputZ;
  OUTPUTS:
  int Mot1,Mot2,Mot3,Mot4;
  */
  
  float kX,kY,kZ;

  //adapt throttle input from joystick
  int meanT = map(joy_t, 0, 255, MIN_HORIZ_THROTTLE, MAX_HORIZ_THROTTLE);
  int correction = 1; // might be necessary to increase mean throttle to keep its vertical component constant
  meanT = meanT * correction;
  
  /* Distribute throttle
    X-Wing configuration    M4   M1       
                               X     
                            M3   M2 
  */
  #ifdef QUADX  
    kX = 0.45;
    kY = kX;
    kZ = 1 - 2*kX;
    Mot1 = meanT + kX*OutputX + kY*OutputY - kZ*OutputZ;
    Mot2 = meanT - kX*OutputX + kY*OutputY + kZ*OutputZ;
    Mot3 = meanT - kX*OutputX - kY*OutputY - kZ*OutputZ;
    Mot4 = meanT + kX*OutputX - kY*OutputY + kZ*OutputZ;
  #endif
  
  /* Distribute throttle
    P-Wing configuration      M1     
                           M4 + M2
                              M4
  */
  #ifdef QUADP
    kX = 0.9;
    kY = kX;
    kZ = 1 - kX;
    Mot1 = meanT + kX*OutputX - kZ*OutputZ;
    Mot2 = meanT + kY*OutputY + kZ*OutputZ;
    Mot3 = meanT - kX*OutputX - kZ*OutputZ;
    Mot4 = meanT - kY*OutputY + kZ*OutputZ;   
  #endif 
  
  return(0);
}




void printPIDvalues() {
  
  Serial.print(InputX_angle); Serial.print("\t");
  Serial.print(InputY_angle); Serial.print("\t");
  Serial.print(InputX); Serial.print("\t");
  Serial.print(InputY); Serial.print("\t");
  Serial.print(InputZ); Serial.print("\t"); 
  
  Serial.print(SetpointX_angle); Serial.print("\t");
  Serial.print(SetpointY_angle); Serial.print("\t");
  Serial.print(SetpointX); Serial.print("\t");
  Serial.print(SetpointY); Serial.print("\t");
  Serial.print(SetpointZ); Serial.print("\t"); 
  
  Serial.print(OutputX_angle); Serial.print("\t");
  Serial.print(OutputY_angle); Serial.print("\t");
  Serial.print(OutputX); Serial.print("\t");
  Serial.print(OutputY); Serial.print("\t");
  Serial.print(OutputZ); Serial.print("\t"); 
  
  Serial.print(PID_X_angle.GetITerm()); Serial.print("\t");
  Serial.print(PID_Y_angle.GetITerm()); Serial.print("\t");
  Serial.print(PID_X.GetITerm()); Serial.print("\t");
  Serial.print(PID_Y.GetITerm()); Serial.print("\t");
  Serial.print(PID_Z.GetITerm()); Serial.print("\t");
  
  Serial.print(Mot1); Serial.print("\t");
  Serial.print(Mot2); Serial.print("\t");
  Serial.print(Mot3); Serial.print("\t");        
  Serial.print(Mot4); Serial.print("\t");
  
  Serial.print(time_current_loop - time_last_loop); Serial.print("\t");
    
  Serial.print("\r\n"); 
  
}
