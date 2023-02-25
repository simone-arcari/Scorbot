/*
 [NOTA][LINUX]in caso di errore:
 
 RuntimeException: Error opening serial port /dev/ttyACM0: Permission denied
 
 risolvere con i seguenti comandi su terminale linux:
 sudo groupadd dialout
 sudo gpasswd -a "user" dialout
 sudo usermod -a -G dialout "user"
 sudo chmod a+rw /dev/ttyACM0  (se la porta non è ttyACM0 sostituire con il nome corretto)
 
 */
import processing.serial.*;

Serial port;                                                                                                    // reference per la porta seriale

boolean portFound = false;                                                                                      // flag per indicare se la porta è stata trovata
boolean loop_flag = true;                                                                                       // flag per il controllo dei cicli while
boolean ack_flag = true;                                                                                        // flag per indicare l'avvenuta ricezione dei dati

String id;                                                                                                      // stringa per salvare l'id letto sulla porta seriale
String portName;                                                                                                // nome della porta corrente
String buffer;                                                                                                  // buffer d'appoggio per letture e scritture varie
String ARDUINO_ID = "ARO22ARL";                                                                                 // codice identificazione della scheda arduino
String PROCESSING_ID = "PRO04IDE";                                                                              // codice identificazione di questo programma
String[] portNames = {"COM0", "COM1", "COM2", "COM3", "COM4", "COM5", "COM6", "COM7", "/dev/ttyACM0"};          // vettore delle possibili porte seriali
String point_ascii;                                                                                             // valore di point in formato ascii

int count = 0;                                                                                                  // contatore dei cicli di connessione
int portBoundRate = 9600;                                                                                       // velocità trasmissione portaseriale


void serialTryConnect() {
  printArray(Serial.list());                                                                                    // stampo la lista di tutte le porte presenti

  for (i=0; i<Serial.list().length; i++) {                                                                      // itero per ogni porta seriale per trovare quella corretta
    portName = Serial.list()[i];                                                                                      // prelevo il nome della porta corrente di indice i

    if (checkPortName(portName)) {                                                                                    // verifico che il nome della porta corrente sia uno dei possibili nomi
      port = new Serial(this, portName, portBoundRate);                                                                     // mi connetto alla porta corrente
      printInfo("[message] --> port name = " + portName);                                                                   // stampo su terminale processing e su file dati di connessione
      printInfo("[message] --> port reference = " + port);                                                                  // stampo su terminale processing e su file dati di connessione
      lastTime = millis();                                                                                                  // salvo il valore del tempo corrente in millisecondi

      while (loop_flag && (millis()-lastTime) < MAX_TIME_LOOP) {                                                            // ciclo finché la porta seriale non diventa disponibile o finché non scade il tempo disponibile
        println("tentativo di connessione numero #" + count);                                                                                               // messaggio da stampare solo su console
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
            printInfo("[message] --> fine comunicazione con porta: " + portName);                                                             // stampo su terminale processing e su file dati di connessione
            port.stop();                                                                                                                      // interrompo la comunicazione con la porta corrente non essendo quella corretta
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
    exit();     // termino il programma
  } else {                                                                                                      // se invece la porta viene trovata
    port.write(PROCESSING_ID);                                                                                        // comunico codice di identificazione(di questo programma) alla scheda arduino
  }
}


/* Per scopo didattico è stata implmentata la funzionalità che solo le porte i cui nomi
 * sono presenti nel vettore portNames[] vanno considerate come porte valide per la 
 * comunicazione con la scheda arduino.
 * Se si vuole aggiungere altre porte basta aggingerle nell definizione del vettore 
 * alla riga 26 di questo file
 */
boolean checkPortName(String name) { 
  for (i=0; i<portNames.length; i++) {
    if (name.equals(portNames[i]))
      return true;
  }
  return false;
}

/*
 * Invia gli angoli da far attuare ai servomotori:
 * prima comunica il codice identificativo di questo programma (PROCESSING_ID)
 * successivamente comunica i 6 angoli nella loro rappresentazione a caratteri
 * Se un numero ha mene di tre cifre intere (come 7°) viene inviata sempre
 * una stringa da tre caratteri (come "007") per motivi di compatibilità 
 * è semplicità di ricezione dei dati.
 */
void serialSendPositions(float[] angle) {
  if (ack_flag == true) 
  {    
    ack_flag = false;
    port.write(PROCESSING_ID);
    
    for (j=0; j<MOTORS_NUM; j++) 
    {
      point_ascii = Integer.toString((int)deg(angle[j]));

      if (point_ascii.length() == 2)
      {
        point_ascii = "0" + point_ascii;
      }

      if (point_ascii.length() == 1)
      {
        point_ascii = "00" + point_ascii;
      }

      port.write(point_ascii);
      positionFile.println("angle[" + j + "]: " + (int)deg(angle[j]));
      println("angle[" + j + "]: " + (int)deg(angle[j]) + ", in ascii: " + point_ascii);
    }
  }
}


/*
 * Invia gli angoli da far attuare ai servomotori memorizzati nella matrice frames[][]
 * prima comunica il codice identificativo di questo programma (PROCESSING_ID)
 * successivamente comunica i 6 angoli nella loro rappresentazione a caratteri
 * Se un numero ha mene di tre cifre intere (come 7°) viene inviata sempre
 * una stringa da tre caratteri (come "007") per motivi di compatibilità 
 * è semplicità di ricezione dei dati.
 * La matrice frames[FRAMES_NUM][MOTORS_NUM] per ogni indice di FRAMES_NUM 
 * contine 6 angoli da attuare, l'indice usato per FRAMES_NUM è framesCount e viene
 * incrementato ad ogni chiamata di questa funzione.
 */
void serialSendFrame() {
  if (ack_flag == true) 
  {
    ack_flag = false;
    port.write(PROCESSING_ID);
    positionFile.println("[message] --> coordinate frame: " + framesCount);
    println("[message] --> coordinate frame: " + framesCount);

    for (j=0; j<MOTORS_NUM; j++) 
    {
      realServoTheta[j] = rad(frames[framesCount][j]);
      point_ascii = Integer.toString(int(frames[framesCount][j]));

      if (point_ascii.length() == 2)
      {
        point_ascii = "0" + point_ascii;
      }

      if (point_ascii.length() == 1)
      {
        point_ascii = "00" + point_ascii;
      }

      port.write(point_ascii);
      positionFile.println("angle[" + j + "]: " + frames[framesCount][j]);
      println("angle[" + j + "]: " + frames[framesCount][j] + ", in ascii: " + point_ascii);
    }

    framesCount++;
    if (framesCount >= FRAMES_NUM) framesCount = 0;
  }
}


/* Verifica che la scheda arduino abbia inviato il suo codice identificativo (ARDUINO_ID)*/
void serialCheckACK() {
  if (port.available() >= ARDUINO_ID.length()) 
  {
    id = port.readString();
    println("[message] --> " + id);

    if (id.equals(ARDUINO_ID))
    {
      ack_flag = true;
    }
  }
}
