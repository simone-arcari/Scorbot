PImage background;                                                                                              // reference per l'immagine di background della finestra //<>//

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

public enum Mod {
  MANUAL_CONTROL,                                                                                               // modalità che permette di controllare gli angoli dei motori manualmente
    FRAME_MOD,                                                                                                  // modalità in cui il robot si muove secondo una serie di frames prefissati
    INVERSE_KINEMATIC_MOD                                                                                       // modalità in cui il robot si muove secondo il calcolo della cinematica inversa
}

Mod ControlMod = Mod.MANUAL_CONTROL;                                                                            // flag per la modalità di controllo del robot


void setup() {
  size(1280, 720, P3D);                                                                                         // creo la finestra con la taglia in pixel dell'immagine
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
  text("quando il led si accende premere", width/2, 250);                                                       // stampo il testo parte 1
  text("il tasto CTRL", width/2, 290);                                                                          // stampo il testo parte 2
  textAlign(LEFT);                                                                                              // rimposto allineamento standard (a sinistra)

  connectionFile = createWriter("connection_data.txt");                                                         // apro/creo il file per i dati di connessione alla porta
  positionFile = createWriter("position_data.txt");                                                             // apro/creo il file per i dati delle posizioni del robot

  serialTryConnect();                                                                                           // tento di avviare la connessione seriale, in caso di fallimento termino il programma
  /*DEBUG--->*/  //portFound=true;
  
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
    if (ControlMod == Mod.MANUAL_CONTROL) {
      for (i=0; i<MOTORS_NUM; i++) {
        realServoTheta[i] =  thetaSign[i]*theta[i] + thetaOffset[i];
      }
      serialSendPositions(realServoTheta);
      serialCheckACK();
    } else if (ControlMod == Mod.FRAME_MOD) {
      for (i=0; i<MOTORS_NUM; i++) {
        theta[i] =  (realServoTheta[i]-thetaOffset[i])/thetaSign[i];
      }
    } else if (ControlMod == Mod.INVERSE_KINEMATIC_MOD) {
      float[] prova_d = inverseKinematic(0, 200, 250, rad(90), rad(0));

//      theta[0] = prova_d[0] - rad(90);
//      theta[1] = -prova_d[1];
//      theta[2] = -prova_d[2];
//      theta[3] = -prova_d[3];
//      theta[4] = prova_d[4];
//      theta[5] = rad(0);
      
      theta[0] = prova_d[0] - rad(90);
      theta[1] = prova_d[1];
      theta[2] = prova_d[2];
      theta[3] = prova_d[3];
      theta[4] = prova_d[4];
      theta[5] = rad(0);

      for (i=0; i<MOTORS_NUM; i++) {
        realServoTheta[i] =  thetaSign[i]*theta[i] + thetaOffset[i];
      }
      
      serialSendPositions(realServoTheta);
      serialCheckACK();
    }

    // Parametri stampati su schermo
    printText();

    // Disegno
    drawFloor();  // disegno il pavimento
    drawRobot();  // disegno lo scorbot

    // Timer non bloccante
    if (ControlMod == Mod.FRAME_MOD) {
      if (millis()-lastTime >= FRAMES_RATE) {
        lastTime = millis();
        serialSendFrame();  // Inivia i punti memorizzati
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

    // Modalità controllo motori
    if (key == 'm' || key == 'M') {
      switch(ControlMod) {
      case MANUAL_CONTROL:
        ControlMod = Mod.FRAME_MOD;
        break;
      case FRAME_MOD:
        ControlMod = Mod.INVERSE_KINEMATIC_MOD;
        break;
      case INVERSE_KINEMATIC_MOD:
        ControlMod = Mod.MANUAL_CONTROL;
        break;
      }
      delay(200);
    }

    // Controllo rotazioni motori
    if (ControlMod == Mod.MANUAL_CONTROL) {

      // Reset posizioni/spazio3D
      if (key == 'q' || key == 'Q') {
        for (i=0; i<MOTORS_NUM; i++) {
          theta[i] = thetaInit[i];
        }
      }

      // Direzione rotazione motori
      if (key == 's' || key == 'S') {
        direction = -1*direction;
        delay(200);
      }

      // Rotazione motore 1
      if (key == '1' && theta[0] >= -PI/2 && theta[0] <= PI/2) {
        theta[0] += direction*rad(1);
        if (theta[0] < -PI/2)  theta[0] = rad(-90);
        if (theta[0] > PI/2)  theta[0] = rad(90);
      }

      // Rotazione motore 2
      if (key == '2' && theta[1] >= -PI && theta[1] <= 0) {
        theta[1] += direction*rad(1);
        if (theta[1] < -PI)  theta[1] = rad(-180);
        if (theta[1] > 0)  theta[1] = rad(0);
      }

      // Rotazione motore 3
      if (key == '3' && theta[2] >= -PI/2 && theta[2] <= PI/2) {
        theta[2] += direction*rad(1);
        if (theta[2] < -PI/2)  theta[2] = rad(-90);
        if (theta[2] > PI/2)  theta[2] = rad(90);
      }

      // Rotazione motore 4
      if (key == '4' && theta[3] >= -PI/2 && theta[3] <= PI/2) {
        theta[3] += direction*rad(1);
        if (theta[3] < -PI/2)  theta[3] = rad(-90);
        if (theta[3] > PI/2)  theta[3] = rad(90);
      }

      // Rotazione motore 5
      if (key == '5' && theta[4] >= -PI && theta[4] <= 0) {
        theta[4] += direction*rad(1);
        if (theta[4] < -PI)  theta[4] = rad(-180);
        if (theta[4] > 0)  theta[4] = rad(0);
      }

      // Rotazione motore 6
      if (key == '6' && theta[5] >= 0 && theta[5] <= 65*PI/180) {
        theta[5] += direction*rad(1);
        if (theta[5] < 0)  theta[5] = rad(0);
        if (theta[5] > 65*PI/180)  theta[5] = rad(65);
      }
    }

    if (ControlMod == Mod.INVERSE_KINEMATIC_MOD) {
      if (key == 'g' || key == 'G') {
        sign_d *= -1;
        delay(200);
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


void printText() {
  textSize(25);
  fill(#FF9100); // Colore parametri theta

  for (i=0; i<MOTORS_NUM; i++) {
    text("realServoTheta["+i+"]:", 10, 25 + 25*i);
    text(int(deg(realServoTheta[i])) + "°", 250, 25 + 25*i);
  }

  fill(#32DB23); // Colore parametro ControlMod
  text("ControlMod:", 10, 25+25*7);

  switch(ControlMod) {
  case MANUAL_CONTROL:
    text("MANUAL_CONTROL", 150, 25+25*7);
    break;
  case FRAME_MOD:
    text("FRAME_MOD", 150, 25+25*7);
    break;
  case INVERSE_KINEMATIC_MOD:
    text("INVERSE_KINEMATIC_MOD", 150, 25+25*7);
    break;
  }
}
