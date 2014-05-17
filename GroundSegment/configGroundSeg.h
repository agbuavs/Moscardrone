// ****** Global configuration ****** //
#define GUI_CONF //uncomment if you are going to use Processing GUI to calibrate PIDs instead of serial monitor
          //once it is done, every line of code left out of this definition should be erasedtuning


// ****** Debugging options ****** //
//At most, one of them can be uncommented. The rest must be commented.
//They must be commented if we are using ConfGUI.
//#define DEBUG_POTS
//#define DEBUG_RC_COMMANDS
//#define DEBUG_TELEMETRY

// ****** Joystick setup ***** //
#define MIN_JOY_DETECTABLE_SHIFT 80 //less shift from center in pot measurements are ignored
#define MIN_RANGE_TO_CALIBRATE 600  //min difference between max and min detected values to consider JOY_calibrated


/* The following definitions must be a copy from those at configQuadSeg.h ! */

// ****** RF channel configuration ***** //
#define RF_PACKET_SIZE 32 //maximum 32 by definition
#define MAX_TIME_NO_PACKETS 1000 //Time (ms) to wait before entering ABORT mode when data link is lost.
#define MAX_TIME_2_SEND 500 //Time (ms) limit for send telemetry to GS.
#define TIME_BETWEEN_2_TX_G2Q 50 //Time left between 2 transmissions from Ground to Quad.
#define TIME_BETWEEN_2_TX_Q2G 200 //Time left between 2 transmissions from Quad to Ground. Must be larger than needed time to print data over serial port.

//Milliseconds left between start and first PID computation. Used to arm motors.
#define TIME_TO_ARM 10000 

//Throttle absolute range
#define MIN_PWM_THROTTLE 1000
#define MAX_PWM_THROTTLE 2000

//Throttle range in horizontal position (controlled by joystick throttle stick)
#define MIN_HORIZ_THROTTLE 1000
#define MAX_HORIZ_THROTTLE 1700 //shall be less than MAX_PWM_THROTTLE

//Throttle limits for change given by PID outputs
#define MIN_PWM_PID_OUTPUT -300. // (== MAX_HORIZ_THROTTLE - MAX_PWM_THROTTLE)
#define MAX_PWM_PID_OUTPUT 300.  // (== MAX_PWM_THROTTLE - MAX_HORIZ_THROTTLE)

// Gyro rate limits given by PID_angle to gyro rate PIDs
#define MAX_ANGLE_PID_OUTPUT 200 //maximun rate physically reachable is +-250.
#define MIN_ANGLE_PID_OUTPUT -MAX_ANGLE_PID_OUTPUT

// ****** GYROSCOPE constants ****** //
#define MAX_ABS_GYRO_RATE 250 //value got from IMU readings and manually moving the quad


// ****** PID definitions ****** //
//Time (ms) left between two computations of PID. It should be computed in almost every loop execution.
#define PID_SAMPLETIME 10 //You can use DEBUG_TIMING to know how much time it takes in loop() code
//PID tunings by default
#define KpX_angle 0.
#define KiX_angle 0.
#define KdX_angle 0.
#define KpY_angle 0.
#define KiY_angle 0.
#define KdY_angle 0.
#define KpX 0.
#define KiX 0.
#define KdX 0.
#define KpY 0.
#define KiY 0.
#define KdY 0.
#define KpZ 0.
#define KiZ 0.
#define KdZ 0.
