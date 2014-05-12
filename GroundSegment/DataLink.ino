/* 
  Data Link functions:
  
  receiveData: 
    - reads message from nRF24l01 buffer when something is available
    - udpdates Telemetry data from Quadcopter segment
   
  sendData:
    - sends payload, taking care of timing restrictions (in order to avoid channel saturation)
  
  prepareDataToGroundSegment:
    - prepares command data to send with sendData(). You shall modify receiveData() in Quadcopter
      code if you change something here and want to keep communications under control.
*/  


/************************ Receive *************************/
int receiveData(byte* data) {
//Check if rf24l has something to deliver. Return sequence number to verify communications.

  int nseq_rx = 0;
  double InputX_angle,InputY_angle,InputX,InputY,InputZ;
  double OutputX_angle,OutputY_angle,OutputX,OutputY,OutputZ;
  double Mot1,Mot2,Mot3,Mot4;
  
  if(!Mirf.isSending() && Mirf.dataReady()){

    Mirf.getData(data);
    RX_packets++;
    nseq_rx = data[1];
    
    InputX_angle = map((double)data[2],0,255,0,360);
    InputY_angle = map((double)data[3],0,255,0,360);
    InputX = map((double)data[4],0,255,-MAX_ABS_GYRO_RATE,MAX_ABS_GYRO_RATE);
    InputY = map((double)data[5],0,255,-MAX_ABS_GYRO_RATE,MAX_ABS_GYRO_RATE);
    InputZ = map((double)data[6],0,255,-MAX_ABS_GYRO_RATE,MAX_ABS_GYRO_RATE);
    
    OutputX_angle = map((double)data[7],0,255,MIN_ANGLE_PID_OUTPUT,MAX_ANGLE_PID_OUTPUT);
    OutputY_angle = map((double)data[8],0,255,MIN_ANGLE_PID_OUTPUT,MAX_ANGLE_PID_OUTPUT);
    OutputX = map((double)data[9],0,255,MIN_PWM_PID_OUTPUT,MAX_PWM_PID_OUTPUT);
    OutputY = map((double)data[10],0,255,MIN_PWM_PID_OUTPUT,MAX_PWM_PID_OUTPUT);
    OutputZ = map((double)data[11],0,255,MIN_PWM_PID_OUTPUT,MAX_PWM_PID_OUTPUT);    
    
    Mot1 = MIN_PWM_THROTTLE + ((double)(data[12])*(MAX_PWM_THROTTLE - MIN_PWM_THROTTLE)/256);
    Mot2 = MIN_PWM_THROTTLE + ((double)(data[13])*(MAX_PWM_THROTTLE - MIN_PWM_THROTTLE)/256);
    Mot3 = MIN_PWM_THROTTLE + ((double)(data[14])*(MAX_PWM_THROTTLE - MIN_PWM_THROTTLE)/256);
    Mot4 = MIN_PWM_THROTTLE + ((double)(data[15])*(MAX_PWM_THROTTLE - MIN_PWM_THROTTLE)/256);
    
    #ifdef GUI_CONF
    
    PID_id_ACK = data[16];
    PID_term_ACK = data[17];
    switch (PID_id_ACK) {
      case 1: //Pitch PID_angle tuning
        PID_value_ACK.asBytes[0] = data[18];
        PID_value_ACK.asBytes[1] = data[19];
        PID_value_ACK.asBytes[2] = data[20];
        PID_value_ACK.asBytes[3] = data[21];
        sendAckToGUI(PID_id_ACK, PID_term_ACK, (float)PID_value_ACK.asDouble);
        break;
      case 2: //Roll PID_angle tuning
        PID_value_ACK.asBytes[0] = data[18];
        PID_value_ACK.asBytes[1] = data[19];
        PID_value_ACK.asBytes[2] = data[20];
        PID_value_ACK.asBytes[3] = data[21];
        sendAckToGUI(PID_id_ACK, PID_term_ACK, (float)PID_value_ACK.asDouble);
        break;
      case 3: //Pitch rate PID tuning
        PID_value_ACK.asBytes[0] = data[18];
        PID_value_ACK.asBytes[1] = data[19];
        PID_value_ACK.asBytes[2] = data[20];
        PID_value_ACK.asBytes[3] = data[21];
        sendAckToGUI(PID_id_ACK, PID_term_ACK, (float)PID_value_ACK.asDouble);
        break;
      case 4: //Roll rate PID tuning
        PID_value_ACK.asBytes[0] = data[18];
        PID_value_ACK.asBytes[1] = data[19];
        PID_value_ACK.asBytes[2] = data[20];
        PID_value_ACK.asBytes[3] = data[21];
        sendAckToGUI(PID_id_ACK, PID_term_ACK, (float)PID_value_ACK.asDouble);
        break;
      case 5: //Yaw rate PID tuning
        PID_value_ACK.asBytes[0] = data[18];
        PID_value_ACK.asBytes[1] = data[19];
        PID_value_ACK.asBytes[2] = data[20];
        PID_value_ACK.asBytes[3] = data[21];
        sendAckToGUI(PID_id_ACK, PID_term_ACK, (float)PID_value_ACK.asDouble);
        break;
    }      
    
    #else
    
    PID_change_ACK = data[16];    
    switch (PID_change_ACK) {
      case 1: //Pitch PID_angle tuning
        PID_X_angle_p = ((double)data[17])/data[20];
        PID_X_angle_i = ((double)data[18])/data[21];tuning
        PID_X_angle_d = ((double)data[19])/data[22];
        break;
      case 2: //Roll PID_angle tuning
        PID_Y_angle_p = ((double)data[17])/data[20];
        PID_Y_angle_i = ((double)data[18])/data[21];
        PID_Y_angle_d = ((double)data[19])/data[22];
        break;
      case 3: //Pitch rate PID tuning
        PID_X_p = ((double)data[17])/data[20];
        PID_X_i = ((double)data[18])/data[21];
        PID_X_d = ((double)data[19])/data[22];
        break;
      case 4: //Roll rate PID tuning
        PID_Y_p = ((double)data[17])/data[20];
        PID_Y_i = ((double)data[18])/data[21];
        PID_Y_d = ((double)data[19])/data[22];
        break;
      case 5: //Yaw rate PID tuning
        PID_Z_p = ((double)data[17])/data[20];
        PID_Z_i = ((double)data[18])/data[21];
        PID_Z_d = ((double)data[19])/data[22];
        break;
    }    
    
    #endif
    
    //(optional, to monitor on serial when testing)
    #ifdef DEBUG_TELEMETRY
      Serial.print(nseq_rx); Serial.print("\t");  
      Serial.print("IMU:\t");
      //Serial.print(InputX_angle); Serial.print("\t");        
      Serial.print(InputY_angle); Serial.print("\t");
      //Serial.print(InputX); Serial.print("\t");        
      Serial.print(InputY); Serial.print("\t");
      //Serial.print(InputZ); Serial.print("\t");
      /*
      Serial.print("PID_X_angle:\t");
      Serial.print(PID_X_angle_p); Serial.print("\t"); 
      Serial.print(PID_X_angle_i); Serial.print("\t"); 
      Serial.print(PID_X_angle_d); Serial.print("\t");  
      */
      Serial.print("PID_Y_angle:\t");
      Serial.print(PID_Y_angle_p); Serial.print("\t"); 
      Serial.print(PID_Y_angle_i); Serial.print("\t"); 
      Serial.print(PID_Y_angle_d); Serial.print("\t"); 
      /*
      Serial.print("PID_X:\t");
      Serial.print(PID_X_p); Serial.print("\t"); 
      Serial.print(PID_X_i); Serial.print("\t"); 
      Serial.print(PID_X_d); Serial.print("\t"); 
      */
      Serial.print("PID_Y:\t");
      Serial.print(PID_Y_p); Serial.print("\t"); 
      Serial.print(PID_Y_i); Serial.print("\t"); 
      Serial.print(PID_Y_d); Serial.print("\t"); 
      /*
      Serial.print("PID_Z:\t");
      Serial.print(PID_Z_p); Serial.print("\t"); 
      Serial.print(PID_Z_i); Serial.print("\t"); 
      Serial.print(PID_Z_d); Serial.print("\t"); 
      */
      Serial.print("Outputs:\t");
      //Serial.print(OutputX_angle); Serial.print("\t");      
      Serial.print(OutputY_angle); Serial.print("\t"); 
      //Serial.print(OutputX); Serial.print("\t");      
      Serial.print(OutputY); Serial.print("\t");        
      //Serial.print(OutputZ); Serial.print("\t");
      Serial.print("Mots:\t");
      //Serial.print(Mot1); Serial.print("\t");
      Serial.print(Mot2); Serial.print("\t");
      //Serial.print(Mot3); Serial.print("\t");        
      Serial.print(Mot4); Serial.print("\t");
      Serial.print("\r\n");
    #endif
    
    //Keep in mind last reception. (Communication loss control)
    
    /* MISSING CODE */
  }
  
  return(nseq_rx);
}



/************************ Send *************************/
int sendData(byte* data) {
  
  unsigned long time_startTx = millis(); //Use timer to avoid blocking inside sending loop
  unsigned long time_max = MAX_TIME_2_SEND;
  boolean EXIT = 0;
  
  //Packets are sent within intervals of preconfigured ms  
  if ((millis() - time_lastTx) > TIME_BETWEEN_2_TX_G2Q) {
    TX_packets++;
    nseq_tx++;
    data[1] = nseq_tx;
    //Send data_tx
    Mirf.send((byte *)data);            //Indicate address of payload
    while(Mirf.isSending() && !EXIT){
      digitalWrite(PIN_TX,HIGH);
      digitalWrite(PIN_TX,LOW);
      if ( (millis()-time_startTx) > time_max) {
        EXIT = 1;      
      }
    } 
    time_lastTx = millis();
    digitalWrite(PIN_TX,LOW);
  }  
  
  return(EXIT);  
}



void prepareDataToQuadcopter() {  
  data_tx[0] = ID_local;  
  data_tx[1] = nseq_tx;
  //Compute values from joystick in order to get setpoints for Quad PIDs
  //Reversed mapping because IMU and Joystick have opposite senses
  data_tx[2] = map(joy_x,joy_x_min,joy_x_max,255,0); 
  data_tx[3] = map(joy_y,joy_y_min,joy_y_max,255,0);  
  data_tx[4] = map(joy_z,joy_z_min,joy_z_max,255,0);
  data_tx[5] = map(joy_t,joy_t_min,joy_t_max,255,0);
  
  #ifdef GUI_CONF
  
  data_tx[6] = PID_id;
  data_tx[7] = PID_term;
  data_tx[8] = PID_value.asBytes[0];
  data_tx[9] = PID_value.asBytes[1];
  data_tx[10] = PID_value.asBytes[2];
  data_tx[11] = PID_value.asBytes[3];
  data_tx[12] = 0; //not used
  
  #else //(old dirty way)
  
  data_tx[6] = PID_change;
  data_tx[7] = PID_p;
  data_tx[8] = PID_p_div;
  data_tx[9] = PID_i;
  data_tx[10] = PID_i_div;
  data_tx[11] = PID_d;
  data_tx[12] = PID_d_div;  

  #endif
}
