// MakeShields Motor shield library
// copyright MakeShields, 2010
// this code is public jacky, enjoy!

#include "MSMotorShield.h"
#include "motor_modes.h"
#include "data_rcv.h"
#include "SimpleTimer.h"

// #define MOTOR_TEST

//Motor rumble intensities
#define RUMBLE_INTENSITY_HALF   (110)
#define RUMBLE_INTENSITY_FULL   (200)

#define NUM_OF_MOTORS            (2)

//Motor Pulsing Timing Behaviour
#define FULL_SPIKE_HIGH_BOUND   (1000) //in ms
#define FULL_SPIKE_LOW_BOUND    (800)

#define FULL_OFF_HIGH_BOUND     (2000)
#define FULL_OFF_LOW_BOUND      (1000)

#define HALF_SPIKE_HIGH_BOUND   (700) //in ms
#define HALF_SPIKE_LOW_BOUND    (400)

#define HALF_OFF_HIGH_BOUND     (3000)
#define HALF_OFF_LOW_BOUND      (2000)

// #define LEFT_RIGHT_DELAY        (500)

long left_spike_length = 0;
long left_off_length = 0;

long right_spike_length = 0;
long right_off_length = 0;

/* USE MOTORS 1 and 2 for high frequency PWM */

MS_DCMotor rumbleMotor[NUM_OF_MOTORS] =
{
  MS_DCMotor(1),
  MS_DCMotor(2),
};

SimpleTimer timer;

int leftSpikeHighTimerId;
int leftSpikeLowTimerId;

int rightSpikeHighTimerId;
int rightSpikeLowTimerId;

bool isLeftMotorCycleComplete = true;
bool isRightMotorCycleComplete = true;

motor_modes_t motor_cmd = OFF_OFF;
bool data_was_read = false;

void setup() {
  Serial.begin(115200);           // set up Serial library at 115200 bps
  Serial.println("Start!");

  setPwmFrequencyUNO(3,1);  //32.37 KHz for driving Motor 1 and Motor 2, reduce whine
  setPwmFrequencyUNO(11,1);

  data_rcv_init();

  // turn on motor
  #ifdef MOTOR_TEST
    allMotorsSetSpeed(RUMBLE_INTENSITY_HALF);
    allMotorsRun(FORWARD);
    delay(1000);
    allMotorsSetSpeed(RUMBLE_INTENSITY_FULL);
    allMotorsRun(FORWARD);
    delay(1000);
  #endif
}

void loop() {

    timer.run();

    //Read new data that is available
    if(data_is_rdy() && !data_was_read)
    {
      motor_cmd = data_read();
      data_was_read = true;

      //When new data comes in, reset the motor cycles and disable all ongoing timers
      rightMotorCycleComplete();
      leftMotorCycleComplete();

      // timer.disable(leftSpikeHighTimerId);
      // timer.disable(leftSpikeLowTimerId);
      // timer.disable(rightSpikeHighTimerId);
      // timer.disable(rightSpikeLowTimerId);

      //for debugging
      switch(motor_cmd)
      {
        case OFF_OFF:
          Serial.println("------------OFF_OFF------------");
          break;
        case OFF_HALF:
          Serial.println("------------OFF_HALF------------");
          break;
        case HALF_OFF:
          Serial.println("------------HALF_OFF------------");
          break;
        case HALF_HALF:
          Serial.println("------------HALF_HALF------------");
          break;
        case HALF_FULL:
          Serial.println("------------HALF_FULL------------");
          break;
        case FULL_HALF:
          Serial.println("------------FULL_HALF------------");
          break;
        case FULL_FULL:
          Serial.println("------------FULL_FULL------------");
      }
    }

    else if (!data_is_rdy() && data_was_read)
    {
      data_was_read = false;
    }


    if (isRightMotorCycleComplete && isLeftMotorCycleComplete)
    {
      switch(motor_cmd)
      {
        case OFF_OFF:
          allMotorsSetSpeed(0);
          allMotorsRun(BRAKE);
          break;

        case OFF_HALF:
          rightMotorCycleStart();
          rightMotorHalfSpikeHigh();

          right_spike_length = random(HALF_SPIKE_LOW_BOUND,
                                      HALF_SPIKE_HIGH_BOUND+1);
          right_off_length = random(HALF_OFF_LOW_BOUND, HALF_OFF_HIGH_BOUND+1);

          rightSpikeHighTimerId = timer.setTimeout(right_spike_length,
                                                   rightMotorSpikeLow);
          rightSpikeLowTimerId = timer.setTimeout(right_spike_length+right_off_length,
                                                  rightMotorCycleComplete);
          leftMotorSpikeLow();
          break;

        case HALF_OFF:
          leftMotorCycleStart();
          leftMotorHalfSpikeHigh();

          left_spike_length = random(HALF_SPIKE_LOW_BOUND,
                                      HALF_SPIKE_HIGH_BOUND+1);
          left_off_length = random(HALF_OFF_LOW_BOUND, HALF_OFF_HIGH_BOUND+1);

          leftSpikeHighTimerId = timer.setTimeout(left_spike_length,
                                                  leftMotorSpikeLow);
          leftSpikeLowTimerId = timer.setTimeout(left_spike_length+left_off_length,
                                                 leftMotorCycleComplete);
          rightMotorSpikeLow();


          break;

        case HALF_HALF:
          leftMotorCycleStart();
          leftMotorHalfSpikeHigh();

          left_spike_length = random(HALF_SPIKE_LOW_BOUND,
                                      HALF_SPIKE_HIGH_BOUND+1);
          left_off_length = random(HALF_OFF_LOW_BOUND, HALF_OFF_HIGH_BOUND+1);

          leftSpikeHighTimerId = timer.setTimeout(left_spike_length,
                                                  leftMotorSpikeLow);
          leftSpikeLowTimerId = timer.setTimeout(left_off_length + left_spike_length,
                                                 leftMotorCycleComplete);

          rightMotorCycleStart();
          rightMotorHalfSpikeHigh();

          right_spike_length = random(HALF_SPIKE_LOW_BOUND,
                                     HALF_SPIKE_HIGH_BOUND+1);
          right_off_length = random(HALF_OFF_LOW_BOUND, HALF_OFF_HIGH_BOUND+1);

          rightSpikeHighTimerId = timer.setTimeout(right_spike_length,
                                                   rightMotorSpikeLow);
          rightSpikeLowTimerId = timer.setTimeout(right_off_length+right_spike_length,
                                                  rightMotorCycleComplete);

          break;
        case HALF_FULL:
          leftMotorCycleStart();
          leftMotorHalfSpikeHigh();

          left_spike_length = random(HALF_SPIKE_LOW_BOUND,
                                      HALF_SPIKE_HIGH_BOUND+1);
          left_off_length = random(HALF_OFF_LOW_BOUND, HALF_OFF_HIGH_BOUND+1);

          leftSpikeHighTimerId = timer.setTimeout(left_spike_length,
                                                  leftMotorSpikeLow);
          leftSpikeLowTimerId = timer.setTimeout(left_off_length + left_spike_length,
                                                 leftMotorCycleComplete);

          rightMotorCycleStart();
          rightMotorFullSpikeHigh();

          right_spike_length = random(FULL_SPIKE_LOW_BOUND,
                                     FULL_SPIKE_HIGH_BOUND+1);
          right_off_length = random(FULL_OFF_LOW_BOUND, FULL_OFF_HIGH_BOUND+1);

          rightSpikeHighTimerId = timer.setTimeout(right_spike_length,
                                                   rightMotorSpikeLow);
          rightSpikeLowTimerId = timer.setTimeout(right_off_length+right_spike_length,
                                                  rightMotorCycleComplete);
          break;

        case FULL_HALF:
          leftMotorCycleStart();
          leftMotorFullSpikeHigh();

          left_spike_length = random(FULL_SPIKE_LOW_BOUND,
                                      FULL_SPIKE_HIGH_BOUND+1);
          left_off_length = random(FULL_OFF_LOW_BOUND, FULL_OFF_HIGH_BOUND+1);

          leftSpikeHighTimerId = timer.setTimeout(left_spike_length,
                                                  leftMotorSpikeLow);
          leftSpikeLowTimerId = timer.setTimeout(left_off_length + left_spike_length,
                                                 leftMotorCycleComplete);

          rightMotorCycleStart();
          rightMotorHalfSpikeHigh();

          right_spike_length = random(HALF_SPIKE_LOW_BOUND,
                                     HALF_SPIKE_HIGH_BOUND+1);
          right_off_length = random(HALF_OFF_LOW_BOUND, HALF_OFF_HIGH_BOUND+1);

          rightSpikeHighTimerId = timer.setTimeout(right_spike_length,
                                                   rightMotorSpikeLow);
          rightSpikeLowTimerId = timer.setTimeout(right_off_length+right_spike_length,
                                                  rightMotorCycleComplete);

          break;
        case FULL_FULL:
          leftMotorCycleStart();
          leftMotorFullSpikeHigh();

          left_spike_length = random(FULL_SPIKE_LOW_BOUND,
                                      FULL_SPIKE_HIGH_BOUND+1);
          left_off_length = random(FULL_OFF_LOW_BOUND, FULL_OFF_HIGH_BOUND+1);

          leftSpikeHighTimerId = timer.setTimeout(left_spike_length,
                                                  leftMotorSpikeLow);
          leftSpikeLowTimerId = timer.setTimeout(left_off_length + left_spike_length,
                                                 leftMotorCycleComplete);


          rightMotorCycleStart();
          rightMotorFullSpikeHigh();

          right_spike_length = random(FULL_SPIKE_LOW_BOUND,
                                    FULL_SPIKE_HIGH_BOUND+1);
          right_off_length = random(FULL_OFF_LOW_BOUND, FULL_OFF_HIGH_BOUND+1);

          rightSpikeHighTimerId = timer.setTimeout(right_spike_length,
                                                  rightMotorSpikeLow);
          rightSpikeLowTimerId = timer.setTimeout(right_off_length+right_spike_length,
                                                 rightMotorCycleComplete);
          break;
      }
    }
}

//Rumble Spike Functions to be called from Timers

void leftMotorFullSpikeHigh()
{
  motorRumble(0,RUMBLE_INTENSITY_FULL);
  Serial.println("L_FULL");
}

void leftMotorHalfSpikeHigh()
{
  motorRumble(0,RUMBLE_INTENSITY_HALF);
  Serial.println("L_HALF");

}

void leftMotorSpikeLow()
{
  motorRumble(0,0);
  Serial.println("L_OFF");
}

void rightMotorFullSpikeHigh()
{
  motorRumble(1,RUMBLE_INTENSITY_FULL);
  Serial.println("R_FULL");
}

void rightMotorHalfSpikeHigh()
{
  motorRumble(1,RUMBLE_INTENSITY_HALF);
  Serial.println("R_HALF");
}

void rightMotorSpikeLow()
{
  motorRumble(1,0);
  Serial.println("R_OFF");
}

//Flag Setting
void leftMotorCycleStart()
{
  isLeftMotorCycleComplete = false;
  Serial.println("L_START");
}

void leftMotorCycleComplete()
{
  isLeftMotorCycleComplete = true;
  Serial.println("L_FINISH");
}

void rightMotorCycleStart()
{
  isRightMotorCycleComplete = false;
  Serial.println("R_START");
}

void rightMotorCycleComplete()
{
  isRightMotorCycleComplete = true;
  Serial.println("R_FINISH");
}



//Constant Rumble Functions
void motorRumble(int motorId, int intensity)
{
  if(intensity <= 255 )
  {
    rumbleMotor[motorId].setSpeed(intensity);
    rumbleMotor[motorId].run(FORWARD);
  }
  else if (intensity == 0)
  {
    rumbleMotor[motorId].run(BRAKE);
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
