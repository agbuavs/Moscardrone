/* 
  Data Link functions:
  
  receiveData: 
    - reads message from nRF24l01 buffer when something is available
    - udpdates RC commands and PID params conf. from Ground segment.
   
  sendData:
    - sends payload, taking care of timing restrictions (in order to avoid channel saturation)
  
  prepareDataToGroundSegment:
    - prepares telemetry data to send with sendData(). You shall modify receiveData() in GroundSegment
      code if you change something here and want to keep communications under control.
*/  


/************************ Receive *************************/
int receiveData(byte* data) {
//Check if rf24l has something to deliver. Return sequence number to verify communications.

  int nseq_rx = 0;
  PID_change = 0;
  
  if(!Mirf.isSending() && Mirf.dataReady()){
    
    digitalWrite(PIN_RX,HIGH);
    
    Mirf.getData(data);
    RX_packets++;
  
    //Assign buffer data to PID inputs
    ID_remote = int(data[0]);
    nseq_rx = int(data[1]);
    joy_x = int(data[2]);
    joy_y = int(data[3]);
    joy_z = int(data[4]);
    joy_t = int(data[5]);
    
    //Check if there is an order to change PID tunning parameters
    PID_change = data[6];
    double kp = 0;
    double ki = 0;
    double kd = 0;
    PID_p = data[7];
    if (data[8] != 0) {
      PID_p_div = data[8];
      kp = (double)(PID_p)/PID_p_div;
    }    
    PID_i = data[9];    
    if (data[10] != 0) {
      PID_i_div = data[10];
      ki = (double)(PID_i)/PID_i_div;
    }
    PID_d = data[11];
    if (data[12] != 0) {
      PID_d_div = data[12];
      kd = (double)(PID_d)/PID_d_div;
    }  
    switch (PID_change) {
      case 1: //Pitch PID_angle tunning
        PID_X_angle.SetTunings(kp, ki, kd);
        break;
      case 2: //Roll PID_angle tunning
        PID_Y_angle.SetTunings(kp, ki, kd);
        break;
      case 3: //Pitch PID tunning
        PID_X.SetTunings(kp, ki, kd);
        break;
      case 4: //Roll PID tunning
        PID_Y.SetTunings(kp, ki, kd);
        break;
      case 5: //Yaw rate PID tunning
        PID_Z.SetTunings(kp, ki, kd);
        break;  
    }
    if (PID_change!=0)
      PID_change_ACK = PID_change; //keep track of last PID params changed to send ack to GS.
    
    //(optional, to monitor on serial when testing)
    #ifdef DEBUG_RX      
      Serial.print(data[2]); Serial.print("\t");        
      Serial.print(data[3]); Serial.print("\t");
      Serial.print(data[4]); Serial.print("\t");
      Serial.print(data[5]); Serial.print("\t");
      Serial.print("\r\n");
    #endif
    
    digitalWrite(PIN_RX,LOW);
    time_lastRx = millis();
    
    //Keep in mind last reception. (Communication loss control)
    
    /* MISSING CODE */
  }
  else {
    if ((time_lastRx > 0) && ((millis() - time_lastRx) > MAX_TIME_NO_PACKETS))
      ABORT = 1;
  }
  
  return(nseq_rx);
}



/************************ Send *************************/
int sendData(byte* data) {
  
  unsigned long time_startTx = millis(); //Use timer to avoid blocking inside sending loop
  unsigned long time_max = MAX_TIME_2_SEND;
  boolean EXIT = 0;
  
  //Packets are sent within intervals of preconfigured ms  
  if ((millis() - time_lastTx) > TIME_BETWEEN_2_TX_Q2G) {
    TX_packets++;
    nseq_tx++;
    data[1] = nseq_tx;
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

void prepareDataToGroundSegment(){
  data_tx[0] = ID_local;
  data_tx[1] = nseq_tx;
  //Read and map values from IMU, PID and ESC to send them to ground segment
  data_tx[2] = (int) map(InputX_angle, 0, 360, 0,255); //IMU pitch angle
  data_tx[3] = (int) map(InputY_angle, 0, 360, 0,255); //IMU roll angle
  data_tx[4] = (int) map(InputX, -MAX_ABS_GYRO_RATE, MAX_ABS_GYRO_RATE, 0,255); //IMU pitch rate
  data_tx[5] = (int) map(InputY, -MAX_ABS_GYRO_RATE, MAX_ABS_GYRO_RATE, 0,255); //IMU roll rate
  data_tx[6] = (int) map(InputZ, -MAX_ABS_GYRO_RATE, MAX_ABS_GYRO_RATE, 0,255); //IMU yaw rate
  data_tx[7] = (int) map(OutputX_angle, MIN_ANGLE_PID_OUTPUT, MAX_ANGLE_PID_OUTPUT, 0,255); //PID output for pitch
  data_tx[8] = (int) map(OutputY_angle, MIN_ANGLE_PID_OUTPUT, MAX_ANGLE_PID_OUTPUT, 0,255); //PID output for roll
  data_tx[9] = (int) map(OutputX, MIN_PWM_PID_OUTPUT, MAX_PWM_PID_OUTPUT, 0,255); //PID output for pitch
  data_tx[10] = (int) map(OutputY, MIN_PWM_PID_OUTPUT, MAX_PWM_PID_OUTPUT, 0,255); //PID output for roll
  data_tx[11] = (int) map(OutputZ, MIN_PWM_PID_OUTPUT, MAX_PWM_PID_OUTPUT, 0,255); //PID output for yaw
  data_tx[12] = (int) (((double)Mot1 - MIN_PWM_THROTTLE)*256/(MAX_PWM_THROTTLE - MIN_PWM_THROTTLE)); //Mot1 value
  data_tx[13] = (int) (((double)Mot2 - MIN_PWM_THROTTLE)*256/(MAX_PWM_THROTTLE - MIN_PWM_THROTTLE)); //Mot2 value
  data_tx[14] = (int) (((double)Mot3 - MIN_PWM_THROTTLE)*256/(MAX_PWM_THROTTLE - MIN_PWM_THROTTLE)); //Mot3 value
  data_tx[15] = (int) (((double)Mot4 - MIN_PWM_THROTTLE)*256/(MAX_PWM_THROTTLE - MIN_PWM_THROTTLE)); //Mot4 value
  data_tx[16] = PID_change_ACK;
  switch (PID_change_ACK) {
      case 1: //Pitch PID_angle tunning ACK
        data_tx[17] = (int)(PID_p_div*PID_X_angle.GetKp());
        data_tx[18] = (int)(PID_i_div*PID_X_angle.GetKi());
        data_tx[19] = (int)(PID_d_div*PID_X_angle.GetKd());
        break;
      case 2: //Roll PID_angle tunning ACK
        data_tx[17] = (int)(PID_p_div*PID_Y_angle.GetKp());
        data_tx[18] = (int)(PID_i_div*PID_Y_angle.GetKi());
        data_tx[19] = (int)(PID_d_div*PID_Y_angle.GetKd());
        break;
      case 3: //Pitch PID tunning ACK
        data_tx[17] = (int)(PID_p_div*PID_X.GetKp());
        data_tx[18] = (int)(PID_i_div*PID_X.GetKi());
        data_tx[19] = (int)(PID_d_div*PID_X.GetKd());
        break;
      case 4: //Roll PID tunning ACK
        data_tx[17] = (int)(PID_p_div*PID_Y.GetKp());
        data_tx[18] = (int)(PID_i_div*PID_Y.GetKi());
        data_tx[19] = (int)(PID_d_div*PID_Y.GetKd());
        break;
      case 5: //Yaw rate PID tunning ACK
        data_tx[17] = (int)(PID_p_div*PID_Z.GetKp());
        data_tx[18] = (int)(PID_i_div*PID_Z.GetKi());
        data_tx[19] = (int)(PID_d_div*PID_Z.GetKd());
        break;
  }       
  data_tx[20] = PID_p_div;
  data_tx[21] = PID_i_div;
  data_tx[22] = PID_d_div;
}
