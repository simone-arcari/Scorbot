#ifndef ROBOT_H
#define ROBOT_H

#include <Servo.h>


typedef struct point {
  
    uint16_t x1;   // impulso servomotore #1
    uint16_t x2;   // impulso servomotore #2
    uint16_t x3;   // impulso servomotore #3
    uint16_t x4;   // impulso servomotore #4
    uint16_t x5;   // impulso servomotore #5
    uint16_t x6;   // impulso servomotore #6
  
}point_t;

typedef struct pwmpin {

    uint8_t pwm2Pin;   // pin per s2
    uint8_t pwm3Pin;   // pin per s3
    uint8_t pwm4Pin;   // pin per s4
    uint8_t pwm5Pin;   // pin per s5
    uint8_t pwm6Pin;   // pin per s6
    uint8_t pwm1Pin;   // pin per s1
    
}pwmpin_t;


class Robot {
  
    public: 
        /* attributes */
        bool type;            // true --> costruttore 1, false --> costruttore 2
        point_t maxPoints;    // finecorsa superiori
        point_t minPoints;    // finecorsa inferiori
        pwmpin_t pwmPins;     // pin per i servomotori

        /* oggetti servomotore */
        Servo s1;
        Servo s2;
        Servo s3;
        Servo s4;
        Servo s5;
        Servo s6;

        bool gripperStatus;   //open == true   close == false

        /* methods */
        Robot(point_t, point_t, pwmpin_t);  // costruttore tipo 1
        Robot(pwmpin_t);                    // costruttore tipo 1
        
        void setPosition(point_t);
        
        //bool isGripperOpened(void);
        //bool isGripperClosed(void);
        
        //void openGripper(void);
        //void closeGripper(void);
    
    private:
        bool chekPosition(point_t pos);
};

/* PUBBLIC */
Robot::Robot(point_t max, point_t min, pwmpin_t pwm) {

    type = true;
    maxPoints = max;
    minPoints = min;
    pwmPins = pwm;

    pinMode(pwm.pwm1Pin, OUTPUT);
    pinMode(pwm.pwm2Pin, OUTPUT);
    pinMode(pwm.pwm3Pin, OUTPUT);
    pinMode(pwm.pwm4Pin, OUTPUT);
    pinMode(pwm.pwm5Pin, OUTPUT);
    pinMode(pwm.pwm6Pin, OUTPUT);

    s1.attach(pwm.pwm1Pin, minPoints.x1, maxPoints.x1);
    s2.attach(pwm.pwm2Pin, minPoints.x1, maxPoints.x2);
    s3.attach(pwm.pwm3Pin, minPoints.x1, maxPoints.x3);
    s4.attach(pwm.pwm4Pin, minPoints.x1, maxPoints.x4);
    s5.attach(pwm.pwm5Pin, minPoints.x1, maxPoints.x5);
    s6.attach(pwm.pwm6Pin, minPoints.x1, maxPoints.x6);

}

Robot::Robot(pwmpin_t pwm) {

    type = false;
    pwmPins = pwm;

    pinMode(pwm.pwm1Pin, OUTPUT);
    pinMode(pwm.pwm2Pin, OUTPUT);
    pinMode(pwm.pwm3Pin, OUTPUT);
    pinMode(pwm.pwm4Pin, OUTPUT);
    pinMode(pwm.pwm5Pin, OUTPUT);
    pinMode(pwm.pwm6Pin, OUTPUT);

    s1.attach(pwm.pwm1Pin);
    s2.attach(pwm.pwm2Pin);
    s3.attach(pwm.pwm3Pin);
    s4.attach(pwm.pwm4Pin);
    s5.attach(pwm.pwm5Pin);
    s6.attach(pwm.pwm6Pin);

}

void Robot::setPosition(point_t pos) {

    if (type == true) {
        if(chekPosition(pos)) {
            s1.writeMicroseconds(pos.x1);
            s2.writeMicroseconds(pos.x2);
            s3.writeMicroseconds(pos.x3);
            s4.writeMicroseconds(pos.x4);
            s5.writeMicroseconds(pos.x5);
            s6.writeMicroseconds(pos.x6);

        }else {

            Serial.println("error setPosition(): posizioni dei motori non conformi");
        }
    } else {
        if(chekPosition(pos)) {
            s1.write(pos.x1);
            s2.write(pos.x2);
            s3.write(pos.x3);
            s4.write(pos.x4);
            s5.write(pos.x5);
            s6.write(pos.x6);

        }else {

            Serial.println("error setPosition(): posizioni dei motori non conformi");
        }      
    }
}
/*
bool Robot::isGripperOpened(void) {

    return gripperStatus;
}

bool Robot::isGripperClosed(void){

    return !gripperStatus;
}

void Robot::openGripper(void) {

    s6.writeMicroseconds(maxPoints.x6);
}

void Robot::closeGripper(void) {

    s6.writeMicroseconds(minPoints.x6);
}
*/

/* PRIVATE */
bool Robot::chekPosition(point_t pos) {

    if (type == true) {
        return (pos.x1>=minPoints.x1 && pos.x1<=maxPoints.x1) &&
               (pos.x2>=minPoints.x2 && pos.x2<=maxPoints.x2) &&
               (pos.x3>=minPoints.x3 && pos.x3<=maxPoints.x3) &&
               (pos.x4>=minPoints.x4 && pos.x4<=maxPoints.x4) &&
               (pos.x5>=minPoints.x5 && pos.x5<=maxPoints.x5) &&
               (pos.x6>=minPoints.x6 && pos.x6<=maxPoints.x6);
    } else {
        return (pos.x1>=0 && pos.x1<=180) &&
               (pos.x2>=0 && pos.x2<=180) &&
               (pos.x3>=0 && pos.x3<=180) &&
               (pos.x4>=0 && pos.x4<=180) &&
               (pos.x5>=0 && pos.x5<=180) &&
               (pos.x6>=0 && pos.x6<=65);
    }
}

#endif  /* ROBOT_H */
