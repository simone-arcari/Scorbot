float xBase;
float yBase;
float zBase;

// Motore: corpo principale
float motorHeight = 40;         // 4cm
float motorWidth = 40;          // 4cm
float motorDepth = 25;          // 2.5cm

// Motore: ingranaggio
float gearHeight = 12;          // 1.2cm
float gearWidth = 8;            // 0.8cm
float gearDepth = gearWidth;    // 0.8cm
float gearOffset = 10;          // 1cm (dalla posizionecentrale)

// Pavimento
float xFloor = 580;             // 58cm
float yFloor = 10;              // 1cm
float zFloor = 410;             // 41cm

// Base
float xBlock1 = 90;             // 9cm
float yBlock1 = 28;             // 2.8cm
float zBlock1 = 90;             // 9cm
float xOffsetBase = 95;         // 9.5cm
float zOffsetBase = 70;         // 7cm
float xBlock2 = 25;             // 2.5cm
float yBlock2 = 42;             // 4.2cm
float zBlock2 = 90;             // 9cm

// Spostamento verticale motore1
float yOffsetM1 = 17;           // 1.7cm

// Gabbia motore1
float xBlock3 = 62;             // 6.2cm
float yBlock3 = 2;              // 0.2cm
float zBlock3 = 25;             // 2.5cm
float xBlock4 = 2;              // 0.2cm
float yBlock4 = 54;             // 5.4cm
float zBlock4 = 25;             // 2.5cm
float xBlock5 = 70;             // 7cm
float yBlock5 = 2;              // 0.2cm
float zBlock5 = 25;             // 2.5cm

// Spostamento orizzontale motore2
float xOffsetM2 = xBlock3 -(motorDepth/2+gearOffset+xBlock5/2);   // 0.45cm

// Gabbia motore2_3_4
float xBlock6 = 62;             // 6.2cm
float yBlock6 = 25;             // 2.5cm
float zBlock6 = 2;              // 0.2cm
float xBlock7 = 2;              // 0.2cm
float yBlock7 = 25;             // 2.5cm
float zBlock7 = 54;             // 5.4cm

// Connessione motore3 con gabbia motore4
float xBlock8 = 55;             // 5.5cm
float yBlock8 = 2;              // 0.2cm
float zBlock8 = 25;             // 2.5cm
float xBlock9 = 2;              // 0.2cm
float yBlock9 = 27;             // 2.7cm
float zBlock9 = 25;             // 2.5cm

// Connessione motore4 con motore5
float xBlock10 = 48;            // 4.8cm
float yBlock10 = 2;             // 0.2cm
float zBlock10 = 25;            // 2.5cm
float xBlock11 = 2;             // 0.2cm
float yBlock11 = motorDepth+2;  // 2.7cm
float zBlock11 = motorWidth;    // 4cm

// Spostamento orizzontale motore5 (placca di fissaggio non compresa)
float xOffsetM5 = 15;           // 1.5cm

// Connessione motore5 con la pinza
float xBlock12 = 4;             // 0.4cm
float yBlock12 = 16;            // 1.6cm
float zBlock12 = yBlock12;      // 1.6cm
float xBlock13 = 50;            // 5cm
float yBlock13 = 2;             // 0.2cm
float zBlock13 = 40;            // 4cm
float xBlock14 = motorDepth;    // 2.5cm
float yBlock14 = 2;             // 0.2cm
float zBlock14 = motorWidth;    // 4cm
float xBlock15 = motorDepth;    // 2.5cm
float yBlock15 = 10+gearHeight; // 2.2cm
float zBlock15 = 2;             // 0.2cm

// Spostamento in profondità motore6
float zOffsetM6 = 8;            // 0.8cm

// Spostamento in verticale motore6
float yOffsetM6 = gearHeight-4; // 0.8cm

// Pinza
float xBlock16 = 40;            // 4cm
float yBlock16 = 5;             // 0.5cm
float zBlock16 = 10;            // 1cm
float xBlock17 = 30;            // 3cm
float yBlock17 = yBlock16;      // 0.5cm
float zBlock17 = zBlock16;      // 1cm
float xBlock18 = 35;            // 3.5cm
float yBlock18 = yBlock16;      // 0.5cm
float zBlock18 = zBlock16;      // 1cm

// Variabile per disegnare la pinza
float omega = PI/2-acos((zBlock17/2)/xBlock17);
float offsetPinza = zBlock16/2*sin(omega);

int direction = 1;                                                                                              // verso rotazione motori per la modalità a controllo manuale
int MOTORS_NUM = 6;                                                                                             // numero motori = numero di coordinate per ogni frames
int MAX_FRAMES = 10 ;                                                                                           // numero massimo di frames(ogni frames ha sei coordinate)
int[][] punti = new int[MAX_FRAMES][MOTORS_NUM];                                                                // matrice di punti / coordinate
int pointCount = 0;                                                                                             // contatore dei punti/frame presenti nella sequenza

// Angoli d'interesse
float alpha = 0;
float beta = 0;

float[] theta = new float[6];
float[] realServoTheta = new float[6];
float[] thetaSign = {1,-1,1,1,-1,-1};
float[] thetaInit = {rad(0),rad(-60),rad(40),rad(20),rad(0),rad(0)};
float[] thetaOffset = {rad(90),rad(0),rad(90),rad(90),rad(0),rad(65)};


void drawRobot() {

  // Base
  fill(#C4C0C0);  // Colore del robot
  translate(-xFloor/2+xBlock1/2+xOffsetBase, -(yFloor/2+yBlock1/2), -zFloor/2+zBlock1/2+zOffsetBase);
  box(xBlock1, yBlock1, zBlock1);
  translate(-xBlock1/2+xBlock2/2, -(yBlock1/2+yBlock2/2), 0);
  box(xBlock2, yBlock2, zBlock2);

  // Motore1
  fill(#000000);  // Colore motore
  translate(xBlock2/2+motorDepth/2, -yOffsetM1, 0);
  box(motorDepth, motorHeight, motorWidth);
  fill(#A09908);  // Colore ingranaggio
  translate(0, -(motorHeight/2+gearHeight/2), gearOffset);
  rotateY(theta[0]);  // Asse rotazione motore1
  box(gearDepth, gearHeight, gearWidth);
  rotateY(120*PI/180);  // Per disegnare ingranaggio
  box(gearDepth, gearHeight, gearWidth);
  rotateY(120*PI/180);  // Per disegnare ingranaggio
  box(gearDepth, gearHeight, gearWidth);
  rotateY(120*PI/180);  // Torno all'angolo iniziale

  // Gabbia motore1
  fill(#C4C0C0);  // Colore del robot
  translate(xBlock3/2-motorDepth/2, motorHeight+yBlock3/2+gearHeight/2, 0);
  box(xBlock3, yBlock3, zBlock3);
  translate(xBlock3/2-xBlock4/2, -yBlock4/2+yBlock3/2, 0);
  box(xBlock4, yBlock4, zBlock4);
  translate(-xBlock5/2+xBlock4/2, -yBlock4/2+yBlock5/2, 0);
  box(xBlock5, yBlock5, zBlock5);

  // Motore2
  fill(#000000);  // Colore motore
  translate(-xOffsetM2, -(motorDepth/2+yBlock5/2), -gearHeight/2);
  box(motorWidth, motorDepth, motorHeight);
  fill(#A09908);  // Colore ingranaggio
  translate(-gearOffset, 0, motorHeight/2+gearHeight/2);
  rotateZ(theta[1]);  // Asse rotazione motore2
  box(gearWidth, gearDepth, gearHeight);
  rotateZ(120*PI/180);  // Per disegnare ingranaggio
  box(gearWidth, gearDepth, gearHeight);
  rotateZ(120*PI/180);  // Per disegnare ingranaggio
  box(gearWidth, gearDepth, gearHeight);
  rotateZ(120*PI/180);  // Torno all'angolo iniziale

  // Gabbia motore2
  fill(#C4C0C0);  // colore del robot
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
  pushMatrix(); // Memorizzo il sistema attuale
  translate(xBlock6/2+xBlock7/2, 0, zBlock7/2-zBlock6/2);
  box(xBlock6, yBlock6, zBlock6);
  popMatrix();  // Ritorno al sistema di riferimento memorizzato

  // Motore3
  fill(#A09908);  // Colore ingranaggio
  translate(xBlock6-motorDepth/2, 0, zBlock7/2-gearHeight/2);
  box(gearWidth, gearDepth, gearHeight);
  rotateZ(120*PI/180);  // Per disegnare ingranaggio
  box(gearWidth, gearDepth, gearHeight);
  rotateZ(120*PI/180);  // Per disegnare ingranaggio
  box(gearWidth, gearDepth, gearHeight);
  rotateZ(120*PI/180);  // Torno all'angolo iniziale
  rotateZ(theta[2]);  // Asse rotazione motore3
  fill(#000000);  // Colore motore
  translate(gearOffset, 0, -motorHeight/2-gearHeight/2);
  box(motorWidth, motorDepth, motorHeight);

  // Connessione motore3 con gabbia motore4
  fill(#C4C0C0);  // Colore del robot
  translate((xBlock8-motorWidth)/2, motorDepth/2+yBlock8/2, (gearHeight-zBlock6)/2);
  box(xBlock8, yBlock8, zBlock8);
  translate(xBlock8/2-xBlock9/2, -yBlock9/2+yBlock8/2, 0);
  box(xBlock9, yBlock9, zBlock9);

  // Gabbia motore4
  translate(xBlock9, -yBlock8/2, 0);
  box(xBlock7, yBlock7, zBlock7);
  pushMatrix();  // Memorizzo il sistema attuale
  translate(xBlock6/2-xBlock7/2, 0, -zBlock7/2+zBlock6/2);
  box(xBlock6, yBlock6, zBlock6);
  translate(0, 0, zBlock7-zBlock6);
  box(xBlock6, yBlock6, zBlock6);
  popMatrix();  // Ritorno al sistema di riferimento memorizzato

  // Motore4
  fill(#A09908);  // Colore ingranaggio
  translate(xBlock6-motorDepth/2, 0, zBlock7/2-gearHeight/2);
  box(gearWidth, gearDepth, gearHeight);
  rotateZ(120*PI/180);  // Per disegnare ingranaggio
  box(gearWidth, gearDepth, gearHeight);
  rotateZ(120*PI/180);  // Per disegnare ingranaggio
  box(gearWidth, gearDepth, gearHeight);
  rotateZ(120*PI/180);  // Torno all'angolo iniziale
  rotateZ(theta[3]);  // Asse rotazione motore4
  fill(#000000);  // Colore motore
  translate(gearOffset, 0, -motorHeight/2-gearHeight/2);
  box(motorWidth, motorDepth, motorHeight);

  // Connessione motore4 con gabbia motore5
  fill(#C4C0C0);  // Colore del robot
  translate((xBlock10-motorWidth)/2, -(motorDepth/2+yBlock10/2), 0);
  box(xBlock10, yBlock10, zBlock10);
  translate(xOffsetM5-xBlock10/2, -yBlock11/2+yBlock10/2, 0);
  box(xBlock11, yBlock11, zBlock11);

  // Motore5
  fill(#000000);  // Colore motore
  translate(motorHeight/2+xBlock11/2, -(yBlock11-motorDepth)/2, 0);
  box(motorHeight, motorDepth, motorWidth);
  fill(#A09908);  // Colore ingranaggio
  translate(motorHeight/2+gearHeight/2, 0, gearOffset);
  rotateX(theta[4]);  // Asse rotazione motore5
  box(gearHeight, gearDepth, gearWidth);
  rotateX(120*PI/180);  // Per disegnare ingranaggio
  box(gearHeight, gearDepth, gearWidth);
  rotateX(120*PI/180);  // Per disegnare ingranaggio
  box(gearHeight, gearDepth, gearWidth);
  rotateX(120*PI/180);  // Torno all'angolo iniziale

  // Connessione motore5 con la pinza
  fill(#C4C0C0);  // Colore del robot
  translate(gearHeight/2-xBlock12/2, 0, 0);
  box(xBlock12, yBlock12, zBlock12);
  translate(xBlock13/2+xBlock12/2, 0, 0);
  box(xBlock13, yBlock13, zBlock13);
  pushMatrix();  // Memorizzo il sistema attuale
  translate(0, 0, -(zBlock13/2+zOffsetM6));
  box(xBlock14, yBlock14, zBlock14);
  pushMatrix();  // Memorizzo il sistema attuale
  translate(0, -yBlock15/2+yBlock14/2, zBlock14/2+zBlock15/2);
  box(xBlock15, yBlock15, zBlock15);
  translate(0, 0, -zBlock14-zBlock15);
  box(xBlock15, yBlock15, zBlock15);
  popMatrix();  // Ritorno al sistema di riferimento memorizzato

  // Motore6
  fill(#000000);  // Colore motore
  translate(0, -(motorHeight/2+yBlock14/2)-yOffsetM6, 0);
  box(motorDepth, motorHeight, motorWidth);
  fill(#A09908);  // Colore ingranaggio
  translate(0, motorHeight/2+gearHeight/2, gearOffset);
  rotateY(theta[5]);  // rotazione ingranaggio pinza
  box(gearDepth, gearHeight, gearWidth);
  rotateY(120*PI/180);  // Per disegnare ingranaggio
  box(gearDepth, gearHeight, gearWidth);
  rotateY(120*PI/180);  // Per disegnare ingranaggio
  box(gearDepth, gearHeight, gearWidth);
  rotateY(120*PI/180);  // Torno all'angolo iniziale
  popMatrix();  // Ritorno al sistema di riferimento memorizzato
  /*ricorda il popMatrix qui sopra, serve per disegnare la pinza*/

  // Pinza
  fill(#C4C0C0);  // Colore del robot
  pushMatrix();  // Memorizzo il sistema attuale

  translate(zBlock16, 0, zBlock16);
  translate(zBlock16/2, yBlock16/2+yBlock13/2, 0);
  rotateY(-theta[5]);
  translate(+xBlock16/2-zBlock16/2, 0, 0);
  box(xBlock16, yBlock16, zBlock16);

  translate(xBlock16/2-offsetPinza, 0, 0);
  rotateY(+theta[5]);
  rotateY(omega); //rotateY(9.59*PI/180);
  translate(xBlock17/2, 0, 0);
  box(xBlock17, yBlock17, zBlock17);

  translate(xBlock17/2-offsetPinza, 0, 0);
  rotateY(-omega); //rotateY(-9.59*PI/180);
  translate(xBlock18/2, 0, 0);
  box(xBlock18, yBlock18, zBlock18);

  popMatrix();  // Ritorno al sistema di riferimento memorizzato

  translate(zBlock16, 0, -zBlock16);
  translate(zBlock16/2, yBlock16/2+yBlock13/2, 0);
  rotateY(theta[5]);
  translate(+xBlock16/2-zBlock16/2, 0, 0);
  box(xBlock16, yBlock16, zBlock16);

  translate(xBlock16/2-offsetPinza, 0, 0);
  rotateY(-theta[5]);
  rotateY(-omega); //rotateY(-9.59*PI/180);
  translate(xBlock17/2, 0, 0);
  box(xBlock17, yBlock17, zBlock17);

  translate(xBlock17/2-offsetPinza, 0, 0);
  rotateY(omega); //rotateY(9.59*PI/180);
  translate(xBlock18/2, 0, 0);
  box(xBlock18, yBlock18, zBlock18);
}


void drawFloor() {
  fill(#E5E06D);  // Colore del pavimento
  translate(xBase, yBase, zBase);
  rotateY(alpha);
  rotateX(beta);
  box(xFloor, yFloor, zFloor);
}
