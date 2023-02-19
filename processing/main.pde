PImage background;                                                                                              // reference per l'immagine di background della finestra //<>//

PrintWriter connectionFile;                                                                                     // reference per il file con i dati di connessione alla porta
PrintWriter positionFile;                                                                                       // reference per il file con i dati sulle posizioni del robot
PrintWriter framesFile;                                                                                         // reference per il file utilizzato per salvare gli angoli per i frames

int i, j;                                                                                                       // indici per i vari cicli
int offset;                                                                                                     // variabile di appoggio per gestire coordinate varie
int RECT_WIDTH = 600;                                                                                           // lunghezza rettangolo usato per contenere una scritta
int RECT_HEIGHT = 100;                                                                                          // altezza rettangolo usato per contenere una scritta

long lastTime;                                                                                                  // variabile per contenere le misure di millis()
long MAX_TIME_LOOP = 10000;                                                                                     // tempo massimo per il ciclo di connessione prima di fallire
long FRAMES_RATE = 100;                                                                                         // rate di invio delle coordinate tra un frame e l'altro in ms

boolean startFlag = false;                                                                                      // flag per l'inizio del ciclo draw()

float x_d = 0;
float y_d = 276;
float z_d = 253;
float B_d = 0;
float W_d = 0;

public enum Mod {
  MANUAL_CONTROL,                                                                                               // modalità che permette di controllare gli angoli dei motori manualmente
    FRAME_MOD,                                                                                                  // modalità in cui il robot si muove secondo una serie di frames prefissati
    INVERSE_KINEMATIC_MOD                                                                                       // modalità in cui il robot si muove secondo il calcolo della cinematica inversa
}

Mod ControlMod = Mod.INVERSE_KINEMATIC_MOD;                                                                     // flag per la modalità iniziale di controllo del robot



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
  //framesFile = createWriter("frames_data.txt");                                                                 // apro/creo il file per prelevare i dari sui frames memorizzati

  serialTryConnect();                                                                                           // tento di avviare la connessione seriale, in caso di fallimento termino il programma
  
  xBase = width/2;                                                                                              // coordinata x iniziale spazzio processing
  yBase = 5*(height/6);                                                                                         // coordinata y iniziale spazzio processing
  zBase = -180;                                                                                                 // coordinata z iniziale spazzio processing

  for (i=0; i<MOTORS_NUM; i++) {
    theta[i] = thetaInit[i];
    realServoTheta[i] =  thetaSign[i]*theta[i] + thetaOffset[i];
  }

  // per ogni frame i-esimo inizializzo un i-esima configurazione(frames[][]) ovvero un insieme di 6 angoli per i 6 motori
  try { // Provo a leggere i dati memorizzati nel file
    String[] linee = loadStrings("frames_data.txt");
    if (linee != null) { 
      FRAMES_NUM = linee.length/MOTORS_NUM;
      frames = new int[FRAMES_NUM][MOTORS_NUM]; 
      
      for (i=0; i<FRAMES_NUM; i++) {        
        frames[i][0] = int(linee[i*MOTORS_NUM]);
        frames[i][1] = int(linee[i*MOTORS_NUM + 1]);
        frames[i][2] = int(linee[i*MOTORS_NUM + 2]);
        frames[i][3] = int(linee[i*MOTORS_NUM + 3]);
        frames[i][4] = int(linee[i*MOTORS_NUM + 4]);
        frames[i][5] = int(linee[i*MOTORS_NUM + 5]);
      }
    }
  } catch (Exception e) { // In caso di errore/eccezione stampo lo StackTrace
    e.printStackTrace();
    println("[Possibile Errore nella lettura del file frames_data.txt]");
  }
}


void draw() {
  if (startFlag == true) { // Il contenuto del draw viene eseguito solo dopo che l'utente preme il tasto ctrl (dopo l'avvenuta connessione con la scheda arduino) 
    background(0);
    lights();

    keyEvent();  // Comandi da tastiera

    if (ControlMod == Mod.MANUAL_CONTROL) // Calcolo thetaDenavitHartenberg[](angolo dipendente) e realServoTheta[](angolo dipendente) a partire dal valore di theta[](angolo indipendente)
    {
      thetaDenavitHartenberg[0] =  theta[0] + rad(90);
      thetaDenavitHartenberg[1] = -theta[1];
      thetaDenavitHartenberg[2] = -theta[2];
      thetaDenavitHartenberg[3] = -theta[3] + rad(90);
      thetaDenavitHartenberg[4] =  theta[4];
      
      for (i=0; i<MOTORS_NUM; i++) 
      {
        realServoTheta[i] =  thetaSign[i]*theta[i] + thetaOffset[i];
      }
      
      /* comunicazione */
      serialSendPositions(realServoTheta);
      serialCheckACK();
    }
   
   
    else if (ControlMod == Mod.FRAME_MOD) // Calcolo theta[](angolo dipendente) e thetaDenavitHartenberg[](angolo dipendente) a partire dal valore di realServoTheta[](angolo indipendente)
    {
      for (i=0; i<MOTORS_NUM; i++) 
      {
        theta[i] =  (realServoTheta[i]-thetaOffset[i])/thetaSign[i];
      }
      
      thetaDenavitHartenberg[0] =  theta[0] + rad(90);
      thetaDenavitHartenberg[1] = -theta[1];
      thetaDenavitHartenberg[2] = -theta[2];
      thetaDenavitHartenberg[3] = -theta[3] + rad(90);
      thetaDenavitHartenberg[4] =  theta[4];
      
      /* la comunicazione non avviene qui (riga 161)*/
    }
    
    
    else if (ControlMod == Mod.INVERSE_KINEMATIC_MOD) // Calcolo theta[](angolo dipendente) e realServoTheta[](angolo dipendente) a partire dal valore di thetaDenavitHartenberg[](angolo indipendente)
    {
      //x_d = 150*sin(0.0001*millis());
      //y_d = 150*sin(0.0003*millis());
      //z_d = 253 + 32*sin(0.001*millis());
      thetaDenavitHartenberg = inverseKinematic(x_d, y_d, z_d, rad(B_d), rad(W_d));
      
      theta[0] =  thetaDenavitHartenberg[0] - rad(90);
      theta[1] = -thetaDenavitHartenberg[1];
      theta[2] = -thetaDenavitHartenberg[2];
      theta[3] = -thetaDenavitHartenberg[3] + rad(90);
      theta[4] =  thetaDenavitHartenberg[4];
      theta[5] = rad(0);

      for (i=0; i<MOTORS_NUM; i++) 
      {
        realServoTheta[i] =  thetaSign[i]*theta[i] + thetaOffset[i];
        //framesFile.println(int(deg(realServoTheta[i])));
      }
      
      /* comunicazione */
      serialSendPositions(realServoTheta);
      serialCheckACK();
    }

    // Parametri stampati su schermo
    printText();

    // Disegno spazio 3D
    drawFloor();  // disegno il pavimento
    drawBall();    // disegna la pallina
    drawRobot();  // disegno lo scorbot
    
    
    // Timer non bloccante per 
    if (ControlMod == Mod.FRAME_MOD) {
      if (millis()-lastTime >= FRAMES_RATE) {
        lastTime = millis();
        serialSendFrame();  // Inivia i frames memorizzati (uno per ogni chiamata di questa funzione)
      }
      serialCheckACK();
    }
  }
}


void keyEvent() {
  if (mousePressed) 
  {
    xBase = mouseX;
    yBase = mouseY;
  }

  if (keyPressed) 
  {
    // Arresto del programma
    if (key == 'f' || key == 'F')
    {
      connectionFile.println("[message] --> chiusura comunicazione seriale");
      connectionFile.println("[PROGRAMMA ARRESTATO]");
      
      connectionFile.flush();
      connectionFile.close();
      
      positionFile.flush();
      positionFile.close();
      
      //framesFile.flush();
      //framesFile.close();
      
      port.stop();  // interronpo la comunicazione con la porta corrente non essendo quella corretta
      exit();
    }

    // Rotazione intorno asse verticale
    if (keyCode == RIGHT) 
    {
      alpha += rad(1);
    }
    if (keyCode == LEFT) 
    {
      alpha -= rad(1);
    }

    // Movimento lungo asse z
    if (keyCode == UP) 
    {
      zBase+=15;
    }
    if (keyCode == DOWN) 
    {
      zBase-=5;
    }

    // Rotazione intorno asse orizzontale
    if (key == '0') 
    {
      beta += rad(1);
    }

    // Modalità controllo motori
    if (key == 'm' || key == 'M') 
    {
      switch(ControlMod) 
      {
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
    if (ControlMod == Mod.MANUAL_CONTROL) 
    {

      // Reset posizioni/spazio3D
      if (key == 'q' || key == 'Q') 
      {
        for (i=0; i<MOTORS_NUM; i++) 
        {
          theta[i] = thetaInit[i];
        }
      }

      // Direzione rotazione motori
      if (key == 's' || key == 'S') 
      {
        direction = -1*direction;
        delay(200);
      }

      // Rotazione motore 1
      if (key == '1' && theta[0] >= -PI/2 && theta[0] <= PI/2) 
      {
        theta[0] += direction*rad(1);
        if (theta[0] < -PI/2)  theta[0] = rad(-90);
        if (theta[0] > PI/2)  theta[0] = rad(90);
      }

      // Rotazione motore 2
      if (key == '2' && theta[1] >= -PI && theta[1] <= 0) 
      {
        theta[1] += direction*rad(1);
        if (theta[1] < -PI)  theta[1] = rad(-180);
        if (theta[1] > 0)  theta[1] = rad(0);
      }

      // Rotazione motore 3
      if (key == '3' && theta[2] >= -PI/2 && theta[2] <= PI/2) 
      {
        theta[2] += direction*rad(1);
        if (theta[2] < -PI/2)  theta[2] = rad(-90);
        if (theta[2] > PI/2)  theta[2] = rad(90);
      }

      // Rotazione motore 4
      if (key == '4' && theta[3] >= -PI/2 && theta[3] <= PI/2) 
      {
        theta[3] += direction*rad(1);
        if (theta[3] < -PI/2)  theta[3] = rad(-90);
        if (theta[3] > PI/2)  theta[3] = rad(90);
      }

      // Rotazione motore 5
      if (key == '5' && theta[4] >= -PI && theta[4] <= 0) 
      {
        theta[4] += direction*rad(1);
        if (theta[4] < -PI)  theta[4] = rad(-180);
        if (theta[4] > 0)  theta[4] = rad(0);
      }

      // Rotazione motore 6
      if (key == '6' && theta[5] >= 0 && theta[5] <= 65*PI/180) 
      {
        theta[5] += direction*rad(1);
        if (theta[5] < 0)  theta[5] = rad(0);
        if (theta[5] > 65*PI/180)  theta[5] = rad(65);
      }
    }

    if (ControlMod == Mod.INVERSE_KINEMATIC_MOD) 
    {
      if (key == 'g' || key == 'G') 
      {
        sign_d *= -1;
        delay(200);
      }
      
      if (key == 'q' || key == 'Q') 
      {
        x_d--;
      }
      if (key == 'w' || key == 'W') 
      {
        x_d++;
      }
      if (key == 'e' || key == 'E') 
      {
        y_d--;
      }
      if (key == 'r' || key == 'R') 
      {
        y_d++;
      }
      if (key == 't' || key == 'T') 
      {
        z_d--;
      }
      if (key == 'y' || key == 'Y') 
      {
        z_d++;
      }
      if (key == 'u' || key == 'U') 
      {
        B_d--;
      }
      if (key == 'i' || key == 'I') 
      {
        B_d++;
      }
      if (key == 'o' || key == 'o') 
      {
        W_d--;
      }
      if (key == 'p' || key == 'P') 
      {
        W_d++;
      }
    }
  }
}


void keyPressed() {  /* premendo ctrl faccio partire il draw() */
  if (key == CODED) 
  {
    if (keyCode == CONTROL) 
    {
      startFlag = true;
    }
  }
}


void mouseWheel(MouseEvent event) {  /* ruotando la rotellina del mouse ruoto lo spazio di disegno */
  beta += rad(event.getCount());
}


void printInfo(String text) {  /* serve per stampare sia sulla console che su file */
  println(text);
  connectionFile.println(text);
}


void printText() {  /* si occupa delle stampe a schermo delle possibili rapresentazioni degli angoli e della modalità corrente */
  textSize(25);

  for (i=0; i<MOTORS_NUM; i++) 
  {
    fill(#FF9100);
    text("realServoTheta[" +i+ "]:  " + int(deg(realServoTheta[i])) + "°", 5, 25 + 25*i);
  }
  
  for (i=0; i<MOTORS_NUM; i++) 
  {
    fill(#EC41F0);
    text("theta[" +i+ "]:  " + int(deg(theta[i])) + "°", 270, 25 + 25*i);
  }
  
  for (i=0; i<DOF; i++) 
  {
    fill(#27D8CE);
    text("thetaDenavitHartenberg[" +i+ "]:  " + int(deg(thetaDenavitHartenberg[i])) + "°", 425, 25 + 25*i);
  }

  fill(#32DB23); // Colore parametro ControlMod
  text("ControlMod:", 5, 25+25*7);

  switch(ControlMod) 
  {
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
