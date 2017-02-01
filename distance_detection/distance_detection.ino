// ---------------------------------------------------------------------------
// This example code was used to successfully communicate with 15 ultrasonic sensors. You can adjust
// the number of sensors in your project by changing SONAR_NUM and the number of NewPing objects in the
// "sonar" array. You also need to change the pins for each sensor for the NewPing objects. Each sensor
// is pinged at 33ms intervals. So, one cycle of all sensors takes 495ms (33 * 15 = 495ms). The results
// are sent to the "oneSensorCycle" function which currently just displays the distance data. Your project
// would normally process the sensor results in this function (for example, decide if a robot needs to
// turn and call the turn function). Keep in mind this example is event-driven. Your complete sketch needs
// to be written so there's no "delay" commands and the loop() cycles at faster than a 33ms rate. If other
// processes take longer than 33ms, you'll need to increase PING_INTERVAL so it doesn't get behind.
// ---------------------------------------------------------------------------
#include <NewPing.h>
#include "distance_sensor_config.h"
#include "data_send.h"
#include "motor_modes.h"
#include "Arduino.h"

unsigned long pingTimer[SONAR_NUM]; // Holds the times when the next ping should happen for each sensor.
unsigned int cm[SONAR_NUM];         // Where the ping distances are stored.
uint8_t currentSensor = 0;          // Keeps track of which sensor is active.

unsigned long interrupt_rising_edge;


bool flip = 0;

NewPing sonar[SONAR_NUM] = {     // Sensor object array.
  NewPing(SENSOR_L_TRIG, SENSOR_L_ECHO, SENSOR_L_MAX_DIST), // Each sensor's trigger pin, echo pin, and max distance to ping.
  // NewPing(SENSOR_M_TRIG, SENSOR_M_ECHO, SENSOR_M_MAX_DIST),
  NewPing(SENSOR_R_TRIG, SENSOR_R_ECHO, SENSOR_R_MAX_DIST)
};

void setup() {
  Serial.begin(115200);
  pingTimer[0] = millis() + 75;           // First ping starts at 75ms, gives time for the Arduino to chill before starting.
  for (uint8_t i = 1; i < SONAR_NUM; i++)
  {
    pingTimer[i] = pingTimer[i - 1] + PING_INTERVAL;
  } // Set the starting time for each sensor.
  data_init();
}

void loop() {
  for (uint8_t i = 0; i < SONAR_NUM; i++) { // Loop through all the sensors.
    if (millis() >= pingTimer[i]) {         // Is it this sensor's time to ping?
      pingTimer[i] += PING_INTERVAL * SONAR_NUM;  // Set next time this sensor will be pinged.

      if (i == 0 && currentSensor == SONAR_NUM - 1)
      {
        oneSensorCycle(); // Sensor ping cycle complete, do something with the results.

        data_send(distToMotorModeConversion(cm[0],cm[1]));

        data_rdy_int_high(); // Send the data and pull the interrupt high so the motor arduino knows the send has completed
        interrupt_rising_edge = millis();
      }

      sonar[currentSensor].timer_stop();          // Make sure previous timer is canceled before starting a new ping (insurance).
      currentSensor = i;                          // Sensor being accessed.
      cm[currentSensor] = 255;                      // Make distance zero in case there's no ping echo for this sensor.
      sonar[currentSensor].ping_timer(echoCheck); // Do the ping (processing continues, interrupt will call echoCheck to look for echo).
    }

    if ((interrupt_rising_edge != 0) && (millis() > ((interrupt_rising_edge + INTERRUPT_LENGTH))))
    {
        data_rdy_int_low();
    }
  }

  // Other code that *DOESN'T* analyze ping results can go here.
}

motor_modes_t distToMotorModeConversion(unsigned int leftDist, unsigned int rightDist)
{
    motor_modes_t motorCommand;

    //Too far away
    if ((leftDist == 255) & (rightDist == 255) )
    {
        motorCommand = OFF_OFF;
        Serial.println("OFF_OFF");
    }
    else if ((leftDist <= HALF_THRESHOLD) && (leftDist > FULL_THRESHOLD) && (rightDist == 255))
    {
        motorCommand = HALF_OFF;
        Serial.println("HALF_OFF");

    }
    else if ((rightDist <= HALF_THRESHOLD) && (rightDist > FULL_THRESHOLD) && (leftDist == 255))
    {
        motorCommand = OFF_HALF;
        Serial.println("OFF_HALF");

    }
    else if ((rightDist <= HALF_THRESHOLD) && (rightDist > FULL_THRESHOLD) && (leftDist <= HALF_THRESHOLD) && (leftDist > FULL_THRESHOLD))
    {
        motorCommand = HALF_HALF;
        Serial.println("HALF_HALF");

    }

    //Below: SHOULD BE FULL_OFF and OFF_FULL
    else if ((leftDist <= FULL_THRESHOLD) && (rightDist == 255))
    {
        motorCommand = FULL_HALF;
        Serial.println("FULL_HALF");

    }
    else if ((rightDist <= FULL_THRESHOLD) && (leftDist == 255))
    {
        motorCommand = HALF_OFF;
        Serial.println("FULL_HALF");

    }
    //End

    else if ((leftDist <= FULL_THRESHOLD) && (rightDist <= HALF_THRESHOLD) && (rightDist >= FULL_THRESHOLD))
    {
        motorCommand = FULL_HALF;
        Serial.println("FULL_HALF");

    }
    else if ((rightDist <= FULL_THRESHOLD) && (leftDist <= HALF_THRESHOLD) && (leftDist >= FULL_THRESHOLD))
    {
        motorCommand = HALF_FULL;
        Serial.println("HALF_FULL");

    }
    else if (leftDist <= FULL_THRESHOLD && rightDist <= FULL_THRESHOLD)
    {
        motorCommand = FULL_FULL;
        Serial.println("FULL_FULL");
    }

    data_send(motorCommand);
}

void echoCheck() { // If ping received, set the sensor distance to array.
  if (sonar[currentSensor].check_timer())
    cm[currentSensor] = sonar[currentSensor].ping_result / US_ROUNDTRIP_CM;
}

void oneSensorCycle() { // Sensor ping cycle complete, do something with the results.
  // The following code would be replaced with your code that does something with the ping results.
  for (uint8_t i = 0; i < SONAR_NUM; i++) {
    Serial.print(i);
    Serial.print("=");
    Serial.print(cm[i]);
    Serial.print("cm ");
  }
  Serial.println();
}
