byte[] floatArrayToByteArray(float[] input)
{
  int len = 4*input.length;
  int index=0;
  byte[] b = new byte[4];
  byte[] out = new byte[len];
  ByteBuffer buf = ByteBuffer.wrap(b);
  for(int i=0;i<input.length;i++) 
  {
    buf.position(0);
    buf.putFloat(input[i]);
    for(int j=0;j<4;j++) out[j+i*4]=b[3-j];
  }
  return out;
}


byte[] floatToByteArray(float input)
{
  int len = 4;
  int index=0;
  byte[] b = new byte[4];
  byte[] out = new byte[len];
  
  ByteBuffer buf = ByteBuffer.wrap(b);  
  buf.position(0);
  buf.putFloat(input);
  
  for(int j=0;j<4;j++) out[j]=b[3-j];
  
  return out;
}

