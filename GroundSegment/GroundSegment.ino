/*
  Moscardrone - Ground Segment firmware
  
  Created by Alvaro Gippini, 8 February 2014
  
  This program is free software: you can redistribute it and/or modify it under the terms of
  the GNU General Public License as published by the Free Software Foundation, either version 3
  of the License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  See the GNU General Public License for more details.
  
  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
  
  
  
  This program is for the Ground Segment. It uses nRF24l module to communicate with quadcopter.
  It reads values from 4 Logitech Joystick potentiometers and uses them to compute
  pitch,roll,yaw and throttle. Then, it sends those 4 values to the quadcopter.
    Pitch & roll are angle setpoints for PIDs
    Yaw is a gyroscope change rate setpoint for PID
    Throttle is the mean power for the 4 motors. 
      (Throttle for each motor will be calculated from mean throttle command and 3 PIDs outputs)

*/


////////////////////////////////////////////////////////////////////////
///////  Libraries
////////////////////////////////////////////////////////////////////////

//My own definitions
#include "configGroundSeg.h"

// The following librearies must be installed to use nRF24l module
#include <SPI.h>
#include <EEPROM.h>
#include <Mirf.h>
#include <nRF24L01.h>
#include <MirfHardwareSpiDriver.h>



////////////////////////////////////////////////////////////////////////
///////  Global variables
////////////////////////////////////////////////////////////////////////

//Ground segment identifier (change it on both here and at Quadcopter code in order to achieve communication)
#define ID_local 1
//Quadcopter segment identifier (change it on both here and at Quadcopter code in order to achieve communication)
int ID_remote = 0;
int led = 13;
int blinking = 0;
unsigned long startT = 0;

//Joystick pot measures
int joy_x = 0;        // value read from the PITCH pot
int joy_y = 0;        // value read from the ROLL pot
int joy_z = 0;        // value read from the YAW pot
int joy_t = 0;        // value read from the THROTTLE pot
//Joystick calirbation: pot max,min and center values
int joy_x_max = 0;
int joy_y_max = 0;
int joy_z_max = 0;
int joy_t_max = 0;
int joy_x_min = 1024;
int joy_y_min = 1024;
int joy_z_min = 1024;
int joy_t_min = 1024;
int JOY_calibrated = 0; // calibration is done when achieved min/max values aproximate defined range.

//Communications protocol
int last_nseq_rx = 0;
int nseq_tx = 0;
unsigned long time_lastTx = 0;
unsigned long time_lastRx = 0;
double RX_packets = 0;
double TX_packets = 0;
byte data_tx[RF_PACKET_SIZE]; //Prepare payload to send to quadcopter

//PIN display declarations
int LED_CALIBRATE_OK = 10;
int PIN_TX = 9; //blue
int PIN_RX = 2; //yellow

//Variables used in communication with GUI
double lastGUIpacket = 0;
byte ackSent = 0;

//Wireless PID settings. Variables used to import data from serial and send it to quadcopter
union {                // This Data structure lets us take the byte array
  byte asBytes[4];     // sent from processing and easily convert it to a float array
  float asFloat;       // 
}                      // 
PID_value;             //
byte PID_id = 0;       // angleX, angleY, rateX, rateY or rateZ (in the future, it can be GPS, barometer, etc)
byte PID_term = 0;     //P, I or D
//(for recepcion of acks from quadcopter)
union {                
  byte asBytes[4];     
  float asDouble;        
}                       
PID_value_ACK;          
byte PID_id_ACK = 0;    //used to know if quad has updated PID requested axis
byte PID_term_ACK = 0;  //used to know if quad has received PID change command
//The next are variables used to configure other things than PIDs with ConfGUI.
byte addMSG_type = 0;
byte addMSG_data = 0;
byte addMSG_type_ACK = 0;
byte addMSG_data_ACK = 0;



////////////////////////////////////////////////////////////////////////
///////  Initial Setup
////////////////////////////////////////////////////////////////////////

void setup(){
  //General settings
  Serial.begin(115200);
   
  //LEDs off at start
  digitalWrite(PIN_TX,LOW);
  digitalWrite(PIN_RX,LOW);
  analogWrite(LED_CALIBRATE_OK,0);
  
  //RF setup
  Mirf.spi = &MirfHardwareSpi;
  Mirf.cePin = 8;
  Mirf.csnPin = 7;
  Mirf.init();
  Mirf.setRADDR((byte *)"GroundSegment"); //Set local segment name
  Mirf.setTADDR((byte *)"QuadcopterSegment");    //Set remote segment name
  Mirf.payload = RF_PACKET_SIZE; //shall be the same length on quadcopter segment.
  Mirf.config();
  
  //Load last MAX and MIN values for joy potentiometers
  /*if ( JoystickPreviouslyCalibrated() == JOY_IS_CAL) {
    ROMloadJoystickCalibration();
  }*/
}


////////////////////////////////////////////////////////////////////////
///////  Main Loop
////////////////////////////////////////////////////////////////////////

void loop(){
  
  //Read values from potentiometers
  readPotValues();
  
  //Joystick calibration (never finishes unless you code some more)
  if (!JOY_calibrated) {
    calibrateJoystick();
  }
  
  //Joystick pot measures transformed to ignore little movements around the center
  transformJoystickValues();
  
  //Read PID tuning commands from serial. 
  #ifdef GUI_CONF //Processing GUI is used to calibrate PIDs. Float values can be used

    if (((millis()-lastGUIpacket) > 500) && (Serial.available()>5)) {
      receiveDataFromGUI();   
    }  
    
  #endif
  
  //Prepare payload for transmission to quadcopter
  prepareDataToQuadcopter();
  
  //Send RC and PID tuning data to Quadcopter
  sendData(data_tx);
  
  #ifdef DEBUG_POTS //These values can be monitored with Graph (Processing sketch)

      //print the results to the serial monitor: 
      Serial.print(joy_x); Serial.print("\t");        
      Serial.print(joy_y); Serial.print("\t");
      Serial.print(joy_z); Serial.print("\t");
      Serial.print(joy_t); Serial.print("\t");
      Serial.print("\r\n");

  #endif
  
  //Receive data (if there is anything in buffer) from remote control
  byte data_rx[Mirf.payload];//Buffer for received data  
  last_nseq_rx = receiveData(data_rx);  //function not verified
     
}

