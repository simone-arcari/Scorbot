/* //<>//
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

int MOTORS_NUM = 6;                                                                                             // numero motori = numero di coordinate per ogni frames
int MAX_FRAMES = 10 ;                                                                                           // numero massimo di frames(ogni frames ha sei coordinate)
int[][] punti = new int[MAX_FRAMES][MOTORS_NUM];                                                                // matrice di punti / coordinate
int pointCount = 0;                                                                                             // contatore dei punti/frame presenti nella sequenza
int count = 0;                                                                                                  // contatore dei cicli di connessione
int RECT_WIDTH = 600;                                                                                           // lunghezza rettangolo usato per contenere una scritta
int RECT_HEIGHT = 100;                                                                                          // altezza rettangolo usato per contenere una scritta
int offset;                                                                                                     // variabile di appoggio per gestirecoordinate varie
int i,j;                                                                                                        // indici per i vari cicli
int portBoundRate = 9600;                                                                                       // velocità trasmissione portaseriale

long lastTime;                                                                                                  // variabile per contenere le misure di millis()
long MAX_TIME_LOOP = 10000;                                                                                     // tempo massimo per il ciclo di connessione prima di fallire
long FRAMES_RATE = 10;                                                                                          // rate di invio delle coordinate tra un frame e l'altro

///////////////////////////////////////////////
float x, y;
float[] theta = new float[2];
int giunto = 1;
float velocita = .1;
int fineCorsa = 0;
float L1 = 100; // lunghezza primo link
float L2 = 70; // lunghezza secondo link
///////////////////////////////////////////////


/*##################################################################################################################################################################################################################################################################*/


void setup() {
    size(626, 626);                                                                                               // creo la finestra con la taglia in pixel dell'immagine
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
    
    for (i=0; i<MAX_FRAMES; i++) {                                                                                // per ogni frames
        for (j=0; j<MOTORS_NUM; j++) {                                                                                    // per ogni punto(motre) del frame
            punti[i][j] = (int)random(1200, 2100);                                                                                // genero valori casuali
        }
    }
  
    ///////////////////////////////
    theta[0] = 0;
    theta[1] = PI/2;
    x = width/2;
    y = height/2;
    ///////////////////////////////
  
  
  
}


/*##################################################################################################################################################################################################################################################################*/


void draw() {

    if (start_flag == true) {
  
        fill(#DBA028);
        background(0);
    
        if (mousePressed) {       
            connectionFile.flush();
            connectionFile.close();
            positionFile.flush();
            positionFile.close();
            port.stop();  // interronpo la comunicazione con la porta corrente non essendo quella corretta
            exit();
        
        }
    
        if (millis()-lastTime >= FRAMES_RATE) {
            lastTime = millis();
      
            if (ack_flag) {
              
                ack_flag = false;
                port.write(PROCESSING_ID);
                positionFile.println("[message] --> coordinate frame: " + pointCount);
                println("[message] --> coordinate frame: " + pointCount);
        
                for (j=0; j<MOTORS_NUM; j++) {
                  
                    String point_ascii = Integer.toString(punti[pointCount][j]);
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


    ////////////////////////////////////////////////////////////////////////////////////////////////
    if (keyPressed)
    {
      if (key == '1')
      {
        giunto = 1;
      }
      if (key == '2')
      {
        giunto = 2;
      }
      if (keyCode == RIGHT)
      {
        if ((giunto == 2) && (theta[giunto-1] < -PI+.4))
        {
          fineCorsa = 1;
        } else
        {
          fineCorsa = 0;
        }
        theta[giunto-1] -= (1-fineCorsa)*velocita;
      }
      if (keyCode == LEFT)
      {
        if ((giunto == 2) && (theta[giunto-1] > PI-.4))
        {
          fineCorsa = 1;
        } else
        {
          fineCorsa = 0;
        }
        theta[giunto-1] += (1-fineCorsa)*velocita;
      }
      if (keyCode == UP)
      {
        velocita += .001;
        if (velocita > .2)
        {
          velocita = .2;
        }
      }
      if (keyCode == DOWN)
      {
        velocita -= .001;
        if (velocita < 0.005)
        {
          velocita = 0.005;
        }
      }
    }
    robot(x, y, theta[0], theta[1]);
    textSize(15);
    text("velocita = ", width-180, height-20);
    text(velocita, width-100, height-20);
    ////////////////////////////////////////////////////////////////////////////////////////////////
  }
}

/*##################################################################################################################################################################################################################################################################*/

void keyPressed() {  /* premendo ctrl faccio partire il draw() */
    if (key == CODED){
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

void robot(float x, float y, float theta1, float theta2)
{
  // Qui le coordinate si riferiscono allo schermo: (0,0) = in alto a sinistra
  // coordinate grafiche primo giunto
  float x1 = x+L1*cos(theta1);
  float y1 = y-L1*sin(theta1);  // Il meno per la convenzione grafica della y positiva verso il basso
  // coordinate grafiche secondo giunto
  float x2 = x1+L2*cos(theta1+theta2);
  float y2 = y1-L2*sin(theta1+theta2);

  noStroke();
  fill(#DBA028);
  // disegno base
  rect(x-15, y-15, 30, 30);
  fill(255, 0, 0);

  // disegno giunti (rossi)
  ellipse(x, y, 15, 15);
  //  fill(255,0,0);
  ellipse(x1, y1, 15, 15);

  // Disegno i due link
  stroke(#DBA028);
  strokeWeight(8);
  line(x, y, x1, y1);
  line(x1, y1, x2, y2);

  // Disegno la pinza
  float xPuntoP1 = x2-7*sin(theta1+theta2);
  float yPuntoP1 = y2-7*cos(theta1+theta2);
  float xPuntoP2 = x2+7*sin(theta1+theta2);
  float yPuntoP2 = y2+7*cos(theta1+theta2);
  float xPuntoP11 = xPuntoP1+8*cos(theta1+theta2);
  float yPuntoP11 = yPuntoP1-8*sin(theta1+theta2);
  float xPuntoP22 = xPuntoP2+8*cos(theta1+theta2);
  float yPuntoP22 = yPuntoP2-8*sin(theta1+theta2);
  line(xPuntoP1, yPuntoP1, xPuntoP2, yPuntoP2);
  line(xPuntoP1, yPuntoP1, xPuntoP11, yPuntoP11);
  line(xPuntoP2, yPuntoP2, xPuntoP22, yPuntoP22);
}
