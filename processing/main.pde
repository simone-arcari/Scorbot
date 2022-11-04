PImage background;                                                                                              // reference per l'immagine di background della finestra

PrintWriter connectionFile;                                                                                     // reference per il file con i dati di connessione alla porta
PrintWriter positionFile;                                                                                       // reference per il file con i dati sulle posizioni del robot

int i, j;                                                                                                       // indici per i vari cicli
int offset;                                                                                                     // variabile di appoggio per gestire coordinate varie
int RECT_WIDTH = 600;                                                                                           // lunghezza rettangolo usato per contenere una scritta
int RECT_HEIGHT = 100;                                                                                          // altezza rettangolo usato per contenere una scritta


long lastTime;                                                                                                  // variabile per contenere le misure di millis()
long MAX_TIME_LOOP = 10000;                                                                                     // tempo massimo per il ciclo di connessione prima di fallire
long FRAMES_RATE = 3000;                                                                                        // rate di invio delle coordinate tra un frame e l'altro

boolean startFlag = false;                                                                                      // flag per l'inizio del ciclo draw()
boolean manualControl = true;                                                                                   // flag per la modalità di controllo motori


void setup() {
  size(626, 626, P3D);                                                                                          // creo la finestra con la taglia in pixel dell'immagine
  smooth(8);                                                                                                    // 8x anti-aliasing
  stroke(255);
  strokeWeight(2);

  background = loadImage("robotic-arms.jpg");                                                                   // immagine di background
  background(background);                                                                                       // imposto l'immagine come background

  offset = 150;                                                                                                 // offset veritcale per la posizione del rettangolo
  fill(#DBA028);                                                                                                // colore rettangolo
  rect(width/2-RECT_WIDTH/2, height/2-offset, RECT_WIDTH, RECT_HEIGHT, 28);                                     // disegno il rettangolo

  fill(0);                                                                                                      // colore nero per il testo nel rettangolo
  textSize(40);                                                                                                 // dimensione del testo
  textAlign(CENTER);                                                                                            // allineo il testo al centro della finestra
  text("quando il led si accende premere", width/2, 200);                                                       // stampo il testo parte 1
  text("il tasto CTRL", width/2, 240);                                                                          // stampo il testo parte 2
  textAlign(LEFT);                                                                                              // rimposto allineamento standard (a sinistra)

  connectionFile = createWriter("connection_data.txt");                                                         // apro/creo il file per i dati di connessione alla porta
  positionFile = createWriter("position_data.txt");                                                             // apro/creo il file per i dati delle posizioni del robot

  serialTryConnect();                                                                                           // tento di avviare la connessione seriale, in caso di fallimento termino il programma

  xBase = width/2;                                                                                              // coordinata x iniziale spazzio processing
  yBase = 5*(height/6);                                                                                         // coordinata y iniziale spazzio processing
  zBase = -180;                                                                                                 // coordinata z iniziale spazzio processing

  for (i=0; i<MOTORS_NUM; i++) {
    theta[i] = thetaInit[i];
    realServoTheta[i] =  thetaSign[i]*theta[i] + thetaOffset[i];
  }

  for (i=0; i<MAX_FRAMES; i++) {    // per ogni frames
    punti[i][0] = (int)random(0, 180);
    punti[i][1] = (int)random(0, 180);
    punti[i][2] = (int)random(0, 180);
    punti[i][3] = (int)random(0, 180);
    punti[i][4] = (int)random(0, 180);
    punti[i][5] = (int)random(0, 65);
  }
}


void draw() {
  if (startFlag == true) {
    background(0);
    lights();

    keyEvent();

    // Calcolo relazioni tra angoli veri(servomotori) e angoli fittizzi(processing space)
    if (manualControl == true) {
      for (i=0; i<MOTORS_NUM; i++) {
        realServoTheta[i] =  thetaSign[i]*theta[i] + thetaOffset[i];
      }
      serialSendPositions(realServoTheta);
      serialCheckACK();
    } else {
      for (i=0; i<MOTORS_NUM; i++) {
        theta[i] =  (realServoTheta[i]-thetaOffset[i])/thetaSign[i];
      }
    }
    
    // Parametri stampati su schermo
    textSize(25);
    fill(#FF9100); // Colore parametri theta
    for (i=0; i<MOTORS_NUM; i++) {
      text("realServoTheta["+i+"]:", 10, 75+25*i);
      text(int(deg(realServoTheta[i])) + "°", 250, 75+25*i);
    }

    drawFloor();  // Pavimento
    drawRobot();

    if (manualControl == false) {
      if (millis()-lastTime >= FRAMES_RATE) {
        lastTime = millis();
        serialSendFrame();
      }
      serialCheckACK();
    }
  }
}


void keyEvent() {
  if (mousePressed) {
    xBase = mouseX;
    yBase = mouseY;
  }

  if (keyPressed) {

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

    // Rotazione intorno asse verticale
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

    // Rotazione intorno asse orizzontale
    if (key == '0') {
      beta += rad(1);
    }

    // Reset posizioni/spazio3D
    if (key == 'q' || key == 'Q') {
      for (i=0; i<MOTORS_NUM; i++) {
        theta[i] = thetaInit[i];
      }
    }

    // Modalità controllo motori
    if (key == 'm' || key == 'M') {
      manualControl = !manualControl;
      delay(200);
    }

    // Direzione rotazione motori
    if (key == 's' || key == 'S') {
      direction = -1*direction;
      delay(200);
    }

    // Controllo rotazioni motori
    if (manualControl == true) {

      // Rotazione motore1
      if (key == '1' && theta[0] >= -PI/2 && theta[0] <= PI/2) {
        theta[0] += direction*rad(1);
        if (theta[0] < -PI/2)  theta[0] = rad(-90);
        if (theta[0] > PI/2)  theta[0] = rad(90);
      }

      // Rotazione motore2
      if (key == '2' && theta[1] >= -PI && theta[1] <= 0) {
        theta[1] += direction*rad(1);
        if (theta[1] < -PI)  theta[1] = rad(-180);
        if (theta[1] > 0)  theta[1] = rad(0);
      }

      // Rotazione motore3
      if (key == '3' && theta[2] >= -PI/2 && theta[2] <= PI/2) {
        theta[2] += direction*rad(1);
        if (theta[2] < -PI/2)  theta[2] = rad(-90);
        if (theta[2] > PI/2)  theta[2] = rad(90);
      }

      // Rotazione motore4
      if (key == '4' && theta[3] >= -PI/2 && theta[3] <= PI/2) {
        theta[3] += direction*rad(1);
        if (theta[3] < -PI/2)  theta[3] = rad(-90);
        if (theta[3] > PI/2)  theta[3] = rad(90);
      }

      // Rotazione motore5
      if (key == '5' && theta[4] >= -PI && theta[4] <= 0) {
        theta[4] += direction*rad(1);
        if (theta[4] < -PI)  theta[4] = rad(-180);
        if (theta[4] > 0)  theta[4] = rad(0);
      }

      // Rotazione motore6
      if (key == '6' && theta[5] >= 0 && theta[5] <= 65*PI/180) {
        theta[5] += direction*rad(1);
        if (theta[5] < 0)  theta[5] = rad(0);
        if (theta[5] > 65*PI/180)  theta[5] = rad(65);
      }
    }
  }
}


void keyPressed() {  /* premendo ctrl faccio partire il draw() */
  if (key == CODED) {
    if (keyCode == CONTROL)
      startFlag = true;
  }
}


void mouseWheel(MouseEvent event) {  /* ruotando la rotellina del mouse ruoto lo spazio di disegno */
  beta += rad(event.getCount());
}


void printInfo(String text) {
  println(text);
  connectionFile.println(text);
}
