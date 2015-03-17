void drawAxis() {
  /* draw x-axis */
  noFill();
  stroke(255,0,0); //red
  // redraw everything
  beginShape();
  for(int i = 0; i<X.length;i++)
    vertex(i,graphYpos+X[i]);
  endShape();
  // put all data one array back
  for(int i = 1; i<X.length;i++)
    X[i-1] = X[i];  
    
  /* draw y-axis */
  noFill();
  stroke(0,255,0); // green
  // redraw everything
  beginShape();
  for(int i = 0; i<Y.length;i++)
    vertex(i,graphYpos+Y[i]);
  endShape();
  // put all data one array back
  for(int i = 1; i<Y.length;i++)
   Y[i-1] = Y[i];   
   
    
  /* draw y-axis */
  noFill();
  stroke(0,0,255); // blue
  // redraw everything
  beginShape();
  for(int i = 0; i<Z.length;i++)
    vertex(i,graphYpos+Z[i]);
  endShape();
  // put all data one array back
  for(int i = 1; i<Z.length;i++)
   Z[i-1] = Z[i];    
   
   
  /* draw throttel-axis */
  noFill();
  stroke(255,255,255); // white
  // redraw everything
  beginShape();
  for(int i = 0; i<T.length;i++)
    vertex(i,graphYpos+T[i]);
  endShape();
  // put all data one array back
  for(int i = 1; i<T.length;i++)
   T[i-1] = T[i]; 
}
