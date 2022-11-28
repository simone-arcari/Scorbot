#ifndef ROBOT_H
#define ROBOT_H

#include <Servo.h>


typedef struct point {

  uint16_t x1;  // impulso servomotore #1
  uint16_t x2;  // impulso servomotore #2
  uint16_t x3;  // impulso servomotore #3
  uint16_t x4;  // impulso servomotore #4
  uint16_t x5;  // impulso servomotore #5
  uint16_t x6;  // impulso servomotore #6

} point_t;

typedef struct pwmpin {

  uint8_t pwm1Pin;  // pin per s1
  uint8_t pwm2Pin;  // pin per s2
  uint8_t pwm3Pin;  // pin per s3
  uint8_t pwm4Pin;  // pin per s4
  uint8_t pwm5Pin;  // pin per s5
  uint8_t pwm6Pin;  // pin per s6

} pwmpin_t;


class Robot {

  public:
    /* attributes */
    pwmpin_t pwmPins;   // pin per i servomotori
    /* servomotor objects */
    Servo s1;
    Servo s2;
    Servo s3;
    Servo s4;
    Servo s5;
    Servo s6;

    /* methods */
    Robot(pwmpin_t);  // costruttore tipo 1
    void setupRobot(void);
    void setPosition(point_t*);
};

/* PUBBLIC */
Robot::Robot(pwmpin_t pwm) {
  pwmPins = pwm;
}

void Robot::setupRobot(void) {

  pinMode(pwmPins.pwm1Pin, OUTPUT);
  pinMode(pwmPins.pwm2Pin, OUTPUT);
  pinMode(pwmPins.pwm3Pin, OUTPUT);
  pinMode(pwmPins.pwm4Pin, OUTPUT);
  pinMode(pwmPins.pwm5Pin, OUTPUT);
  pinMode(pwmPins.pwm6Pin, OUTPUT);

  s1.attach(pwmPins.pwm1Pin);
  s2.attach(pwmPins.pwm2Pin);
  s3.attach(pwmPins.pwm3Pin);
  s4.attach(pwmPins.pwm4Pin);
  s5.attach(pwmPins.pwm5Pin);
  s6.attach(pwmPins.pwm6Pin);
}

void Robot::setPosition(point_t *pos) {

  s1.write(pos->x1);
  s2.write(pos->x2);
  s3.write(pos->x3);
  s4.write(pos->x4);
  s5.write(pos->x5);
  s6.write(pos->x6);
}

#endif /* ROBOT_H */