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

int DIVISORE = 12;                                                                                              // il file che contiene i frames è stato campionato ad una frequenza elevata, ergo sono necessari meno frames di quelli memorizzati

boolean startFlag = false;                                                                                      // flag per l'inizio del ciclo draw()


float x_d = 0;
float y_d = 180;
float z_d = 0;
float B_d = 90;
float W_d = 0;

float time = 0;
float t0 = 0;
int step = 0;

public enum Mod {
  MANUAL_CONTROL,                                                                                               // modalità che permette di controllare gli angoli dei motori manualmente
  FRAME_MOD,                                                                                                    // modalità in cui il robot si muove secondo una serie di frames prefissati
  INVERSE_KINEMATIC_MOD                                                                                         // modalità in cui il robot si muove secondo il calcolo della cinematica inversa
}

Mod ControlMod = Mod.FRAME_MOD-++;                                                                                 // flag per la modalità iniziale di controllo del robot



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
      FRAMES_NUM = linee.length/(MOTORS_NUM*DIVISORE);
      frames = new float[FRAMES_NUM][MOTORS_NUM]; 
      
      for (i=0; i<FRAMES_NUM; i++) {        
        frames[i][0] = float(linee[DIVISORE*i*MOTORS_NUM]);
        frames[i][1] = float(linee[DIVISORE*i*MOTORS_NUM + 1]);
        frames[i][2] = float(linee[DIVISORE*i*MOTORS_NUM + 2]);
        frames[i][3] = float(linee[DIVISORE*i*MOTORS_NUM + 3]);
        frames[i][4] = float(linee[DIVISORE*i*MOTORS_NUM + 4]);
        frames[i][5] = float(linee[DIVISORE*i*MOTORS_NUM + 5]);
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
      
      serialSendFrame();  // Inivia i frames memorizzati (uno per ogni chiamata di questa funzione)
      serialCheckACK();
      /* la comunicazione non avviene qui (vedi riga 184)*/
    }
    
    
    else if (ControlMod == Mod.INVERSE_KINEMATIC_MOD) // Calcolo theta[](angolo dipendente) e realServoTheta[](angolo dipendente) a partire dal valore di thetaDenavitHartenberg[](angolo indipendente)
    {
      movimento(time);
      time++;
      
      for(int i=0; i<5; i++) {
        thetaDenHartOld[i] = thetaDenavitHartenberg[i];
      }
      
      thetaDenavitHartenberg = inverseKinematic(x_d, y_d, z_d, rad(B_d), rad(W_d));
      
      if( cheakAngles( inverseKinematic(x_d, y_d, z_d, rad(B_d), rad(W_d))) == false )
      {
        for(int i=0; i<5; i++) {
          thetaDenavitHartenberg[i] = thetaDenHartOld[i];
        }
      }
           
      theta[0] =  thetaDenavitHartenberg[0] - rad(90);
      theta[1] = -thetaDenavitHartenberg[1];
      theta[2] = -thetaDenavitHartenberg[2];
      theta[3] = -thetaDenavitHartenberg[3] + rad(90);
      theta[4] =  thetaDenavitHartenberg[4];

      for (i=0; i<MOTORS_NUM; i++) 
      {
        realServoTheta[i] =  thetaSign[i]*theta[i] + thetaOffset[i];
        //framesFile.println(deg(realServoTheta[i]));
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
        framesCount = 0;
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
        if(W_d < -180) W_d = -180;
      }
      if (key == 'p' || key == 'P') 
      {
        W_d++;      
        if(W_d > 0) W_d = 0;
      }
      // apertura pinza
      if (key == 'a' || key == 'A') 
      {
        theta[5] -= rad(1);
        if(theta[5] < 0) theta[5] = 0;
      }
      if (key == 's' || key == 'S') 
      {
        theta[5] += rad(1);      
        if(theta[5] > 65*PI/180) theta[5] = 65*PI/180;
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


/* Questa funzione è servita in fase di sviluppo per campionare i dati (di questo movimento)
 * all'interno del file "framesFile.txt"
 */
void movimento(float t) {
  
  
  if(step == 0) {
    x_d = -abs(180*sin(0.005*t));
    y_d = abs(180*cos(0.005*t));
    z_d = 20*(1-exp(-0.07*t));
    
    W_d = -130*(1-exp(-0.06*t));
    theta[5] = rad(65)*(1-exp(-0.1*t));
    
    if( abs(theta[0] - rad(35)) < 0.01 ) {
      step = 1;
      t0 = t;
    }
  }
  
  if(step == 1) {
    z_d = 20 - 0.3*(t-t0);
    
    if( abs(z_d - 1) < 0.1 ) {
      step = 2;
      t0 = t;
    }
  }
  
  if(step == 2) {
    theta[5] = rad(65) - rad(1)*(t-t0);
    
    if( abs(theta[5] - rad(10)) < 0.01) {
      step = 3;
      t0 = t;
    }
  }
  
  if(step == 3) {
    z_d = 0.3*(t-t0);
    
    if( abs(z_d - 20) < 0.3 ) {
      step = 4;
      t0 = t;
    }
  }
  
  if(step == 4) {
    x_d = -abs(180*sin( 0.005*(t-t0) + rad(35) ));
    y_d = abs(180*cos( 0.005*(t-t0) + rad(35) ));
    
    W_d = -130 + 41*(1-exp(-0.1*(t-t0)));
    
    if( abs(theta[0] - rad(90)) < rad(0.5) ) {
      step = 5;
      t0 = t;
    }
  }
  
  if(step == 5) {
    theta[5] = rad(10) + rad(1)*(t-t0);
    
    if( abs(theta[5] - rad(65)) < rad(0.1) ) {
      step = 6;
      t0 = t;
    }
  }
  
  if(step == 6) {
    x_d = -abs(180*sin( 0.005*(t-t0) + rad(89) ));
    y_d = abs(180*cos( 0.005*(t-t0) + rad(89) ));
    z_d = 20 - 20*(1-exp(-0.017*(t-t0)));
    
    W_d = -90 + 90*(1-exp(-0.017*(t-t0)));
    theta[5] = rad(66) - rad(65)*(1-exp(-0.017*(t-t0)));
    
    
    if( abs(theta[0] - rad(1)) < rad(0.5) ) {
      step = 7;
      t0 = t;
    }
  }
   
}

boolean cheakAngles(float[] DenHartAngles) {
  
  boolean res = true;
  
  /* verifichiamo il range degli angoli*/
  if( DenHartAngles[0] < 0 || DenHartAngles[0] > PI) 
  {
    res = false;
  }
  
  if( DenHartAngles[1] < 0 || DenHartAngles[1] > PI)
  {
    res = false;
  } 
  
  if( DenHartAngles[2] < -PI/2 || DenHartAngles[2] > PI/2)
  {
    res = false;
  }
  
  if( DenHartAngles[3] < 0 || DenHartAngles[3] > PI)
  {
    res = false;
  }
  
  if( DenHartAngles[4] < -PI || DenHartAngles[4] > 0)
  {
    res = false;
  }
  
  /* verifichiamo la validità numerica */
  for(int i=0; i<DOF; i++) {
    if( Float.isNaN(DenHartAngles[i]) ) res = false;
  }
  
  
  return res;
}
