#include "data_rcv.h"
#include "motor_modes.h"
#include "Arduino.h"


void data_rcv_init(void)
{
  pinMode(DATA_RDY_INT_PIN, INPUT);
  pinMode(DATA_BIT_0_PIN, INPUT);
  pinMode(DATA_BIT_1_PIN, INPUT);
  pinMode(DATA_BIT_2_PIN, INPUT);
}

bool data_is_rdy(void)
{
  return digitalRead(DATA_RDY_INT_PIN);
}

motor_modes_t data_read(void)
{
  uint8_t data = 0;

  data = data | ((uint8_t)(digitalRead(DATA_BIT_0_PIN)));
  data = data | ((uint8_t)(digitalRead(DATA_BIT_1_PIN)) << 1);
  data = data | ((uint8_t)(digitalRead(DATA_BIT_2_PIN)) << 2);

  return (motor_modes_t)(data);
}
