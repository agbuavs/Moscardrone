//convert all axis
int minAngle = 0;
//int maxAngle = 1024; //debug potentiometer measurements
int maxAngle = 255; //debug bytes sent over RF

void convert() {   
  /* convert the x-axis */
  if (stringX != null) {
    // trim off any whitespace:
    stringX = trim(stringX);
    // convert to an float and map to the screen height, then save in buffer:    
    X[X.length-1] = map(float(stringX), minAngle, maxAngle, height, 0);
  }
  
  /* convert the y-axis */
  if (stringY != null) {    
    // trim off any whitespace:
    stringY = trim(stringY);
    // convert to an float and map to the screen height, then save in buffer:   
    Y[Y.length-1] = map(float(stringY), minAngle, maxAngle, height, 0);
  }
  
  /* convert the z-axis */
  if (stringZ != null) {    
    // trim off any whitespace:
    stringZ = trim(stringZ);
    // convert to an float and map to the screen height, then save in buffer:   
    Z[Z.length-1] = map(float(stringZ), minAngle, maxAngle, height, 0);
  }
  
  /* convert the throttle-axis */
  if (stringT != null) {    
    // trim off any whitespace:
    stringT = trim(stringT);
    // convert to an float and map to the screen height, then save in buffer:   
    T[T.length-1] = map(float(stringT), minAngle, maxAngle, height, 0);
  }
}
