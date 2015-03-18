/*
  Moscardrone - Quadcopter firmware
  
  Created by Alvaro Gippini, 8 February 2014
  
  This program is free software: you can redistribute it and/or modify it under the terms of
  the GNU General Public License as published by the Free Software Foundation, either version 3
  of the License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  See the GNU General Public License for more details.
  
  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
  
  
  
  This program is for the Quadcopter segment. It uses nRF24l module to communicate with ground station.
  It receives commands for pitch, roll, yaw and throttle, which have been calculated on ground station
  from 4 joystick potentiometer measurements.
    Pitch & roll are angle setpoints for PIDs
    Yaw is a gyroscope change rate setpoint for PID
    Throttle is the mean power for the 4 motors. 
      (Throttle for each motor will be calculated from mean throttle command and 3 PIDs outputs)
      
  PID default constants are defined in configQuadSeg.h but they can be tuned remotely 
  (using serial port on Ground Segment board) once your quad had been turned on (see DataLink code).

*/


////////////////////////////////////////////////////////////////////////
///////  Libraries
////////////////////////////////////////////////////////////////////////

// My own definitions
#include "configQuadSeg.h"

// PID library
#include <PID_agb.h>

// The following libraries must be installed to use nRF24l module
#include <SPI.h>
#include <Mirf.h>
#include <nRF24L01.h>
#include <MirfHardwareSpiDriver.h>

// The following libraries must be installed to use MPU6050 module
// Arduino Wire library is required if I2Cdev I2CDEV_ARDUINO_WIRE implementation is used in I2Cdev.h
#include "Wire.h"
// I2Cdev and MPU6050 must be installed as libraries, or else the .cpp/.h files
// for both classes must be in the include path of your project
#include "I2Cdev.h"
#include "MPU6050.h"
// class default I2C address is 0x68
// specific I2C addresses may be passed as a parameter here
// AD0 low = 0x68 (default for InvenSense evaluation board)
// AD0 high = 0x69

// Servo library used for ESC control
#include <Servo.h> 



////////////////////////////////////////////////////////////////////////
///////  Global variables
////////////////////////////////////////////////////////////////////////

//Quadcopter segment identifier (change it on both here and at Ground sengment code in order to achieve communication)
#define ID_local 1
//Ground segment identifier
int ID_remote = 0;
#define LED_PIN 13
boolean blinkState = false;

//PID global variables
double SetpointX_angle, InputX_angle, OutputX_angle;
double SetpointY_angle, InputY_angle, OutputY_angle;
double SetpointX, InputX, OutputX;
double SetpointY, InputY, OutputY;
double SetpointZ, InputZ, OutputZ;

//Specify the links and initial tuning parameters
PID PID_X_angle(&InputX_angle, &OutputX_angle, &SetpointX_angle, KpX_angle, KiX_angle, KdX_angle, DIRECT);
PID PID_Y_angle(&InputY_angle, &OutputY_angle, &SetpointY_angle, KpY_angle, KiY_angle, KdY_angle, DIRECT);
PID PID_X(&InputX, &OutputX, &SetpointX, KpX, KiX, KdX, DIRECT);
PID PID_Y(&InputY, &OutputY, &SetpointY, KpY, KiY, KdY, DIRECT);
PID PID_Z(&InputZ, &OutputZ, &SetpointZ, KpZ, KiZ, KdZ, DIRECT);

// IMU declararion and data
MPU6050 accelgyro;
int16_t accX, accY, accZ;
int16_t tempRaw;
int16_t gyroX, gyroY, gyroZ;
// Kalman instances (not used yet)
//Kalman kalmanX;
//Kalman kalmanY;
//Kalman kalmanZ;

// Variables to process IMU data
double accXangle, accYangle, accZangle; // Angle calculate using the accelerometer
double temp; // Temperature
double gyroXrate, gyroYrate, gyroZrate; // Gyroscope changing rate
double gyroXoffset, gyroYoffset, gyroZoffset; //Gyroscope rate measure when quad isn't moving. Get values on startup
double gyroSamples = 1; //aux variable used to calculate average gyro noise while arming motors.
double gyroXangle, gyroYangle,  gyroZangle; // Angle calculate using the gyro
double compAngleX, compAngleY, compAngleZ; // Calculate the angle using a complementary filter
double kalAngleX, kalAngleY, kalAngleZ; // Calculate the angle using a Kalman filter
int IMU_calibrated = 1; //IMU calibration is done afer several seconds in horizontal position.
uint32_t timer;
uint8_t i2cData[14]; // Buffer for I2C data

//Commands received from GS
int joy_x = 128;      // PITCH angle
int joy_y = 128;      // ROLL angle 
int joy_z = 128;      // YAW gyro rate (half between 0 and 255, since it has sign
int joy_t = 5;        // THROTTLE average for 4 motors. More than 2 to wait for ESC calibration.
//margins to control if ESC calibration is done
int min_joy_t_rx = 255;
int max_joy_t_rx = 0;
int joystickMode = DEFAULT_JOY_MODE;

//ESCs controls (individual motor throttle) 
int Mot1,Mot2,Mot3,Mot4;
Servo MOTOR1;
Servo MOTOR2;
Servo MOTOR3;
Servo MOTOR4;
int ESC_calibrated = 0;

//Communications protocol & safety modes global variables
int danger = 0;
int last_nseq_rx = 0;
int nseq_tx = 0;
unsigned long time_lastTx = 0;
unsigned long time_lastRx = 0;
double RX_packets = 0;
double TX_packets = 0;
int ABORT = 0;
byte data_tx[RF_PACKET_SIZE]; //Mirf payload to send telemetry to Ground Station.

//PIN display declarations
int PIN_TX = 9; //blue
int PIN_RX = 2; //yellow
int PIN_EMERG = 4; //green.
boolean blinkABORT = false;
double time_last_loop = 0;
double mean_cycle_time = 0;
int counter = 0;

//Variables used in communication with GUI
double lastGUIpacket = 0;
byte ackSent = 0;
union {                // This Data structure lets us take the byte array
  byte asBytes[4];     // sent from processing and easily convert it to a float array
  float asFloat;       // 
  double asDouble;     //
}                      // 
PID_value;
unsigned char PID_id = 0;       // angleX, angleY, rateX, rateY or rateZ (in the future, it can be GPS, barometer, etc)
                                // this value received from GS and it is != 0 when you want to change some PID params
unsigned char PID_term = 0;     // P, I or D
unsigned char i_PID_id = 0;
unsigned char i_PID_term = 0;
//The next are variables used to configure other things than PIDs with ConfGUI.
byte addMSG_type = 0;
byte addMSG_data = 0;


////////////////////////////////////////////////////////////////////////
///////  Initial Setup
////////////////////////////////////////////////////////////////////////

void setup(){

  Serial.begin(115200); //(optional, to monitor on serial when testing)

  //LEDs off at start
  digitalWrite(PIN_TX,LOW);
  digitalWrite(PIN_RX,LOW);
  digitalWrite(PIN_EMERG,LOW);
  
  // join I2C bus (I2Cdev library doesn't do this automatically)
  Wire.begin();

  //RF module configuration
  Mirf.spi = &MirfHardwareSpi;
  Mirf.cePin = 8;
  Mirf.csnPin = 7;
  Mirf.init();
  Mirf.setRADDR((byte *)"QuadcopterSegment"); //Set local segment name
  Mirf.setTADDR((byte *)"GroundSegment");    //Set remote segment name
  Mirf.payload = RF_PACKET_SIZE; //shall be the same length on ground segment.
  Mirf.config();
  
  Serial.println("Listening to RF...");

  // initialize IMU device
  Serial.println("Initializing I2C devices...");
  accelgyro.initialize();
  gyroSamples = 1;

  // verify connection with IMU
  Serial.println("Testing device connections...");
  Serial.println(accelgyro.testConnection() ? "MPU6050 connection successful" : "MPU6050 connection failed");

  // initialize PID inputs, setpoints and outputs
  initializePIDs();

  // initialize Mot values to 0
  initMotValues();
  
  // configure Servo-ESC connections
  MOTOR1.attach(ESC1);
  MOTOR2.attach(ESC2);
  MOTOR3.attach(ESC3);
  MOTOR4.attach(ESC4); 
  Serial.println("Four motors attached as servos...");

  // configure Arduino LED for showing activity
  pinMode(LED_PIN, OUTPUT);
  pinMode(PIN_TX, OUTPUT);
  pinMode(PIN_RX, OUTPUT);
  pinMode(PIN_EMERG, OUTPUT);
  digitalWrite(PIN_EMERG, false);
}


////////////////////////////////////////////////////////////////////////
///////  Main Loop
////////////////////////////////////////////////////////////////////////

void loop(){

  //Read PID tuning commands from serial. 
  #ifndef GUI_CONF_OVER_RF //Compile if ConfGUI is used to calibrate PIDs. Float values can be used
    if (((millis()-lastGUIpacket) > 500) && (Serial.available()>5)) {
      receiveDataFromGUI();   
    }  
  #endif
  
  //Read data from IMU and operate to get angles
  computeIMU();

  //Do necessary calculations on IMU data to get PIDs inputs
  computeInputs(); //Don't know if it will be used, since computeIMU() returns angle data.
  
  //Receive data (if there is anything in buffer) from remote control
  byte data_rx[Mirf.payload];//Buffer for received data  
  last_nseq_rx = receiveData(data_rx);  //function not verified
  
  //Check possible communication loss
  //danger = checkCommLoss(nseq_rx); //not implemented
  
  //If necessary, enter safety mode
  //enterSafetyMode(danger); //not implemented
      
  //Do necessary calculations on received data to get PIDs setpoints
  computeSetpoints(); //Take care of data format sent by RC. Look into GroundSegment code.
  
  //PID calculations 
  if (IMU_calibrated) { //IMU DEFINED as 1. IMU CALIBRATION PROCESS NOT IMPLEMENTED!
   
    #ifndef ESC_CALIBRATION_ON //To calibrate ESCs, no PIDs nor gyros are needed.
      if (millis() > (double)TIME_TO_ARM) { //Compute PIDs in order to get outputs
        if (joystickMode == JOY_MODE_ANGLE) { //If rate mode, joystick X,Y commands control Gyro Rates.
          PID_X_angle.Compute();
          PID_Y_angle.Compute();
          SetpointX = OutputX_angle; //This is 0 if you set Kp,Ki,Kd to 0 in angle PIDs
          SetpointY = OutputY_angle;
        }
        PID_X.Compute();
        PID_Y.Compute();
        PID_Z.Compute();
      }   
      else { //Calibrate gyros
        gyroXoffset = gyroXoffset * (gyroSamples-1)/gyroSamples + gyroXrate * (1/gyroSamples);
        gyroYoffset = gyroYoffset * (gyroSamples-1)/gyroSamples + gyroYrate * (1/gyroSamples);
        gyroZoffset = gyroZoffset * (gyroSamples-1)/gyroSamples + gyroZrate * (1/gyroSamples);
        gyroSamples++;
        /*
        Serial.print(gyroXrate); Serial.print("\t");
        Serial.print(gyroSamples); Serial.print("\t");
        Serial.print(gyroXoffset); Serial.print("\t");
        Serial.print("\r\n");
        */
      }
    #endif
    
    #ifdef DEBUG_PID
      printPIDvalues(); //Here, Mot values are not truncated yet.
    #endif
  
    //Do necessary calculations on PID outputs to get the 4 motor throttle values
    computeOutputs(); 

    //Apply corresponding throttle value to each Motor individually
    if (ABORT) {
      turnOffMotors();
    }
    else {
      changeMotorsThrottle();
    }
  }

  //Prepare payload for transmission to ground station
  prepareDataToGroundSegment();
  
  //Send telemetry data to ground station.
  sendData(data_tx);

  //(optional, to monitor on serial when testing quad)
  #ifdef DEBUG_TELEMETRY
    Serial.print(data_tx[1]); Serial.print("\t");  
    Serial.print("IMU:\t");
    Serial.print(InputX); Serial.print("\t");        
    Serial.print(InputY); Serial.print("\t");
    Serial.print(InputZ); Serial.print("\t");
    Serial.print("PID:\t");
    Serial.print(OutputX); Serial.print("\t");      
    Serial.print(OutputY); Serial.print("\t");        
    Serial.print(OutputZ); Serial.print("\t");
    Serial.print("Mots:\t");
    Serial.print(Mot1); Serial.print("\t");
    Serial.print(Mot2); Serial.print("\t");
    Serial.print(Mot3); Serial.print("\t");        
    Serial.print(Mot4); Serial.print("\t");
    Serial.print("\r\n");
  #endif
  
  //LED to indicate ABORT operation
  if (ABORT) {
    blinkABORT = !blinkABORT;
    digitalWrite(PIN_EMERG, blinkABORT);
  }
  
  // blink LED to indicate activity
  blinkState = !blinkState;
  digitalWrite(LED_PIN, blinkState);
  
  //print time elapsed during loop. Necessary to know minimum cycle time for datalink
  #ifdef DEBUG_TIMING  
    if(counter == 1000) {    
      Serial.println(mean_cycle_time,6);
      mean_cycle_time = 0;
      time_last_loop = millis();
      counter = 0;
    }
    else {
      double aux = millis()-time_last_loop;
      mean_cycle_time = mean_cycle_time + aux/1000;    
      time_last_loop = millis();
      counter++;
    }
  #endif
}
