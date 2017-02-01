// MakeShields Motor shield library
// copyright MakeShields, 2010
// this code is public jacky, enjoy!

#include <MSMotorShield.h>
#include "motor_modes.h"
#include "data_rcv.h"

#define MOTOR_TEST (1)

//Motor rumble intensities
#define RUMBLE_INTENSITY_HALF   (80)
#define RUMBLE_INTENSITY_FULL   (100)

#define NUM_OF_MOTORS            (2)

/* USE MOTORS 1 and 2 for high frequency PWM */

MS_DCMotor rumbleMotor[NUM_OF_MOTORS] =
{
  MS_DCMotor(1),
  MS_DCMotor(2),
};

motor_modes_t motor_cmd = OFF_OFF;
bool data_was_read = false;

void setup() {
  Serial.begin(115200);           // set up Serial library at 115200 bps
  Serial.println("Motor test!");

  setPwmFrequencyUNO(3,1);  //32.37 KHz for driving Motor 1 and Motor 2, reduce whine
  setPwmFrequencyUNO(11,1);

  data_rcv_init();

  // turn on motor
  #ifdef MOTOR_TEST
    allMotorsSetSpeed(RUMBLE_INTENSITY_HALF);
    allMotorsRun(FORWARD);
    delay(4000);
    allMotorsSetSpeed(RUMBLE_INTENSITY_FULL);
    allMotorsRun(FORWARD);
    delay(4000);
  #endif
}

void loop() {
    if(data_is_rdy() && !data_was_read)
    {
      motor_cmd = data_read();
      switch (motor_cmd)
      {
          case OFF_OFF:
            allMotorsSetSpeed(0);
            allMotorsRun(BRAKE);
            Serial.println("OFF_OFF");
            break;
          case OFF_HALF:
            rumbleMotor[1].setSpeed(RUMBLE_INTENSITY_HALF);
            rumbleMotor[0].setSpeed(0);
            rumbleMotor[1].run(FORWARD);
            rumbleMotor[0].run(BRAKE);
            Serial.println("OFF_HALF");
            break;
          case HALF_OFF:
            rumbleMotor[0].setSpeed(RUMBLE_INTENSITY_HALF);
            rumbleMotor[1].setSpeed(0);
            rumbleMotor[0].run(FORWARD);
            rumbleMotor[1].run(BRAKE);
            Serial.println("HALF_OFF");
            break;
          case HALF_HALF:
            allMotorsSetSpeed(RUMBLE_INTENSITY_HALF);
            allMotorsRun(FORWARD);
            Serial.println("HALF_HALF");
            break;
          case HALF_FULL:
            rumbleMotor[0].setSpeed(RUMBLE_INTENSITY_HALF);
            rumbleMotor[1].setSpeed(RUMBLE_INTENSITY_FULL);
            allMotorsRun(FORWARD);
            Serial.println("HALF_FULL");
            break;
          case FULL_HALF:
            rumbleMotor[1].setSpeed(RUMBLE_INTENSITY_HALF);
            rumbleMotor[0].setSpeed(RUMBLE_INTENSITY_FULL);
            allMotorsRun(FORWARD);
            Serial.println("FULL_HALF");
            break;
          case FULL_FULL:
            allMotorsSetSpeed(RUMBLE_INTENSITY_FULL);
            allMotorsRun(FORWARD);
            Serial.println("FULL_FULL");
            break;
      }
      data_was_read = true;
    }
    else if (!data_is_rdy() && data_was_read)
    {
      data_was_read = false;
    }

}


void motorRumble(int motorId, int intensity)
{
  if(intensity < 255 || intensity > 0)
  {
    rumbleMotor[motorId].setSpeed(intensity);
    rumbleMotor[motorId].run(FORWARD);
  }
}


//param[in] speed: 0 - 255
void allMotorsSetSpeed( int speed )
{
  for (int i = 0; i < NUM_OF_MOTORS; i++)
  {
    rumbleMotor[i].setSpeed(speed);
  }
}

//param[in] direction: FORWARD, BACKWARD, BRAKE, RELEASE
void allMotorsRun(int direction)
{
  for (int i = 0; i < NUM_OF_MOTORS; i++)
  {
    rumbleMotor[i].run(direction);
  }
}

void setPwmFrequencyUNO(int pin, int divisor) {
  byte mode;
  if(pin == 5 || pin == 6 || pin == 9 || pin == 10) {
    switch(divisor) {
      case 1: mode = 0x01; break;
      case 2: mode = 0x02; break;
      case 3: mode = 0x03; break;
      case 4: mode = 0x04; break;
      case 5: mode = 0x05; break;
      default: return;
    }
    if(pin == 5 || pin == 6) {
      TCCR0B = TCCR0B & 0b11111000 | mode;
    } else {
      TCCR1B = TCCR1B & 0b11111000 | mode;
    }
  } else if(pin == 3 || pin == 11) {
    switch(divisor) {
      case 1: mode = 0x01; break;
      case 2: mode = 0x02; break;
      case 3: mode = 0x03; break;
      case 4: mode = 0x04; break;
      case 5: mode = 0x05; break;
      case 6: mode = 0x06; break;
      case 7: mode = 0x07; break;
      default: return;
    }
    TCCR2B = TCCR2B & 0b11111000 | mode;

}}
