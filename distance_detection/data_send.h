#ifndef DATA_SEND_H
#define DATA_SEND_H

#include "motor_modes.h"

#define INT_PIN   (A0)
#define BIT_O_PIN (A1)
#define BIT_1_PIN (A2)
#define BIT_2_PIN (A3)

#define INTERRUPT_LENGTH (50) //in ms

void data_init(void);

void data_send(motor_modes_t mode);

void data_rdy_int_low(void);

void data_rdy_int_high(void);

#endif //DATA_SEND_H
