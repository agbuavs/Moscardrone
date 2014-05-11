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
      
  It is possible to tune PIDs using serial communications from a computer. 
  //  Command format => "PID_ID,p,p_div,i,i_div,d,d_div:", where...
  //  - axis is an integer meaning 1:pitch_angle, 2:roll_angle, 3:pitch_rate, 4:roll_rate, 5:yaw_rate
  //  - p,d and i are integers for PID tunning
  //  - p_div, i_div and d_div are integers to compute float values at quadcopter segment(I'm not dealing with sending floats with Mirf library)
  
*/


////////////////////////////////////////////////////////////////////////
///////  Libraries
////////////////////////////////////////////////////////////////////////

//My own definitions
#include "configGroundSeg.h"

// The following librearies must be installed to use nRF24l module
#include <SPI.h>
#include <Mirf.h>
#include <nRF24L01.h>
#include <MirfHardwareSpiDriver.h>

int counter = 0; //used to serial com with pc. (printing in every cycle saturates Matlab graphing sketch)

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

//Wireless PID settings. Variables used to import data from serial and send it to quadcopter.
int PID_change = 0; //update only PID requested axis
int PID_change_ACK = 0; //used to know if quad has received PID change command
int PID_p = 0;
int PID_i = 0;
int PID_d = 0;
int PID_p_div = 1; //this can't ever be 0!
int PID_i_div = 1; //this can't ever be 0!
int PID_d_div = 1; //this can't ever be 0!
//variables to monitor PID commands sent to quadcopter.
double PID_X_angle_p, PID_X_angle_i, PID_X_angle_d;
double PID_Y_angle_p, PID_Y_angle_i, PID_Y_angle_d;
double PID_X_p, PID_X_i, PID_X_d;
double PID_Y_p, PID_Y_i, PID_Y_d;
double PID_Z_p, PID_Z_i, PID_Z_d;

//PIN display declarations
int PIN_TX = 9; //blue
int PIN_RX = 2; //yellow



////////////////////////////////////////////////////////////////////////
///////  Initial Setup
////////////////////////////////////////////////////////////////////////

void setup(){
  //General settings
  Serial.begin(115200);
   
  //LEDs off at start
  digitalWrite(PIN_TX,LOW);
  digitalWrite(PIN_RX,LOW);
  
  //Init variables used to monitor PID settings from quadcopter
  initPIDmonValues();
  
  //RF setup
  Mirf.spi = &MirfHardwareSpi;
  Mirf.cePin = 8;
  Mirf.csnPin = 7;
  Mirf.init();
  Mirf.setRADDR((byte *)"GroundSegment"); //Set local segment name
  Mirf.setTADDR((byte *)"QuadcopterSegment");    //Set remote segment name
  Mirf.payload = RF_PACKET_SIZE; //shall be the same length on quadcopter segment.
  Mirf.config();
  Serial.println("Iniciando ... ");
}


////////////////////////////////////////////////////////////////////////
///////  Main Loop
////////////////////////////////////////////////////////////////////////

void loop(){
  
  //Read x from potentiometers
  joy_x = analogRead(A0);
  joy_y = analogRead(A1);
  joy_z = analogRead(A2);
  joy_t = analogRead(A3);
    
  //Joystick calibration (never finishes unless you code some more)
  if (!JOY_calibrated) {
    calibrateJoystick();
  }
  
  //Read PID tuning commands from serial. 
  //  Command format => "PID_ID,p,p_div,i,i_div,d,d_div:", where...
  //  - axis is an integer meaning 1:pitch_angle, 2:roll_angle, 3:pitch_rate, 4:roll_rate, 5:yaw_rate
  //  - p,d and i are integers for PID tunning
  //  - p_div, i_div and d_div are integers to compute float values at quadcopter segment (I'm not dealing with sending floats with Mirf library)
  if (Serial.available()>6) {
    PID_change = 0;
    //char change = Serial.read();
    int e = Serial.parseInt();
    int p = Serial.parseInt();
    int p_div = Serial.parseInt(); //integer diveder for P constant
    int i = Serial.parseInt();
    int i_div = Serial.parseInt(); //integer diveder for I constant
    int d = Serial.parseInt();
    int d_div = Serial.parseInt(); //integer diveder for D constant
    int EndChar = Serial.read();
    if (EndChar == ':') {
      if ((e==1) || (e==2) || (e==3) || (e==4) || (e==5)) {
        PID_change = e;
        PID_p = p;
        PID_p_div = p_div;
        PID_i = i;
        PID_i_div = i_div;
        PID_d = d;
        PID_d_div = d_div;
      }
    }
    for (int y = Serial.available(); y == 0; y--) { 
      Serial.read(); //Clear out any residual junk 
    } 
    /*
    Serial.println(PID_p);
    Serial.println(PID_i);
    Serial.println(PID_d);
    Serial.println(PID_p_div);
    Serial.println(PID_i_div);
    Serial.println(PID_d_div);
    Serial.println("+++++++++++++++++++");
    */
  }
  
  //Prepare payload for transmission to quadcopter
  prepareDataToQuadcopter();
  
  //Send RC and PID tunning data to Quadcopter
  sendData(data_tx);
  
  #ifdef DEBUG_POTS //These values can be monitored with Graph (Processing sketch)
    if (counter == 100) { //(printing in every cycle saturates Matlab graphing sketch)
      counter = 1;
      //(optional) print the results to the serial monitor: 
      Serial.print(joy_x); Serial.print("\t");        
      Serial.print(joy_y); Serial.print("\t");
      Serial.print(joy_z); Serial.print("\t");
      Serial.print(joy_t); Serial.print("\t");
      Serial.print("\r\n");
    }
    else counter++; 
  #endif
  
  //Receive data (if there is anything in buffer) from remote control
  byte data_rx[Mirf.payload];//Buffer for received data  
  last_nseq_rx = receiveData(data_rx);  //function not verified
  
  // wait 2 milliseconds before the next loop
  // for the analog-to-digital converter to settle
  // after the last reading:
  //delay(2);      
}



////////////////////////////////////////////////////////////////////////
///////  Functions
////////////////////////////////////////////////////////////////////////

int calibrateJoystick () {
  
 //Update maximum levels
 if (joy_x_max < joy_x)
   joy_x_max = joy_x;
 if (joy_y_max < joy_y)
   joy_y_max = joy_y;
 if (joy_z_max < joy_z)
   joy_z_max = joy_z;
 if (joy_t_max < joy_t)
   joy_t_max = joy_t;

 //Update minimum levels
 if (joy_x_min > joy_x)
   joy_x_min = joy_x;
 if (joy_y_min > joy_y)
   joy_y_min = joy_y;
 if (joy_z_min > joy_z)
   joy_z_min = joy_z;
 if (joy_t_min > joy_t)
   joy_t_min = joy_t;
 
 return(0);
}


void initPIDmonValues() {
  PID_X_angle_p = KpX_angle;
  PID_X_angle_i = KiX_angle;
  PID_X_angle_d = KdX_angle;
  PID_Y_angle_p = KpY_angle;
  PID_Y_angle_i = KiY_angle;
  PID_Y_angle_d = KdY_angle;
  PID_X_p = KpX; PID_X_i = KiX; PID_X_d = KdX;
  PID_Y_p = KpY; PID_Y_i = KiY; PID_Y_d = KdY;
  PID_Z_p = KpZ; PID_Z_i = KiZ; PID_Z_d = KdZ;
}
