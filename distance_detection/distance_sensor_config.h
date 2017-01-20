#ifndef DISTANCE_SENSOR_CONFIG_H
#define DISTANCE_SENSOR_CONFIG_H

//pin definition
#define SENSOR_L_TRIG 		12
#define SENSOR_L_ECHO 		11
#define SENSOR_L_MAX_DIST 	100

#define SENSOR_M_TRIG 		9
#define SENSOR_M_ECHO 		8
#define SENSOR_M_MAX_DIST 	100


#define SENSOR_R_TRIG 		6
#define SENSOR_R_ECHO 		5
#define SENSOR_R_MAX_DIST 	100

#define SONAR_NUM     3 // Number of sensors.
#define PING_INTERVAL 45 // Milliseconds between sensor pings (29ms is about the min to avoid cross-sensor echo).


#endif //DISTANCE_SENSOR_CONFIG_H