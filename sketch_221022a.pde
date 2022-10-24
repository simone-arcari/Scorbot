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


// Parametri camera
float eyeY = 0;
float eyeX = 0;

// Angoli d'interesse
float alpha = 0;
float[] thetaFictitious = new float[6];
float[] theta = new float[6];

boolean direction = true;

void setup(){
    size(626,626,P3D);
    stroke(255);
    strokeWeight(2);
    smooth();
   
    xBase = width/2;
    yBase = 5*(height/6);
    zBase = -180;
    
    thetaFictitious[0] = PI/2;
    thetaFictitious[1] = 0;
    thetaFictitious[2] = PI/2;
    thetaFictitious[3] = PI/2;
    thetaFictitious[5] = 0;
    
    
    theta[0] = 0;
    theta[1] = -60*PI/180;;
    theta[2] = 40*PI/180;
    theta[3] = 20*PI/180;
    theta[4] = 0;
    theta[5] = 0;
}

void draw(){
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
        
        // Rotazionesu intorno asse verticale
        if(keyCode == RIGHT) {
            alpha += PI/180;
        }
        if (keyCode == LEFT) {
            alpha -= PI/180;
        }
        
        // Movimento lungo asse z
        if (keyCode == UP) {
            zBase+=15;
        }
        if (keyCode == DOWN) {
            zBase-=5;
        }
        
        // Verso rotazione motori
        if (key == 'q') {
            direction = !direction;
            delay(500);
        }
        
        // Rotazione motore1
        if (key == '1') {
            if (direction == true && theta[0] < PI/2) {
                theta[0]+= PI/180;
            }
            if (direction == false && theta[0] > -PI/2) {
                theta[0]-= PI/180;
            }
        }
        
        // Rotazione motore2
        if (key == '2') {
            if (direction == true && theta[1] < 0) {
                theta[1]+= PI/180;
            }
            if (direction == false && theta[1] > -PI) {
                theta[1]-= PI/180;
            }
        }
        
        // Rotazione motore3
        if (key == '3') {
            if (direction == true && theta[2] < PI/2) {
                theta[2]+= PI/180;
            }
            if (direction == false && theta[2] > -PI/2) {
                theta[2]-= PI/180;
            }
        }
        
        // Rotazione motore4
        if (key == '4') {
            if (direction == true && theta[3] < PI/2) {
                theta[3]+= PI/180;
            }
            if (direction == false && theta[3] > -PI/2) {
                theta[3]-= PI/180;
            }
        }
        
        // Rotazione motore5
        if (key == '5') {
            if (direction == true && theta[4] < 0) {
                theta[4]+= PI/180;
            }
            if (direction == false && theta[4] > -PI) {
                theta[4]-= PI/180;
            }
        }
        
        if (key == '6') {
            if (direction == true && theta[5] < 0) {
                theta[5]+= PI/180;
            }
            if (direction == false && theta[5] > -PI) {
                theta[5]-= PI/180;
            }
        }
    }
    
    if(mousePressed){
        xBase = mouseX;
        yBase = mouseY;
    }
    
    // Parametri stampati su schermo
    textSize(25);
    fill(#00FF00); // Colore parametri camera 
    text("coordinata y vista:",10,25); 
    text(eyeY,250,25);
    text("coordinata x vista:",10,50); 
    text(eyeX,250,50);
    fill(#FF9100); // Colore parametri theta
    text("theta[0]:",10,75);
    text(int(180*(theta[0]+thetaFictitious[0])/PI) + "°",250,75);
    text("theta[1]:",10,100);
    text(int(180*(theta[1])/PI) + "°",250,100);
    text("theta[2]:",10,125);
    text(int(180*(theta[2]+thetaFictitious[2])/PI) + "°",250,125);
    text("theta[3]:",10,150);
    text(int(180*(theta[3]+thetaFictitious[3])/PI) + "°",250,150);
    text("theta[4]:",10,175);
    text(int(180*(theta[4]+thetaFictitious[4])/PI) + "°",250,175);
  
    // Pavimento
    fill(#E5E06D);  // Colore del pavimento
    translate(xBase,yBase,zBase);
    rotateY(alpha);
    box(xFloor,yFloor,zFloor);
    
    // Base
    fill(#C4C0C0);  // Colore del robot
    translate(-xFloor/2+xBlock1/2+xOffsetBase,-(yFloor/2+yBlock1/2),-zFloor/2+zBlock1/2+zOffsetBase);
    box(xBlock1,yBlock1,zBlock1);  
    translate(-xBlock1/2+xBlock2/2,-(yBlock1/2+yBlock2/2),0);
    box(xBlock2,yBlock2,zBlock2);
    
    // Motore1
    fill(#000000);  // Colore motore
    translate(xBlock2/2+motorDepth/2,-yOffsetM1,0);
    box(motorDepth,motorHeight,motorWidth);
    fill(#A09908);  // Colore ingranaggio
    translate(0,-(motorHeight/2+gearHeight/2),gearOffset);
    rotateY(theta[0]);  // Asse rotazione motore1
    box(gearDepth,gearHeight,gearWidth);
    rotateY(120*PI/180);  // Per disegnare ingranaggio
    box(gearDepth,gearHeight,gearWidth);
    rotateY(120*PI/180);  // Per disegnare ingranaggio
    box(gearDepth,gearHeight,gearWidth);
    rotateY(120*PI/180);  // Torno all'angolo iniziale
      
    // Gabbia motore1
    fill(#C4C0C0);  // Colore del robot
    translate(xBlock3/2-motorDepth/2,motorHeight+yBlock3/2+gearHeight/2,0);
    box(xBlock3,yBlock3,zBlock3);    
    translate(xBlock3/2-xBlock4/2,-yBlock4/2+yBlock3/2,0);
    box(xBlock4,yBlock4,zBlock4);    
    translate(-xBlock5/2+xBlock4/2,-yBlock4/2+yBlock5/2,0);
    box(xBlock5,yBlock5,zBlock5);
    
    // Motore2
    fill(#000000);  // Colore motore
    translate(-xOffsetM2,-(motorDepth/2+yBlock5/2),-gearHeight/2);
    box(motorWidth,motorDepth,motorHeight);
    fill(#A09908);  // Colore ingranaggio
    translate(-gearOffset,0,motorHeight/2+gearHeight/2);
    rotateZ(theta[1]);  // Asse rotazione motore2
    box(gearWidth,gearDepth,gearHeight);
    rotateZ(120*PI/180);  // Per disegnare ingranaggio
    box(gearWidth,gearDepth,gearHeight);
    rotateZ(120*PI/180);  // Per disegnare ingranaggio
    box(gearWidth,gearDepth,gearHeight);
    rotateZ(120*PI/180);  // Torno all'angolo iniziale
    
    // Gabbia motore2
    fill(#C4C0C0);  // colore del robot
    translate(xBlock6/2-motorDepth/2,0,gearHeight/2-zBlock6/2);
    box(xBlock6,yBlock6,zBlock6);    
    translate(xBlock6/2-xBlock7/2,0,-zBlock7/2+zBlock6/2);
    box(xBlock7,yBlock7,zBlock7);    
    translate(-xBlock6/2+xBlock7/2,0,-zBlock7/2+zBlock6/2);
    box(xBlock6,yBlock6,zBlock6);
    
    // Gabbia motore3
    translate(xBlock6,0,0);
    box(xBlock6,yBlock6,zBlock6);
    translate(-xBlock6/2+xBlock7/2,0,zBlock7/2-zBlock6/2);
    box(xBlock7,yBlock7,zBlock7);
    pushMatrix(); // Memorizzo il sistema attuale
    translate(xBlock6/2+xBlock7/2,0,zBlock7/2-zBlock6/2);
    box(xBlock6,yBlock6,zBlock6);
    popMatrix();  // Ritorno al sistema di riferimento memorizzato
    
    // Motore3
    fill(#A09908);  // Colore ingranaggio
    translate(xBlock6-motorDepth/2,0,zBlock7/2-gearHeight/2);
    box(gearWidth,gearDepth,gearHeight);
    rotateZ(120*PI/180);  // Per disegnare ingranaggio
    box(gearWidth,gearDepth,gearHeight);
    rotateZ(120*PI/180);  // Per disegnare ingranaggio
    box(gearWidth,gearDepth,gearHeight);
    rotateZ(120*PI/180);  // Torno all'angolo iniziale
    rotateZ(theta[2]);  // Asse rotazione motore3
    fill(#000000);  // Colore motore
    translate(gearOffset,0,-motorHeight/2-gearHeight/2);
    box(motorWidth,motorDepth,motorHeight);
    
    // Connessione motore3 con gabbia motore4
    fill(#C4C0C0);  // Colore del robot
    translate((xBlock8-motorWidth)/2,motorDepth/2+yBlock8/2, (gearHeight-zBlock6)/2);
    box(xBlock8,yBlock8,zBlock8);
    translate(xBlock8/2-xBlock9/2,-yBlock9/2+yBlock8/2,0);
    box(xBlock9,yBlock9,zBlock9);
    
    // Gabbia motore4
    translate(xBlock9,-yBlock8/2,0);
    box(xBlock7,yBlock7,zBlock7);
    pushMatrix();  // Memorizzo il sistema attuale
    translate(xBlock6/2-xBlock7/2,0,-zBlock7/2+zBlock6/2);
    box(xBlock6,yBlock6,zBlock6);
    translate(0,0,zBlock7-zBlock6);
    box(xBlock6,yBlock6,zBlock6);
    popMatrix();  // Ritorno al sistema di riferimento memorizzato
    
    // Motore4
    fill(#A09908);  // Colore ingranaggio
    translate(xBlock6-motorDepth/2,0,zBlock7/2-gearHeight/2);
    box(gearWidth,gearDepth,gearHeight);
    rotateZ(120*PI/180);  // Per disegnare ingranaggio
    box(gearWidth,gearDepth,gearHeight);
    rotateZ(120*PI/180);  // Per disegnare ingranaggio
    box(gearWidth,gearDepth,gearHeight);
    rotateZ(120*PI/180);  // Torno all'angolo iniziale
    rotateZ(theta[3]);  // Asse rotazione motore4
    fill(#000000);  // Colore motore
    translate(gearOffset,0,-motorHeight/2-gearHeight/2);
    box(motorWidth,motorDepth,motorHeight);
    
    // Connessione motore4 con gabbia motore5
    fill(#C4C0C0);  // Colore del robot
    translate((xBlock10-motorWidth)/2,-(motorDepth/2+yBlock10/2),0);
    box(xBlock10,yBlock10,zBlock10);
    translate(xOffsetM5-xBlock10/2,-yBlock11/2+yBlock10/2,0);
    box(xBlock11,yBlock11,zBlock11);
    
    // Motore5
    fill(#000000);  // Colore motore
    translate(motorHeight/2+xBlock11/2,-(yBlock11-motorDepth)/2,0);
    box(motorHeight,motorDepth,motorWidth);
    fill(#A09908);  // Colore ingranaggio
    translate(motorHeight/2+gearHeight/2,0,gearOffset);
    rotateX(theta[4]);  // Asse rotazione motore5
    box(gearHeight,gearDepth,gearWidth);
    rotateX(120*PI/180);  // Per disegnare ingranaggio
    box(gearHeight,gearDepth,gearWidth);
    rotateX(120*PI/180);  // Per disegnare ingranaggio
    box(gearHeight,gearDepth,gearWidth);
    rotateX(120*PI/180);  // Torno all'angolo iniziale
    
    // Connessione motore5 con la pinza
    fill(#C4C0C0);  // Colore del robot
    translate(gearHeight/2-xBlock12/2,0,0);
    box(xBlock12,yBlock12,zBlock12);
    translate(xBlock13/2+xBlock12/2,0,0);
    box(xBlock13,yBlock13,zBlock13);
    translate(0,0,-(zBlock13/2+zOffsetM6));
    box(xBlock14,yBlock14,zBlock14);
    pushMatrix();  // Memorizzo il sistema attuale
    translate(0,-yBlock15/2+yBlock14/2,zBlock14/2+zBlock15/2);
    box(xBlock15,yBlock15,zBlock15);
    translate(0,0,-zBlock14-zBlock15);
    box(xBlock15,yBlock15,zBlock15);
    popMatrix();  // Ritorno al sistema di riferimento memorizzato
    
    // Motore6
    fill(#000000);  // Colore motore
    translate(0,-(motorHeight/2+yBlock14/2)-yOffsetM6,0);
    box(motorDepth,motorHeight,motorWidth);    
    pushMatrix();  // Memorizzo il sistema attuale
    fill(#A09908);  // Colore ingranaggio
    translate(0,motorHeight/2+gearHeight/2,gearOffset);
    rotateY(theta[5]);  // rotazione ingranaggio pinza
    box(gearDepth,gearHeight,gearWidth);
    rotateY(120*PI/180);  // Per disegnare ingranaggio
    box(gearDepth,gearHeight,gearWidth);
    rotateY(120*PI/180);  // Per disegnare ingranaggio
    box(gearDepth,gearHeight,gearWidth);
    rotateY(120*PI/180);  // Torno all'angolo iniziale
    popMatrix();  // Ritorno al sistema di riferimento memorizzato
    /*ricorda il popMatrix qui sopra, serve per disegnare la pinza*/
}
