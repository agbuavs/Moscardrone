void drawX(float[] x, int[] col) {
  
  /* draw ax vector */
  noFill();
  stroke(col[0], col[1], col[2]);
  // redraw everything
  beginShape();
  for(int i = 0; i<x.length;i++)
    vertex(i,x[i]);
  endShape();
  // put all data one array back
  for(int i = 1; i<x.length;i++)
    x[i-1] = x[i]; 

}
