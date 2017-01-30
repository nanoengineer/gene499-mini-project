#include "data_send.h"
#include "Arduino.h"


void data_init(void)
{
  pinMode(BIT_O_PIN, OUTPUT);
  pinMode(BIT_1_PIN, OUTPUT);
  pinMode(BIT_2_PIN, OUTPUT);
  pinMode(INT_PIN, OUTPUT);

  digitalWrite(BIT_O_PIN, LOW);
  digitalWrite(BIT_1_PIN, LOW);
  digitalWrite(BIT_2_PIN, LOW);
  digitalWrite(INT_PIN, LOW);
}

void data_interrupt_high(void)
{
  digitalWrite(INT_PIN, HIGH);
}

void data_interrupt_low(void)
{
  digitalWrite(INT_PIN, LOW);
}


void data_send(motor_modes_t mode)
{
  switch (mode)
  {
    case OFF_OFF:
      digitalWrite(BIT_O_PIN, LOW);
      digitalWrite(BIT_1_PIN, LOW);
      digitalWrite(BIT_2_PIN, LOW);
      break;
    case OFF_HALF:
      digitalWrite(BIT_O_PIN, LOW);
      digitalWrite(BIT_1_PIN, LOW);
      digitalWrite(BIT_2_PIN, HIGH);
      break;
    case HALF_OFF:
      digitalWrite(BIT_O_PIN, LOW);
      digitalWrite(BIT_1_PIN, HIGH);
      digitalWrite(BIT_2_PIN, LOW);
      break;
    case HALF_HALF:
      digitalWrite(BIT_O_PIN, LOW);
      digitalWrite(BIT_1_PIN, HIGH);
      digitalWrite(BIT_2_PIN, HIGH);
      break;
    case HALF_FULL:
      digitalWrite(BIT_O_PIN, HIGH);
      digitalWrite(BIT_1_PIN, LOW);
      digitalWrite(BIT_2_PIN, LOW);
      break;
    case FULL_HALF:
      digitalWrite(BIT_O_PIN, HIGH);
      digitalWrite(BIT_1_PIN, LOW);
      digitalWrite(BIT_2_PIN, HIGH);
      break;
    case FULL_FULL:
      digitalWrite(BIT_O_PIN, HIGH);
      digitalWrite(BIT_1_PIN, HIGH);
      digitalWrite(BIT_2_PIN, LOW);
      break;
  }
}
