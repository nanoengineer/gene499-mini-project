#ifndef DATA_RCV_H
#define DATA_RCV_H

#include "motor_modes.h"

#define DATA_RDY_INT_PIN (A0)
#define DATA_BIT_0_PIN   (A1)
#define DATA_BIT_1_PIN   (A2)
#define DATA_BIT_2_PIN   (A3)

void data_rcv_init(void);

bool data_is_rdy(void);

motor_modes_t data_read(void);





#endif //DATA_RCV_H
