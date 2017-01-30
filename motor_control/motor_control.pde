// MakeShields Motor shield library
// copyright MakeShields, 2010
// this code is public jacky, enjoy!

#include <MSMotorShield.h>

#define MOTOR_TEST (1)

//Motor rumble intensities
#define RUMBLE_INTENSITY_LOW    (50)
#define RUMBLE_INTENSITY_MED    (100)
#define RUMBLE_INTENSITY_HIGH   (200)

#define NUM_OF_MOTORS            (4)

/* USE MOTORS 1 and 2 for high frequency PWM */

//Instantiate Motor Classes
// MS_DCMotor motor4(4); //Create a motor instance, connected to port 4
// MS_DCMotor motor3(3); //Create a motor instance, connected to port 3
// MS_DCMotor motor2(2); //Create a motor instance, connected to port 2
// MS_DCMotor motor1(1); //Create a motor instance, connected to port 1


MS_DCMotor rumbleMotor[NUM_OF_MOTORS] =
{
  MS_DCMotor(1),
  MS_DCMotor(2),
  MS_DCMotor(3),
  MS_DCMotor(4)
};

void setup() {
  Serial.begin(9600);           // set up Serial library at 9600 bps
  Serial.println("Motor test!");

  setPwmFrequencyUNO(3,1);  //32.37 KHz
  setPwmFrequencyUNO(11,1);

  // turn on motor
  #ifdef MOTOR_TEST
    allMotorsSetSpeed(160);

    allMotorsRun(FORWARD);
    // delay(2000);
    // allMotorsRun(BACKWARD);
    // delay(2000);
    // allMotorsRun(BRAKE);
  #endif
}

void loop() {

  allMotorsSetSpeed(160);
  allMotorsRun(FORWARD);
  delay(1000);
  allMotorsSetSpeed(160);
  allMotorsRun(BACKWARD);
  delay(500);
 //  uint8_t i;
 //
 //  Serial.print("tick");
 //
 //  motor.run(FORWARD);
 //  for (i=0; i<255; i++) {
 //    motor.setSpeed(i);
 //    delay(10);
 // }
 //
 //  for (i=255; i!=0; i--) {
 //    motor.setSpeed(i);
 //    delay(10);
 // }
 //
 //  Serial.print("tock");
 //
 //  motor.run(BACKWARD);
 //  for (i=0; i<255; i++) {
 //    motor.setSpeed(i);
 //    delay(10);
 // }
 //
 //  for (i=255; i!=0; i--) {
 //    motor.setSpeed(i);
 //    delay(10);
 // }
 //
 //
 //  Serial.print("tech");
 //  motor.run(RELEASE);
 //  delay(1000);
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
