# *storm in a teacup*

GENE 499/FINE 392 Tech Art: Mini Project

Interdisciplinary collaboration between engineering and fine art.

![Alt text](pictures/sitc_side.jpg?raw=true "storm in a teacup")

# Artist Statement

**Nicole Brkic, Tony Wu**

*storm in a teacup*, 2017

kinetic sculpture

dimensions: 27 x 22 x 40cm

*porcelain, MDF, ultrasonic distance sensors, DC motors, Arduino.*


The delicate nature of porcelain is associated with both fragility and preciousness; consequently, the teacup is understood on a social and cultural level to be an object of value. *storm in a teacup* is comprised of stacked teacups and saucers that seem as though they could collapse at any moment. In combining a seemingly unstable structure with perceived precious objects, this interactive piece aims to evoke a physical or emotional response from the viewer. In addition to their precarious form, the teacups rattle as the viewer approaches the structure, further heightening an already anxious and suspenseful situation.

Despite the teacup having social and cultural associations, any object is only as significant as the value that is attributed to them by an individual or group. The title, storm in a teacup, derives from the idiom that describes a situation in which a person or group overreacts to something that is not in reality important. With an ever increasing materialistic attitude, this work comments on excessive feelings of distress experienced by our society when faced with the loss of valuable yet dispensable objects.

# Electronics

![Alt text](pictures/electronics.jpg?raw=true "electronics")


| Component        | Qty           | Function  |
| ------------- |:-------------:| -----:|
| Arduino Uno   | 2 | Microcontrollers |
| [Motor Driver Shield](https://www.sunfounder.com/wiki/index.php?title=L293D_Motor_Driver_Shield)     | 1      | Motor Driving|
| 12V, 250 mA DC Motor | 2    | Rattling Actuation |
| [HC-SR04 Ultrasonic Distance Sensor](https://www.amazon.ca/Sainsmart-HC-SR04-Ranging-Detector-Distance/dp/B004U8TOE6) | 2    | Viewer Distance Detection |
| 12V, 2A DC Power Supply | 1    | System Power |

The piece utilizes two Arduinos because the motor driver shield occupies all the digital pins on the Arduino to be able to drive 4 DC motors simultaneously, thus there are no available pins to interface with the ultrasonic distance sensors (UDSs). While we could've modified the shield electrically to free up some digital pins for the two UDSs if we fixed the number of motors we want to drive to two, we felt that the sacrifice in flexibility of being able to add more motors or UDSs to fine tune the interactive behaviour was too much of a compromise. Thus we went with two Arduinos, one to provide logic to motors and one to gather data from the UDSs, to remain flexible.

The tradeoff for using two Arduinos is that now they must communicate with each other, since the motors actuate the rattling of the teacups in reaction to any approaching viewers picked up by the UDSs. A simple ad-hoc protocol was created on a 4-bit bus on the free Analog Pins on both Arduinos.

Instead of communicating directly the distance data from one
Arduino to another, we let the sensor-Arduino do some local processing to convert the distance data
into simple, integer commands for the motors first, before send the data over to simplify the ad-hoc
communication protocol. Essentially, the sensor-Arduino only needs to communicate an integer from 0
to 6 any time a new command should be issued, this results in the use of four analog pins, three for the
data in binary representation (2^3 = 8 max commands), and one for a “data complete” flag. The data-
complete flag is tied to A0, and the 3 data bits are tied to A1-A3 pins, with A1 being the least significant
bit. For example, if the sensor-Arduino needs to send a “4”, it would need to send “1-0-0” in binary.
Hence it writes A1 and A2 “LOW” and writes A3 “HIGH”. Then it writes the data-complete flag “HIGH” as
well for a short period of time (25 ms). Electrically, A0 on both Arduinos are connected, and the same
goes for A1-A3. On the motor-Arduino side, it would constantly check in the “void loop()” for when the
A0 data-complete flag is being turned HIGH. When this is the case, it would perform a “digitalRead()” on
pins A1-A3 to see what is the integer command that came across. Then it waits for A0 to be reset to
LOW by the sensor-Arduino, and then starts checking again to see when it’ll be written HIGH again to
read the next set of data. The purpose of the data-complete flag is to guarantee that the motor-Arduino
will never read the data when it is in the middle of its transmission, which would result in the wrong
motor behaviour. The motor rumbling is triggered by completion of the reading of a new motor
command, and the rumbling would stay in this mode until the next new motor command coming from
the sensor-Arduino.

# Demo Video

<a href="http://www.youtube.com/watch?feature=player_embedded&v=6eTz4j7tZ2k
" target="_blank"><img src="http://img.youtube.com/vi/6eTz4j7tZ2k/0.jpg"
alt="IMAGE ALT TEXT HERE" width="240" height="180" border="5" /></a>
