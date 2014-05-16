//convert all axis
int minAngle = 0;
int maxAngle = 360;  // quad hover horizontal position is at 180º
int maxRate = 250;   // Not found yet a maximum gyro rate

void convert() {   

  /* convert the gyro x-axis */
  if (stringGyroX != null) {
    // trim off any whitespace:
    stringGyroX = trim(stringGyroX);
    // convert to an float and map to the screen height, then save in buffer:    
    gyroX[gyroX.length-1] = map(float(stringGyroX), minAngle, maxAngle, 0, height);
  }
  
  /* convert the gyro y-axis */
  if (stringGyroY != null) {    
    // trim off any whitespace:
    stringGyroY = trim(stringGyroY);
    // convert to an float and map to the screen height, then save in buffer:   
    gyroY[gyroY.length-1] = map(float(stringGyroY), minAngle, maxAngle, 0, height);
  }
  
  /* convert the gyro z-axis */
  if (stringGyroZ != null) {    
    // trim off any whitespace:
    stringGyroZ = trim(stringGyroZ);
    // convert to an float and map to the screen height, then save in buffer:   
    gyroZ[gyroZ.length-1] = map(float(stringGyroZ), minAngle, maxAngle, 0, height);
  }
   


  /* convert the accelerometer x-axis */
  if (stringAccX != null) {
    // trim off any whitespace:
    stringAccX = trim(stringAccX);
    // convert to an float and map to the screen height, then save in buffer:    
    accX[accX.length-1] = map(float(stringAccX), minAngle, maxAngle, 0, height);
  }
  
  /* convert the accelerometer y-axis */
  if (stringAccY != null) {
    // trim off any whitespace:
    stringAccY = trim(stringAccY);
    // convert to an float and map to the screen height, then save in buffer:        
    accY[accY.length-1] = map(float(stringAccY), minAngle, maxAngle, 0, height);
  }
 
  /* convert the accelerometer z-axis */
  if (stringAccZ != null) {
    // trim off any whitespace:
    stringAccZ = trim(stringAccZ);
    // convert to an float and map to the screen height, then save in buffer:        
    accZ[accZ.length-1] = map(float(stringAccZ), minAngle, maxAngle, 0, height);
  }
  


  /* convert the complementary filter x-axis */
  if (stringCompX != null) {
    // trim off any whitespace:
    stringCompX = trim(stringCompX);
    // convert to an float and map to the screen height, then save in buffer:    
    compX[compX.length-1] = map(float(stringCompX), minAngle, maxAngle, 0, height);
  }
  
  /* convert the complementary filter x-axis */
  if (stringCompY != null) {
    // trim off any whitespace:
    stringCompY = trim(stringCompY);
    // convert to an float and map to the screen height, then save in buffer:    
    compY[compY.length-1] = map(float(stringCompY), minAngle, maxAngle, 0, height);
  }
  
  /* convert the complementary filter z-axis */
  if (stringCompZ != null) {
    // trim off any whitespace:
    stringCompZ = trim(stringCompZ);
    // convert to an float and map to the screen height, then save in buffer:    
    compZ[compZ.length-1] = map(float(stringCompZ), minAngle, maxAngle, 0, height);
  }
  
  

  /* convert the kalman filter x-axis */
  if (stringKalmanX != null) {
    // trim off any whitespace:
    stringKalmanX = trim(stringKalmanX);
    // convert to an float and map to the screen height, then save in buffer:    
    kalmanX[kalmanX.length-1] = map(float(stringKalmanX), minAngle, maxAngle, 0, height);
  }
  
  /* convert the kalman filter y-axis */
  if (stringKalmanY != null) {
    // trim off any whitespace:
    stringKalmanY = trim(stringKalmanY);
    // convert to an float and map to the screen height, then save in buffer:    
    kalmanY[kalmanY.length-1] = map(float(stringKalmanY), minAngle, maxAngle, 0, height);
  }

  /* convert the kalman filter z-axis */
  if (stringKalmanZ != null) {
    // trim off any whitespace:
    stringKalmanZ = trim(stringKalmanZ);
    // convert to an float and map to the screen height, then save in buffer:    
    kalmanZ[kalmanZ.length-1] = map(float(stringKalmanZ), minAngle, maxAngle, 0, height);
  }
  
 
  
  /* convert the gyro x-axis change rate */
  if (stringGyroRateX != null) {    
    // trim off any whitespace:
    stringGyroRateX = trim(stringGyroRateX);
    // convert to an float and map to the screen height, then save in buffer:   
    gyroRateX[gyroRateX.length-1] = map(float(stringGyroRateX), -maxRate, maxRate, 0, height);
  }
  
  /* convert the gyro y-axis change rate */
  if (stringGyroRateY != null) {    
    // trim off any whitespace:
    stringGyroRateY = trim(stringGyroRateY);
    // convert to an float and map to the screen height, then save in buffer:   
    gyroRateY[gyroRateY.length-1] = map(float(stringGyroRateY), -maxRate, maxRate, 0, height);
  }  
    
  /* convert the gyro z-axis change rate */
  if (stringGyroRateZ != null) {    
    // trim off any whitespace:
    stringGyroRateZ = trim(stringGyroRateZ);
    // convert to an float and map to the screen height, then save in buffer:   
    gyroRateZ[gyroRateZ.length-1] = map(float(stringGyroRateZ), -maxRate, maxRate, 0, height);
  }
}
