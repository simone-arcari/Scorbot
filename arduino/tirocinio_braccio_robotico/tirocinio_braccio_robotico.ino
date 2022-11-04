#include "robot.h"
#include "string.h"
#include <LiquidCrystal.h>

#define RS 2
#define EN 4
#define D4 7
#define D5 8
#define D6 12
#define D7 13

#define PWM1 3
#define PWM2 5
#define PWM3 6
#define PWM4 9
#define PWM5 10
#define PWM6 11

#define S1MAX 2800
#define S2MAX 3000
#define S3MAX 3300
#define S4MAX 3100
#define S5MAX 3050
#define S6MAX 2100

#define S1MIN 490
#define S2MIN 600
#define S3MIN 400
#define S4MIN 750
#define S5MIN 600
#define S6MIN 1200

#define PIN_LED 13
#define MAX_SIZE 6
#define MOTORS_NUM 6
#define MAX_POINT_NUM 10
#define ARDUINO_ID "ARO22ARL"
#define PROCESSING_ID "PRO04IDE"

point_t pos;
//point_t max = { S1MAX, S2MAX, S3MAX, S4MAX, S5MAX, S6MAX };
//point_t min = { S1MIN, S2MIN, S3MIN, S4MIN, S5MIN, S6MIN };
pwmpin_t pwm = { PWM1, PWM2, PWM3, PWM4, PWM5, PWM6 };

//Robot myRobot = Robot(max, min, pwm);
Robot myRobot = Robot(pwm);
LiquidCrystal lcd(RS, EN, D4, D5, D6, D7);

/*
point_t sequence[MAX_POINT_NUM] = {
  { 1000, 1000, 1000, 1000, 1000, 2000 },  // punto #1
  { 1100, 1000, 1000, 1000, 1000, 2000 },  // punto #2
  { 1200, 1000, 1000, 1000, 1000, 2000 },  // punto #3
  { 1300, 1000, 1000, 1000, 1000, 2000 },  // punto #4
  { 1400, 1000, 1000, 1000, 1000, 2000 },  // punto #5
  { 1500, 1000, 1000, 1000, 1000, 2000 },  // punto #6
  { 1600, 1000, 1000, 1000, 1000, 2000 },  // punto #7
  { 1700, 1000, 1000, 1000, 1000, 2000 },  // punto #8
  { 1800, 1000, 1000, 1000, 1000, 2000 },  // punto #9
  { 1900, 1000, 1000, 1000, 1000, 2000 }   // punto #10
};
*/
int i;
String id;
char buffer[32];
char point_ascii[MOTORS_NUM][4];
uint32_t buffer32[MAX_SIZE];
bool loop_flag = true;


void setup() {

  Serial.begin(9600);
  lcd.begin(16, 2);  
  lcd.print("hello, world!");

  pinMode(PIN_LED, OUTPUT);
  digitalWrite(PIN_LED, LOW);

  if (Serial.available() > 0) {  // pulisco il buffer della porta seriale
    while (Serial.read() != -1);
  }

  if (Serial.availableForWrite()) {
    Serial.write(ARDUINO_ID);
  }

  while (loop_flag) {
    if (Serial.available() >= strlen(PROCESSING_ID)) {
      id = Serial.readString();

      if (id.equals(PROCESSING_ID)) {
        digitalWrite(PIN_LED, HIGH);
        loop_flag = false;
      }
    }
  }

  point_ascii[0][3] = '\0';
  point_ascii[1][3] = '\0';
  point_ascii[2][3] = '\0';
  point_ascii[3][3] = '\0';
  point_ascii[4][3] = '\0';
  point_ascii[5][3] = '\0';
}

void loop() {

  if (Serial.available() >= strlen(PROCESSING_ID)+3*MOTORS_NUM) {
    Serial.readBytes(buffer, strlen(PROCESSING_ID)); // implementare lettura di tot caratteri
    id = buffer;
    
    if (id.equals(PROCESSING_ID)) {
    
      for(i=0; i<MOTORS_NUM; i++) {
        Serial.readBytes(&point_ascii[i][0], 3);
      }
      
      pos.x1 = atoi(&point_ascii[0][0]);
      pos.x2 = atoi(&point_ascii[1][0]);
      pos.x3 = atoi(&point_ascii[2][0]);
      pos.x4 = atoi(&point_ascii[3][0]);
      pos.x5 = atoi(&point_ascii[4][0]);
      pos.x6 = atoi(&point_ascii[5][0]);

      lcd.clear();
      lcd.home();
      lcd.print("pos.x1: ");
      lcd.print(pos.x1);
      lcd.setCursor(0,1);
      lcd.print("str: ");
      lcd.print(&point_ascii[0][0]);
      //myRobot.setPosition(pos);

      if (Serial.availableForWrite()) {
        Serial.write(ARDUINO_ID);
      }
    }
  }
}
