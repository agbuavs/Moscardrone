void readPotValues() {
  joy_x = analogRead(A0);
  joy_y = analogRead(A1);
  joy_z = analogRead(A2);
  joy_t = analogRead(A3);
}



int calibrateJoystick () {
  
 //Update maximum levels
 if (joy_x_max < joy_x)
   joy_x_max = joy_x;
 if (joy_y_max < joy_y)
   joy_y_max = joy_y;
 if (joy_z_max < joy_z)
   joy_z_max = joy_z;
 if (joy_t_max < joy_t)
   joy_t_max = joy_t;

 //Update minimum levels
 if (joy_x_min > joy_x)
   joy_x_min = joy_x;
 if (joy_y_min > joy_y)
   joy_y_min = joy_y;
 if (joy_z_min > joy_z)
   joy_z_min = joy_z;
 if (joy_t_min > joy_t)
   joy_t_min = joy_t;
 
 //Calibration done?
 if ((joy_x_max - joy_x_min > MIN_RANGE_TO_CALIBRATE) && (joy_y_max - joy_y_min > MIN_RANGE_TO_CALIBRATE) && (joy_z_max - joy_z_min > MIN_RANGE_TO_CALIBRATE) && (joy_t_max - joy_t_min > MIN_RANGE_TO_CALIBRATE))
 {
   JOY_calibrated = 1;
   analogWrite(LED_CALIBRATE_OK,255);
 }
 else
   analogWrite(LED_CALIBRATE_OK,0);
 
 return(0);
}



void transformJoystickValues() {
   
  if ( abs( joy_x - (joy_x_max + joy_x_min)/2 ) < MIN_JOY_DETECTABLE_SHIFT ) joy_x = (joy_x_max + joy_x_min)/2;
  else {
   if (joy_x > (joy_x_max + joy_x_min)/2) joy_x = joy_x - MIN_JOY_DETECTABLE_SHIFT;
   if (joy_x < (joy_x_max + joy_x_min)/2) joy_x = joy_x + MIN_JOY_DETECTABLE_SHIFT;
  }
  if ( abs( joy_y - (joy_y_max + joy_y_min)/2 ) < MIN_JOY_DETECTABLE_SHIFT ) joy_y = (joy_y_max + joy_y_min)/2;
  else {
   if (joy_y > (joy_y_max + joy_y_min)/2) joy_y = joy_y - MIN_JOY_DETECTABLE_SHIFT;
   if (joy_y < (joy_y_max + joy_y_min)/2) joy_y = joy_y + MIN_JOY_DETECTABLE_SHIFT;
  }
  if ( abs( joy_z - (joy_z_max + joy_z_min)/2 ) < MIN_JOY_DETECTABLE_SHIFT ) joy_z = (joy_z_max + joy_z_min)/2;
  else {
   if (joy_z > (joy_z_max + joy_z_min)/2) joy_z = joy_z - MIN_JOY_DETECTABLE_SHIFT;
   if (joy_z < (joy_z_max + joy_z_min)/2) joy_z = joy_z + MIN_JOY_DETECTABLE_SHIFT;
  }
}
