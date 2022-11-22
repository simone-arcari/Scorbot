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

boolean portFound = false;                                                                                      // flag per indicare se la porta è stata trovata
boolean loop_flag = true;                                                                                       // flag per il controllo dei cicli while
boolean ack_flag = true;                                                                                        // flag per indicare l'avvenuta ricezione dei dati

String id;                                                                                                      // stringa per salvare l'id letto sulla porta seriale
String portName;                                                                                                // nome della porta corrente
String buffer;                                                                                                  // buffer d'appoggio per letture e scritture varie
String ARDUINO_ID = "ARO22ARL";                                                                                 // codice identificazione della scheda arduino
String PROCESSING_ID = "PRO04IDE";                                                                              // codice identificazione di questo programma
String[] portNames = {"COM0", "COM1", "COM2", "COM3", "COM4", "COM5", "COM6", "COM7", "/dev/ttyACM0"};                          // vettore delle possibili porte seriali
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
            printInfo("[message] --> fine comunicazione con porta: " + portName);                                                             // stampo su terminale processing e su file dati di connessione
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
    exit();     // termino il programma
  } else {                                                                                                      // se invece la porta viene trovata
    port.write(PROCESSING_ID);                                                                                        // comunico codice di identificazione(di questo programma) alla scheda arduino
  }
}


boolean checkPortName(String name) {
  for (i=0; i<portNames.length; i++) {
    if (name.equals(portNames[i]))
      return true;
  }
  return false;
}


void serialSendPositions(float[] angle) {
  if (ack_flag == true) {
    
    ack_flag = false;
    port.write(PROCESSING_ID);
    
    for (j=0; j<MOTORS_NUM; j++) {
      point_ascii = Integer.toString((int)deg(angle[j]));

      if (point_ascii.length() == 2)
        point_ascii = "0" + point_ascii;

      if (point_ascii.length() == 1)
        point_ascii = "00" + point_ascii;

      port.write(point_ascii);
      positionFile.println("punto: " + (int)deg(angle[j]));
      println("punto: " + (int)deg(angle[j]) + ", in ascii: " + point_ascii);
    }
  }
}


void serialSendFrame() {
  if (ack_flag == true) {

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


void serialCheckACK() {
  if (port.available() >= ARDUINO_ID.length()) {
    id = port.readString();
    println("[message] --> " + id);

    if (id.equals(ARDUINO_ID))
      ack_flag = true;
  }
}
