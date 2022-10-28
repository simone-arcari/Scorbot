/*
[NOTA][LINUX]in caso di errore:
 
 RuntimeException: Error opening serial port /dev/ttyACM0: Permission denied
 
 risolvere con i seguenti comandi su terminale linux:
 sudo groupadd dialout
 sudo gpasswd -a "user" dialout
 sudo usermod -a -G dialout "user"
 sudo chmod a+rw /dev/ttyACM0
 
 */

import processing.serial.*;


Serial port;                                                                                                    // reference per la porta seriale

PImage background;                                                                                              // reference per l'immagine di background della finestra

PrintWriter connectionFile;                                                                                     // reference per il file con i dati di connessione alla porta
PrintWriter positionFile;                                                                                       // reference per il file con i dati sulle posizioni del robot

boolean portFound = false;                                                                                      // flag per indicare se la porta è stata trovata
boolean loop_flag = true;                                                                                       // flag per il controllo dei cicli while
boolean start_flag = false;                                                                                     // flag per l'inizio del ciclo draw()
boolean ack_flag = true;                                                                                        // flag per indicare l'avvenuta ricezione dei dati

String id;                                                                                                      // stringa per salvare l'id letto sulla porta seriale
String portName;                                                                                                // nome della porta corrente
String buffer;                                                                                                  // buffer d'appoggio per letture e scritture varie
String ARDUINO_ID = "ARO22ARL";                                                                                 // codice identificazione della scheda arduino
String PROCESSING_ID = "PRO04IDE";                                                                              // codice identificazione di questo programma
String[] portNames = {"COM0", "COM1", "COM2", "COM3", "COM4", "COM5", "/dev/ttyACM0"};                          // vettore delle possibili porte seriali
String point_ascii;                                                                                             // valore dipoint in formato ascii

int MOTORS_NUM = 6;                                                                                             // numero motori = numero di coordinate per ogni frames
int MAX_FRAMES = 10 ;                                                                                           // numero massimo di frames(ogni frames ha sei coordinate)
int[][] punti = new int[MAX_FRAMES][MOTORS_NUM];                                                                // matrice di punti / coordinate
int pointCount = 0;                                                                                             // contatore dei punti/frame presenti nella sequenza
int count = 0;                                                                                                  // contatore dei cicli di connessione
int RECT_WIDTH = 600;                                                                                           // lunghezza rettangolo usato per contenere una scritta
int RECT_HEIGHT = 100;                                                                                          // altezza rettangolo usato per contenere una scritta
int offset;                                                                                                     // variabile di appoggio per gestirecoordinate varie
int i, j;                                                                                                        // indici per i vari cicli
int portBoundRate = 9600;                                                                                       // velocità trasmissione portaseriale

long lastTime;                                                                                                  // variabile per contenere le misure di millis()
long MAX_TIME_LOOP = 10000;                                                                                     // tempo massimo per il ciclo di connessione prima di fallire
long FRAMES_RATE = 3000;                                                                                        // rate di invio delle coordinate tra un frame e l'altro

///////////////////////////////////////////////
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

// Parametri camera
float eyeY = 0;
float eyeX = 0;

// Angoli d'interesse
float alpha = 0;

float[] theta = new float[6];
float[] thetaOffset = new float[6];
float[] realServoTheta = new float[6];

boolean direction = true;
///////////////////////////////////////////////


/*##################################################################################################################################################################################################################################################################*/


void setup() {
  size(626, 626, P3D);                                                                                           // creo la finestra con la taglia in pixel dell'immagine
  background = loadImage("robotic-arms.jpg");                                                                   // immagine di background
  background(background);                                                                                       // imposto l'immagine come background

  offset = 150;                                                                                                 // offset veritcale per la posizione del rettangolo
  fill(#DBA028);                                                                                                // colore rettangolo
  rect(width/2-RECT_WIDTH/2, height/2-offset, RECT_WIDTH, RECT_HEIGHT, 28);                                     // disegno il rettangolo

  fill(0);                                                                                                      // colore nero per il testonel rettangolo
  textSize(40);                                                                                                 // dimensione del testo
  textAlign(CENTER);                                                                                            // allineo il testo al centro della finestra
  text("quando il led si accende premere", width/2, 200);                                                       // stampo il testo parte 1
  text("il tasto CTRL", width/2, 240);                                                                          // stampo il testo parte 2


  connectionFile = createWriter("connection_data.txt");                                                         // apro/creo il file per i dati di connessione alla porta
  positionFile = createWriter("position_data.txt");                                                             // apro/creo il file per i dati delle posizioni del robot


  printArray(Serial.list());                                                                                    // stampo la lista di tutte le porte presenti


  for (i=0; i<Serial.list().length; i++) {                                                                      // itero per ogni porta seriale per trovare quella corretta

    portName = Serial.list()[i];                                                                                      // prelevo il nome della porta corrente di indice i

    if (checkPortName(portName)) {                                                                                    // verifico che il nome della porta corrente sia uno dei possibili nomi

      port = new Serial(this, portName, portBoundRate);                                                                     // mi connetto alla porta corrente
      printInfo("[message] --> port name = " + portName);                                                                   // stampo su terminale processing e su file dati di connessione
      printInfo("[message] --> port reference = " + port);                                                                  // stampo su terminale processing e su file dati di connessione
      lastTime = millis();                                                                                                  // salvo il valore del tempo corrente in millisecondi

      while (loop_flag && (millis()-lastTime) < MAX_TIME_LOOP) {                                                            // ciclo finche la porta seriale non diventa disponibile o finchè nonscadeil tempo disponibile

        println("ciclo: " + count);                                                                                               // messaggio da stampare solo su terminale
        count++;                                                                                                                  // incremento il contatore dei cicli

        if (port.available() >= ARDUINO_ID.length()) {                                                                            // verifico che siano disponibili tot byte da leggere

          printInfo("[message] --> port available");                                                                                    // stampo su terminale processing e su file dati di connessione
          loop_flag = false;                                                                                                            // sono disponibili tot byte ergo non devo fare altri cicli di controllo
          id = port.readString();                                                                                                       // leggo dalla porta seriale
          printInfo("[message] --> id = " + id);                                                                                        // stampo su terminale processing e su file dati di connessione

          if (id.equals(ARDUINO_ID)) {                                                                                                  // verifico che il messaggio letto sia proprio il codice di identificazione

            printInfo("[message] --> porta trovata id corretto");                                                                             // stampo su terminale processing e su file dati di connessione
            portFound = true;                                                                                                                 // tengo traccia che la porta è stata trovata correttamente
          } else {                                                                                                                      // il messaggio letto non corrisponde al codice di identificazione

            printInfo("[message] --> id non corretto");                                                                                       // stampo su terminale processing e su file dati di connessione
            printInfo("[message] --> fine comunicazione con porta: " + portName);                                                             // stampo su terminale processing e su file dati di connessione                                 // stampo su file(dati di connessione)
            port.stop();                                                                                                                      // interronpo la comunicazione con la porta corrente non essendo quella corretta
          }
        }
      }
      loop_flag = true;                                                                                                     // rimposto il flag per ciclo(for) successivo
    }

    if (portFound==true)  break;                                                                                      // se la porta viene trovata interrompo il ciclo for
  }

  if (portFound == false) {                                                                                     // se la porta non viene trovata
    printInfo("[error] --> porta seriale non trovata");                                                               // stampo su terminale processing e su file dati di connessione
    connectionFile.flush();                                                                                           // riverso sul filesystem tutto il buffer cache del file(dati di connessione)
    connectionFile.close();                                                                                           // chiudo il file(dati di connessione)
    positionFile.flush();                                                                                             // riverso sul filesystem tutto il buffercache del file(dati posizioni)
    positionFile.close();                                                                                             // chiudo il file(dati posizioni)
    exit();                                                                                                           // termino il programma
  } else {                                                                                                      // se invece la porta viene trovata

    port.write(PROCESSING_ID);                                                                                        // comunico codice di identificazione(di questo programma) alla scheda arduino
  }

  ///////////////////////////////
  size(626, 626, P3D);
  stroke(255);
  strokeWeight(2);
  smooth();
  textAlign(LEFT);

  xBase = width/2;
  yBase = 5*(height/6);
  zBase = -180;

  thetaOffset[0] = rad(90);
  thetaOffset[1] = rad(0);
  thetaOffset[2] = rad(90);
  thetaOffset[3] = rad(90);
  thetaOffset[4] = rad(0);
  thetaOffset[5] = rad(65);

  theta[0] = rad(0);
  theta[1] = rad(-60);
  theta[2] = rad(40);
  theta[3] = rad(20);
  theta[4] = rad(0);
  theta[5] = rad(0);

  realServoTheta[0] =  theta[0] + thetaOffset[0];
  realServoTheta[1] = -theta[1] + thetaOffset[1];
  realServoTheta[2] =  theta[2] + thetaOffset[2];
  realServoTheta[3] =  theta[3] + thetaOffset[3];
  realServoTheta[4] = -theta[4] + thetaOffset[4];
  realServoTheta[5] = -theta[5] + thetaOffset[5];
  ///////////////////////////////

  for (i=0; i<MAX_FRAMES; i++) {    // per ogni frames
    punti[i][0] = (int)random(0, 180);
    punti[i][1] = (int)random(0, 180);
    punti[i][2] = (int)random(0, 180);
    punti[i][3] = (int)random(0, 180);
    punti[i][4] = (int)random(0, 180);
    punti[i][5] = (int)random(0, 65);
  }
}


/*##################################################################################################################################################################################################################################################################*/


void draw() {

  if (start_flag == true) {
    ////////////////////////////////////////////////////////////////////////////////////////////////
    background(0);
    lights();

    camera((width/2.0) - eyeX, height/2 - eyeY, (height/2.0) / tan(PI*60.0 / 360.0), width/2.0, height/2.0, 0, 0, 1, 0);

    if (keyPressed) {
      // Movimento camera
      if (key == 's') {
        eyeY -= 5;
      }
      if (key == 'w') {
        eyeY += 5;
      }
      if (key == 'a') {
        eyeX -= 5;
      }
      if (key == 'd') {
        eyeX += 5;
      }

      // Arresto del programma
      if (key == 'f' || key == 'F') {
        connectionFile.println("[message] --> chiusura comunicazione seriale");
        connectionFile.println("[PROGRAMMA ARRESTATO]");
        connectionFile.flush();
        connectionFile.close();
        positionFile.flush();
        positionFile.close();
        port.stop();  // interronpo la comunicazione con la porta corrente non essendo quella corretta
        exit();
      }

      // Rotazionesu intorno asse verticale
      if (keyCode == RIGHT) {
        alpha += rad(1);
      }
      if (keyCode == LEFT) {
        alpha -= rad(1);
      }

      // Movimento lungo asse z
      if (keyCode == UP) {
        zBase+=15;
      }
      if (keyCode == DOWN) {
        zBase-=5;
      }
/*
      // Verso rotazione motori
      if (key == 'q') {
        direction = !direction;
        delay(500);
      }

      // Rotazione motore1
      if (key == '1') {
        if (direction == true && theta[0] < PI/2) {
          theta[0]+= rad(1);
        }
        if (direction == false && theta[0] > -PI/2) {
          theta[0]-= rad(1);
        }
      }

      // Rotazione motore2
      if (key == '2') {
        if (direction == true && theta[1] < 0) {
          theta[1]+= rad(1);
        }
        if (direction == false && theta[1] > -PI) {
          theta[1]-= rad(1);
        }
      }

      // Rotazione motore3
      if (key == '3') {
        if (direction == true && theta[2] < PI/2) {
          theta[2]+= rad(1);
        }
        if (direction == false && theta[2] > -PI/2) {
          theta[2]-= rad(1);
        }
      }

      // Rotazione motore4
      if (key == '4') {
        if (direction == true && theta[3] < PI/2) {
          theta[3]+= rad(1);
        }
        if (direction == false && theta[3] > -PI/2) {
          theta[3]-= rad(1);
        }
      }

      // Rotazione motore5
      if (key == '5') {
        if (direction == true && theta[4] < 0) {
          theta[4]+= rad(1);
        }
        if (direction == false && theta[4] > -PI) {
          theta[4]-= rad(1);
        }
      }

      if (key == '6') {
        if (direction == true && theta[5] < 65*PI/180) {
          theta[5]+= rad(1);
        }
        if (direction == false && theta[5] > 0) {
          theta[5]-= rad(1);
        }
      }
*/
    }

    if (mousePressed) {
      xBase = mouseX;
      yBase = mouseY;
    }

    /*
    realServoTheta[0] =  theta[0] + thetaOffset[0];
    realServoTheta[1] = -theta[1] + thetaOffset[1];
    realServoTheta[2] =  theta[2] + thetaOffset[2];
    realServoTheta[3] =  theta[3] + thetaOffset[3];
    realServoTheta[4] = -theta[4] + thetaOffset[4];
    realServoTheta[5] = -theta[5] + thetaOffset[5];
    */

    theta[0] =  realServoTheta[0] - thetaOffset[0];
    theta[1] = -realServoTheta[1] + thetaOffset[1];
    theta[2] =  realServoTheta[2] - thetaOffset[2];
    theta[3] =  realServoTheta[3] - thetaOffset[3];
    theta[4] = -realServoTheta[4] + thetaOffset[4];
    theta[5] =  realServoTheta[5] - thetaOffset[5];

    // Parametri stampati su schermo
    textSize(25);
    fill(#00FF00); // Colore parametri camera
    text("coordinata y vista:", 10, 25);
    text(eyeY, 250, 25);
    text("coordinata x vista:", 10, 50);
    text(eyeX, 250, 50);
    fill(#FF9100); // Colore parametri theta
    text("theta[0]:", 10, 75);
    text(int(deg(realServoTheta[0])) + "°", 250, 75);
    text("theta[1]:", 10, 100);
    text(int(deg(realServoTheta[1])) + "°", 250, 100);
    text("theta[2]:", 10, 125);
    text(int(deg(realServoTheta[2])) + "°", 250, 125);
    text("theta[3]:", 10, 150);
    text(int(deg(realServoTheta[3])) + "°", 250, 150);
    text("theta[4]:", 10, 175);
    text(int(deg(realServoTheta[4])) + "°", 250, 175);
    text("theta[5]:", 10, 200);
    text(int(deg(realServoTheta[5])) + "°", 250, 200);

    // Pavimento
    fill(#E5E06D);  // Colore del pavimento
    translate(xBase, yBase, zBase);
    rotateY(alpha);
    box(xFloor, yFloor, zFloor);

    drawRobot();

    ////////////////////////////////////////////////////////////////////////////////////////////////

    if (millis()-lastTime >= FRAMES_RATE) {
      lastTime = millis();

      if (ack_flag) {

        ack_flag = false;
        port.write(PROCESSING_ID);
        positionFile.println("[message] --> coordinate frame: " + pointCount);
        println("[message] --> coordinate frame: " + pointCount);

        for (j=0; j<MOTORS_NUM; j++) {

          realServoTheta[j] = rad(float(punti[pointCount][j]));
          point_ascii = Integer.toString(punti[pointCount][j]);

          if (point_ascii.length() == 2)
            point_ascii = "0" + point_ascii;

          if (point_ascii.length() == 1)
            point_ascii = "00" + point_ascii;

          port.write(point_ascii);
          positionFile.println("punto: " + punti[pointCount][j]);
          println("punto: " + punti[pointCount][j] + ", in ascii: " + point_ascii);
        }

        pointCount++;
        if (pointCount >= 10) pointCount = 0;
      }
    }

    if (port.available() >= ARDUINO_ID.length()) {
      id = port.readString();
      println("[message] --> " + id);

      if (id.equals(ARDUINO_ID))
        ack_flag = true;
    }
  }
}

/*##################################################################################################################################################################################################################################################################*/

void keyPressed() {  /* premendo ctrl faccio partire il draw() */
  if (key == CODED) {
    if (keyCode == CONTROL)
      start_flag = true;
  }
}

/*##################################################################################################################################################################################################################################################################*/

boolean checkPortName(String name) {
  for (i=0; i<portNames.length; i++) {
    if (name.equals(portNames[i]))
      return true;
  }
  return false;
}

/*##################################################################################################################################################################################################################################################################*/

void printInfo(String text) {
  println(text);
  connectionFile.println(text);
}

/*##################################################################################################################################################################################################################################################################*/

float rad(float degrees) {
  return degrees * PI/180.0;
}

/*##################################################################################################################################################################################################################################################################*/

float deg(float radians) {
  return radians * 180.0/PI;
}

/*##################################################################################################################################################################################################################################################################*/

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
