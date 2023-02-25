float xBase;                                                                                                    // coordinate x del centro del pavimento rispetto al riferimento assoluto dello spazio di disegno di processing
float yBase;                                                                                                    // coordinate y del centro del pavimento rispetto al riferimento assoluto dello spazio di disegno di processing
float zBase;                                                                                                    // coordinate z del centro del pavimento rispetto al riferimento assoluto dello spazio di disegno di processing

// Motore: corpo principale
float motorHeight = 40;                                                                                         // 4cm
float motorWidth = 40;                                                                                          // 4cm
float motorDepth = 25;                                                                                          // 2.5cm

// Motore: ingranaggio
float gearHeight = 12;                                                                                          // 1.2cm
float gearWidth = 8;                                                                                            // 0.8cm
float gearDepth = gearWidth;                                                                                    // 0.8cm
float gearOffset = 10;                                                                                          // 1cm (dalla posizione centrale)

// Pavimento
float xFloor = 580;                                                                                             // 58cm
float yFloor = 10;                                                                                              // 1cm
float zFloor = 410;                                                                                             // 41cm

// Base
float xBlock1 = 90;                                                                                             // 9cm
float yBlock1 = 28;                                                                                             // 2.8cm
float zBlock1 = 90;                                                                                             // 9cm
float xOffsetBase = 95;                                                                                         // 9.5cm
float zOffsetBase = 70;                                                                                         // 7cm
float xBlock2 = 25;                                                                                             // 2.5cm
float yBlock2 = 42;                                                                                             // 4.2cm
float zBlock2 = 90;                                                                                             // 9cm

// Spostamento verticale motore1
float yOffsetM1 = 17;                                                                                           // 1.7cm

// Spostamento in profondità Gabbia motore1
float zOffsetGM1 = 4;                                                                                           // 0.4cm

// Gabbia motore1
float xBlock3 = 62;                                                                                             // 6.2cm
float yBlock3 = 2;                                                                                              // 0.2cm
float zBlock3 = 25;                                                                                             // 2.5cm
float xBlock4 = 2;                                                                                              // 0.2cm
float yBlock4 = 54;                                                                                             // 5.4cm
float zBlock4 = 25;                                                                                             // 2.5cm
float xBlock5 = 70;                                                                                             // 7cm
float yBlock5 = 2;                                                                                              // 0.2cm
float zBlock5 = 25;                                                                                             // 2.5cm

// Spostamento orizzontale motore2
float xOffsetM2 = xBlock3 -(motorDepth/2+gearOffset+xBlock5/2);                                                 // 0.45cm

// Gabbia motore2_3_4
float xBlock6 = 62;                                                                                             // 6.2cm
float yBlock6 = 25;                                                                                             // 2.5cm
float zBlock6 = 2;                                                                                              // 0.2cm
float xBlock7 = 2;                                                                                              // 0.2cm
float yBlock7 = 25;                                                                                             // 2.5cm
float zBlock7 = 54;                                                                                             // 5.4cm

// Connessione motore3 con gabbia motore4
float xBlock8 = 55;                                                                                             // 5.5cm
float yBlock8 = 2;                                                                                              // 0.2cm
float zBlock8 = 25;                                                                                             // 2.5cm
float xBlock9 = 2;                                                                                              // 0.2cm
float yBlock9 = 27;                                                                                             // 2.7cm
float zBlock9 = 25;                                                                                             // 2.5cm

// Connessione motore4 con motore5
float xBlock10 = 48;                                                                                            // 4.8cm
float yBlock10 = 2;                                                                                             // 0.2cm
float zBlock10 = 25;                                                                                            // 2.5cm
float xBlock11 = 2;                                                                                             // 0.2cm
float yBlock11 = motorDepth+2;                                                                                  // 2.7cm
float zBlock11 = motorWidth;                                                                                    // 4cm

// Spostamento orizzontale motore5 (placca di fissaggio non compresa)
float xOffsetM5 = 15;                                                                                           // 1.5cm

// Connessione motore5 con la pinza
float xBlock12 = 4;                                                                                             // 0.4cm
float yBlock12 = 16;                                                                                            // 1.6cm
float zBlock12 = yBlock12;                                                                                      // 1.6cm
float xBlock13 = 50;                                                                                            // 5cm
float yBlock13 = 2;                                                                                             // 0.2cm
float zBlock13 = 40;                                                                                            // 4cm
float xBlock14 = motorDepth;                                                                                    // 2.5cm
float yBlock14 = 2;                                                                                             // 0.2cm
float zBlock14 = motorWidth;                                                                                    // 4cm
float xBlock15 = motorDepth;                                                                                    // 2.5cm
float yBlock15 = 10+gearHeight;                                                                                 // 2.2cm
float zBlock15 = 2;                                                                                             // 0.2cm

// Spostamento in profondità motore6
float zOffsetM6 = 8;                                                                                            // 0.8cm

// Spostamento in verticale motore6
float yOffsetM6 = gearHeight-4;                                                                                 // 0.8cm

// Pinza
float xBlock16 = 20;                                                                                            // 4cm
float yBlock16 = 5;                                                                                             // 0.5cm
float zBlock16 = 10;                                                                                            // 1cm
float xBlock17 = 20;                                                                                            // 3cm
float yBlock17 = yBlock16;                                                                                      // 0.5cm
float zBlock17 = zBlock16;                                                                                      // 1cm
float xBlock18 = 25;                                                                                            // 3.5cm
float yBlock18 = yBlock16;                                                                                      // 0.5cm
float zBlock18 = zBlock16;                                                                                      // 1cm

// Variabile per disegnare la pinza
float omega = PI/2-acos((zBlock17/2)/xBlock17);                                                                 // questo angolo deriva da considerazioni geometriche per il disegno della pinza
float offsetPinza = zBlock16/2*sin(omega);                                                                      // questa distanza deriva da considerazioni geometriche per il disegno della pinza

// Variabili varie
int direction = 1;                                                                                              // verso rotazione motori per la modalità a controllo manuale
int MOTORS_NUM = 6;                                                                                             // numero motori = numero di coordinate per ogni frames
int FRAMES_NUM = 10 ;                                                                                           // numero massimo di frames(ogni frames ha sei coordinate)
float[][] frames;                                                                                               // matrice di frames / angoli
int framesCount = 0;                                                                                            // contatore dei punti/frame presenti nella sequenza

// Angoli d'interesse
float alpha = rad(180);
float beta = 0;
float[] theta = new float[6];
float[] realServoTheta = new float[6];
float[] thetaSign = {1,-1,1,1,-1,-1};
float[] thetaInit = {rad(0),rad(-60),rad(40),rad(20),rad(0),rad(0)};
float[] thetaOffset = {rad(90),rad(0),rad(90),rad(90),rad(0),rad(65)};

// Parametri Scorbot
float d1 = yBlock1+yBlock2/2+yOffsetM1+motorHeight/2+gearHeight+motorDepth/2;
float d4 = 0;
float d5 = 155.5;
float l2 = 2*xBlock6-motorDepth+xBlock7/2;
float l3 = -motorWidth/2+gearOffset+xBlock8+xBlock6-motorDepth/2;
float a4 = 26.5;


// Colori
int FLOOR_COLOR   = #E5E06D;                                                                                    // colore del pavimento
int CHASSIS_COLOR = #C4C0C0;                                                                                    // colore del robot
int MOTOR_COLOR   = #000000;                                                                                    // colore motori
int GEAR_COLOR    = #A09908;                                                                                    // colore ingranaggi
int SPHERE_COLOR  = #27D8CE;                                                                                    // colore della sfere posizionata in (x_d, y_d, z_d)
int STANDARD_STROKE_COLOR = #FAFAFA;                                                                            // colore di default per le linee di contorno 

float SPHERE_RADIUS = 4;


void drawFloor() {
  fill(FLOOR_COLOR);                                                                                            // imposto colore del pavimento
  translate(xBase, yBase, zBase);
  rotateY(alpha);
  rotateX(beta);
  box(xFloor, yFloor, zFloor);
  translate(-xFloor/2+xBlock1/2+xOffsetBase, -(yFloor/2+yBlock1/2), -zFloor/2+zBlock1/2+zOffsetBase);
}


void drawRobot() {
  
  // Base
  fill(CHASSIS_COLOR);                                                                                          // imposto colore del robot
   
  box(xBlock1, yBlock1, zBlock1);
  translate(-xBlock1/2+xBlock2/2, -(yBlock1/2+yBlock2/2), 0);
  box(xBlock2, yBlock2, zBlock2);

  // Motore1
  fill(MOTOR_COLOR);                                                                                            // imposto colore motore
  translate(xBlock2/2+motorDepth/2, -yOffsetM1, 0);
  box(motorDepth, motorHeight, motorWidth);
  fill(GEAR_COLOR);                                                                                             // imposto colore ingranaggio
  translate(0, -(motorHeight/2+gearHeight/2), gearOffset);                                                                                                 
  rotateY(theta[0]);                                                                                            // [AXIS.1]----------------------------------------------------------------------------->asse rotazione motore 1
  box(gearDepth, gearHeight, gearWidth);
  rotateY(120*PI/180);                                                                                          // questa rotate serve per disegnare una parte dell'ingranaggio
  box(gearDepth, gearHeight, gearWidth);
  rotateY(120*PI/180);                                                                                          // questa rotate serve per disegnare una parte dell'ingranaggio
  box(gearDepth, gearHeight, gearWidth);
  rotateY(120*PI/180);                                                                                          // questa rotate serve per tornare all'angolo iniziale

  // Gabbia motore1
  fill(CHASSIS_COLOR);                                                                                          // imposto colore del robot
  translate(xBlock3/2-motorDepth/2, motorHeight+yBlock3/2+gearHeight/2, -zOffsetGM1);
  box(xBlock3, yBlock3, zBlock3);
  translate(xBlock3/2-xBlock4/2, -yBlock4/2+yBlock3/2, 0);
  box(xBlock4, yBlock4, zBlock4);
  translate(-xBlock5/2+xBlock4/2, -yBlock4/2+yBlock5/2, 0);
  box(xBlock5, yBlock5, zBlock5);

  // Motore2
  fill(MOTOR_COLOR);                                                                                            // imposto colore motore
  translate(-xOffsetM2, -(motorDepth/2+yBlock5/2), -gearHeight/2);
  box(motorWidth, motorDepth, motorHeight);
  fill(GEAR_COLOR);                                                                                             // imposto colore ingranaggio
  translate(-gearOffset, 0, motorHeight/2+gearHeight/2);
  rotateZ(theta[1]);                                                                                            // [AXIS.2]----------------------------------------------------------------------------->asse rotazione motore 2
  box(gearWidth, gearDepth, gearHeight);
  rotateZ(120*PI/180);                                                                                          // questa rotate serve per disegnare una parte dell'ingranaggio
  box(gearWidth, gearDepth, gearHeight);
  rotateZ(120*PI/180);                                                                                          // questa rotate serve per disegnare una parte dell'ingranaggio
  box(gearWidth, gearDepth, gearHeight);
  rotateZ(120*PI/180);                                                                                          // questa rotate serve per tornare all'angolo iniziale
  
  // Gabbia motore2
  fill(CHASSIS_COLOR);                                                                                          // imposto colore del robot
  translate(xBlock6/2-motorDepth/2, 0, gearHeight/2-zBlock6/2);
  box(xBlock6, yBlock6, zBlock6);
  translate(xBlock6/2-xBlock7/2, 0, -zBlock7/2+zBlock6/2);
  box(xBlock7, yBlock7, zBlock7);
  translate(-xBlock6/2+xBlock7/2, 0, -zBlock7/2+zBlock6/2);
  box(xBlock6, yBlock6, zBlock6);

  // Gabbia motore3
  translate(xBlock6, 0, 0);
  box(xBlock6, yBlock6, zBlock6);
  translate(-xBlock6/2+xBlock7/2, 0, zBlock7/2-zBlock6/2);
  box(xBlock7, yBlock7, zBlock7);
  pushMatrix();                                                                                                 // memorizzo il sistema di riferimeto attuale
  translate(xBlock6/2-xBlock7/2, 0, zBlock7/2-zBlock6/2);
  box(xBlock6, yBlock6, zBlock6);
  popMatrix();                                                                                                  // ritorno al sistema di riferimento memorizzato precedentemete

  // Motore3
  fill(GEAR_COLOR);                                                                                             // imposto colore ingranaggio
  translate(xBlock6-motorDepth/2, 0, zBlock7/2-gearHeight/2);
  box(gearWidth, gearDepth, gearHeight);
  rotateZ(120*PI/180);                                                                                          // questa rotate serve per disegnare una parte dell'ingranaggio
  box(gearWidth, gearDepth, gearHeight);
  rotateZ(120*PI/180);                                                                                          // questa rotate serve per disegnare una parte dell'ingranaggio
  box(gearWidth, gearDepth, gearHeight);
  rotateZ(120*PI/180);                                                                                          // questa rotate serve per tornare all'angolo iniziale
  rotateZ(theta[2]);                                                                                            // [AXIS.3]----------------------------------------------------------------------------->asse rotazione motore 3
  fill(MOTOR_COLOR);                                                                                            // imposto colore motore
  translate(gearOffset, 0, -motorHeight/2-gearHeight/2);
  box(motorWidth, motorDepth, motorHeight);
  
  // Connessione motore3 con gabbia motore4
  fill(CHASSIS_COLOR);                                                                                          // imposto colore del robot
  translate((xBlock8-motorWidth)/2, motorDepth/2+yBlock8/2, (gearHeight-zBlock6)/2);
  box(xBlock8, yBlock8, zBlock8);
  translate(xBlock8/2-xBlock9/2, -yBlock9/2+yBlock8/2, 0);
  box(xBlock9, yBlock9, zBlock9);

  // Gabbia motore4
  translate(xBlock9, -yBlock8/2, 0);
  box(xBlock7, yBlock7, zBlock7);
  pushMatrix();                                                                                                 // memorizzo il sistema di riferimeto attuale
  translate(xBlock6/2-xBlock7/2, 0, -zBlock7/2+zBlock6/2);
  box(xBlock6, yBlock6, zBlock6);
  translate(0, 0, zBlock7-zBlock6);
  box(xBlock6, yBlock6, zBlock6);
  popMatrix();                                                                                                  // ritorno al sistema di riferimento memorizzato precedentemete

  // Motore4
  fill(GEAR_COLOR);                                                                                             // imposto colore ingranaggio
  translate(xBlock6-motorDepth/2, 0, zBlock7/2-gearHeight/2);
  box(gearWidth, gearDepth, gearHeight);
  rotateZ(120*PI/180);                                                                                          // questa rotate serve per disegnare una parte dell'ingranaggio
  box(gearWidth, gearDepth, gearHeight);
  rotateZ(120*PI/180);                                                                                          // questa rotate serve per disegnare una parte dell'ingranaggio
  box(gearWidth, gearDepth, gearHeight);
  rotateZ(120*PI/180);                                                                                          // questa rotate serve per tornare all'angolo iniziale
  rotateZ(theta[3]);                                                                                            // [AXIS.4]----------------------------------------------------------------------------->asse rotazione motore 4
  fill(MOTOR_COLOR);                                                                                            // imposto colore motore
  translate(gearOffset, 0, -motorHeight/2-gearHeight/2);
  box(motorWidth, motorDepth, motorHeight);

  // Connessione motore4 con gabbia motore5
  fill(CHASSIS_COLOR);                                                                                          // imposto colore del robot
  translate((xBlock10-motorWidth)/2, -(motorDepth/2+yBlock10/2), 0);
  box(xBlock10, yBlock10, zBlock10);
  translate(xOffsetM5-xBlock10/2, -yBlock11/2+yBlock10/2, 0);
  box(xBlock11, yBlock11, zBlock11);

  // Motore5
  fill(MOTOR_COLOR);                                                                                            // imposta colore motore
  translate(motorHeight/2+xBlock11/2, -(yBlock11-motorDepth)/2, 0);
  box(motorHeight, motorDepth, motorWidth);
  fill(GEAR_COLOR);                                                                                             // imposto colore ingranaggio
  translate(motorHeight/2+gearHeight/2, 0, gearOffset);
  rotateX(theta[4]);                                                                                            // [AXIS.5]----------------------------------------------------------------------------->asse rotazione motore 5
  box(gearHeight, gearDepth, gearWidth);
  rotateX(120*PI/180);                                                                                          // questa rotate serve per disegnare una parte dell'ingranaggio
  box(gearHeight, gearDepth, gearWidth);
  rotateX(120*PI/180);                                                                                          // questa rotate serve per disegnare una parte dell'ingranaggio
  box(gearHeight, gearDepth, gearWidth);
  rotateX(120*PI/180);                                                                                          // questa rotate serve per tornare all'angolo iniziale

  // Connessione motore5 con la pinza
  fill(CHASSIS_COLOR);                                                                                          // imposta colore del robot
  translate(gearHeight/2-xBlock12/2, 0, 0);
  box(xBlock12, yBlock12, zBlock12);
  translate(xBlock13/2+xBlock12/2, 0, 0);
  box(xBlock13, yBlock13, zBlock13);
  pushMatrix();                                                                                                 //  memorizzo il sistema di riferimeto attuale[1]
  translate(0, 0, -(zBlock13/2+zOffsetM6));
  box(xBlock14, yBlock14, zBlock14);
  pushMatrix();                                                                                                 // memorizzo il sistema di riferimeto attuale[2]
  translate(0, -yBlock15/2+yBlock14/2, zBlock14/2+zBlock15/2);
  box(xBlock15, yBlock15, zBlock15);
  translate(0, 0, -zBlock14-zBlock15);
  box(xBlock15, yBlock15, zBlock15);
  popMatrix();                                                                                                  // ritorno al sistema di riferimento memorizzato precedentemete[2]

  // Motore6
  fill(MOTOR_COLOR);                                                                                            // imposto colore motore
  translate(0, -(motorHeight/2+yBlock14/2)-yOffsetM6, 0);
  box(motorDepth, motorHeight, motorWidth);
  fill(GEAR_COLOR);                                                                                             // imposto colore ingranaggio
  translate(0, motorHeight/2+gearHeight/2, gearOffset);
  rotateY(theta[5]);                                                                                            // [AXIS.6]----------------------------------------------------------------------------->regola l'apertura della pinza(non è un vero asse)
  box(gearDepth, gearHeight, gearWidth);
  rotateY(120*PI/180);                                                                                          // questa rotate serve per disegnare una parte dell'ingranaggio
  box(gearDepth, gearHeight, gearWidth);
  rotateY(120*PI/180);                                                                                          // questa rotate serve per disegnare una parte dell'ingranaggio
  box(gearDepth, gearHeight, gearWidth);
  rotateY(120*PI/180);                                                                                          // questa rotate serve per tornare all'angolo iniziale
  popMatrix();                                                                                                  // ritorno al sistema di riferimento memorizzato precedentemete[1] (ricorda il popMatrix qui sopra, serve per disegnare la pinza)

  // Pinza
  fill(CHASSIS_COLOR);                                                                                          // imposto colore del robot
  pushMatrix();                                                                                                 // memorizzo il sistema di riferimeto attuale

  translate(zBlock16, -yBlock16/2 -yBlock13/2, zBlock16);
  translate(zBlock16/2, yBlock16/2+yBlock13/2, 0);
  rotateY(-theta[5]);
  translate(+xBlock16/2-zBlock16/2, 0, 0);
  box(xBlock16, yBlock16, zBlock16);

  translate(xBlock16/2-offsetPinza, 0, 0);
  rotateY(+theta[5]);
  rotateY(omega);                                                                                               // numericamente sarebbe: rotateY(9.59*PI/180);
  translate(xBlock17/2, 0, 0);
  box(xBlock17, yBlock17, zBlock17);

  translate(xBlock17/2-offsetPinza, 0, 0);
  rotateY(-omega);                                                                                              // numericamente sarebbe: rotateY(-9.59*PI/180);
  translate(xBlock18/2, 0, 0);
  box(xBlock18, yBlock18, zBlock18);

  popMatrix();                                                                                                  // ritorno al sistema di riferimento memorizzato precedentemete

  translate(zBlock16, -yBlock16/2 -yBlock13/2, -zBlock16);
  translate(zBlock16/2, yBlock16/2+yBlock13/2, 0);
  rotateY(theta[5]);
  translate(+xBlock16/2-zBlock16/2, 0, 0);
  box(xBlock16, yBlock16, zBlock16);

  translate(xBlock16/2-offsetPinza, 0, 0);
  rotateY(-theta[5]);
  rotateY(-omega);                                                                                              // numericamente sarebbe: rotateY(-9.59*PI/180);
  translate(xBlock17/2, 0, 0);
  box(xBlock17, yBlock17, zBlock17);

  translate(xBlock17/2-offsetPinza, 0, 0);
  rotateY(omega);                                                                                               // numericamente sarebbe: rotateY(9.59*PI/180);
  translate(xBlock18/2, 0, 0);
  box(xBlock18, yBlock18, zBlock18);
}

void drawBall() {
  pushMatrix();
  
  translate(-xBlock1/2+xBlock2+motorDepth/2, yBlock1/2, gearOffset);
  translate(y_d, -z_d, x_d);
  
  fill(SPHERE_COLOR);
  stroke(SPHERE_COLOR);
  
  sphere(SPHERE_RADIUS);
  
  stroke(STANDARD_STROKE_COLOR);
  popMatrix();
}
