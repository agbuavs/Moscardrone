int changeMotorsThrottle() {
//Applies MotX value to every ESC
//maybe Mot values calculated at computeOutputs() exceed ranges that Servos (ESCs) understand?  
  
  //constrain throttle to defined limits
  Mot1 = constrain(Mot1, MIN_PWM_THROTTLE, MAX_PWM_THROTTLE);
  Mot2 = constrain(Mot2, MIN_PWM_THROTTLE, MAX_PWM_THROTTLE);
  Mot3 = constrain(Mot3, MIN_PWM_THROTTLE, MAX_PWM_THROTTLE);
  Mot4 = constrain(Mot4, MIN_PWM_THROTTLE, MAX_PWM_THROTTLE);
  
  //Send calculated throttle values to ESCs
  MOTOR1.writeMicroseconds(Mot1);
  MOTOR2.writeMicroseconds(Mot2);
  MOTOR3.writeMicroseconds(Mot3);
  MOTOR4.writeMicroseconds(Mot4);
  
  return(0);
}


void turnOffMotors() {  
  MOTOR1.writeMicroseconds(MIN_PWM_THROTTLE);
  MOTOR2.writeMicroseconds(MIN_PWM_THROTTLE);
  MOTOR3.writeMicroseconds(MIN_PWM_THROTTLE);
  MOTOR4.writeMicroseconds(MIN_PWM_THROTTLE);
}


void initMotValues() {  
  Mot1 = 0;
  Mot2 = 0;
  Mot3 = 0;
  Mot4 = 0;
}
