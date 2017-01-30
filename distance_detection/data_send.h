#ifndef DATA_SEND_H
#define DATA_SEND_H

#define BIT_O_PIN (2)
#define BIT_1_PIN (3)
#define BIT_2_PIN (4)
#define INT_PIN   (13)

#define INTERRUPT_LENGTH (50) //in ms

typedef enum
{
  OFF_OFF,
  OFF_HALF,
  HALF_OFF,
  HALF_HALF,
  HALF_FULL,
  FULL_HALF,
  FULL_FULL
} motor_modes_t;

void data_init(void);

void data_send(motor_modes_t mode);

void data_interrupt_low(void);

void data_interrupt_high(void);

#endif //DATA_SEND_H
