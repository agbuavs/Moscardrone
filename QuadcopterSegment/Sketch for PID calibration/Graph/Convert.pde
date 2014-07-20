//convert all axis
/*
int minAngle = 0;
int maxAngle = 360;  // quad hover horizontal position is at 180º
int maxRate = 250;   // Not found yet a maximum gyro rate
*/

void convert(String stringx,float[] x, int min, int max) {   

  /* convert the gyro x-axis */
  if (stringx != null) {
    // trim off any whitespace:
    stringx = trim(stringx);
    // convert to an float and map to the screen height, then save in buffer:    
    x[x.length-1] = map(float(stringx), min, max, 0, HEIGHT_GRAPH);
    
    // put all data one array back
    for(int i = 1; i<x.length;i++)
      x[i-1] = x[i]; 
  }
}
