#include "robot.h"
#include "string.h"
#include <Servo.h>
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

#define PIN_LED 13
#define MAX_SIZE 6
#define MOTORS_NUM 6
#define MAX_POINT_NUM 10
#define ARDUINO_ID "ARO22ARL"
#define PROCESSING_ID "PRO04IDE"

point_t pos;
pwmpin_t pwm = { PWM1, PWM2, PWM3, PWM4, PWM5, PWM6 };

Robot myRobot = Robot(pwm);
LiquidCrystal lcd(RS, EN, D4, D5, D6, D7);

int i;
String id;
char buffer[32];
char point_ascii[MOTORS_NUM][4];
uint32_t buffer32[MAX_SIZE];
bool loop_flag = true;


void setup() {

  Serial.begin(9600);
  lcd.begin(16, 2);  
  lcd.print("Hello Scorbot!");
  myRobot.setupRobot();

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

      lcd.print(&point_ascii[0][0]);
      lcd.print("-");
      lcd.print(&point_ascii[1][0]);
      lcd.print("-");
      lcd.print(&point_ascii[2][0]);

      lcd.setCursor(0,1);

      lcd.print(&point_ascii[3][0]);
      lcd.print("-");
      lcd.print(&point_ascii[4][0]);
      lcd.print("-");
      lcd.print(&point_ascii[5][0]);

      myRobot.setPosition(&pos);

      if (Serial.availableForWrite()) {
        Serial.write(ARDUINO_ID);
      }
    }
  }
}
